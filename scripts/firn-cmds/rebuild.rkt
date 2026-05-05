#lang racket/base

(require racket/string
         racket/list
         racket/path
         racket/system
         "util.rkt")

(provide cmd-rebuild)

(define (cmd-rebuild args)
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
