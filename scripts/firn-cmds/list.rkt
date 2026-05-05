#lang racket/base

(require racket/string
         racket/list
         "util.rkt")

(provide cmd-list cmd-refs host-of-path bundle-of-path commands)

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
     (printf "Unreferenced bundles:\n")
     (for ([b (in-list (bundles))])
       (define re (regexp (format "myConfig\\.bundles\\.~a\\.enable" b)))
       (when (and (null? (grep-files "hosts" re))
                  (null? (grep-files "bundles" re)))
         (printf "  ~a\n" b)))
     (printf "\nUnreferenced modules:\n")
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

(define commands
  (list (cmd "list" "[--used | --unused]"
             "list modules and bundles (with usage filter)"
             cmd-list)
        (cmd "refs" "<name>"
             "show what references a module or bundle"
             cmd-refs)))
