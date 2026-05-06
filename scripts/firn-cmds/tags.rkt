#lang racket/base

;; firn-cmds/tags — module/bundle tag index.
;;
;; Tags answer "which modules are gpu-required / gui-only / network /
;; proprietary / etc." — orthogonal facets that don't form coherent
;; bundles. Two sources, unioned per module:
;;
;;   1. Derived from bundle membership. A module appearing in
;;      bundles/gaming/default.rkt's (sub-modules …) gets the
;;      `bundle:gaming` tag. Cheap, no authoring needed; covers ~60-70%
;;      of the discovery problem (per the user's framing).
;;
;;   2. Explicit (tags …) clauses inside (module-file …). The DSL
;;      extension landed in nisp v0.11.0; the clause is recorded
;;      in source but never emitted into Nix. Read directly from the
;;      .rkt source by this command.
;;
;; Source-of-truth lives in the .rkt files; the index (jsonl by
;; default; sqlite or HTML on demand) is regenerated, never authored.
;;
;; Usage:
;;   firn tags                      tag universe with module counts
;;   firn tags <module>             tags for one module
;;   firn tags --filter <tag>       modules carrying a tag
;;   firn tags --index              write .nisp-cache/tags.jsonl
;;   firn tags --index --stdout     emit jsonl to stdout

(require racket/file
         racket/list
         racket/path
         racket/string
         racket/format
         json
         "util.rkt"
         "list.rkt") ; for bundle-modules

(provide cmd-tags commands)

(define INDEX-PATH (build-path ROOT ".nisp-cache" "tags.jsonl"))

;; ---------- explicit-tag extraction from .rkt ----------
;;
;; Walks a module's .rkt source(s) looking for (tags name1 name2 …)
;; clauses inside (module-file …). Returns a list of tag strings.
;; Tolerant — read errors, files without #lang nisp, files without a
;; tags clause all return '().

(define (extract-tags-from-datum datum)
  (cond
    [(not (pair? datum)) '()]
    [else
     (define head (and (symbol? (car datum)) (car datum)))
     (cond
       [(eq? head 'tags)
        (filter string?
                (for/list ([t (in-list (cdr datum))])
                  (cond
                    [(symbol? t) (symbol->string t)]
                    [(string? t) t]
                    [else #f])))]
       [else
        (apply append
               (for/list ([d (in-list datum)])
                 (extract-tags-from-datum d)))])]))

(define (count-char c s)
  (for/sum ([ch (in-string s)] #:when (char=? ch c)) 1))

(define (read-rkt-data rkt-path)
  ;; Read all top-level forms from a .rkt file (skipping #lang line),
  ;; return as a list of datums.
  (with-handlers ([exn:fail? (λ (_) '())])
    (define raw (file->string rkt-path))
    (define-values (lp rest)
      (let ([m (regexp-match-positions #rx"^#lang [^\n]*\n" raw)])
        (cond [m (values (substring raw 0 (cdr (car m)))
                         (substring raw (cdr (car m))))]
              [else (values "" raw)])))
    (define padded (string-append (make-string (count-char #\newline lp) #\newline) rest))
    (define port (open-input-string padded))
    (let loop ([acc '()])
      (define d (read port))
      (cond [(eof-object? d) (reverse acc)]
            [else (loop (cons d acc))]))))

(define (explicit-tags-for-module name)
  (define dir (in-repo "modules" name))
  (cond
    [(directory-exists? dir)
     (define files
       (for/list ([p (directory-list dir)]
                  #:when (regexp-match? #rx"\\.rkt$" (path->string p)))
         (build-path dir p)))
     (sort
      (remove-duplicates
       (apply append
              (for/list ([f (in-list files)])
                (define data (read-rkt-data f))
                (apply append (map extract-tags-from-datum data)))))
      string<?)]
    [else '()]))

;; ---------- derived tags from bundle membership ----------

(define (derived-tags-for-module name)
  ;; bundle:<name> for each bundle (NixOS or darwin variant) that
  ;; references this module via (sub-modules …) or an explicit
  ;; (set myConfig.modules.<X>.enable …).
  (define bundle-names
    (for/list ([b (in-list (bundles))]
               #:when (member name (bundle-modules b)))
      (string-append "bundle:" b)))
  (sort bundle-names string<?))

;; ---------- merged tag index ----------

(define (tags-for-module name)
  ;; Union of explicit + derived. Sorted, deduplicated.
  (sort
   (remove-duplicates
    (append (explicit-tags-for-module name)
            (derived-tags-for-module name)))
   string<?))

(define (build-index)
  ;; Returns hash: module-name → (list of tag strings)
  (define h (make-hash))
  (for ([m (in-list (modules))])
    (hash-set! h m (tags-for-module m)))
  h)

(define (tag-universe index)
  ;; Returns hash: tag → (list of module names carrying that tag)
  (define u (make-hash))
  (for* ([(mod tags) (in-hash index)]
         [t (in-list tags)])
    (hash-set! u t (cons mod (hash-ref u t '()))))
  u)

;; ---------- output ----------

(define (cmd-tags args)
  (define index (build-index))
  (cond
    ;; firn tags --index [--stdout]
    [(and (pair? args) (equal? (car args) "--index"))
     (define stdout? (and (pair? (cdr args)) (equal? (cadr args) "--stdout")))
     (define lines
       (for/list ([m (in-list (sort (hash-keys index) string<?))])
         (jsexpr->string
          (hash 'name m
                'tags (hash-ref index m '())))))
     (cond
       [stdout?
        (for ([line (in-list lines)]) (displayln line))]
       [else
        (make-directory* (path-only INDEX-PATH))
        (with-output-to-file INDEX-PATH #:exists 'replace
          (λ () (for ([line (in-list lines)]) (displayln line))))
        (printf "firn tags: wrote ~a entries → ~a\n"
                (length lines) (relative-to-repo INDEX-PATH))])]

    ;; firn tags --filter <tag>
    [(and (>= (length args) 2) (equal? (car args) "--filter"))
     (define tag (cadr args))
     (define mods (sort (filter (λ (m) (member tag (hash-ref index m '())))
                                (hash-keys index))
                        string<?))
     (cond
       [(null? mods) (printf "no modules tagged '~a'\n" tag)]
       [else
        (printf "modules tagged '~a' (~a):\n" tag (length mods))
        (for ([m (in-list mods)]) (printf "  ~a\n" m))])]

    ;; firn tags <module>
    [(and (pair? args) (member (car args) (modules)))
     (define m (car args))
     (define explicit (explicit-tags-for-module m))
     (define derived (derived-tags-for-module m))
     (printf "module: ~a\n" m)
     (cond
       [(pair? explicit)
        (printf "explicit tags: ~a\n" (string-join explicit ", "))]
       [else
        (printf "explicit tags: (none — add a (tags …) clause to modules/~a/default.rkt)\n" m)])
     (cond
       [(pair? derived)
        (printf "derived tags:  ~a\n" (string-join derived ", "))]
       [else
        (printf "derived tags:  (not in any bundle)\n")])]

    ;; firn tags <unknown-name>
    [(pair? args)
     (eprintf "firn tags: no module named '~a'\n" (car args))
     (eprintf "  use --filter <tag> to query by tag, or no args to list the tag universe.\n")
     (exit 1)]

    ;; firn tags — show tag universe
    [else
     (define universe (tag-universe index))
     (define keys (sort (hash-keys universe) string<?))
     (define explicit-tags (filter (λ (t) (not (string-prefix? t "bundle:"))) keys))
     (define bundle-tags  (filter (λ (t) (string-prefix? t "bundle:")) keys))

     (cond
       [(pair? explicit-tags)
        (printf "Explicit tags (~a):\n" (length explicit-tags))
        (for ([t (in-list explicit-tags)])
          (printf "  ~a  (~a)\n" (~a t #:min-width 18)
                  (length (hash-ref universe t))))]
       [else
        (printf "Explicit tags: (none authored — add (tags …) clauses to module .rkt files)\n")])

     (newline)
     (printf "Bundle-derived tags (~a):\n" (length bundle-tags))
     (for ([t (in-list bundle-tags)])
       (printf "  ~a  (~a)\n" (~a t #:min-width 18)
               (length (hash-ref universe t))))

     (newline)
     (define total-modules (hash-count index))
     (define tagged-modules
       (for/sum ([(_ tags) (in-hash index)] #:when (pair? tags)) 1))
     (printf "Coverage: ~a / ~a modules carry at least one tag.\n"
             tagged-modules total-modules)
     (newline)
     (printf "Run `firn tags <module>` to inspect one,\n")
     (printf "    `firn tags --filter <tag>` to query by tag,\n")
     (printf "    `firn tags --index` to write .nisp-cache/tags.jsonl.\n")]))

(define commands
  (list (cmd "tags" "[<module> | --filter <tag> | --index [--stdout]]"
             "module/bundle tag index (derived from bundle membership + explicit (tags …))"
             cmd-tags)))
