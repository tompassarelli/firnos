#lang racket/base

(require racket/path
         racket/file
         racket/list
         racket/string
         json
         "util.rkt")

(provide node-edges)

(define (write-and-add path contents)
  (when (file-exists? path)
    (eprintf "firn scaffold: refusing to overwrite ~a\n" path)
    (exit 1))
  (make-directory* (path-only path))
  (display-to-file contents path)
  (sh "git" "-C" ROOT "add" (path->string path))
  (printf "Created ~a (git added)\n" (relative-to-repo path)))

(define (handle-module-add name)
  (define dir (in-repo "modules" name))
  (when (directory-exists? dir)
    (eprintf "Module ~a already exists\n" name) (exit 1))
  (make-directory* dir)
  (define f (build-path dir "default.bnix"))
  (with-output-to-file f
    (λ ()
      (printf "#lang beagle/nix~n(ns modules.~a)~n~n" name)
      (printf "(module [config lib pkgs]~n")
      (printf "  {:options.myConfig.modules.~a.enable~n" name)
      (printf "     (lib/mkEnableOption ~s)~n~n" (format "Enable ~a" name))
      (printf "   :config~n")
      (printf "     (lib/mkIf config.myConfig.modules.~a.enable~n" name)
      (printf "       {:environment.systemPackages (with pkgs [~a])})})~n" name)))
  (sh "git" "-C" ROOT "add" (path->string dir))
  (printf "Created modules/~a/default.bnix (git added)\n" name))

(define (handle-bundle-add leaf)
  (define-values (name mods)
    (cond
      [(regexp-match #rx"^([^+]+)\\+(.+)$" leaf)
       => (λ (m) (values (cadr m) (regexp-split #rx"," (caddr m))))]
      [else (values leaf '())]))
  (define dir (in-repo "bundles" name))
  (when (directory-exists? dir)
    (eprintf "Bundle ~a already exists\n" name) (exit 1))
  (make-directory* dir)
  (define f (build-path dir "default.bnix"))
  (with-output-to-file f
    (λ ()
      (printf "#lang beagle/nix~n(ns bundles.~a)~n~n" name)
      (printf "(module [config lib pkgs]~n")
      (printf "  {:options.myConfig.bundles.~a.enable (lib/mkEnableOption ~s)~n" name (format "Enable ~a bundle" name))
      (printf "   :config~n")
      (printf "     (lib/mkIf config.myConfig.bundles.~a.enable~n" name)
      (printf "       {~a})})~n"
              (string-join
                (for/list ([m (in-list mods)])
                  (format ":myConfig.modules.~a.enable (lib/mkDefault true)" m))
                "~n        "))))
  (sh "git" "-C" ROOT "add" (path->string dir))
  (printf "Created bundles/~a/default.bnix with ~a modules (git added)\n"
          name (length mods)))

;; ---------- template scaffolds ----------

(define SCHEMA-PATH (build-path ROOT ".beagle-cache" "schema.json"))

(define (load-schema)
  (cond
    [(file-exists? SCHEMA-PATH) (call-with-input-file SCHEMA-PATH read-json)]
    [else #f]))

(define (schema-children-of prefix)
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

(define (handle-template-service name)
  (define dir (in-repo "modules" name))
  (define f (build-path dir "default.bnix"))
  (define service-prefix (string-append "services." name))
  (define children (schema-children-of service-prefix))
  (define interesting
    (filter (λ (e)
              (define p (hash-ref e 'p))
              (define t (hash-ref e 't "?"))
              (and (not (equal? p (string-append service-prefix ".enable")))
                   (not (member t '("submodule" "attrsOf" "lazyAttrsOf"
                                    "anything" "unspecified" "package")))))
            children))
  (define top (take interesting (min 8 (length interesting))))
  (define stub-lines
    (cond
      [(null? top) ""]
      [else
       (string-append
        "        ;; common options — uncomment to override:\n"
        (string-join
          (map (λ (e)
                 (define p (hash-ref e 'p))
                 (define t (describe-type (hash-ref e 't "?")))
                 (format "        ;; :~a <value>   ; ~a" p t))
               top)
          "\n"))]))
  (define body
    (string-append
     "#lang beagle/nix\n"
     (format "(ns modules.~a)\n\n" name)
     "(module [config lib pkgs]\n"
     (format "  {:options.myConfig.modules.~a.enable (lib/mkEnableOption ~s)\n" name (format "~a service" name))
     "   :config\n"
     (format "     (lib/mkIf config.myConfig.modules.~a.enable\n" name)
     (format "       {:services.~a.enable true~a})})\n"
             name
             (if (string=? stub-lines "") "" (string-append "\n" stub-lines)))))
  (write-and-add f body)
  (cond
    [(null? top)
     (printf "  (no schema entries found for services.~a — schema cache stale or service not in nixpkgs?)\n" name)]
    [else
     (printf "  pre-filled ~a common options as commented stubs (from schema)\n" (length top))]))

(define (handle-template-submodule name)
  (define dir (in-repo "modules" name))
  (define f (build-path dir "default.bnix"))
  (define body
    (string-append
     "#lang beagle/nix\n"
     (format "(ns modules.~a)\n\n" name)
     "(module [config lib pkgs]\n"
     (format "  {:options.myConfig.modules.~a~n" name)
     "   {:enable (lib/mkEnableOption \"~a configuration\")\n"
     "    :extraConfig (lib/mkOption {:type lib/types.lines\n"
     "                                :default \"\"\n"
     "                                :description \"Extra config text.\"})}\n"
     "   :config\n"
     (format "     (lib/mkIf config.myConfig.modules.~a.enable\n" name)
     (format "       {:environment.systemPackages (with pkgs [~a])})})~n" name)))
  (write-and-add f body))

(define (handle-template-home name)
  (define dir (in-repo "modules" name))
  (define f (build-path dir "default.bnix"))
  (define body
    (string-append
     "#lang beagle/nix\n"
     (format "(ns modules.~a)\n\n" name)
     "(module [config lib pkgs]\n"
     (format "  {:options.myConfig.modules.~a.enable (lib/mkEnableOption ~s)\n" name (format "~a (home-manager)" name))
     "   :config\n"
     (format "     (lib/mkIf config.myConfig.modules.~a.enable\n" name)
     "       {:home-manager.users\n"
     "        {\"${config.myConfig.modules.users.username}\"\n"
     (format "         {:programs.~a.enable true}}})})~n" name)))
  (write-and-add f body))

(define (handle-template-host name)
  (define dir (in-repo "hosts" name))
  (define f (build-path dir "configuration.bnix"))
  (define body
    (string-append
     "#lang beagle/nix\n"
     (format "(ns hosts.~a)\n\n" name)
     "(module [config lib pkgs]\n"
     "  {:myConfig.modules.system.stateVersion \"25.11\"\n"
     "   :myConfig.modules.users.username \"you\"\n"
     "   :myConfig.modules.users.enable true\n"
     "   :myConfig.modules.boot.enable true\n"
     "   :myConfig.modules.networking.enable true\n"
     "   ;; REQUIRED for the firn-build pipeline\n"
     "   :myConfig.bundles.racket.enable true\n"
     "   :myConfig.bundles.terminal.enable true\n"
     "   :myConfig.bundles.development.enable true})\n"))
  (write-and-add f body)
  (printf "Don't forget to add ~a to flake.bnix's nixosConfigurations.\n" name))

(define node-edges
  (list
   (walk-edge "module" "add" "<name>" #f
              handle-module-add
              "scaffold a minimal module (.bnix + .nix)")
   (walk-edge "bundle" "add" "<name>[+<mod1>,<mod2>,...]" #f
              handle-bundle-add
              "scaffold a new bundle; optional +sub-module list")
   (walk-edge "template" "service"   "<name>" #f handle-template-service
              "scaffold a NixOS service-wrapping module from schema")
   (walk-edge "template" "submodule" "<name>" #f handle-template-submodule
              "scaffold a module with an option-attrs submodule shape")
   (walk-edge "template" "home"      "<name>" #f handle-template-home
              "scaffold a home-manager-only module")
   (walk-edge "template" "host"      "<name>" #f handle-template-host
              "scaffold a new host's configuration.bnix")))
