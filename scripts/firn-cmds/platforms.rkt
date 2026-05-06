#lang racket/base

;; firn-cmds/platforms — answer "which modules/bundles work on darwin?"
;;
;; The mechanism: every (set X.Y val) and (enable X.Y) form in a module
;; references an option path. nisp/validate already walks the AST and
;; extracts these. We cross-check each module's paths against both the
;; NixOS schema and the darwin schema; a module whose paths all exist
;; in darwin is darwin-compatible. Bundles aggregate their sub-modules:
;; a bundle is darwin-compatible iff every sub-module it references is
;; darwin-compatible AND any options it sets directly are also in the
;; darwin schema.
;;
;; Pre-req: both schemas extracted.
;;   ./scripts/firn-extract-schema           → .nisp-cache/schema.json
;;   ./scripts/firn-extract-schema --darwin  → .nisp-cache/schema-darwin.json
;;
;; Usage:
;;   firn platforms                  full matrix (modules + bundles)
;;   firn platforms darwin           list darwin-compatible only
;;   firn platforms linux            list NixOS-only
;;   firn platforms <name>           single module/bundle, with reason
;;   firn platforms --bundles        bundle compat with blocking modules
;;   firn platforms --safelist       suggested safelist for flake.rkt

(require racket/file
         racket/list
         racket/path
         racket/string
         racket/format
         json
         "util.rkt")

(provide cmd-platforms commands)

(define CACHE-DIR (build-path ROOT ".nisp-cache"))
(define NIXOS-SCHEMA (build-path CACHE-DIR "schema.json"))
(define DARWIN-SCHEMA (build-path CACHE-DIR "schema-darwin.json"))

;; ---------- schema loading ----------

;; Schema info for compat-check. A schema is a triple of hashes:
;;   - direct: every option path → #t
;;   - prefix: every dotted prefix of every option path → #t
;;     (handles `(set programs.bash (att …))` where the attrset
;;     covers multiple leaves under that prefix)
;;   - freeform: every option whose type is attrsOf/lazyAttrsOf/etc.
;;     → #t. Children of freeform paths are always valid (e.g.
;;     `users.users.tom.shell` matches because `users.users` is
;;     attrsOf submodule).
(struct schema (direct prefix freeform) #:transparent)

(define FREEFORM-TYPES
  '("attrsOf" "lazyAttrsOf" "anything" "unspecified" "freeform"))

(define (load-schema-paths path)
  (define direct (make-hash))
  (define prefix-h (make-hash))
  (define freeform (make-hash))
  (when (file-exists? path)
    (for ([e (in-list (call-with-input-file path read-json))])
      (define p (hash-ref e 'p))
      (define t (hash-ref e 't "?"))
      (hash-set! direct p #t)
      (when (member t FREEFORM-TYPES)
        (hash-set! freeform p #t))
      (define segs (string-split p "."))
      (let loop ([acc '()] [rest segs])
        (when (pair? rest)
          (define new-acc (append acc (list (car rest))))
          (hash-set! prefix-h (string-join new-acc ".") #t)
          (loop new-acc (cdr rest))))))
  (schema direct prefix-h freeform))

(define (path-in-schema? sch path)
  ;; Three checks, in order:
  ;;   1. Direct/prefix hit (exact or `(set X (att …))` covering multiple leaves).
  ;;   2. Wildcard parent — `users.users.tom.shell` matches schema's
  ;;      `users.users.<name>.shell` if extractor stored that form.
  ;;   3. Freeform ancestor — `users.users.kanata` matches because
  ;;      `users.users` has type attrsOf and accepts arbitrary children.
  (cond
    [(hash-has-key? (schema-prefix sch) path) #t]
    [else
     (define segs (string-split path "."))
     (define n (length segs))
     (or
      ;; wildcard substitution
      (for/or ([i (in-range n)])
        (define candidate
          (string-join
           (for/list ([(s j) (in-indexed (in-list segs))])
             (if (= j i) "<name>" s))
           "."))
        (hash-has-key? (schema-prefix sch) candidate))
      ;; freeform ancestor
      (let loop ([i (- n 1)])
        (cond
          [(<= i 0) #f]
          [else
           (define ancestor (string-join (take segs i) "."))
           (cond
             [(hash-has-key? (schema-freeform sch) ancestor) #t]
             [else (loop (- i 1))])])))]))

;; ---------- per-rkt path extraction ----------

(define (count-char c s)
  (for/sum ([ch (in-string s)] #:when (char=? ch c)) 1))

;; HM-FORMS bodies are skipped — paths inside home-of / home-of-bare /
;; hm / hm-bare / hm-module are home-manager submodule paths, which
;; live in a different schema slice. They're known portable by virtue
;; of running under home-manager.darwinModules on darwin.
(define HM-FORMS '(home-of home-of-bare hm hm-bare hm-module))

(define (form-head-symbol datum)
  (and (pair? datum) (symbol? (car datum)) (car datum)))

(define (path-from-arg arg)
  ;; Accept three shapes:
  ;;   bare identifier:  boot.loader.X    → datum is symbol 'boot.loader.X
  ;;   quoted symbol:    'boot.loader.X   → datum is (quote boot.loader.X)
  ;;   string literal:   "boot.loader.X"  → datum is "boot.loader.X"
  (cond
    [(symbol? arg) (symbol->string arg)]
    [(and (pair? arg) (eq? (car arg) 'quote)
          (pair? (cdr arg)) (symbol? (cadr arg)))
     (symbol->string (cadr arg))]
    [(string? arg) arg]
    [else #f]))

(define (collect-paths-from datum acc)
  ;; Recurse over the datum tree. When we hit a (set PATH …) or
  ;; (enable PATH …) form, extract paths. Otherwise keep walking.
  ;; Bodies under HM-FORMS heads are skipped — caller handles via gating.
  ;;
  ;; nisp shortcut macros are handled inline rather than waiting for
  ;; macroexpansion: (pkg N) → environment.systemPackages,
  ;; (svc N) → services.N.enable. These cover most of firnos's
  ;; one-line modules; without this they'd fall into no-data.
  (cond
    [(not (pair? datum)) acc]
    [else
     (define head (form-head-symbol datum))
     (cond
       [(memq head HM-FORMS)
        ;; Skip the entire subtree — HM bodies use home-manager paths
        ;; that aren't in the system schema.
        acc]
       [(eq? head 'set)
        (define rest (cdr datum))
        (cond
          [(null? rest) acc]
          [else
           (define p (path-from-arg (car rest)))
           (define acc2 (if p (cons p acc) acc))
           ;; Also recurse into the value side — (set X (att (Y val)))
           ;; doesn't put Y at top-level but we still want to find
           ;; nested set/enable forms in helper expressions.
           (for/fold ([a acc2]) ([d (in-list (cdr rest))])
             (collect-paths-from d a))])]
       [(eq? head 'enable)
        (for/fold ([a acc]) ([arg (in-list (cdr datum))])
          (define p (path-from-arg arg))
          (if p (cons (string-append p ".enable") a) a))]
       [(eq? head 'pkg)
        ;; (pkg name [desc]) → installs pkgs.<name> via env.systemPackages
        (cons "environment.systemPackages" acc)]
       [(eq? head 'svc)
        ;; (svc name)            → services.name.enable
        ;; (svc name desc)       → services.name.enable
        ;; (svc name path desc)  → <path> (custom service path)
        (define args (cdr datum))
        (cond
          [(null? args) acc]
          [(and (= (length args) 3) (string? (cadr args)))
           ;; 3-arg form: name, custom-path-string, desc
           (cons (cadr args) acc)]
          [else
           (define n (path-from-arg (car args)))
           (if n (cons (string-append "services." n ".enable") acc) acc)])]
       [(eq? head 'hm-module)
        ;; (hm-module name desc body...) — body is implicitly inside
        ;; home-of. Skip the body subtree.
        acc]
       [(or (eq? head 'sub-modules) (eq? head 'sub-modules*))
        ;; (sub-modules a b c) → emits `myConfig.modules.<a>.enable = …`
        ;; for each. (sub-modules* (a #t) (b #f) …) → same shape but
        ;; with explicit defaults. Either way we want to record the
        ;; module references so bundle-compat can read them.
        (for/fold ([a acc]) ([arg (in-list (cdr datum))])
          (define name
            (cond
              [(symbol? arg) (symbol->string arg)]
              [(and (pair? arg) (symbol? (car arg))) (symbol->string (car arg))]
              [else #f]))
          (if name (cons (string-append "myConfig.modules." name ".enable") a) a))]
       [else
        ;; Recurse into all elements
        (for/fold ([a acc]) ([d (in-list datum)])
          (collect-paths-from d a))])]))

(define (paths-referenced-in rkt-path)
  ;; Returns a list of option-path strings referenced via (set …) /
  ;; (enable …) at any depth in the file. Skips home-of / hm-* bodies.
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

;; ---------- module / bundle resolution ----------

(define (module-rkt-files name)
  ;; Returns all .rkt files in modules/<name>/ (default + any siblings)
  (define dir (in-repo "modules" name))
  (cond
    [(directory-exists? dir)
     (for/list ([p (directory-list dir)]
                #:when (regexp-match? #rx"\\.rkt$" (path->string p)))
       (build-path dir p))]
    [else '()]))

(define (bundle-rkt-file name)
  (in-repo "bundles" name "default.rkt"))

;; ---------- compatibility check ----------

(define (module-compat name nixos-schema darwin-schema)
  ;; Returns (values verdict blockers)
  ;;   verdict ∈ '(both linux-only darwin-only no-data)
  ;;   blockers = list of paths that broke compat (relevant for
  ;;              linux-only or darwin-only)
  (define files (module-rkt-files name))
  (cond
    [(null? files) (values 'no-data '())]
    [else
     (define all-paths
       (remove-duplicates
        (for/fold ([acc '()]) ([f (in-list files)])
          (append (paths-referenced-in f) acc))))
     ;; Skip:
     ;;   - myConfig.* (declared by our own modules, not in upstream schema)
     ;;   - cfg./config. lookups (read-only references, not setter targets)
     ;;   - bare "config"/"options"/"imports" — these are NixOS module
     ;;     top-level attrs (e.g. (set config (att …)) in the explicit
     ;;     options/config split shape), not option paths
     (define system-paths
       (filter (λ (p)
                 (and (not (string-prefix? p "cfg."))
                      (not (string-prefix? p "config."))
                      (not (string-prefix? p "myConfig."))
                      (not (member p '("config" "options" "imports")))))
               all-paths))
     (cond
       [(null? system-paths)
        ;; Pure HM module — compatible on both (HM works on darwin
        ;; via home-manager.darwinModules)
        (values 'both '())]
       [else
        (define linux-ok?
          (andmap (λ (p) (path-in-schema? nixos-schema p)) system-paths))
        (define darwin-ok?
          (andmap (λ (p) (path-in-schema? darwin-schema p)) system-paths))
        (define linux-blockers
          (filter (λ (p) (not (path-in-schema? nixos-schema p))) system-paths))
        (define darwin-blockers
          (filter (λ (p) (not (path-in-schema? darwin-schema p))) system-paths))
        (cond
          [(and linux-ok? darwin-ok?) (values 'both '())]
          [linux-ok? (values 'linux-only darwin-blockers)]
          [darwin-ok? (values 'darwin-only linux-blockers)]
          [else (values 'no-data
                        (append linux-blockers darwin-blockers))])])]))

(define (bundle-compat name nixos-schema darwin-schema all-module-verdicts)
  ;; A bundle is darwin-compatible iff:
  ;;   1. Every option path it sets directly exists in darwin schema, AND
  ;;   2. Every sub-module it references is darwin-compatible
  ;; Returns (values verdict blocking-modules)
  (define f (bundle-rkt-file name))
  (cond
    [(not (file-exists? f)) (values 'no-data '())]
    [else
     (define all-paths (paths-referenced-in f))
     ;; Sub-module references look like myConfig.modules.<X>.enable
     (define sub-modules
       (remove-duplicates
        (for/list ([p (in-list all-paths)]
                   #:when (regexp-match? #rx"^myConfig\\.modules\\." p))
          (define m (regexp-match #rx"^myConfig\\.modules\\.([^.]+)" p))
          (cadr m))))
     (define blocking
       (for/list ([m (in-list sub-modules)]
                  #:when (memq (hash-ref all-module-verdicts m 'no-data)
                               '(linux-only no-data)))
         m))
     (cond
       [(null? blocking) (values 'both '())]
       [else (values 'linux-only blocking)])]))

;; ---------- output ----------

(define (print-list label items)
  (cond
    [(null? items) (printf "~a (0):  (none)\n" label)]
    [else
     (printf "~a (~a):\n" label (length items))
     (define cols 5)
     (define widest (apply max (map string-length items)))
     (define col-w (+ widest 2))
     (let loop ([xs items] [n 0])
       (cond
         [(null? xs) (newline)]
         [else
          (printf "  ~a" (~a (car xs) #:min-width col-w))
          (when (and (> n 0) (zero? (modulo (+ n 1) cols))) (newline))
          (loop (cdr xs) (+ n 1))]))
     (when (not (zero? (modulo (length items) cols))) (newline))]))

(define (run-matrix nixos-schema darwin-schema)
  (define mods (modules))
  (define verdicts (make-hash))
  (define blockers (make-hash))
  (for ([m (in-list mods)])
    (define-values (v bs) (module-compat m nixos-schema darwin-schema))
    (hash-set! verdicts m v)
    (hash-set! blockers m bs))
  (values verdicts blockers))

(define (cmd-platforms args)
  (cond
    [(not (file-exists? NIXOS-SCHEMA))
     (eprintf "firn platforms: NixOS schema cache missing.\n")
     (eprintf "  run: ./scripts/firn-extract-schema\n")
     (exit 1)]
    [(not (file-exists? DARWIN-SCHEMA))
     (eprintf "firn platforms: darwin schema cache missing.\n")
     (eprintf "  run: ./scripts/firn-extract-schema --darwin\n")
     (exit 1)])

  (define nixos-schema (load-schema-paths NIXOS-SCHEMA))
  (define darwin-schema (load-schema-paths DARWIN-SCHEMA))

  (define-values (verdicts blockers) (run-matrix nixos-schema darwin-schema))

  (define (mods-with v)
    (sort (filter (λ (m) (eq? (hash-ref verdicts m) v))
                  (hash-keys verdicts))
          string<?))

  (define both       (mods-with 'both))
  (define linux-only (mods-with 'linux-only))
  (define no-data    (mods-with 'no-data))

  (cond
    ;; firn platforms darwin
    [(and (pair? args) (equal? (car args) "darwin"))
     (print-list "darwin-compatible modules" both)]

    ;; firn platforms linux
    [(and (pair? args) (equal? (car args) "linux"))
     (print-list "NixOS-only modules" linux-only)
     (when (pair? no-data)
       (newline)
       (print-list "modules with no detectable paths (skipped)" no-data))]

    ;; firn platforms --bundles
    [(and (pair? args) (equal? (car args) "--bundles"))
     (define bundles-list (bundles))
     (printf "bundle              compatible?  blocking modules\n")
     (printf "------              -----------  ----------------\n")
     (for ([b (in-list bundles-list)])
       (define-values (v blocking) (bundle-compat b nixos-schema darwin-schema verdicts))
       (cond
         [(eq? v 'both)
          (printf "~a  ✓\n" (~a b #:min-width 18))]
         [else
          (printf "~a  NixOS-only  ~a\n"
                  (~a b #:min-width 18)
                  (string-join blocking ", "))]))]

    ;; firn platforms --safelist
    [(and (pair? args) (equal? (car args) "--safelist"))
     (printf ";; darwin-compatible modules (auto-generated by `firn platforms --safelist`).\n")
     (printf ";; Paste into mkDarwinSystem's imports list. ~a entries.\n" (length both))
     (printf "(lst")
     (for ([m (in-list both)])
       (printf "\n     ~s" m))
     (printf ")\n")]

    ;; firn platforms <name>
    [(pair? args)
     (define name (car args))
     (cond
       [(member name (modules))
        (define v (hash-ref verdicts name 'no-data))
        (define bs (hash-ref blockers name '()))
        (printf "module:  ~a\n" name)
        (printf "verdict: ~a\n" v)
        (when (pair? bs)
          (printf "blocking paths:\n")
          (for ([p (in-list bs)]) (printf "  ~a\n" p)))]
       [(member name (bundles))
        (define-values (v blocking) (bundle-compat name nixos-schema darwin-schema verdicts))
        (printf "bundle:  ~a\n" name)
        (printf "verdict: ~a\n" v)
        (when (pair? blocking)
          (printf "blocking sub-modules:\n")
          (for ([m (in-list blocking)])
            (define mv (hash-ref verdicts m 'no-data))
            (define mbs (hash-ref blockers m '()))
            (printf "  ~a (~a)\n" m mv)
            (for ([p (in-list mbs)]) (printf "    ~a\n" p))))]
       [else
        (eprintf "firn platforms: no module or bundle named '~a'\n" name)
        (exit 1)])]

    ;; firn platforms — full matrix
    [else
     (printf "Platform compatibility matrix (~a modules, ~a bundles)\n"
             (length (modules)) (length (bundles)))
     (printf "Sources: NixOS schema (~a paths), darwin schema (~a paths)\n\n"
             (hash-count (schema-direct nixos-schema))
             (hash-count (schema-direct darwin-schema)))
     (print-list "darwin-compatible modules" both)
     (newline)
     (print-list "NixOS-only modules" linux-only)
     (when (pair? no-data)
       (newline)
       (print-list "no-data (HM-only or unparsable)" no-data))
     (newline)
     (printf "Note: this is a *schema* compatibility check — option paths the\n")
     (printf "module sets must exist on the target platform. It doesn't\n")
     (printf "verify package availability; modules that only set\n")
     (printf "environment.systemPackages will pass even if the package itself\n")
     (printf "has no darwin build. Try `darwin-rebuild build` to confirm.\n\n")
     (printf "Run `firn platforms --bundles` for bundle compat,\n")
     (printf "    `firn platforms <name>` to inspect a single module/bundle,\n")
     (printf "    `firn platforms --safelist` for a flake.rkt safelist.\n")]))

(define commands
  (list (cmd "platforms" "[darwin | linux | <name> | --bundles | --safelist]"
             "show platform compatibility for modules and bundles"
             cmd-platforms)))
