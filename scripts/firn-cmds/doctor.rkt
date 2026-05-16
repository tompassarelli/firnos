#lang racket/base

;; firn-cmds/doctor — repo health check. Walks a battery of
;; common-trouble checks and prints a status report.
;;
;; Checks:
;;   1. Untracked .rkt/.nix files (invisible to Nix's flake reader)
;;   2. Stale .nix files (sibling .rkt newer)
;;   3. Schema cache freshness (vs flake.lock mtime)
;;   4. Orphaned modules (not enabled by any host or bundle)
;;   5. Validator clean
;;   6. Flake inputs use no absolute paths (pure-eval safe)
;;
;; Exits 0 if all pass, 1 if any fail.

(require racket/file
         racket/list
         racket/path
         racket/string
         racket/system
         "util.rkt"
         "list.rkt")  ; for host-of-path / bundle-of-path / cmd-list machinery

(provide node-edges)

(define (check-status name predicate-thunk)
  ;; predicate-thunk returns (values pass? detail-lines)
  (define-values (ok? details) (predicate-thunk))
  (cond
    [ok?
     (printf "  ✓ ~a\n" name)
     #t]
    [else
     (printf "  ✗ ~a\n" name)
     (for ([line (in-list details)])
       (printf "      ~a\n" line))
     #f]))

;; ---------- individual checks ----------

(define (check-untracked)
  (define s (sh-out "git" "-C" ROOT "ls-files" "--others" "--exclude-standard"))
  (define files
    (filter (λ (p) (regexp-match? #rx"\\.(rkt|nix)$" p))
            (string-split s "\n")))
  (cond
    [(null? files) (values #t '())]
    [else (values #f (cons "untracked .rkt/.nix files (invisible to Nix):"
                           (map (λ (f) (string-append "  " f)) files)))]))

(define (check-stale-nix)
  ;; For every .rkt under modules/bundles/hosts/flake.rkt, check that its
  ;; .nix sibling exists AND is at least as new as the .rkt.
  (define stale '())
  (define missing '())
  (for ([f (in-directory ROOT)])
    (define s (path->string f))
    (when (and (regexp-match? #rx"\\.rkt$" s)
               (or (regexp-match? #rx"/modules/" s)
                   (regexp-match? #rx"/bundles/" s)
                   (regexp-match? #rx"/hosts/" s)
                   (regexp-match? #rx"/flake\\.rkt$" s)))
      (when (with-handlers ([exn:fail? (λ (_) #f)])
              (regexp-match? #rx"^#lang nisp"
                             (call-with-input-file f (λ (p) (read-line p)))))
        (define nix-path (regexp-replace #rx"\\.rkt$" s ".nix"))
        (cond
          [(not (file-exists? nix-path))
           (set! missing (cons (relative-to-repo f) missing))]
          [(< (file-or-directory-modify-seconds nix-path)
              (file-or-directory-modify-seconds f))
           (set! stale (cons (relative-to-repo f) stale))]))))
  (define issues '())
  (when (pair? missing)
    (set! issues (cons (format "missing .nix output for: ~a" (length missing)) issues))
    (for ([f (in-list (reverse missing))]) (set! issues (cons (string-append "  " f) issues))))
  (when (pair? stale)
    (set! issues (cons (format "stale .nix (older than .rkt): ~a" (length stale)) issues))
    (for ([f (in-list (reverse stale))]) (set! issues (cons (string-append "  " f) issues))))
  (cond
    [(null? issues) (values #t '())]
    [else (values #f (reverse issues))]))

(define (check-schema-cache)
  (define schema-path (build-path ROOT ".nisp-cache" "schema.json"))
  (cond
    [(not (file-exists? schema-path))
     (values #f (list "schema cache missing — run firn-extract-schema"))]
    [else
     (define lock (build-path ROOT "flake.lock"))
     (cond
       [(and (file-exists? lock)
             (> (file-or-directory-modify-seconds lock)
                (file-or-directory-modify-seconds schema-path)))
        (values #f (list "schema cache older than flake.lock — re-run firn-extract-schema"))]
       [else (values #t '())])]))

(define (check-darwin-schema-cache)
  ;; Optional check — the darwin schema only matters if there are
  ;; darwinConfigurations in flake.rkt. We detect that via a grep.
  (define has-darwin?
    (with-handlers ([exn:fail? (λ (_) #f)])
      (regexp-match? #rx"darwinConfigurations"
                     (file->string (in-repo "flake.rkt")))))
  (cond
    [(not has-darwin?) (values #t '())]
    [else
     (define dar-schema (build-path ROOT ".nisp-cache" "schema-darwin.json"))
     (cond
       [(not (file-exists? dar-schema))
        (values #f (list "darwin schema cache missing — run firn-extract-schema --darwin"))]
       [else
        (define lock (build-path ROOT "flake.lock"))
        (cond
          [(and (file-exists? lock)
                (> (file-or-directory-modify-seconds lock)
                   (file-or-directory-modify-seconds dar-schema)))
           (values #f (list "darwin schema cache older than flake.lock — re-run firn-extract-schema --darwin"))]
          [else (values #t '())])])]))

(define (check-orphaned-modules)
  (define orphans '())
  (for ([m (in-list (modules))])
    (define re (regexp (format "myConfig\\.modules\\.~a\\.enable" m)))
    (when (and (null? (grep-files "hosts" re))
               (null? (grep-files "bundles" re)))
      (set! orphans (cons m orphans))))
  (cond
    [(null? orphans) (values #t '())]
    [else (values #f (cons (format "~a unreferenced modules:" (length orphans))
                           (map (λ (m) (string-append "  " m))
                                (reverse orphans))))]))

(define (check-flake-input-purity)
  ;; Flake inputs declared as "path:/abs/..." resolve to an absolute filesystem
  ;; path. Pure-eval (default for flakes) forbids reading outside the flake's
  ;; own source tree, so any module that *references* such an input — directly
  ;; or via flake-lock resolution — fails the rebuild with: "access to absolute
  ;; path '/...' is forbidden in pure evaluation mode". firn-validate is
  ;; schema-only and can't see this; firn rebuild runs the same check
  ;; pre-flight.
  (define offenders (flake-input-purity-violations))
  (cond
    [(null? offenders) (values #t '())]
    [else (values #f
                  (cons "absolute path: inputs break pure eval when referenced:"
                        (append offenders
                                (list "fix: publish to a git remote (github:owner/repo), or override locally with --override-input"))))]))

(define (check-validator)
  (define out (open-output-string))
  (define err (open-output-string))
  (define ok?
    (parameterize ([current-output-port out] [current-error-port err])
      (system* (path->string (in-repo "scripts" "firn-validate")))))
  (cond
    [ok? (values #t '())]
    [else
     (define lines (regexp-split #rx"\n" (get-output-string err)))
     (define filtered (filter (λ (l) (not (regexp-match? #rx"^\\s*$" l))) lines))
     (values #f (take filtered (min 5 (length filtered))))]))

;; ---------- main ----------

(define (handle-doctor _leaf)
  (printf "fi doctor: running checks on ~a\n\n"
          (if (path? ROOT) (path->string ROOT) ROOT))
  (define passes
    (list
     (check-status "no untracked .rkt/.nix files" check-untracked)
     (check-status ".nix outputs are up-to-date with .rkt sources" check-stale-nix)
     (check-status "schema cache is fresh" check-schema-cache)
     (check-status "darwin schema cache is fresh (if applicable)" check-darwin-schema-cache)
     (check-status "no orphaned (unreferenced) modules" check-orphaned-modules)
     (check-status "flake inputs are pure-eval safe (no absolute paths)" check-flake-input-purity)
     (check-status "validator passes" check-validator)))
  (define total (length passes))
  (define passed (length (filter values passes)))
  (printf "\nfirn doctor: ~a/~a checks passed.\n" passed total)
  (exit (if (= passed total) 0 1)))

(define node-edges
  (list
   (walk-edge "repo" "doctor" "all" 'all
              handle-doctor
              "repo health check (untracked, stale, schema, orphans, validator)")
   (walk-edge "host" "doctor" "<host>" 'current-host
              handle-doctor
              "alias for repo doctor (host arg ignored)")))
