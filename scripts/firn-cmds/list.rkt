#lang racket/base

(require racket/string
         racket/list
         racket/path
         "util.rkt")

(provide cmd-list cmd-refs host-of-path bundle-of-path commands
         direct-references-by host-bundles host-modules bundle-modules
         live-modules live-bundles)

;; ---------- AST-based reference extraction ----------
;;
;; A module/bundle is "referenced by" a file if any path mentioned in
;; that file starts with `myConfig.modules.<name>` or
;; `myConfig.bundles.<name>`. This catches every shape the regex-based
;; predecessor missed:
;;   (set myConfig.modules.X.enable #t)             — direct enable
;;   (set myConfig.modules.X (att (enable #t) …))   — attrset form
;;   (set myConfig.modules.X.someOption val)        — config-only
;;   (enable myConfig.modules.X)                    — bare enable
;;   (sub-modules X …) inside a bundle              — bundle membership
;;
;; All of those go through util.rkt's `paths-referenced-in`, which
;; handles bare-id paths, quoted paths, shortcut macros, and
;; (sub-modules …) expansion.

(define (host-of-path p)
  (define m (regexp-match #rx"/hosts/([^/]+)/" p))
  (and m (cadr m)))

(define (bundle-of-path p)
  (define m (regexp-match #rx"/bundles/([^/]+)/" p))
  (and m (cadr m)))

(define (rkt-files-in dir-rel)
  ;; All .rkt files under <repo>/<dir-rel>, recursively.
  (define dir (in-repo dir-rel))
  (cond
    [(directory-exists? dir)
     (for/list ([f (in-directory dir)]
                #:when (regexp-match? #rx"\\.rkt$" (path->string f)))
       f)]
    [else '()]))

(define (direct-references-by file-prefix kind name)
  ;; kind ∈ '(modules bundles). Returns list of "owner names" (host or
  ;; bundle names depending on file-prefix) whose .rkt source mentions
  ;; myConfig.<kind>.<name> at any depth.
  (define needle (format "myConfig.~a.~a" kind name))
  (define needle. (string-append needle "."))
  (define owner-of (case file-prefix [("hosts") host-of-path] [("bundles") bundle-of-path]))
  (sort
   (remove-duplicates
    (filter values
            (for/list ([f (in-list (rkt-files-in file-prefix))]
                       #:when (let ([paths (paths-referenced-in f)])
                                (or (member needle paths)
                                    (for/or ([p (in-list paths)])
                                      (string-prefix? p needle.)))))
              (owner-of (path->string f)))))
   string<?))

(define (host-modules host)
  ;; Direct module references in this host's configuration.rkt.
  (define f (host-config-rkt host))
  (cond
    [(file-exists? f)
     (define paths (paths-referenced-in f))
     (sort
      (remove-duplicates
       (filter values
               (for/list ([p (in-list paths)])
                 (define m (regexp-match #rx"^myConfig\\.modules\\.([^.]+)" p))
                 (and m (cadr m)))))
      string<?)]
    [else '()]))

(define (host-bundles host)
  ;; Direct bundle references in this host's configuration.rkt.
  (define f (host-config-rkt host))
  (cond
    [(file-exists? f)
     (define paths (paths-referenced-in f))
     (sort
      (remove-duplicates
       (filter values
               (for/list ([p (in-list paths)])
                 (define m (regexp-match #rx"^myConfig\\.bundles\\.([^.]+)" p))
                 (and m (cadr m)))))
      string<?)]
    [else '()]))

(define (bundle-rkt-files bundle)
  ;; Look in both bundles/ (NixOS) and bundles-darwin/ (parallel
  ;; darwin variants). A module reachable via either is live.
  (filter file-exists?
          (list (in-repo "bundles" bundle "default.rkt")
                (in-repo "bundles-darwin" bundle "default.rkt"))))

(define (bundle-modules bundle)
  (define paths
    (apply append (map paths-referenced-in (bundle-rkt-files bundle))))
  (sort
   (remove-duplicates
    (filter values
            (for/list ([p (in-list paths)])
              (define m (regexp-match #rx"^myConfig\\.modules\\.([^.]+)" p))
              (and m (cadr m)))))
   string<?))

;; ---------- live closure ----------

(define (live-bundles)
  ;; Bundles enabled by any host (transitively — bundles can include
  ;; other bundles). Computed via fixed-point.
  (define seed
    (apply append (map host-bundles (hosts))))
  (let loop ([acc (list->set seed)])
    (define added
      (for*/fold ([new '()]) ([b (in-set acc)])
        (define f (in-repo "bundles" b "default.rkt"))
        (cond
          [(file-exists? f)
           (define paths (paths-referenced-in f))
           (define refs
             (filter-map
              (λ (p)
                (define m (regexp-match #rx"^myConfig\\.bundles\\.([^.]+)" p))
                (and m (cadr m)))
              paths))
           (append refs new)]
          [else new])))
    (define next (set-union acc (list->set added)))
    (cond [(equal? next acc) (sort (set->list acc) string<?)]
          [else (loop next)])))

(define (live-modules)
  ;; Modules enabled by any host directly OR via a live bundle.
  (define from-hosts (apply append (map host-modules (hosts))))
  (define from-bundles
    (apply append (map bundle-modules (live-bundles))))
  (sort (remove-duplicates (append from-hosts from-bundles)) string<?))

;; ---------- set helpers (avoid pulling in racket/set fully) ----------

(define (list->set xs) (let ([h (make-hash)]) (for ([x (in-list xs)]) (hash-set! h x #t)) h))
(define (set->list s) (hash-keys s))
(define (set-union a b) (let ([h (make-hash)])
                          (for ([k (in-hash-keys a)]) (hash-set! h k #t))
                          (for ([k (in-hash-keys b)]) (hash-set! h k #t))
                          h))
(define (in-set s) (in-hash-keys s))

;; ---------- the cmd ----------

(define (cmd-list args)
  (define flag (and (pair? args) (car args)))
  (cond
    [(equal? flag "--used")
     (define live-mods (live-modules))
     (define live-bs (live-bundles))
     (printf "Used bundles (~a):\n" (length live-bs))
     (for ([b (in-list live-bs)])
       (define h (sort
                  (filter (λ (host) (member b (host-bundles host)))
                          (hosts))
                  string<?))
       (printf "  ~a  (~a)\n" b
               (cond [(pair? h) (string-join h ", ")]
                     [else "via another bundle"])))
     (printf "\nUsed modules (~a):\n" (length live-mods))
     (for ([m (in-list live-mods)])
       (define direct-h (filter (λ (host) (member m (host-modules host)))
                                (hosts)))
       (define via-b (filter (λ (b) (member m (bundle-modules b)))
                             (live-bundles)))
       (define sources
         (append direct-h (map (λ (b) (string-append "via " b)) via-b)))
       (printf "  ~a  (~a)\n" m
               (cond [(pair? sources) (string-join sources ", ")]
                     [else "—"])))]
    [(equal? flag "--unused")
     (define live-mods (list->set (live-modules)))
     (define live-bs (list->set (live-bundles)))
     (define dead-bs (sort (filter (λ (b) (not (hash-has-key? live-bs b))) (bundles)) string<?))
     (define dead-mods (sort (filter (λ (m) (not (hash-has-key? live-mods m))) (modules)) string<?))
     (printf "Unreferenced bundles (~a):\n" (length dead-bs))
     (for ([b (in-list dead-bs)]) (printf "  ~a\n" b))
     (printf "\nUnreferenced modules (~a):\n" (length dead-mods))
     (for ([m (in-list dead-mods)]) (printf "  ~a\n" m))]
    [else
     (define bs (bundles))
     (define ms (modules))
     (printf "Bundles (~a):\n" (length bs))
     (for ([b (in-list bs)]) (printf "  myConfig.bundles.~a\n" b))
     (printf "\nModules (~a):\n" (length ms))
     (for ([m (in-list ms)]) (printf "  myConfig.modules.~a\n" m))]))

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
