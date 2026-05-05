#lang racket/base

(require racket/list
         racket/path
         "util.rkt")

(provide cmd-secret cmd-gen)

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
     (define f (in-repo "secrets" (string-append subcmd ".yaml")))
     (sh "sops" (path->string f))
     (when (file-exists? f)
       (sh "git" "-C" ROOT "add" (path->string f))
       (printf "secrets/~a.yaml (git added)\n" subcmd))]))

(require racket/string)

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
