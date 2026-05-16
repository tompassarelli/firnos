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
    (eprintf "fi scaffold: refusing to overwrite ~a\n" path)
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
  (define f (build-path dir "default.rkt"))
  (with-output-to-file f
    (λ ()
      (printf "#lang nisp~n~n(pkg ~a ~s)~n" name name)))
  (sh "git" "-C" ROOT "add" (path->string dir))
  (printf "Created modules/~a/default.rkt (git added)\n" name))

(define (handle-bundle-add leaf)
  ;; leaf is either "<name>" or "<name>+<m1>,<m2>,..."
  (define-values (name mods)
    (cond
      [(regexp-match #rx"^([^+]+)\\+(.+)$" leaf)
       => (λ (m) (values (cadr m) (regexp-split #rx"," (caddr m))))]
      [else (values leaf '())]))
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
          name (length mods)))

;; ---------- template scaffolds ----------

(define SCHEMA-PATH (build-path ROOT ".nisp-cache" "schema.json"))

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
  (define f (build-path dir "default.rkt"))
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
  (write-and-add f body)
  (cond
    [(null? top)
     (printf "  (no schema entries found for services.~a — schema cache stale or service not in nixpkgs?)\n" name)]
    [else
     (printf "  pre-filled ~a common options as commented stubs (from schema)\n" (length top))]))

(define (handle-template-submodule name)
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
  (write-and-add f body))

(define (handle-template-home name)
  (define dir (in-repo "modules" name))
  (define f (build-path dir "default.rkt"))
  (define body
    (string-append
     "#lang nisp\n\n"
     (format "(hm-module ~a ~s~n" name (format "~a (home-manager)" name))
     (format "  (set programs.~a~n" name)
     "    (att (enable #t))))\n"))
  (write-and-add f body))

(define (handle-template-host name)
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
  (write-and-add f body)
  (printf "Don't forget to add ~a to flake.rkt's nixosConfigurations.\n" name))

(define node-edges
  (list
   (walk-edge "module" "add" "<name>" #f
              handle-module-add
              "scaffold a minimal module (.rkt + .nix)")
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
              "scaffold a new host's configuration.rkt")))
