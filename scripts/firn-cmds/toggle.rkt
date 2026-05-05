#lang racket/base

(require racket/file
         (only-in nisp/edit
                  edit-set
                  edit-enable-add edit-enable-remove
                  find-set-form-positions)
         "util.rkt")

(provide cmd-enable cmd-disable cmd-status commands)

(define (find-name-kind name)
  ;; Return 'module, 'bundle, or #f
  (cond
    [(directory-exists? (in-repo "modules" name)) 'module]
    [(directory-exists? (in-repo "bundles" name)) 'bundle]
    [else #f]))

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
  ;; Three shapes to handle:
  ;;   (set 'X.enable BOOL)  → flip BOOL via edit-set
  ;;   (enable X …)          → add/remove via edit-enable-{add,remove}
  ;;   (set 'X (att (enable BOOL) ...))  → leave alone (composite, surface as no-op)
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

(define (cmd-enable args)
  (cond
    [(null? args) (eprintf "Usage: firn enable <module-or-bundle-name> [host]\n") (exit 1)]
    [else
     (define name (car args))
     (define host (if (>= (length args) 2) (cadr args) (current-hostname)))
     (define kind (find-name-kind name))
     (cond
       [(not kind) (eprintf "no module or bundle named ~a\n" name) (exit 1)]
       [else (toggle-host-config host kind name #t)])]))

(define (cmd-disable args)
  (cond
    [(null? args) (eprintf "Usage: firn disable <module-or-bundle-name> [host]\n") (exit 1)]
    [else
     (define name (car args))
     (define host (if (>= (length args) 2) (cadr args) (current-hostname)))
     (define kind (find-name-kind name))
     (cond
       [(not kind) (eprintf "no module or bundle named ~a\n" name) (exit 1)]
       [else (toggle-host-config host kind name #f)])]))

(define (cmd-status args)
  (define host (if (pair? args) (car args) (current-hostname)))
  (define text (read-host-config host))
  (printf "Enabled in ~a:\n" host)
  (define seen (make-hash))
  (for ([m (in-list (regexp-match* #px"'?myConfig\\.(?:modules|bundles)\\.[a-zA-Z0-9_-]+(?:\\.enable)?"
                                   text))])
    (define norm (regexp-replace* #rx"^'|\\.enable$" m ""))
    (hash-set! seen norm #t))
  (for ([k (in-list (sort (hash-keys seen) string<?))])
    (printf "  ~a\n" k)))

(define commands
  (list (cmd "enable" "<name> [host]"
             "toggle a module or bundle on in a host's config"
             cmd-enable)
        (cmd "disable" "<name> [host]"
             "toggle a module or bundle off in a host's config"
             cmd-disable)
        (cmd "status" "[host]"
             "list enabled modules and bundles for a host"
             cmd-status)))
