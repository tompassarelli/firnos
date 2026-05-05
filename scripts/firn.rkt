#!/usr/bin/env racket
#lang racket/base

;; firn — FirnOS config management CLI.
;;
;; Single Racket program: same Racket as the nisp #lang itself, the validator,
;; and the build pipeline. Compile to a standalone binary with `raco exe`.

(require racket/cmdline
         racket/string
         racket/list
         racket/system
         racket/file
         racket/path
         racket/format
         racket/runtime-path)

;; ---------- repo discovery ----------

(define (find-repo-root)
  (define home (or (getenv "HOME") "/home/tom"))
  (define default (build-path home "code" "nixos-config"))
  ;; Try `git rev-parse --show-toplevel` from the cwd; fall back to default.
  (with-handlers ([exn:fail? (λ (_) (path->string default))])
    (define o (open-output-string))
    (parameterize ([current-output-port o])
      (system "git rev-parse --show-toplevel 2>/dev/null"))
    (define s (string-trim (get-output-string o)))
    (cond
      [(and (non-empty-string? s) (directory-exists? s)) s]
      [else (path->string default)])))

(define ROOT (find-repo-root))

(define (in-repo . segments)
  (apply build-path ROOT segments))

;; ---------- shell helpers ----------

(define (sh . args)
  (apply system* (find-exe (car args)) (cdr args)))

(define (sh-out . args)
  (define o (open-output-string))
  (parameterize ([current-output-port o])
    (apply system* (find-exe (car args)) (cdr args)))
  (string-trim (get-output-string o)))

(define (find-exe cmd)
  ;; resolve PATH lookup so `sudo` etc. work
  (define o (open-output-string))
  (parameterize ([current-output-port o])
    (system* "/usr/bin/env" "which" cmd))
  (define s (string-trim (get-output-string o)))
  (if (non-empty-string? s) s cmd))

;; ---------- listing helpers ----------

(define (list-dirs subdir)
  (define dir (in-repo subdir))
  (cond
    [(directory-exists? dir)
     (sort
      (for/list ([p (directory-list dir)]
                 #:when (directory-exists? (build-path dir p)))
        (path->string p))
      string<?)]
    [else '()]))

(define (modules)  (list-dirs "modules"))
(define (bundles)  (list-dirs "bundles"))
(define (hosts)
  (define hd (in-repo "hosts"))
  (cond
    [(directory-exists? hd)
     (sort
      (for/list ([p (directory-list hd)]
                 #:when (directory-exists? (build-path hd p)))
        (path->string p))
      string<?)]
    [else '()]))

(define (current-hostname)
  (with-handlers ([exn:fail? (λ (_) "whiterabbit")])
    (define s (sh-out "hostname"))
    (if (non-empty-string? s) s "whiterabbit")))

(define (host-config-rkt host)
  (in-repo "hosts" host "configuration.rkt"))

;; Find files (recursive) under a directory matching a regex. Returns paths
;; relative to ROOT.
(define (grep-files dir re)
  (define abs-dir (in-repo dir))
  (cond
    [(directory-exists? abs-dir)
     (for/list ([p (in-directory abs-dir)]
                #:when (and (file-exists? p)
                            (regexp-match? #rx"\\.(rkt|nix)$" (path->string p))
                            (with-handlers ([exn:fail? (λ (_) #f)])
                              (regexp-match? re (file->string p)))))
       (path->string p))]
    [else '()]))

(define (relative-to-repo p)
  (define s (path->string (simplify-path p)))
  (define root-s (string-append (path->string (simplify-path ROOT)) "/"))
  (cond [(string-prefix? s root-s) (substring s (string-length root-s))]
        [else s]))

;; ---------- command: rebuild ----------

(define (cmd-rebuild args)
  ;; Strip --skip-checks if present; everything else flows through to host.
  (define-values (skip-checks? rest-args)
    (let loop ([acc '()] [skip? #f] [args args])
      (cond
        [(null? args) (values skip? (reverse acc))]
        [(equal? (car args) "--skip-checks") (loop acc #t (cdr args))]
        [else (loop (cons (car args) acc) skip? (cdr args))])))
  (define host (and (pair? rest-args) (car rest-args)))

  (unless skip-checks?
    ;; Step 1: regenerate any out-of-date .nix from .rkt sources.
    (printf ">> firn-build\n")
    (unless (sh (path->string (in-repo "scripts" "firn-build")))
      (eprintf "firn rebuild: firn-build failed; aborting.\n") (exit 1))
    ;; Step 1b: warn about untracked .rkt/.nix — Nix can't see them.
    (define untracked
      (let ([s (sh-out "git" "-C" ROOT "ls-files" "--others" "--exclude-standard")])
        (filter (λ (p) (regexp-match? #rx"\\.(rkt|nix)$" p))
                (string-split s "\n"))))
    (unless (null? untracked)
      (eprintf "firn rebuild: untracked files invisible to Nix — git add them first:\n")
      (for ([p (in-list untracked)]) (eprintf "  ~a\n" p))
      (exit 1))
    ;; Step 2: validate paths and value types against the schema.
    (printf ">> firn-validate\n")
    (unless (sh (path->string (in-repo "scripts" "firn-validate")))
      (eprintf "firn rebuild: validation failed; aborting.\n") (exit 1)))

  ;; Step 3: actual rebuild.
  (printf ">> rebuild\n")
  (define has-nh? (and (find-executable-path "nh") #t))
  (define rc
    (cond
      [has-nh?
       (apply system* (find-executable-path "nh")
              (append (list "os" "switch" ROOT)
                      (if host (list "-H" host) '())))]
      [else
       (define flake-target (if host (string-append ROOT "#" host) ROOT))
       (sh "sudo" "nixos-rebuild" "switch" "--flake" flake-target)]))
  (cond
    [(not rc) (printf "rebuild failed.\n") (exit 1)]
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

;; ---------- command: list ----------

(define (cmd-list args)
  (define flag (and (pair? args) (car args)))
  (cond
    [(equal? flag "--used")
     (printf "Used bundles:\n")
     (for ([b (in-list (bundles))])
       (define hits (grep-files "hosts" (regexp (format "myConfig\\.bundles\\.~a\\.enable" b))))
       (define host-names (sort (remove-duplicates (map host-of-path hits)) string<?))
       (when (pair? host-names)
         (printf "  ~a  (~a)\n" b (string-join host-names ", "))))
     (printf "\nUsed modules:\n")
     (for ([m (in-list (modules))])
       (define h (sort (remove-duplicates
                        (map host-of-path
                             (grep-files "hosts" (regexp (format "myConfig\\.modules\\.~a\\.enable" m)))))
                       string<?))
       (define b (sort (remove-duplicates
                        (map bundle-of-path
                             (grep-files "bundles" (regexp (format "myConfig\\.modules\\.~a\\.enable" m)))))
                       string<?))
       (define sources (append h (map (λ (x) (string-append "via " x)) b)))
       (when (pair? sources)
         (printf "  ~a  (~a)\n" m (string-join sources ", "))))]
    [(equal? flag "--unused")
     (printf "Unused bundles:\n")
     (for ([b (in-list (bundles))])
       (define re (regexp (format "myConfig\\.bundles\\.~a\\.enable" b)))
       (when (and (null? (grep-files "hosts" re))
                  (null? (grep-files "bundles" re)))
         (printf "  ~a\n" b)))
     (printf "\nUnused modules (not in any host or bundle):\n")
     (for ([m (in-list (modules))])
       (define re (regexp (format "myConfig\\.modules\\.~a\\.enable" m)))
       (when (and (null? (grep-files "hosts" re))
                  (null? (grep-files "bundles" re)))
         (printf "  ~a\n" m)))]
    [else
     (define bs (bundles))
     (define ms (modules))
     (printf "Bundles (~a):\n" (length bs))
     (for ([b (in-list bs)]) (printf "  myConfig.bundles.~a\n" b))
     (printf "\nModules (~a):\n" (length ms))
     (for ([m (in-list ms)]) (printf "  myConfig.modules.~a\n" m))]))

(define (host-of-path p)
  (define m (regexp-match #rx"/hosts/([^/]+)/" p))
  (and m (cadr m)))

(define (bundle-of-path p)
  (define m (regexp-match #rx"/bundles/([^/]+)/" p))
  (and m (cadr m)))

;; ---------- command: refs ----------

(define (cmd-refs args)
  (cond
    [(null? args) (eprintf "Usage: firn refs <name>\n") (exit 1)]
    [else
     (define name (car args))
     (printf "Bundles:\n")
     (for ([b (in-list (sort (remove-duplicates
                              (append
                               (map bundle-of-path
                                    (grep-files "bundles"
                                                (regexp (format "myConfig\\.modules\\.~a\\.enable" name))))
                               (map bundle-of-path
                                    (grep-files "bundles"
                                                (regexp (format "myConfig\\.bundles\\.~a\\.enable" name))))))
                             string<?))])
       (when b (printf "  ~a\n" b)))
     (printf "\nHosts:\n")
     (for ([h (in-list (sort (remove-duplicates
                              (append
                               (map host-of-path
                                    (grep-files "hosts"
                                                (regexp (format "myConfig\\.modules\\.~a\\.enable" name))))
                               (map host-of-path
                                    (grep-files "hosts"
                                                (regexp (format "myConfig\\.bundles\\.~a\\.enable" name))))))
                             string<?))])
       (when h (printf "  ~a\n" h)))]))

;; ---------- command: mod (scaffold) ----------

(define (cmd-mod args)
  (cond
    [(null? args) (eprintf "Usage: firn mod <name>\n") (exit 1)]
    [else
     (define name (car args))
     (define dir (in-repo "modules" name))
     (when (directory-exists? dir)
       (eprintf "Module ~a already exists\n" name) (exit 1))
     (make-directory* dir)
     (define f (build-path dir "default.rkt"))
     (with-output-to-file f
       (λ ()
         (printf "#lang nisp~n~n(pkg ~a ~s)~n" name name)))
     (sh "git" "-C" ROOT "add" (path->string dir))
     (printf "Created modules/~a/default.rkt (git added)\n" name)]))

;; ---------- command: bundle (scaffold) ----------

(define (cmd-bundle args)
  (cond
    [(< (length args) 2)
     (eprintf "Usage: firn bundle <name> <mod1> <mod2> ...\n") (exit 1)]
    [else
     (define name (car args))
     (define mods (cdr args))
     (define dir (in-repo "bundles" name))
     (when (directory-exists? dir)
       (eprintf "Bundle ~a already exists\n" name) (exit 1))
     (make-directory* dir)
     (define f (build-path dir "default.rkt"))
     (with-output-to-file f
       (λ ()
         (printf "#lang nisp~n~n(bundle-file ~a~n  (desc ~s)~n  (sub-modules ~a))~n"
                 name name (string-join mods " "))))
     (sh "git" "-C" ROOT "add" (path->string dir))
     (printf "Created bundles/~a/default.rkt with ~a modules (git added)\n"
             name (length mods))]))

;; ---------- command: secret ----------

(define (cmd-secret args)
  (define subcmd (and (pair? args) (car args)))
  (define rest (if (pair? args) (cdr args) '()))
  (cond
    [(not subcmd)
     (eprintf "Usage: firn secret <name|list|show <name>>\n") (exit 1)]
    [(equal? subcmd "list")
     (define sd (in-repo "secrets"))
     (when (directory-exists? sd)
       (for ([p (in-list (directory-list sd))]
             #:when (regexp-match? #rx"\\.yaml$" (path->string p)))
         (printf "~a\n" (regexp-replace #rx"\\.yaml$" (path->string p) ""))))]
    [(equal? subcmd "show")
     (cond
       [(null? rest) (eprintf "Usage: firn secret show <name>\n") (exit 1)]
       [else
        (define f (in-repo "secrets" (string-append (car rest) ".yaml")))
        (cond
          [(file-exists? f) (sh "sops" "-d" (path->string f))]
          [else (eprintf "No secret file: secrets/~a.yaml\n" (car rest)) (exit 1)])])]
    [else
     ;; treat subcmd as name to edit
     (define f (in-repo "secrets" (string-append subcmd ".yaml")))
     (sh "sops" (path->string f))
     (when (file-exists? f)
       (sh "git" "-C" ROOT "add" (path->string f))
       (printf "secrets/~a.yaml (git added)\n" subcmd))]))

;; ---------- command: gen ----------

(define (cmd-gen _args)
  (define gens (sh-out "nixos-rebuild" "list-generations"))
  (define cur-line
    (for/or ([line (in-list (string-split gens "\n"))]
             #:when (regexp-match? #rx"current" line))
      line))
  (cond
    [cur-line
     (define cur (car (string-split (string-trim cur-line))))
     (printf "current: ~a\n" cur)
     (when (regexp-match? #rx"^[0-9]+$" cur)
       (printf "next:    ~a\n" (+ 1 (string->number cur))))]
    [else (printf "(no generation info)\n")]))

;; ---------- command: enable / disable ----------
;;
;; Toggle a module or bundle in the current host's configuration.rkt.
;;
;; Strategy: textual edit, syntax-aware enough to find and modify the right
;; (enable …) / (set 'myConfig.X.enable …) form, or append a new line near
;; the end if no existing reference is present.

(define (find-name-kind name)
  ;; Return 'module, 'bundle, or #f
  (cond
    [(directory-exists? (in-repo "modules" name)) 'module]
    [(directory-exists? (in-repo "bundles" name)) 'bundle]
    [else #f]))

(define (path-prefix-for-kind kind)
  (case kind
    [(module) "myConfig.modules"]
    [(bundle) "myConfig.bundles"]
    [else (error 'path-prefix "unknown kind")]))

(define (read-host-config host)
  (define f (host-config-rkt host))
  (cond
    [(file-exists? f) (file->string f)]
    [else (error 'read-host-config "no configuration.rkt for host ~a" host)]))

(define (write-host-config host text)
  (define f (host-config-rkt host))
  (display-to-file text f #:exists 'replace))

(define (toggle-host-config host kind name on?)
  (define text (read-host-config host))
  (define prefix (path-prefix-for-kind kind))
  (define full-path (format "~a.~a" prefix name))
  ;; Look for existing references in the text. We handle three shapes:
  ;;   (enable PATH ...) where PATH is full-path
  ;;   (set 'PATH.enable BOOL)
  ;;   (set 'PATH (att (enable BOOL) ...)) — leave alone, surface as match
  (define new-text
    (cond
      [on? (turn-on text full-path)]
      [else (turn-off text full-path)]))
  (cond
    [(equal? new-text text)
     (printf "~a is already ~a (or not toggleable cleanly).\n"
             full-path (if on? "enabled" "disabled"))]
    [else
     (write-host-config host new-text)
     (printf "~a => ~a in hosts/~a/configuration.rkt\n"
             full-path (if on? "enabled" "disabled") host)]))

(define (turn-on text full-path)
  ;; If the path is mentioned in a (set PATH.enable #f|#t), flip to #t.
  ;; Otherwise append a (enable PATH) line before host-file's closing paren.
  ;; Matches both bare `PATH` and quoted `'PATH` styles.
  (define set-re
    (pregexp (string-append "\\(set\\s+'?" (regexp-quote (string-append full-path ".enable"))
                            "\\s+#[ft]\\)")))
  (cond
    [(regexp-match set-re text)
     (regexp-replace set-re text
       (string-append "(set " full-path ".enable #t)"))]
    [(regexp-match (regexp (regexp-quote full-path)) text)
     ;; Mentioned in some other form (e.g., att, bundle composite); leave alone.
     text]
    [else
     (insert-before-final-close text
       (string-append "  (enable " full-path ")\n"))]))

(define (turn-off text full-path)
  (define set-re-true
    (pregexp (string-append "\\(set\\s+'?" (regexp-quote (string-append full-path ".enable"))
                            "\\s+#t\\)")))
  (define enable-line-re
    (pregexp (string-append "\\s*'?" (regexp-quote full-path) "(?=[\\s)])")))
  (cond
    [(regexp-match set-re-true text)
     (regexp-replace set-re-true text
       (string-append "(set " full-path ".enable #f)"))]
    [(regexp-match enable-line-re text)
     ;; Strip the PATH token from an (enable …) call.
     (regexp-replace enable-line-re text "")]
    [else text]))

(define (insert-before-final-close text insertion)
  ;; Find the position where the outermost top-level form (host-file ...)
  ;; closes by tracking paren depth (skipping over strings and comments).
  ;; Then walk backward to the start of that line so the insertion lands
  ;; on its own line above the closing paren(s).
  (define len (string-length text))
  (define close-pos
    (let loop ([i 0] [depth 0] [in-str #f] [in-comment #f] [last-close-at-zero #f])
      (cond
        [(>= i len) last-close-at-zero]
        [in-comment
         (cond [(char=? (string-ref text i) #\newline) (loop (+ i 1) depth in-str #f last-close-at-zero)]
               [else (loop (+ i 1) depth in-str #t last-close-at-zero)])]
        [in-str
         (cond [(and (char=? (string-ref text i) #\\) (< (+ i 1) len))
                (loop (+ i 2) depth #t #f last-close-at-zero)]
               [(char=? (string-ref text i) #\")
                (loop (+ i 1) depth #f #f last-close-at-zero)]
               [else (loop (+ i 1) depth #t #f last-close-at-zero)])]
        [(char=? (string-ref text i) #\;)
         (loop (+ i 1) depth in-str #t last-close-at-zero)]
        [(char=? (string-ref text i) #\")
         (loop (+ i 1) depth #t #f last-close-at-zero)]
        [(char=? (string-ref text i) #\()
         (loop (+ i 1) (+ depth 1) #f #f last-close-at-zero)]
        [(char=? (string-ref text i) #\))
         (define new-depth (- depth 1))
         (loop (+ i 1) new-depth #f #f
               (if (zero? new-depth) i last-close-at-zero))]
        [else (loop (+ i 1) depth in-str #f last-close-at-zero)])))
  (cond
    [(not close-pos) (string-append text insertion)]
    [else
     ;; Insert directly before the depth-0 closing paren, on its own line.
     ;; This is safe regardless of whether the close shares a line with
     ;; inner forms (e.g. `…vm))`) — we land between the inner `)` and
     ;; host-file's `)`.
     (string-append (substring text 0 close-pos)
                    "\n  " (string-trim-right insertion) "\n"
                    (substring text close-pos))]))

(define (string-trim-right s)
  (regexp-replace #rx"[ \t\n]+$" s ""))

(define (cmd-enable args)
  (cond
    [(null? args) (eprintf "Usage: firn enable <module-or-bundle-name> [host]\n") (exit 1)]
    [else
     (define name (car args))
     (define host (if (>= (length args) 2) (cadr args) (current-hostname)))
     (define kind (find-name-kind name))
     (cond
       [(not kind) (eprintf "no module or bundle named ~a\n" name) (exit 1)]
       [else (toggle-host-config host kind name #t)])]))

(define (cmd-disable args)
  (cond
    [(null? args) (eprintf "Usage: firn disable <module-or-bundle-name> [host]\n") (exit 1)]
    [else
     (define name (car args))
     (define host (if (>= (length args) 2) (cadr args) (current-hostname)))
     (define kind (find-name-kind name))
     (cond
       [(not kind) (eprintf "no module or bundle named ~a\n" name) (exit 1)]
       [else (toggle-host-config host kind name #f)])]))

;; ---------- command: status ----------

(define (cmd-status args)
  (define host (if (pair? args) (car args) (current-hostname)))
  (define text (read-host-config host))
  (printf "Enabled in ~a:\n" host)
  ;; Collect every reference to myConfig.{modules,bundles}.NAME — both bare
  ;; (post-#%top-revert style) and quoted ('PATH) form.
  (define seen (make-hash))
  (for ([m (in-list (regexp-match* #px"'?myConfig\\.(?:modules|bundles)\\.[a-zA-Z0-9_-]+(?:\\.enable)?"
                                   text))])
    (define norm (regexp-replace* #rx"^'|\\.enable$" m ""))
    (hash-set! seen norm #t))
  (for ([k (in-list (sort (hash-keys seen) string<?))])
    (printf "  ~a\n" k)))

;; ---------- command: diff ----------
;;
;; Re-emit Nix from a .rkt source and diff it against the committed .nix.
;; Useful for "what would change in the generated Nix if I ran firn-build?"
;; and for confirming hand-edited .nix files are equivalent to what nisp
;; would produce.

(define (resolve-rkt-source name)
  ;; Resolve a user-facing name to a .rkt path. Accepts:
  ;;   - bare name       → modules/<name>/default.rkt or bundles/<name>/default.rkt
  ;;   - module/<name>   → modules/<name>/default.rkt
  ;;   - bundle/<name>   → bundles/<name>/default.rkt
  ;;   - host/<name>     → hosts/<name>/configuration.rkt
  ;;   - flake           → flake.rkt
  ;;   - relative path   → as-is (resolved against repo root if not absolute)
  (cond
    [(equal? name "flake")
     (in-repo "flake.rkt")]
    [(regexp-match #rx"^module[s]?/(.+)$" name)
     => (λ (m) (in-repo "modules" (cadr m) "default.rkt"))]
    [(regexp-match #rx"^bundle[s]?/(.+)$" name)
     => (λ (m) (in-repo "bundles" (cadr m) "default.rkt"))]
    [(regexp-match #rx"^host[s]?/(.+)$" name)
     => (λ (m) (in-repo "hosts" (cadr m) "configuration.rkt"))]
    [(regexp-match #rx"\\.rkt$" name)
     ;; explicit path — allow absolute or repo-relative
     (cond [(file-exists? name) (string->path name)]
           [(file-exists? (in-repo name)) (in-repo name)]
           [else #f])]
    [else
     ;; bare name — try modules/, then bundles/, then hosts/
     (define candidates
       (list (in-repo "modules" name "default.rkt")
             (in-repo "bundles" name "default.rkt")
             (in-repo "hosts" name "configuration.rkt")))
     (or (findf file-exists? candidates) #f)]))

(define (rkt->nix-path rkt)
  (define s (path->string rkt))
  (cond
    [(regexp-match? #rx"\\.rkt$" s)
     (string->path (regexp-replace #rx"\\.rkt$" s ".nix"))]
    [else (error 'rkt->nix-path "not a .rkt file: ~a" s)]))

(define (re-emit-nix rkt-path)
  ;; Run `racket <rkt>` and capture stdout. Returns string or #f on error.
  (define out (open-output-string))
  (define err (open-output-string))
  (define ok?
    (parameterize ([current-output-port out]
                   [current-error-port err])
      (system* (find-exe "racket") (path->string rkt-path))))
  (cond
    [ok? (get-output-string out)]
    [else
     (eprintf "firn diff: failed to evaluate ~a\n" (path->string rkt-path))
     (eprintf "~a" (get-output-string err))
     #f]))

(define (diff-one rkt-path)
  ;; Returns 'same / 'different / 'error
  (define nix-path (rkt->nix-path rkt-path))
  (define fresh (re-emit-nix rkt-path))
  (cond
    [(not fresh) 'error]
    [(not (file-exists? nix-path))
     (printf "=== ~a ===\n" (relative-to-repo nix-path))
     (printf "(no committed .nix — would create)\n")
     'different]
    [else
     (define committed (file->string nix-path))
     (cond
       [(equal? fresh committed) 'same]
       [else
        (define tmp (make-temporary-file "firn-diff-~a.nix"))
        (with-output-to-file tmp #:exists 'replace
          (λ () (display fresh)))
        (printf "=== ~a ===\n" (relative-to-repo nix-path))
        (flush-output)
        (system* (find-exe "diff") "-u" "--color=always"
                 (path->string nix-path) (path->string tmp))
        (delete-file tmp)
        'different])]))

(define (cmd-diff args)
  (define targets
    (cond
      [(null? args)
       ;; diff every nisp .rkt
       (sort
        (for/list ([f (in-directory ROOT)]
                   #:when (let ([s (path->string f)])
                            (and (regexp-match? #rx"\\.rkt$" s)
                                 (not (regexp-match? #rx"/nisp/" s))
                                 (not (regexp-match? #rx"/scripts/" s))
                                 (not (regexp-match? #rx"/\\.firn-build/" s))
                                 (not (regexp-match? #rx"/\\.direnv/" s))
                                 (not (regexp-match? #rx"/\\.git/" s))
                                 (not (regexp-match? #rx"/result" s))
                                 (with-handlers ([exn:fail? (λ (_) #f)])
                                   (regexp-match?
                                    #rx"^#lang nisp"
                                    (call-with-input-file f
                                      (λ (p) (read-line p))))))))
          f)
        path<?)]
      [else
       (filter-map
        (λ (a)
          (define r (resolve-rkt-source a))
          (cond
            [r r]
            [else (eprintf "firn diff: cannot resolve ~a\n" a) #f]))
        args)]))
  (define same 0)
  (define diff 0)
  (define err 0)
  (for ([rkt (in-list targets)])
    (case (diff-one rkt)
      [(same) (set! same (+ same 1))]
      [(different) (set! diff (+ diff 1))]
      [(error) (set! err (+ err 1))]))
  (printf "\nfirn diff: ~a unchanged, ~a differ, ~a error(s)\n" same diff err)
  (exit (if (or (> diff 0) (> err 0)) 1 0)))

;; ---------- command: watch ----------
;;
;; Re-run firn-validate on the changed file whenever a #lang nisp .rkt
;; source is modified. Uses Racket's filesystem-change-evt so no external
;; inotify dep — works on Linux/macOS/BSD.

(define (descend? d)
  ;; in-directory's second arg is `use-dir?` — return #t to recurse, #f
  ;; to prune. Skip directories that hold no nisp config sources.
  (define s (path->string d))
  (not (or (regexp-match? #rx"/\\.git$"        s)
           (regexp-match? #rx"/\\.direnv$"     s)
           (regexp-match? #rx"/\\.firn-build$" s)
           (regexp-match? #rx"/nisp$"          s)
           (regexp-match? #rx"/scripts$"       s)
           (regexp-match? #rx"/result"         s))))

(define (gather-nisp-rkts)
  (sort
   (for/list ([f (in-directory ROOT descend?)]
              #:when (and (regexp-match? #rx"\\.rkt$" (path->string f))
                          (with-handlers ([exn:fail? (λ (_) #f)])
                            (regexp-match?
                             #rx"^#lang nisp"
                             (call-with-input-file f
                               (λ (p) (read-line p)))))))
     f)
   path<?))

(define (cmd-watch _args)
  ;; Make stdout line-buffered so output appears in real time even when
  ;; redirected to a non-tty (logs, pipes).
  (file-stream-buffer-mode (current-output-port) 'line)
  (define files (gather-nisp-rkts))
  (printf "firn watch: monitoring ~a .rkt file(s)... (Ctrl-C to exit)\n"
          (length files))
  (let loop ([files files])
    (define evts (map filesystem-change-evt files))
    (define ready (apply sync evts))
    (define idx (for/or ([e (in-list evts)] [i (in-naturals)]
                         #:when (eq? e ready))
                  i))
    (define changed (and idx (list-ref files idx)))
    ;; Cancel remaining events to release watch slots.
    (for ([e (in-list evts)]) (filesystem-change-evt-cancel e))
    (cond
      [(and changed (file-exists? changed))
       (printf "\n>> ~a changed\n" (relative-to-repo changed))
       (flush-output)
       (system* (find-exe "racket")
                (path->string (in-repo "scripts" "firn-validate"))
                (path->string changed))
       (loop (gather-nisp-rkts))]
      [else
       (loop (gather-nisp-rkts))])))

;; ---------- command: scaffold ----------
;;
;; Template-based generation for module/bundle/host shapes that are richer
;; than what `firn mod` / `firn bundle` produce. Each template emits a
;; `#lang nisp` source so the user starts from a working .rkt.

(define (scaffold-write-file path contents)
  (when (file-exists? path)
    (eprintf "firn scaffold: refusing to overwrite ~a\n" path)
    (exit 1))
  (make-directory* (path-only path))
  (display-to-file contents path)
  (sh "git" "-C" ROOT "add" (path->string path))
  (printf "Created ~a (git added)\n" (relative-to-repo path)))

(define (scaffold-service name)
  (define dir (in-repo "modules" name))
  (define f (build-path dir "default.rkt"))
  (define body
    (string-append
     "#lang nisp\n\n"
     (format "(module-file modules ~a~n" name)
     (format "  (desc ~s)~n" (format "~a service" name))
     "  (config-body\n"
     (format "    (set environment.systemPackages (with-pkgs ~a))~n" name)
     (format "    (set services.~a.enable #t)))~n" name)))
  (scaffold-write-file f body))

(define (scaffold-submodule name)
  (define dir (in-repo "modules" name))
  (define f (build-path dir "default.rkt"))
  (define body
    (string-append
     "#lang nisp\n\n"
     (format "(module-file modules ~a~n" name)
     (format "  (desc ~s)~n" (format "~a configuration" name))
     "  (option-attrs\n"
     "    (extraConfig (mkopt #:type lib.types.lines\n"
     "                        #:default \"\"\n"
     "                        #:desc \"Extra config text.\")))\n"
     "  (config-body\n"
     (format "    (set environment.systemPackages (with-pkgs ~a))))~n" name)))
  (scaffold-write-file f body))

(define (scaffold-home name)
  (define dir (in-repo "modules" name))
  (define f (build-path dir "default.rkt"))
  (define body
    (string-append
     "#lang nisp\n\n"
     (format "(hm-module ~a ~s~n" name (format "~a (home-manager)" name))
     (format "  (set programs.~a~n" name)
     "    (att (enable #t))))\n"))
  (scaffold-write-file f body))

(define (scaffold-host name)
  (define dir (in-repo "hosts" name))
  (define f (build-path dir "configuration.rkt"))
  (define body
    (string-append
     "#lang nisp\n\n"
     "(host-file\n"
     "  (set myConfig.modules.system.stateVersion \"25.11\")\n"
     "  (set myConfig.modules.users.username \"you\")\n"
     "  (enable myConfig.modules.users\n"
     "          myConfig.modules.boot\n"
     "          myConfig.modules.networking)\n\n"
     "  ;; REQUIRED for the firn-build pipeline\n"
     "  (enable myConfig.bundles.racket\n"
     "          myConfig.bundles.terminal\n"
     "          myConfig.bundles.development))\n"))
  (scaffold-write-file f body)
  (printf "Don't forget to add ~a to flake.rkt's nixosConfigurations.\n" name))

(define (cmd-scaffold args)
  (cond
    [(< (length args) 2)
     (eprintf "Usage: firn scaffold <pattern> <name>\n")
     (eprintf "  patterns: service, submodule, home, host\n")
     (exit 1)]
    [else
     (define pattern (car args))
     (define name (cadr args))
     (case (string->symbol pattern)
       [(service)   (scaffold-service name)]
       [(submodule) (scaffold-submodule name)]
       [(home)      (scaffold-home name)]
       [(host)      (scaffold-host name)]
       [else
        (eprintf "firn scaffold: unknown pattern '~a'\n" pattern)
        (eprintf "  patterns: service, submodule, home, host\n")
        (exit 1)])]))

;; ---------- help ----------

(define (cmd-help _args)
  (printf #<<HELP
firn — FirnOS config management

Usage:
  firn <command> [args...]

Commands:
  rebuild [host] [--skip-checks]  firn-build + validate, then nixos-rebuild + tag
  watch                       re-run validator on .rkt save (no external deps)
  list                        list all modules and bundles
  list --used                 show modules/bundles in use and where
  list --unused               show modules/bundles not referenced anywhere
  refs <name>                 show what references a module/bundle
  mod <name>                  scaffold a minimal module (.rkt)
  bundle <name> <mods...>     scaffold a new bundle (.rkt)
  scaffold <pattern> <name>   scaffold from template (service|submodule|home|host)
  diff [target...]            re-emit Nix from .rkt and diff vs committed .nix
  secret <name>               create/edit an encrypted secret
  secret list                 list secret files
  secret show <name>          decrypt and display a secret
  gen                         show current and next generation numbers
  enable <name> [host]        toggle a module/bundle on in host config
  disable <name> [host]       toggle a module/bundle off in host config
  status [host]               list enabled modules/bundles for host

HELP
  ))

;; ---------- main ----------

(define (main argv)
  (cond
    [(null? argv) (cmd-help argv)]
    [else
     (define cmd (car argv))
     (define rest (cdr argv))
     (case cmd
       [("rebuild")     (cmd-rebuild rest)]
       [("watch")       (cmd-watch rest)]
       [("list")        (cmd-list rest)]
       [("refs")        (cmd-refs rest)]
       [("mod")         (cmd-mod rest)]
       [("bundle")      (cmd-bundle rest)]
       [("scaffold")    (cmd-scaffold rest)]
       [("diff")        (cmd-diff rest)]
       [("secret")      (cmd-secret rest)]
       [("gen")         (cmd-gen rest)]
       [("enable")      (cmd-enable rest)]
       [("disable")     (cmd-disable rest)]
       [("status")      (cmd-status rest)]
       [("help" "-h" "--help") (cmd-help rest)]
       [else
        (eprintf "firn: unknown command '~a'\n\n" cmd)
        (cmd-help rest)
        (exit 1)])]))

(main (vector->list (current-command-line-arguments)))
