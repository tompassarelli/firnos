#lang racket/base

(require racket/string
         racket/list
         racket/path
         racket/system
         racket/file
         racket/port
         "util.rkt")

(provide node-edges)

(define (handle-host-rebuild leaf)
  ;; leaf may be "current" or "<host>" or "<host>+skip" (legacy alias sentinel)
  (define-values (host-token skip-checks?)
    (cond
      [(regexp-match #rx"^([^+]+)\\+skip$" leaf)
       => (λ (m) (values (cadr m) #t))]
      [else (values leaf #f)]))
  (define host (cond [(equal? host-token "current") (current-hostname)]
                     [else host-token]))

  ;; cd to ROOT so subshells (firn-build, firn-validate, nh) see the repo
  ;; even when the user invoked `firn rebuild` from another directory.
  (parameterize ([current-directory ROOT])
    (handle-host-rebuild* host skip-checks?)))

;; Modules whose own flake.nix references an absolute path outside the
;; flake source tree (e.g. gjoa's gitignored 5GB engine/ dir) and so
;; can't evaluate under pure-eval. If the host enables one of these,
;; fi rebuild auto-adds --impure so the rebuild doesn't die with the
;; cryptic "access to absolute path '/home' is forbidden" trace.
;;
;; NOTE: enabling a module in this list means a *full system-package
;; rebuild* of that project — gjoa is ~45 min cold. Daily development of
;; gjoa happens OUTSIDE fi rebuild, in the gjoa dev shell via
;; `mach build faster` (~30s). Only flip gjoa.enable to #t when you
;; actually want a release-quality binary installed system-wide.
(define IMPURE-MODULES '("gjoa"))

(define (host-impure-modules host)
  (define host-nix (in-repo "hosts" host "configuration.nix"))
  (cond
    [(not (file-exists? host-nix)) '()]
    [else
     (define text (file->string host-nix))
     (for/list ([m (in-list IMPURE-MODULES)]
                #:when
                (regexp-match?
                 (regexp
                  (format "(myConfig\\.modules\\.~a\\.enable|[ \t\n;{]~a\\.enable)[ \t]*=[ \t]*true"
                          m m))
                 text))
       m)]))

(define (host-needs-impure? host)
  (pair? (host-impure-modules host)))

(define (handle-host-rebuild* host skip-checks?)
  ;; Line-buffer so step headers print before each child process writes
  ;; to fd1. Otherwise (block-buffered pipes) headers appear after their
  ;; child output, making the sequence hard to read.
  (with-handlers ([exn:fail? (λ (_) (void))])
    (file-stream-buffer-mode (current-output-port) 'line))
  ;; Auto-impure when the host enables a module whose flake intrinsically
  ;; reads paths outside its source tree (currently: gjoa). For these
  ;; modules a `fi rebuild` is a full system-package rebuild — for gjoa,
  ;; ~45 minutes — and is intended only for release-time installs.
  (define auto-impure?
    (and host (host-needs-impure? host)))
  (when auto-impure?
    (printf "fi rebuild: passing --impure (host enables: ~a)\n"
            (string-join (host-impure-modules host) ", "))
    (printf "             this triggers a full ~~45 min Firefox compile.\n")
    (printf "             for daily gjoa dev use the gjoa dev shell + mach build faster.\n"))
  (unless skip-checks?
    ;; Step 1: regenerate any out-of-date .nix from .rkt sources.
    (printf ">> firn-build\n")
    (unless (sh (path->string (in-repo "scripts" "firn-build")))
      (eprintf "fi rebuild: firn-build failed; aborting.\n") (exit 1))
    ;; Step 1b: warn about untracked .rkt/.nix — Nix can't see them.
    (define untracked
      (let ([s (sh-out "git" "-C" ROOT "ls-files" "--others" "--exclude-standard")])
        (filter (λ (p) (regexp-match? #rx"\\.(rkt|nix)$" p))
                (string-split s "\n"))))
    (unless (null? untracked)
      (eprintf "fi rebuild: untracked files invisible to Nix — git add them first:\n")
      (for ([p (in-list untracked)]) (eprintf "  ~a\n" p))
      (exit 1))
    ;; Step 2: validate paths and value types against the schema.
    (printf ">> firn-validate\n")
    (unless (sh (path->string (in-repo "scripts" "firn-validate")))
      (eprintf "fi rebuild: validation failed; aborting.\n") (exit 1))
    ;; Step 2b: flake input purity. firn-validate is schema-only and can't
    ;; see flake-level concerns, so check here before nix gets its hands
    ;; on the tree — otherwise the build fails several minutes later with
    ;; "access to absolute path '/...' is forbidden in pure evaluation mode".
    ;; Skip when auto-impure will be in play for a module whose own
    ;; flake demands it.
    (cond
      [auto-impure?
       (printf ">> flake-input-purity (skipped — --impure mode)\n")]
      [else
       (printf ">> flake-input-purity\n")
       (define purity-issues (flake-input-purity-violations))
       (unless (null? purity-issues)
         (eprintf "fi rebuild: flake has absolute path: inputs that break pure eval:\n")
         (for ([line (in-list purity-issues)]) (eprintf "  ~a\n" line))
         (eprintf "fix: publish to a git remote (github:owner/repo), or override locally with --override-input.\n")
         (exit 1))]))

  ;; Step 2c: impact prediction (informational only — never blocks rebuild).
  ;; Runs nix build --dry-run to summarize what will be built vs fetched.
  (with-handlers ([exn:fail? (λ (_) (void))])
    (define host-name (or host (current-hostname)))
    (define flake-ref (string-append ROOT "#nixosConfigurations." host-name
                                     ".config.system.build.toplevel"))
    (define nix-bin (find-executable-path "nix"))
    (when nix-bin
      (define dry-args
        (append (list nix-bin "build" flake-ref "--dry-run")
                (if auto-impure? (list "--impure") '())))
      (define out-port (open-output-string))
      (define err-port (open-output-string))
      (parameterize ([current-output-port out-port]
                     [current-error-port err-port])
        (apply system* dry-args))
      (define dry-text (string-append (get-output-string out-port)
                                      (get-output-string err-port)))
      ;; Parse build/fetch counts
      (define build-match (regexp-match #rx"these ([0-9]+) derivations will be built" dry-text))
      (define fetch-match (regexp-match #rx"these paths will be fetched \\(([0-9.]+) MiB" dry-text))
      (define build-count (if build-match (string->number (cadr build-match)) 0))
      (define fetch-size (if fetch-match (cadr fetch-match) #f))
      ;; Extract names of derivations to build (for notable detection)
      (define build-lines
        (let ([m (regexp-match #rx"will be built:\n([^\n]*(?:\n  /nix/store[^\n]*)*)" dry-text)])
          (if m
              (filter non-empty-string?
                      (map string-trim (string-split (cadr m) "\n")))
              '())))
      ;; Known-expensive patterns
      (define expensive
        '(("firefox" . "~30 min") ("librewolf" . "~30 min")
          ("chromium" . "~60 min") ("linux-6" . "~15 min")
          ("ghc-" . "~30 min") ("llvm-" . "~20 min")
          ("rustc-" . "~20 min") ("nodejs-" . "~5 min")
          ("qt6-" . "~15 min") ("webkit" . "~30 min")))
      (define notable
        (for*/list ([line (in-list build-lines)]
                    [pair (in-list expensive)]
                    #:when (regexp-match? (regexp (car pair)) line))
          (format "~a ~a" (car pair) (cdr pair))))
      ;; Print concise summary
      (when (or (> build-count 0) fetch-size)
        (define parts
          (append
           (if (> build-count 0)
               (list (format "~a to build" build-count))
               '())
           (if fetch-size
               (list (format "~a MiB cached" fetch-size))
               '())))
        (define notable-str
          (if (pair? notable)
              (format " — notable: ~a" (string-join (remove-duplicates notable) ", "))
              ""))
        (printf ">> rebuild (~a~a)\n" (string-join parts ", ") notable-str))))

  ;; Step 3: actual rebuild. Dispatch by platform.
  (printf ">> rebuild\n")
  (define on-darwin?
    (equal? "Darwin" (string-trim (sh-out "uname" "-s"))))
  (define extra (if auto-impure? (list "--impure") '()))
  (define rc
    (cond
      [on-darwin?
       (define flake-target (if host (string-append ROOT "#" host) ROOT))
       (apply sh (append (list "sudo" "darwin-rebuild" "switch" "--flake" flake-target)
                         extra))]
      [(find-executable-path "nh")
       ;; nh forwards everything after `--` to `nix build`, which is where
       ;; --impure lives.
       (define nh-tail (if (null? extra) '() (cons "--" extra)))
       (apply system* (find-executable-path "nh")
              (append (list "os" "switch" ROOT)
                      (if host (list "-H" host) '())
                      nh-tail))]
      [else
       (define flake-target (if host (string-append ROOT "#" host) ROOT))
       (apply sh (append (list "sudo" "nixos-rebuild" "switch" "--flake" flake-target)
                         extra))]))
  (cond
    [(not rc)
     (printf "\n========================================\n")
     (printf "  Build failed\n")
     (printf "========================================\n\n")
     ;; Attempt Claude diagnosis if claude CLI is available
     (define claude-bin (find-executable-path "claude"))
     (when claude-bin
       (printf ">> diagnosing with claude...\n")
       ;; Re-run nix build (eval-only) to capture the error message
       (define host-name (or host (current-hostname)))
       (define flake-ref (string-append ROOT "#nixosConfigurations." host-name
                                        ".config.system.build.toplevel"))
       (define nix-bin (find-executable-path "nix"))
       (when nix-bin
         (define err-port (open-output-string))
         (parameterize ([current-output-port (open-output-nowhere)]
                        [current-error-port err-port])
           (system* nix-bin "build" "--no-link" flake-ref))
         (define err-text (get-output-string err-port))
         (when (non-empty-string? err-text)
           ;; Take last 100 lines to keep the prompt manageable
           (define err-lines (string-split err-text "\n"))
           (define tail-lines (take-right err-lines (min 100 (length err-lines))))
           (define tail-text (string-join tail-lines "\n"))
           (define diag-port (open-output-string))
           (parameterize ([current-output-port diag-port])
             (system* claude-bin "-p"
                      (string-append
                       "A NixOS rebuild failed. Diagnose the root cause from this output. "
                       "Be concise — state the fix in 1-3 sentences.\n\n"
                       tail-text)))
           (define diagnosis (get-output-string diag-port))
           (when (non-empty-string? diagnosis)
             (printf "\n~a\n" diagnosis)))))
     (exit 1)]
    [on-darwin?
     ;; nix-darwin's generation listing is different; skip the gen tag for now.
     (printf "rebuild complete.\n")]
    [else
     (define gens (sh-out "nixos-rebuild" "list-generations"))
     (define cur-line
       (for/or ([line (in-list (string-split gens "\n"))]
                #:when (regexp-match? #rx"current" line))
         line))
     (when cur-line
       (define gen (car (string-split (string-trim cur-line))))
       (when (regexp-match? #rx"^[0-9]+$" gen)
         (sh "git" "-C" ROOT "tag" "-f" (string-append "gen-" gen) "HEAD")
         (printf "Tagged: gen-~a\n" gen)))]))

(define node-edges
  (list
   (walk-edge "host" "rebuild" "<host>" 'current-host
              handle-host-rebuild
              "firn-build → validate → nixos-rebuild → tag generation")))
