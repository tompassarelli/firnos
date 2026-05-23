#lang racket/base

(require racket/file
         racket/string
         "util.rkt")

;; Text-based edits against beagle/nix .bnix host configurations.
;;
;; The canonical shape in a host file is a map literal:
;;   (module [config lib pkgs]
;;     {:myConfig.modules.X.enable true
;;      :myConfig.bundles.Y.enable false ...})
;;
;; edit-set finds `:PATH ENABLE-VALUE` and flips it; edit-enable-add
;; appends a new pair; edit-enable-remove drops the pair entirely.

(define (escape-key-rx path)
  (regexp-quote path))

;; Match :PATH followed by `true` or `false` (whitespace-tolerant).
;; Returns the regexp object.
(define (enable-pair-rx path)
  (pregexp (format ":~a\\s+(true|false)\\b" (escape-key-rx path))))

(define (find-set-form-positions text path)
  ;; Match enable-path with `.enable` suffix already in path.
  (regexp-match-positions (enable-pair-rx path) text))

(define (edit-set text path new-val)
  ;; path is e.g. "myConfig.modules.foo.enable"; new-val is "true" or "false"
  ;; (the legacy code passes "#t"/"#f" — translate).
  (define val (cond [(member new-val '("#t" "true")) "true"]
                    [(member new-val '("#f" "false")) "false"]
                    [else new-val]))
  (regexp-replace (enable-pair-rx path) text
                  (format ":~a ~a" path val)))

;; edit-enable-add takes a path WITHOUT .enable and adds `:PATH.enable true`.
;; Strategy: find the innermost {…} map literal that follows `(module [...]`
;; and insert before its closing `}`. This is heuristic but works for the
;; conventional host shape.
(define (edit-enable-add text full-path)
  (define enable-path (string-append full-path ".enable"))
  ;; Already there? Just set to true.
  (cond
    [(find-set-form-positions text enable-path)
     (edit-set text enable-path "true")]
    [else
     ;; Locate the last `}` and insert `:PATH.enable true\n   ` before it.
     ;; (Crude — assumes the host map is the last form. Works for typical
     ;;  hosts/<name>/configuration.bnix written by the scaffold.)
     (define m (regexp-match-positions #rx"\\}[\\s]*\\)*[\\s]*$" text))
     (cond
       [m
        (define insert-pos (caar m))
        (string-append
          (substring text 0 insert-pos)
          (format "\n   :~a true~a" enable-path
                  (substring text insert-pos)))]
       [else text])]))

(define (edit-enable-remove text full-path)
  (define enable-path (string-append full-path ".enable"))
  ;; Remove `:PATH.enable VALUE` and any trailing newline+whitespace
  (define rx (pregexp (format "[\\s]*:~a\\s+(true|false)\\b" (escape-key-rx enable-path))))
  (regexp-replace rx text ""))

(provide node-edges)

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
  (define enable-path (string-append full-path ".enable"))
  ;; Three shapes:
  ;;   (set 'X.enable BOOL)  → flip via edit-set
  ;;   (enable X …)          → add/remove via edit-enable-{add,remove}
  ;;   (set 'X (att (enable BOOL) ...)) → composite, surface as no-op
  (define existing-set (find-set-form-positions text enable-path))
  (define new-text
    (cond
      [(pair? existing-set)
       (edit-set text enable-path (if on? "#t" "#f"))]
      [on?  (edit-enable-add    text full-path)]
      [else (edit-enable-remove text full-path)]))
  (cond
    [(equal? new-text text)
     (printf "~a is already ~a (or not toggleable cleanly).\n"
             full-path (if on? "enabled" "disabled"))]
    [else
     (write-host-config host new-text)
     (printf "~a => ~a in hosts/~a/configuration.rkt\n"
             full-path (if on? "enabled" "disabled") host)]))

(define (toggle-handler kind on?)
  (λ (name)
    (define host (current-hostname))
    (define existing (find-name-kind name))
    (cond
      [(not existing) (eprintf "no module or bundle named ~a\n" name) (exit 1)]
      [(not (eq? existing kind))
       (eprintf "~a is a ~a, not a ~a — use `firn ~a ~a ~a`\n"
                name existing kind existing (if on? "enable" "disable") name)
       (exit 1)]
      [else (toggle-host-config host kind name on?)])))

;; ---------- status ----------
;;
;; Walks the host's (host-file …) body as datums and records every
;; <path>.enable = #t/#f toggle whether the source form is
;; `(enable A B C)`, `(set X.enable #t/#f)`, or
;; `(set X (att (enable BOOL) (sub.enable BOOL) ...))`.

(define (path-from-arg arg)
  (cond
    [(symbol? arg) (symbol->string arg)]
    [(and (pair? arg) (eq? (car arg) 'quote)
          (pair? (cdr arg)) (symbol? (cadr arg)))
     (symbol->string (cadr arg))]
    [(string? arg) arg]
    [else #f]))

(define (literal-bool? v) (or (eq? v #t) (eq? v #f)))

(define (read-host-forms host)
  (define raw (file->string (host-config-rkt host)))
  (define stripped (regexp-replace #rx"^#lang [^\n]*\n" raw ""))
  (with-handlers ([exn:fail? (λ (_) '())])
    (define port (open-input-string stripped))
    (define top (read port))
    (cond
      [(and (pair? top) (eq? (car top) 'host-file)) (cdr top)]
      [else '()])))

(define (collect-att-clauses! tgl path clauses)
  (for ([clause (in-list clauses)])
    (when (and (pair? clause) (= (length clause) 2))
      (define sub (path-from-arg (car clause)))
      (define sv (cadr clause))
      (when (and sub (literal-bool? sv))
        (cond
          [(string=? sub "enable")
           (hash-set! tgl (string-append path ".enable") sv)]
          [(regexp-match? #rx"\\.enable$" sub)
           (hash-set! tgl (string-append path "." sub) sv)])))))

(define (collect-toggles forms)
  (define tgl (make-hash))
  (for ([form (in-list forms)])
    (when (pair? form)
      (case (car form)
        [(enable)
         (for ([a (in-list (cdr form))])
           (define p (path-from-arg a))
           (when p (hash-set! tgl (string-append p ".enable") #t)))]
        [(set)
         (define args (cdr form))
         (when (= (length args) 2)
           (define path (path-from-arg (car args)))
           (define val (cadr args))
           (cond
             [(and path (literal-bool? val)
                   (regexp-match? #rx"\\.enable$" path))
              (hash-set! tgl path val)]
             [(and path (pair? val) (eq? (car val) 'att))
              (collect-att-clauses! tgl path (cdr val))]))])))
  tgl)

(define (strip-enable-suffix s)
  (regexp-replace #rx"\\.enable$" s ""))

(define (mark v)
  (case v
    [(#t) "✓"]
    [(#f) "✗"]
    [else "?"]))

(define (filter-by-prefix toggles prefix)
  ;; Return a sorted list of (path . value) entries whose key starts with prefix.
  (sort
   (for/list ([(k v) (in-hash toggles)]
              #:when (string-prefix? k prefix))
     (cons k v))
   string<? #:key car))

(define (handle-module-status leaf)
  (cond
    [(equal? leaf "all") (print-flat-status (current-hostname) 'modules)]
    [else
     (eprintf "firn module status: expected 'all', got '~a'\n" leaf)
     (exit 1)]))

(define (handle-bundle-status leaf)
  (cond
    [(equal? leaf "all") (print-bundle-status (current-hostname) #f)]
    [else (print-bundle-status (current-hostname) leaf)]))

(define (handle-host-status leaf)
  (define host (if (or (equal? leaf "current") (equal? leaf "all"))
                   (current-hostname)
                   leaf))
  (print-flat-status host 'both))

(define (print-flat-status host kind-filter)
  (define forms (read-host-forms host))
  (define toggles (collect-toggles forms))
  (define want-module? (or (eq? kind-filter 'modules) (eq? kind-filter 'both)))
  (define want-bundle? (or (eq? kind-filter 'bundles) (eq? kind-filter 'both)))
  (printf "Enabled in ~a:\n" host)
  (define enabled-keys
    (sort (for/list ([(k v) (in-hash toggles)] #:when (eq? v #t)) k) string<?))
  (for ([k (in-list enabled-keys)])
    (when (or (and want-module? (regexp-match? #rx"^myConfig\\.modules\\." k))
              (and want-bundle? (regexp-match? #rx"^myConfig\\.bundles\\." k)))
      (printf "  ~a\n" (strip-enable-suffix k))))
  (define disabled-keys
    (sort (for/list ([(k v) (in-hash toggles)] #:when (eq? v #f)) k) string<?))
  (define disabled-filtered
    (filter (λ (k)
              (or (and want-module? (regexp-match? #rx"^myConfig\\.modules\\." k))
                  (and want-bundle? (regexp-match? #rx"^myConfig\\.bundles\\." k))))
            disabled-keys))
  (unless (null? disabled-filtered)
    (printf "\nExplicitly disabled in ~a:\n" host)
    (for ([k (in-list disabled-filtered)])
      (printf "  ~a\n" (strip-enable-suffix k)))))

(define (bundle-name-from path-str)
  (define m (regexp-match #px"^myConfig\\.bundles\\.([^.]+)" path-str))
  (and m (cadr m)))

(define (host-referenced-bundles forms)
  (define out (make-hash))
  (for ([form (in-list forms)])
    (when (pair? form)
      (case (car form)
        [(enable)
         (for ([a (in-list (cdr form))])
           (define p (path-from-arg a))
           (define n (and p (bundle-name-from p)))
           (when n (hash-set! out n #t)))]
        [(set)
         (define args (cdr form))
         (when (pair? args)
           (define p (path-from-arg (car args)))
           (define n (and p (bundle-name-from p)))
           (when n (hash-set! out n #t)))])))
  (sort (hash-keys out) string<?))

(define (print-bundle-status host one-bundle)
  (define forms (read-host-forms host))
  (define toggles (collect-toggles forms))
  (define names
    (cond
      [one-bundle (list one-bundle)]
      [else (host-referenced-bundles forms)]))
  (printf "Bundles in ~a~a:\n"
          host
          (if one-bundle (format " (filtered to ~a)" one-bundle) ""))
  (for ([name (in-list names)])
    (define base (string-append "myConfig.bundles." name))
    (define top-state (hash-ref toggles (string-append base ".enable") 'unknown))
    (printf "\n~a ~a\n" (mark top-state) name)
    (define sub-keys
      (sort
       (for/list ([k (in-hash-keys toggles)]
                  #:when (and (string-prefix? k (string-append base "."))
                              (not (string=? k (string-append base ".enable")))))
         k) string<?))
    (for ([k (in-list sub-keys)])
      (define s (hash-ref toggles k))
      (define short (substring k (+ (string-length base) 1)))
      (printf "    ~a ~a\n" (mark s) (strip-enable-suffix short)))))

;; ---------- registration ----------

(define node-edges
  (list
   (walk-edge "module" "enable"  "<name>" #f
              (toggle-handler 'module #t)
              "enable a module on the default host")
   (walk-edge "module" "disable" "<name>" #f
              (toggle-handler 'module #f)
              "disable a module on the default host")
   (walk-edge "module" "status"  "all"    'all
              handle-module-status
              "list enabled modules on the default host")
   (walk-edge "bundle" "enable"  "<name>" #f
              (toggle-handler 'bundle #t)
              "enable a bundle on the default host")
   (walk-edge "bundle" "disable" "<name>" #f
              (toggle-handler 'bundle #f)
              "disable a bundle on the default host")
   (walk-edge "bundle" "status"  "<name>|all" 'all
              handle-bundle-status
              "per-bundle sub-toggle tree (all bundles, or one)")
   (walk-edge "host"   "status"  "<host>" 'current-host
              handle-host-status
              "all enabled modules and bundles for a host")))
