#lang racket/base

(require racket/list
         racket/path
         racket/string
         "util.rkt")

(provide node-edges)

(define (handle-secret-list _leaf)
  (define sd (in-repo "secrets"))
  (when (directory-exists? sd)
    (for ([p (in-list (directory-list sd))]
          #:when (regexp-match? #rx"\\.yaml$" (path->string p)))
      (printf "~a\n" (regexp-replace #rx"\\.yaml$" (path->string p) "")))))

(define (handle-secret-show name)
  (define f (in-repo "secrets" (string-append name ".yaml")))
  (cond
    [(file-exists? f) (sh "sops" "-d" (path->string f))]
    [else (eprintf "No secret file: secrets/~a.yaml\n" name) (exit 1)]))

(define (handle-secret-edit name)
  (define f (in-repo "secrets" (string-append name ".yaml")))
  (sh "sops" (path->string f))
  (when (file-exists? f)
    (sh "git" "-C" ROOT "add" (path->string f))
    (printf "secrets/~a.yaml (git added)\n" name)))

(define (handle-host-gen _leaf)
  ;; <leaf> currently unused — generation lookup is system-local. Future:
  ;; remote-host support would consult `nixos-rebuild list-generations`
  ;; against a different system.
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

(define node-edges
  (list
   (walk-edge "secret" "list" "all"    'all  handle-secret-list
              "list secret names under secrets/")
   (walk-edge "secret" "show" "<name>" #f    handle-secret-show
              "decrypt and print a secret to stdout")
   (walk-edge "secret" "edit" "<name>" #f    handle-secret-edit
              "open a secret in $EDITOR via sops (creates if missing)")
   (walk-edge "host" "gen" "<host>" 'current-host handle-host-gen
              "current and next NixOS generation numbers")))
