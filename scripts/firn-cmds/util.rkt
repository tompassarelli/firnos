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
