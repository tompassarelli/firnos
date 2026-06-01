#lang racket/base

;; firn-cmds/tags — module tag index.
;;
;; Tags answer "which modules are gpu-required / gui-only / network /
;; proprietary / etc." — orthogonal facets that compose into hosts via
;; enabled-tags.bnix. Tags are sourced from the module's own .bnix:
;;
;;   :tags         [terminal cli-tools …]    — module belongs to these
;;                                             tags by default
;;   :tags-opt-in  [browsers experimental …] — module can be added under
;;                                             these tags via +<mod>
;;
;; Source-of-truth lives in the .bnix files; the index (jsonl by
;; default; to stdout on demand) is regenerated, never authored.
;;
;; Usage:
;;   firn tag list                    tag universe with module counts
;;   firn tag show <module>           tags for one module
;;   firn tag filter <tag>            modules carrying a tag
;;   firn tag index                   write .beagle-cache/tags.jsonl
;;   firn tag index stdout            emit jsonl to stdout

(require racket/file
         racket/list
         racket/path
         racket/string
         racket/format
         json
         "util.rkt"
         "tag-resolve.rkt")

(provide node-edges)

(define INDEX-PATH (build-path ROOT ".beagle-cache" "tags.jsonl"))

;; ---------- helpers ----------

(define (tag-record-for name)
  ;; Returns (list of (tag . kind)) where kind ∈ '(default opt-in).
  (define mt (extract-module-tags name))
  (append
   (for/list ([t (in-list (module-tags-tags mt))]) (cons t 'default))
   (for/list ([t (in-list (module-tags-opt-in mt))]) (cons t 'opt-in))))

(define (build-index)
  ;; Returns hash: module-name → (list of (cons tag-string kind-sym))
  (define h (make-hash))
  (for ([m (in-list (modules))])
    (hash-set! h m (tag-record-for m)))
  h)

(define (tag-universe index)
  ;; Returns hash: tag → (list of (cons modname kind))
  (define u (make-hash))
  (for* ([(mod records) (in-hash index)]
         [r (in-list records)])
    (define t (car r))
    (hash-set! u t (cons (cons mod (cdr r)) (hash-ref u t '()))))
  u)

;; ---------- handlers ----------

(define (handle-tag-list _leaf)
  (define index (build-index))
  (define universe (tag-universe index))
  (define keys (sort (hash-keys universe) string<?))
  (cond
    [(null? keys)
     (printf "No tags found. Add :tags / :tags-opt-in clauses to modules' default.bnix.\n")]
    [else
     (printf "Tags (~a):\n" (length keys))
     (for ([t (in-list keys)])
       (define mods (hash-ref universe t))
       (define defaults (filter (λ (p) (eq? (cdr p) 'default)) mods))
       (define opt-ins  (filter (λ (p) (eq? (cdr p) 'opt-in)) mods))
       (printf "  ~a  (~a default~a)\n"
               (~a t #:min-width 18)
               (length defaults)
               (cond [(null? opt-ins) ""]
                     [else (format ", ~a opt-in" (length opt-ins))])))])
  (newline)
  (define total-modules (hash-count index))
  (define tagged-modules
    (for/sum ([(_ records) (in-hash index)] #:when (pair? records)) 1))
  (printf "Coverage: ~a / ~a modules carry at least one tag.\n"
          tagged-modules total-modules))

(define (handle-tag-show m)
  (cond
    [(not (member m (modules)))
     (eprintf "firn tag show: no module named '~a'\n" m) (exit 1)]
    [else
     (define mt (extract-module-tags m))
     (define defaults (module-tags-tags mt))
     (define opt-in (module-tags-opt-in mt))
     (printf "module: ~a\n" m)
     (cond
       [(pair? defaults)
        (printf ":tags         ~a\n" (string-join defaults ", "))]
       [else
        (printf ":tags         (none — add a :tags clause to modules/~a/default.bnix)\n" m)])
     (cond
       [(pair? opt-in)
        (printf ":tags-opt-in  ~a\n" (string-join opt-in ", "))]
       [else
        (printf ":tags-opt-in  (none)\n")])]))

(define (handle-tag-filter tag)
  (define index (build-index))
  (define mods (sort (filter (λ (m)
                               (findf (λ (r) (equal? (car r) tag))
                                      (hash-ref index m '())))
                             (hash-keys index))
                     string<?))
  (cond
    [(null? mods) (printf "no modules tagged '~a'\n" tag)]
    [else
     (printf "modules tagged '~a' (~a):\n" tag (length mods))
     (for ([m (in-list mods)])
       (define records (hash-ref index m '()))
       (define kind (cdr (findf (λ (r) (equal? (car r) tag)) records)))
       (printf "  ~a  (~a)\n" m kind))]))

(define (handle-tag-index leaf)
  (define stdout? (equal? leaf "stdout"))
  (define index (build-index))
  (define lines
    (for/list ([m (in-list (sort (hash-keys index) string<?))])
      (define records (hash-ref index m '()))
      (define defaults
        (for/list ([r (in-list records)] #:when (eq? (cdr r) 'default))
          (car r)))
      (define opt-in
        (for/list ([r (in-list records)] #:when (eq? (cdr r) 'opt-in))
          (car r)))
      (jsexpr->string
       (hash 'name m
             'tags defaults
             'tags_opt_in opt-in))))
  (cond
    [stdout?
     (for ([line (in-list lines)]) (displayln line))]
    [else
     (make-directory* (path-only INDEX-PATH))
     (with-output-to-file INDEX-PATH #:exists 'replace
       (λ () (for ([line (in-list lines)]) (displayln line))))
     (printf "firn tag index: wrote ~a entries → ~a\n"
             (length lines) (relative-to-repo INDEX-PATH))]))

(define node-edges
  (list
   (walk-edge "tag" "list"   "all"        'all    handle-tag-list
              "tag universe (sourced from modules' :tags / :tags-opt-in)")
   (walk-edge "tag" "show"   "<module>"   #f      handle-tag-show
              "show a module's :tags and :tags-opt-in")
   (walk-edge "tag" "filter" "<tag>"      #f      handle-tag-filter
              "list modules carrying a tag")
   (walk-edge "tag" "index"  "repo|stdout" 'repo  handle-tag-index
              "write .beagle-cache/tags.jsonl (or 'stdout' to pipe)")))
