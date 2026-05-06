#lang racket/base

;; firn-cmds/util — shared helpers used by all command modules.

(require racket/string
         racket/path
         racket/file
         racket/system)

(provide ROOT
         in-repo
         sh sh-out find-exe
         list-dirs modules bundles hosts
         current-hostname host-config-rkt
         grep-files relative-to-repo
         paths-referenced-in
         (struct-out cmd))

;; ---------- command metadata ----------
;; Each firn-cmds/*.rkt module exports `commands`, a list of these.
;; firn.rkt aggregates them for both help-text generation and dispatch,
;; so the help can never go out of sync with what's actually wired up.
(struct cmd (name usage desc fn) #:transparent)

;; ---------- repo discovery ----------

(define (find-repo-root)
  (define home (or (getenv "HOME") "/home/tom"))
  (define default (build-path home "code" "nixos-config"))
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

;; ---------- option-path extraction from .rkt source ----------
;;
;; Walks a .rkt file and returns every option-path string referenced
;; via (set …), (enable …), or shortcut macros ((pkg X), (svc X),
;; (sub-modules a b c)). Bodies under home-of / hm-* / hm-module are
;; skipped — those reference home-manager paths that aren't in the
;; system schema.
;;
;; Handles both bare-identifier paths `(set boot.X val)` and quoted
;; paths `(set 'boot.X val)`. Tolerant — read errors return '().

(define HM-FORMS '(home-of home-of-bare hm hm-bare hm-module))

(define (count-char c s)
  (for/sum ([ch (in-string s)] #:when (char=? ch c)) 1))

(define (form-head-symbol datum)
  (and (pair? datum) (symbol? (car datum)) (car datum)))

(define (path-from-arg arg)
  (cond
    [(symbol? arg) (symbol->string arg)]
    [(and (pair? arg) (eq? (car arg) 'quote)
          (pair? (cdr arg)) (symbol? (cadr arg)))
     (symbol->string (cadr arg))]
    [(string? arg) arg]
    [else #f]))

(define (collect-paths-from datum acc)
  (cond
    [(not (pair? datum)) acc]
    [else
     (define head (form-head-symbol datum))
     (cond
       [(memq head HM-FORMS) acc]
       [(eq? head 'set)
        (define rest (cdr datum))
        (cond
          [(null? rest) acc]
          [else
           (define p (path-from-arg (car rest)))
           (define acc2 (if p (cons p acc) acc))
           (for/fold ([a acc2]) ([d (in-list (cdr rest))])
             (collect-paths-from d a))])]
       [(eq? head 'enable)
        (for/fold ([a acc]) ([arg (in-list (cdr datum))])
          (define p (path-from-arg arg))
          (if p (cons (string-append p ".enable") a) a))]
       [(eq? head 'pkg)
        (cons "environment.systemPackages" acc)]
       [(eq? head 'svc)
        (define args (cdr datum))
        (cond
          [(null? args) acc]
          [(and (= (length args) 3) (string? (cadr args)))
           (cons (cadr args) acc)]
          [else
           (define n (path-from-arg (car args)))
           (if n (cons (string-append "services." n ".enable") acc) acc)])]
       [(eq? head 'hm-module) acc]
       [(or (eq? head 'sub-modules) (eq? head 'sub-modules*))
        (for/fold ([a acc]) ([arg (in-list (cdr datum))])
          (define name
            (cond
              [(symbol? arg) (symbol->string arg)]
              [(and (pair? arg) (symbol? (car arg))) (symbol->string (car arg))]
              [else #f]))
          (if name (cons (string-append "myConfig.modules." name ".enable") a) a))]
       [else
        (for/fold ([a acc]) ([d (in-list datum)])
          (collect-paths-from d a))])]))

(define (paths-referenced-in rkt-path)
  (with-handlers ([exn:fail? (λ (_) '())])
    (define raw (file->string rkt-path))
    (define-values (lang-prefix rest)
      (let ([m (regexp-match-positions #rx"^#lang [^\n]*\n" raw)])
        (cond [m (values (substring raw 0 (cdr (car m)))
                         (substring raw (cdr (car m))))]
              [else (values "" raw)])))
    (define padded (string-append (make-string (count-char #\newline lang-prefix) #\newline)
                                  rest))
    (define port (open-input-string padded))
    (define out '())
    (let loop ()
      (define datum (read port))
      (unless (eof-object? datum)
        (set! out (collect-paths-from datum out))
        (loop)))
    (reverse out)))
