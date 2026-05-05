#lang racket/base

(require racket/path
         racket/file
         racket/list
         racket/string
         json
         "util.rkt")

(provide cmd-mod cmd-bundle cmd-scaffold commands)

(define (cmd-mod args)
  (cond
    [(null? args) (eprintf "Usage: firn mod <name>\n") (exit 1)]
    [else
     (define name (car args))
     (define dir (in-repo "modules" name))
     (when (directory-exists? dir)
       (eprintf "Module ~a already exists\n" name) (exit 1))
     (make-directory* dir)
     (define f (build-path dir "default.rkt"))
     (with-output-to-file f
       (λ ()
         (printf "#lang nisp~n~n(pkg ~a ~s)~n" name name)))
     (sh "git" "-C" ROOT "add" (path->string dir))
     (printf "Created modules/~a/default.rkt (git added)\n" name)]))

(define (cmd-bundle args)
  (cond
    [(< (length args) 2)
     (eprintf "Usage: firn bundle <name> <mod1> <mod2> ...\n") (exit 1)]
    [else
     (define name (car args))
     (define mods (cdr args))
     (define dir (in-repo "bundles" name))
     (when (directory-exists? dir)
       (eprintf "Bundle ~a already exists\n" name) (exit 1))
     (make-directory* dir)
     (define f (build-path dir "default.rkt"))
     (with-output-to-file f
       (λ ()
         (printf "#lang nisp~n~n(bundle-file ~a~n  (desc ~s)~n  (sub-modules ~a))~n"
                 name name (string-join mods " "))))
     (sh "git" "-C" ROOT "add" (path->string dir))
     (printf "Created bundles/~a/default.rkt with ~a modules (git added)\n"
             name (length mods))]))

(define (scaffold-write-file path contents)
  (when (file-exists? path)
    (eprintf "firn scaffold: refusing to overwrite ~a\n" path)
    (exit 1))
  (make-directory* (path-only path))
  (display-to-file contents path)
  (sh "git" "-C" ROOT "add" (path->string path))
  (printf "Created ~a (git added)\n" (relative-to-repo path)))

;; Schema-driven helpers ------------------------------------------------------

(define SCHEMA-PATH (build-path ROOT ".nisp-cache" "schema.json"))

(define (load-schema)
  (cond
    [(file-exists? SCHEMA-PATH)
     (call-with-input-file SCHEMA-PATH read-json)]
    [else #f]))

(define (schema-children-of prefix)
  ;; Return a list of {p, t, default?} entries for paths directly under `prefix`.
  (define schema (load-schema))
  (cond
    [(not schema) '()]
    [else
     (define depth (length (regexp-split #rx"\\." prefix)))
     (sort
      (for/list ([e (in-list schema)]
                 #:when (let ([p (hash-ref e 'p)])
                          (and (regexp-match? (regexp (string-append "^" (regexp-quote prefix) "\\.")) p)
                               (= (length (regexp-split #rx"\\." p)) (+ depth 1)))))
        e)
      string<? #:key (λ (e) (hash-ref e 'p)))]))

(define (describe-type t)
  (cond [(string? t) t] [else "?"]))

;; ----------------------------------------------------------------------------

(define (scaffold-service name)
  (define dir (in-repo "modules" name))
  (define f (build-path dir "default.rkt"))
  (define service-prefix (string-append "services." name))
  (define children (schema-children-of service-prefix))
  ;; Filter out submodule/internal options and the `enable` option itself
  ;; (we always emit it explicitly).
  (define interesting
    (filter (λ (e)
              (define p (hash-ref e 'p))
              (define t (hash-ref e 't "?"))
              (and (not (equal? p (string-append service-prefix ".enable")))
                   (not (member t '("submodule" "attrsOf" "lazyAttrsOf"
                                    "anything" "unspecified" "package")))))
            children))
  ;; Take up to 8 most common-looking options (alphabetically; could be
  ;; smarter with usage stats).
  (define top (take interesting (min 8 (length interesting))))
  (define stub-lines
    (cond
      [(null? top) '()]
      [else
       (cons "    ;; common options — uncomment to override:"
             (map (λ (e)
                    (define p (hash-ref e 'p))
                    (define short (regexp-replace (regexp (string-append "^" (regexp-quote service-prefix) "\\."))
                                                  p ""))
                    (define t (describe-type (hash-ref e 't "?")))
                    (format "    ;; (set ~a <value>)   ; ~a" p t))
                  top))]))
  (define body
    (string-append
     "#lang nisp\n\n"
     (format "(module-file modules ~a~n" name)
     (format "  (desc ~s)~n" (format "~a service" name))
     "  (config-body\n"
     (format "    (set services.~a.enable #t)" name)
     (cond [(null? stub-lines) ""]
           [else (string-append "\n" (string-join stub-lines "\n") "\n")])
     "))\n"))
  (scaffold-write-file f body)
  (cond
    [(null? top)
     (printf "  (no schema entries found for services.~a — schema cache stale or service not in nixpkgs?)\n" name)]
    [else
     (printf "  pre-filled ~a common options as commented stubs (from schema)\n" (length top))]))

(define (scaffold-submodule name)
  (define dir (in-repo "modules" name))
  (define f (build-path dir "default.rkt"))
  (define body
    (string-append
     "#lang nisp\n\n"
     (format "(module-file modules ~a~n" name)
     (format "  (desc ~s)~n" (format "~a configuration" name))
     "  (option-attrs\n"
     "    (extraConfig (mkopt #:type lib.types.lines\n"
     "                        #:default \"\"\n"
     "                        #:desc \"Extra config text.\")))\n"
     "  (config-body\n"
     (format "    (set environment.systemPackages (with-pkgs ~a))))~n" name)))
  (scaffold-write-file f body))

(define (scaffold-home name)
  (define dir (in-repo "modules" name))
  (define f (build-path dir "default.rkt"))
  (define body
    (string-append
     "#lang nisp\n\n"
     (format "(hm-module ~a ~s~n" name (format "~a (home-manager)" name))
     (format "  (set programs.~a~n" name)
     "    (att (enable #t))))\n"))
  (scaffold-write-file f body))

(define (scaffold-host name)
  (define dir (in-repo "hosts" name))
  (define f (build-path dir "configuration.rkt"))
  (define body
    (string-append
     "#lang nisp\n\n"
     "(host-file\n"
     "  (set myConfig.modules.system.stateVersion \"25.11\")\n"
     "  (set myConfig.modules.users.username \"you\")\n"
     "  (enable myConfig.modules.users\n"
     "          myConfig.modules.boot\n"
     "          myConfig.modules.networking)\n\n"
     "  ;; REQUIRED for the firn-build pipeline\n"
     "  (enable myConfig.bundles.racket\n"
     "          myConfig.bundles.terminal\n"
     "          myConfig.bundles.development))\n"))
  (scaffold-write-file f body)
  (printf "Don't forget to add ~a to flake.rkt's nixosConfigurations.\n" name))

(define (cmd-scaffold args)
  (cond
    [(< (length args) 2)
     (eprintf "Usage: firn scaffold <pattern> <name>\n")
     (eprintf "  patterns: service, submodule, home, host\n")
     (exit 1)]
    [else
     (define pattern (car args))
     (define name (cadr args))
     (case (string->symbol pattern)
       [(service)   (scaffold-service name)]
       [(submodule) (scaffold-submodule name)]
       [(home)      (scaffold-home name)]
       [(host)      (scaffold-host name)]
       [else
        (eprintf "firn scaffold: unknown pattern '~a'\n" pattern)
        (eprintf "  patterns: service, submodule, home, host\n")
        (exit 1)])]))

(define commands
  (list (cmd "mod" "<name>"
             "scaffold a minimal module (.rkt)"
             cmd-mod)
        (cmd "bundle" "<name> <mods...>"
             "scaffold a new bundle (.rkt)"
             cmd-bundle)
        (cmd "scaffold" "<pat> <name>"
             "template scaffold (service | submodule | home | host)"
             cmd-scaffold)))
