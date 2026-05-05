#!/usr/bin/env racket
#lang racket/base

;; firn — FirnOS config management CLI.
;;
;; Single Racket program: same Racket as the nisp #lang itself, the validator,
;; and the build pipeline. Compile to a standalone binary with `raco exe`.

(require racket/cmdline
         racket/string
         racket/list
         racket/system
         racket/file
         racket/path
         racket/format
         racket/runtime-path)

;; ---------- repo discovery ----------

(define (find-repo-root)
  (define home (or (getenv "HOME") "/home/tom"))
  (define default (build-path home "code" "nixos-config"))
  ;; Try `git rev-parse --show-toplevel` from the cwd; fall back to default.
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
  ;; resolve PATH lookup so `sudo` etc. work
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

;; Find files (recursive) under a directory matching a regex. Returns paths
;; relative to ROOT.
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

;; ---------- command: rebuild ----------

(define (cmd-rebuild args)
  (define host (and (pair? args) (car args)))
  (define has-nh? (and (find-executable-path "nh") #t))
  (define rc
    (cond
      [has-nh?
       ;; nh os switch <flake-path> [-H <host>]
       ;; nh handles sudo and gives us progress UI + generation diff.
       (apply system* (find-executable-path "nh")
              (append (list "os" "switch" ROOT)
                      (if host (list "-H" host) '())))]
      [else
       (define flake-target (if host (string-append ROOT "#" host) ROOT))
       (sh "sudo" "nixos-rebuild" "switch" "--flake" flake-target)]))
  (cond
    [(not rc) (printf "rebuild failed.\n") (exit 1)]
    [else
     (define gens (sh-out "nixos-rebuild" "list-generations"))
     (define cur-line
       (for/or ([line (in-list (string-split gens "\n"))]
                #:when (regexp-match? #rx"current" line))
         line))
     (when cur-line
       (define gen (car (string-split (string-trim cur-line))))
       (when (regexp-match? #rx"^[0-9]+$" gen)
         (sh "git" "-C" ROOT "tag" "-f" (string-append "gen-" gen) "HEAD")
         (printf "Tagged: gen-~a\n" gen)))]))

;; ---------- command: list ----------

(define (cmd-list args)
  (define flag (and (pair? args) (car args)))
  (cond
    [(equal? flag "--used")
     (printf "Used bundles:\n")
     (for ([b (in-list (bundles))])
       (define hits (grep-files "hosts" (regexp (format "myConfig\\.bundles\\.~a\\.enable" b))))
       (define host-names (sort (remove-duplicates (map host-of-path hits)) string<?))
       (when (pair? host-names)
         (printf "  ~a  (~a)\n" b (string-join host-names ", "))))
     (printf "\nUsed modules:\n")
     (for ([m (in-list (modules))])
       (define h (sort (remove-duplicates
                        (map host-of-path
                             (grep-files "hosts" (regexp (format "myConfig\\.modules\\.~a\\.enable" m)))))
                       string<?))
       (define b (sort (remove-duplicates
                        (map bundle-of-path
                             (grep-files "bundles" (regexp (format "myConfig\\.modules\\.~a\\.enable" m)))))
                       string<?))
       (define sources (append h (map (λ (x) (string-append "via " x)) b)))
       (when (pair? sources)
         (printf "  ~a  (~a)\n" m (string-join sources ", "))))]
    [(equal? flag "--unused")
     (printf "Unused bundles:\n")
     (for ([b (in-list (bundles))])
       (define re (regexp (format "myConfig\\.bundles\\.~a\\.enable" b)))
       (when (and (null? (grep-files "hosts" re))
                  (null? (grep-files "bundles" re)))
         (printf "  ~a\n" b)))
     (printf "\nUnused modules (not in any host or bundle):\n")
     (for ([m (in-list (modules))])
       (define re (regexp (format "myConfig\\.modules\\.~a\\.enable" m)))
       (when (and (null? (grep-files "hosts" re))
                  (null? (grep-files "bundles" re)))
         (printf "  ~a\n" m)))]
    [else
     (define bs (bundles))
     (define ms (modules))
     (printf "Bundles (~a):\n" (length bs))
     (for ([b (in-list bs)]) (printf "  myConfig.bundles.~a\n" b))
     (printf "\nModules (~a):\n" (length ms))
     (for ([m (in-list ms)]) (printf "  myConfig.modules.~a\n" m))]))

(define (host-of-path p)
  (define m (regexp-match #rx"/hosts/([^/]+)/" p))
  (and m (cadr m)))

(define (bundle-of-path p)
  (define m (regexp-match #rx"/bundles/([^/]+)/" p))
  (and m (cadr m)))

;; ---------- command: refs ----------

(define (cmd-refs args)
  (cond
    [(null? args) (eprintf "Usage: firn refs <name>\n") (exit 1)]
    [else
     (define name (car args))
     (printf "Bundles:\n")
     (for ([b (in-list (sort (remove-duplicates
                              (append
                               (map bundle-of-path
                                    (grep-files "bundles"
                                                (regexp (format "myConfig\\.modules\\.~a\\.enable" name))))
                               (map bundle-of-path
                                    (grep-files "bundles"
                                                (regexp (format "myConfig\\.bundles\\.~a\\.enable" name))))))
                             string<?))])
       (when b (printf "  ~a\n" b)))
     (printf "\nHosts:\n")
     (for ([h (in-list (sort (remove-duplicates
                              (append
                               (map host-of-path
                                    (grep-files "hosts"
                                                (regexp (format "myConfig\\.modules\\.~a\\.enable" name))))
                               (map host-of-path
                                    (grep-files "hosts"
                                                (regexp (format "myConfig\\.bundles\\.~a\\.enable" name))))))
                             string<?))])
       (when h (printf "  ~a\n" h)))]))

;; ---------- command: mod (scaffold) ----------

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

;; ---------- command: bundle (scaffold) ----------

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

;; ---------- command: secret ----------

(define (cmd-secret args)
  (define subcmd (and (pair? args) (car args)))
  (define rest (if (pair? args) (cdr args) '()))
  (cond
    [(not subcmd)
     (eprintf "Usage: firn secret <name|list|show <name>>\n") (exit 1)]
    [(equal? subcmd "list")
     (define sd (in-repo "secrets"))
     (when (directory-exists? sd)
       (for ([p (in-list (directory-list sd))]
             #:when (regexp-match? #rx"\\.yaml$" (path->string p)))
         (printf "~a\n" (regexp-replace #rx"\\.yaml$" (path->string p) ""))))]
    [(equal? subcmd "show")
     (cond
       [(null? rest) (eprintf "Usage: firn secret show <name>\n") (exit 1)]
       [else
        (define f (in-repo "secrets" (string-append (car rest) ".yaml")))
        (cond
          [(file-exists? f) (sh "sops" "-d" (path->string f))]
          [else (eprintf "No secret file: secrets/~a.yaml\n" (car rest)) (exit 1)])])]
    [else
     ;; treat subcmd as name to edit
     (define f (in-repo "secrets" (string-append subcmd ".yaml")))
     (sh "sops" (path->string f))
     (when (file-exists? f)
       (sh "git" "-C" ROOT "add" (path->string f))
       (printf "secrets/~a.yaml (git added)\n" subcmd))]))

;; ---------- command: gen ----------

(define (cmd-gen _args)
  (define gens (sh-out "nixos-rebuild" "list-generations"))
  (define cur-line
    (for/or ([line (in-list (string-split gens "\n"))]
             #:when (regexp-match? #rx"current" line))
      line))
  (cond
    [cur-line
     (define cur (car (string-split (string-trim cur-line))))
     (printf "current: ~a\n" cur)
     (when (regexp-match? #rx"^[0-9]+$" cur)
       (printf "next:    ~a\n" (+ 1 (string->number cur))))]
    [else (printf "(no generation info)\n")]))

;; ---------- command: enable / disable ----------
;;
;; Toggle a module or bundle in the current host's configuration.rkt.
;;
;; Strategy: textual edit, syntax-aware enough to find and modify the right
;; (enable …) / (set 'myConfig.X.enable …) form, or append a new line near
;; the end if no existing reference is present.

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
  ;; Look for existing references in the text. We handle three shapes:
  ;;   (enable PATH ...) where PATH is full-path
  ;;   (set 'PATH.enable BOOL)
  ;;   (set 'PATH (att (enable BOOL) ...)) — leave alone, surface as match
  (define new-text
    (cond
      [on? (turn-on text full-path)]
      [else (turn-off text full-path)]))
  (cond
    [(equal? new-text text)
     (printf "~a is already ~a (or not toggleable cleanly).\n"
             full-path (if on? "enabled" "disabled"))]
    [else
     (write-host-config host new-text)
     (printf "~a => ~a in hosts/~a/configuration.rkt\n"
             full-path (if on? "enabled" "disabled") host)]))

(define (turn-on text full-path)
  ;; If the path is mentioned in a (set PATH.enable #f|#t), flip to #t.
  ;; Otherwise append a (enable PATH) line before host-file's closing paren.
  ;; Matches both bare `PATH` and quoted `'PATH` styles.
  (define set-re
    (pregexp (string-append "\\(set\\s+'?" (regexp-quote (string-append full-path ".enable"))
                            "\\s+#[ft]\\)")))
  (cond
    [(regexp-match set-re text)
     (regexp-replace set-re text
       (string-append "(set " full-path ".enable #t)"))]
    [(regexp-match (regexp (regexp-quote full-path)) text)
     ;; Mentioned in some other form (e.g., att, bundle composite); leave alone.
     text]
    [else
     (insert-before-final-close text
       (string-append "  (enable " full-path ")\n"))]))

(define (turn-off text full-path)
  (define set-re-true
    (pregexp (string-append "\\(set\\s+'?" (regexp-quote (string-append full-path ".enable"))
                            "\\s+#t\\)")))
  (define enable-line-re
    (pregexp (string-append "\\s*'?" (regexp-quote full-path) "(?=[\\s)])")))
  (cond
    [(regexp-match set-re-true text)
     (regexp-replace set-re-true text
       (string-append "(set " full-path ".enable #f)"))]
    [(regexp-match enable-line-re text)
     ;; Strip the PATH token from an (enable …) call.
     (regexp-replace enable-line-re text "")]
    [else text]))

(define (insert-before-final-close text insertion)
  ;; Find the position where the outermost top-level form (host-file ...)
  ;; closes by tracking paren depth (skipping over strings and comments).
  ;; Then walk backward to the start of that line so the insertion lands
  ;; on its own line above the closing paren(s).
  (define len (string-length text))
  (define close-pos
    (let loop ([i 0] [depth 0] [in-str #f] [in-comment #f] [last-close-at-zero #f])
      (cond
        [(>= i len) last-close-at-zero]
        [in-comment
         (cond [(char=? (string-ref text i) #\newline) (loop (+ i 1) depth in-str #f last-close-at-zero)]
               [else (loop (+ i 1) depth in-str #t last-close-at-zero)])]
        [in-str
         (cond [(and (char=? (string-ref text i) #\\) (< (+ i 1) len))
                (loop (+ i 2) depth #t #f last-close-at-zero)]
               [(char=? (string-ref text i) #\")
                (loop (+ i 1) depth #f #f last-close-at-zero)]
               [else (loop (+ i 1) depth #t #f last-close-at-zero)])]
        [(char=? (string-ref text i) #\;)
         (loop (+ i 1) depth in-str #t last-close-at-zero)]
        [(char=? (string-ref text i) #\")
         (loop (+ i 1) depth #t #f last-close-at-zero)]
        [(char=? (string-ref text i) #\()
         (loop (+ i 1) (+ depth 1) #f #f last-close-at-zero)]
        [(char=? (string-ref text i) #\))
         (define new-depth (- depth 1))
         (loop (+ i 1) new-depth #f #f
               (if (zero? new-depth) i last-close-at-zero))]
        [else (loop (+ i 1) depth in-str #f last-close-at-zero)])))
  (cond
    [(not close-pos) (string-append text insertion)]
    [else
     ;; Insert directly before the depth-0 closing paren, on its own line.
     ;; This is safe regardless of whether the close shares a line with
     ;; inner forms (e.g. `…vm))`) — we land between the inner `)` and
     ;; host-file's `)`.
     (string-append (substring text 0 close-pos)
                    "\n  " (string-trim-right insertion) "\n"
                    (substring text close-pos))]))

(define (string-trim-right s)
  (regexp-replace #rx"[ \t\n]+$" s ""))

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

;; ---------- command: status ----------

(define (cmd-status args)
  (define host (if (pair? args) (car args) (current-hostname)))
  (define text (read-host-config host))
  (printf "Enabled in ~a:\n" host)
  ;; Collect every reference to myConfig.{modules,bundles}.NAME — both bare
  ;; (post-#%top-revert style) and quoted ('PATH) form.
  (define seen (make-hash))
  (for ([m (in-list (regexp-match* #px"'?myConfig\\.(?:modules|bundles)\\.[a-zA-Z0-9_-]+(?:\\.enable)?"
                                   text))])
    (define norm (regexp-replace* #rx"^'|\\.enable$" m ""))
    (hash-set! seen norm #t))
  (for ([k (in-list (sort (hash-keys seen) string<?))])
    (printf "  ~a\n" k)))

;; ---------- help ----------

(define (cmd-help _args)
  (printf #<<HELP
firn — FirnOS config management

Usage:
  firn <command> [args...]

Commands:
  rebuild [host]              nixos-rebuild switch + tag generation
  list                        list all modules and bundles
  list --used                 show modules/bundles in use and where
  list --unused               show modules/bundles not referenced anywhere
  refs <name>                 show what references a module/bundle
  mod <name>                  scaffold a new module (.rkt)
  bundle <name> <mods...>     scaffold a new bundle (.rkt)
  secret <name>               create/edit an encrypted secret
  secret list                 list secret files
  secret show <name>          decrypt and display a secret
  gen                         show current and next generation numbers
  enable <name> [host]        toggle a module/bundle on in host config
  disable <name> [host]       toggle a module/bundle off in host config
  status [host]               list enabled modules/bundles for host

HELP
  ))

;; ---------- main ----------

(define (main argv)
  (cond
    [(null? argv) (cmd-help argv)]
    [else
     (define cmd (car argv))
     (define rest (cdr argv))
     (case cmd
       [("rebuild")     (cmd-rebuild rest)]
       [("list")        (cmd-list rest)]
       [("refs")        (cmd-refs rest)]
       [("mod")         (cmd-mod rest)]
       [("bundle")      (cmd-bundle rest)]
       [("secret")      (cmd-secret rest)]
       [("gen")         (cmd-gen rest)]
       [("enable")      (cmd-enable rest)]
       [("disable")     (cmd-disable rest)]
       [("status")      (cmd-status rest)]
       [("help" "-h" "--help") (cmd-help rest)]
       [else
        (eprintf "firn: unknown command '~a'\n\n" cmd)
        (cmd-help rest)
        (exit 1)])]))

(main (vector->list (current-command-line-arguments)))
