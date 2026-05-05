#lang racket/base

(require racket/path
         racket/file
         "util.rkt")

(provide cmd-mod cmd-bundle cmd-scaffold)

(require racket/string)

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

(define (scaffold-service name)
  (define dir (in-repo "modules" name))
  (define f (build-path dir "default.rkt"))
  (define body
    (string-append
     "#lang nisp\n\n"
     (format "(module-file modules ~a~n" name)
     (format "  (desc ~s)~n" (format "~a service" name))
     "  (config-body\n"
     (format "    (set environment.systemPackages (with-pkgs ~a))~n" name)
     (format "    (set services.~a.enable #t)))~n" name)))
  (scaffold-write-file f body))

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
