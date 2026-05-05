#lang racket/base

(require racket/format
         racket/string
         racket/list
         racket/match
         (for-syntax racket/base))

(provide (rename-out [nisp-module-begin #%module-begin])
         #%top #%app #%datum quote
         ;; --- existing nisp surface ---
         enable set service user packages pkg
         ;; --- atoms ---
         s ms p nl
         ;; --- compound ---
         lst att rec-att att* merge concat-list cat bop
         ;; --- path ---
         at .>
         ;; --- expressions ---
         if-then let-in with-do fn fn-set fn-set-rest call inh inh-from
         ;; --- mk helpers ---
         mkif mkdefault mkforce mkmerge mkenable mkopt
         ;; --- types ---
         t-bool t-str t-int t-path t-port t-attrs t-listof t-attrsof t-nullor t-enum t-submodule
         ;; --- file-level ---
         flake-file module-file bundle-file host-file hm-file raw-file frag-file
         ;; --- module body convenience ---
         imports opts cfg-block home-of home-of-bare with-pkgs sops-secret sops-template
         ;; --- low-level entry/path constructors (for paths the macros can't express) ---
         mk-entry smart-split-dot
         ;; --- AST escape (used internally; available for tests) ---
         (struct-out nix-bool)
         (struct-out nix-int)
         (struct-out nix-string)
         (struct-out nix-mstring)
         (struct-out nix-null)
         (struct-out nix-path)
         (struct-out nix-ident)
         (struct-out nix-list)
         (struct-out nix-attrs)
         (struct-out nix-rec-attrs)
         (struct-out nix-attr-entry)
         (struct-out nix-let)
         (struct-out nix-with)
         (struct-out nix-if)
         (struct-out nix-app)
         (struct-out nix-lambda)
         (struct-out nix-binop)
         (struct-out nix-import)
         (struct-out nix-inherit)
         (struct-out lp-simple)
         (struct-out lp-attrs)
         emit emit-toplevel as-value)

;; #%top: standard Racket — unbound identifiers error at compile time.
;; Use 'foo (Racket quote) to inject a nix-ident from a symbol literal.
;; `as-value` converts symbols to nix-idents, so quoted symbols flow through
;; the existing AST builders without special handling.


;; =========================================================================
;; Data model — Nix AST
;; =========================================================================
(struct nix-bool   (v)            #:transparent)
(struct nix-int    (v)            #:transparent)
(struct nix-string (parts)        #:transparent)   ; list of (or/c string nix-expr)
(struct nix-mstring (lines)       #:transparent)   ; list of strings (one per line)
(struct nix-null   ()             #:transparent)
(struct nix-path   (text)         #:transparent)   ; "./foo" or "/abs/path" or "<chan>"
(struct nix-ident  (name)         #:transparent)   ; "pkgs.vim" or "config"

(struct nix-list   (items)        #:transparent)
(struct nix-attrs  (entries)      #:transparent)   ; list of nix-attr-entry
(struct nix-rec-attrs (entries)   #:transparent)
;; entry path: list of segments. Each segment: string (literal) or AST node (for ${...}).
(struct nix-attr-entry (path value) #:transparent)

(struct nix-let    (binds body)   #:transparent)   ; binds: list of (path expr)
(struct nix-with   (ns body)      #:transparent)
(struct nix-if     (c t e)        #:transparent)
(struct nix-app    (fn args)      #:transparent)   ; fn + args list
(struct nix-lambda (params body)  #:transparent)
(struct nix-binop  (op l r)       #:transparent)   ; op is a symbol like '++ '// '+ '-
(struct nix-import (target)       #:transparent)
(struct nix-inherit (ns names)    #:transparent)   ; ns: nix-expr or #f

;; lambda params
(struct lp-simple (name)                              #:transparent)  ; x:
(struct lp-attrs  (entries rest? at-name)             #:transparent)
;; entries: list of (name default-or-#f). rest?: bool. at-name: string or #f.

;; =========================================================================
;; Coercion: turn Racket values into AST nodes
;; =========================================================================
(define (as-value v)
  (cond
    [(boolean? v)        (nix-bool v)]
    [(exact-integer? v)  (nix-int v)]
    [(number? v)         (nix-int v)]                ; treat as int for our needs
    [(string? v)         (nix-string (list v))]
    [(symbol? v)         (nix-ident (symbol->string v))]
    [(null? v)           (nix-list '())]
    [(list? v)           (nix-list (map as-value v))]
    [else                v]))                         ; assume already AST

;; =========================================================================
;; Atoms
;; =========================================================================
(define (s . parts)
  (nix-string (map (lambda (p)
                     (cond [(string? p) p]
                           [else (as-value p)]))
                   parts)))

;; (ms <line> ...) — multi-line indented Nix string ''...''.
;; Each line can be:
;;   - a plain string: emitted literally
;;   - a (s "part" expr "part" ...) result: emitted with ${expr} interpolation
;;   - any AST node: emitted as ${node}
(define (ms . lines)
  (nix-mstring lines))

(define (p str) (nix-path str))
(define (nl)    (nix-null))

;; =========================================================================
;; Path expression helpers
;;
;; (at "inputs.nur.legacyPackages.${pkgs.system}.repos.rycee")
;;   -> parses interpolations, builds an AST of attribute access
;; =========================================================================

;; Parse a Nix-like dotted path with ${...} interpolations into a list
;; of segments. Each segment is either a string (literal) or an AST node.
(define (parse-attr-path str)
  (let loop ([rest str] [segs '()] [buf '()])
    (cond
      [(zero? (string-length rest))
       (let ([final (if (null? buf) segs (cons (list->string (reverse buf)) segs))])
         (parse-segment-list (reverse final)))]
      [(and (>= (string-length rest) 2)
            (string=? (substring rest 0 2) "${"))
       (let* ([close (find-close-brace rest 2)]
              [inner (substring rest 2 close)])
         (loop (substring rest (+ close 1))
               (let ([acc (if (null? buf) segs (cons (list->string (reverse buf)) segs))])
                 (cons (nix-ident inner) acc))
               '()))]
      [else
       (loop (substring rest 1) segs (cons (string-ref rest 0) buf))])))

(define (find-close-brace s start)
  (let loop ([i start] [depth 1])
    (cond
      [(>= i (string-length s)) (error 'parse-attr-path "unmatched ${")]
      [(char=? (string-ref s i) #\{) (loop (+ i 1) (+ depth 1))]
      [(char=? (string-ref s i) #\}) (if (= depth 1) i (loop (+ i 1) (- depth 1)))]
      [else (loop (+ i 1) depth)])))

;; Given a flat list (alternating text/expr), split text on "." into segments.
;; Returns a list of segments suitable for emit-attr-path / nix-attr-entry.
(define (parse-segment-list items)
  (let loop ([rest items] [out '()])
    (cond
      [(null? rest) (reverse out)]
      [(string? (car rest))
       (let ([parts (string-split (car rest) ".")])
         ;; string-split drops leading "" only if string is empty;
         ;; here a leading "." means previous expr-segment then dot.
         (loop (cdr rest)
               (append (reverse parts) out)))]
      [else
       (loop (cdr rest) (cons (car rest) out))])))

(define (at str) (parse-attr-path str))

;; (.> root part ...) — chained access. Returns a list of segments.
;; A string arg is a literal segment (`foo`).
;; A symbol arg ('foo) becomes a nix-ident, emitted as `${foo}` interpolation
;;   (so it can reference let-bound names from the surrounding scope).
;; Any AST node passes through and is emitted as `${expr}`.
(define (.> root . parts)
  (define (->seg x)
    (cond [(string? x) x]
          [(symbol? x) (nix-ident (symbol->string x))]
          [else x]))
  (cons (->seg root) (map ->seg parts)))

;; =========================================================================
;; Compound
;; =========================================================================
(define (lst . items) (nix-list (map as-value items)))

;; (att form ...) — each form is either (k v) (key-value pair) or any expression
;; that returns a nix-attr-entry / nix-inherit / list-of-entries.
;; Distinguished by shape: exactly 2 elements => (k v); anything else => expression.
(define-syntax (att stx)
  (syntax-case stx ()
    [(_ form ...)
     #'(nix-attrs (flatten-entries (list (att-clause form) ...)))]))

(define-syntax (rec-att stx)
  (syntax-case stx ()
    [(_ form ...)
     #'(nix-rec-attrs (flatten-entries (list (att-clause form) ...)))]))

(define-syntax (att-clause stx)
  (syntax-case stx ()
    [(_ (k v)) #'(mk-entry (quote-key k) v)]
    [(_ expr)  #'expr]))

;; att*: pass entries as a single list (for dynamic construction)
(define (att* entries) (nix-attrs entries))

(define-syntax (quote-key stx)
  (syntax-case stx ()
    [(_ k)
     (cond
       [(identifier? #'k) #'(symbol->string 'k)]
       [(string? (syntax->datum #'k)) #'k]
       [else #'k])]))   ; AST list etc.

(define (mk-entry key value)
  (define segs
    (cond
      [(string? key)
       (if (regexp-match? #px"\\$\\{" key)
           (parse-attr-path key)
           (smart-split-dot key))]
      [(symbol? key) (smart-split-dot (symbol->string key))]
      [(list? key) key]
      [else (list key)]))
  (nix-attr-entry segs (as-value value)))

;; Split a dotted path on "." but keep double-quoted segments intact:
;;   "xdg.configFile.\"rofi/config.rasi\".source"
;;   -> ("xdg" "configFile" "\"rofi/config.rasi\"" "source")
(define (smart-split-dot str)
  (let loop ([rest str] [buf '()] [in-quote #f] [out '()])
    (cond
      [(zero? (string-length rest))
       (reverse (if (null? buf) out (cons (list->string (reverse buf)) out)))]
      [(and (not in-quote) (char=? (string-ref rest 0) #\.))
       (loop (substring rest 1) '() #f
             (cons (list->string (reverse buf)) out))]
      [(char=? (string-ref rest 0) #\")
       (loop (substring rest 1) (cons #\" buf) (not in-quote) out)]
      [else
       (loop (substring rest 1) (cons (string-ref rest 0) buf) in-quote out)])))

;; (merge a b) -> a // b
(define (merge a b) (nix-binop '// (as-value a) (as-value b)))

;; (concat-list a b) -> a ++ b
(define (concat-list a b) (nix-binop '++ (as-value a) (as-value b)))

;; (cat a b) -> a + b   (string/path concatenation)
(define (cat a b) (nix-binop '+ (as-value a) (as-value b)))

;; (bop op a b) -> a op b   (generic binary; op is a symbol like '== '!= '&& '|| '<)
(define (bop op a b) (nix-binop op (as-value a) (as-value b)))

;; =========================================================================
;; Expressions
;; =========================================================================
(define (if-then c t e) (nix-if (as-value c) (as-value t) (as-value e)))

;; let-in shadows bound names with nix-idents so they can be referenced as
;; identifiers in subsequent bindings and the body. (Nix `let` is recursive.)
(define-syntax (let-in stx)
  (syntax-case stx ()
    [(_ ([k v] ...) body)
     #'(let ([k (nix-ident (symbol->string 'k))] ...)
         (nix-let (list (list (symbol->string 'k) v) ...) (as-value body)))]))

(define (with-do ns body) (nix-with (as-value ns) (as-value body)))

;; (fn (a b c) body) -> a: b: c: body  (curried)
;; (fn x body)       -> x: body
;; Params are shadowed in body with nix-idents so they emit as identifier refs.
(define-syntax (fn stx)
  (syntax-case stx ()
    [(_ (a ...) body)
     #'(let ([a (nix-ident (symbol->string 'a))] ...)
         (make-curried-fn (list (symbol->string 'a) ...) (as-value body)))]
    [(_ a body)
     (identifier? #'a)
     #'(let ([a (nix-ident (symbol->string 'a))])
         (nix-lambda (lp-simple (symbol->string 'a)) (as-value body)))]))

(define (make-curried-fn names body)
  (cond [(null? names) body]
        [else (nix-lambda (lp-simple (car names))
                          (make-curried-fn (cdr names) body))]))

;; (fn-set (a b (c "default")) body) -> {a, b, c ? "default"}: body
;; Params are shadowed with nix-idents so the body can reference them.
(define-syntax (fn-set stx)
  (syntax-case stx ()
    [(_ (entry ...) body)
     (with-syntax ([(name ...)
                    (map (lambda (e)
                           (syntax-case e ()
                             [(id _default) #'id]
                             [id #'id]))
                         (syntax->list #'(entry ...)))])
       #'(let ([name (nix-ident (symbol->string 'name))] ...)
           (nix-lambda (lp-attrs (list (fn-set-entry entry) ...) #f #f) (as-value body))))]))

;; (fn-set-rest (a b) body) -> {a, b, ...}: body
(define-syntax (fn-set-rest stx)
  (syntax-case stx ()
    [(_ (entry ...) body)
     (with-syntax ([(name ...)
                    (map (lambda (e)
                           (syntax-case e ()
                             [(id _default) #'id]
                             [id #'id]))
                         (syntax->list #'(entry ...)))])
       #'(let ([name (nix-ident (symbol->string 'name))] ...)
           (nix-lambda (lp-attrs (list (fn-set-entry entry) ...) #t #f) (as-value body))))]))

(define-syntax (fn-set-entry stx)
  (syntax-case stx ()
    [(_ (id default))
     #'(list (symbol->string 'id) (as-value default))]
    [(_ id)
     #'(list (symbol->string 'id) #f)]))

(define (call fn . args)
  (nix-app (as-value fn) (map as-value args)))

;; inherit / inherit (ns) names
(define-syntax (inh stx)
  (syntax-case stx ()
    [(_ name ...) #'(nix-inherit #f (list (symbol->string 'name) ...))]))

(define-syntax (inh-from stx)
  (syntax-case stx ()
    [(_ ns name ...) #'(nix-inherit (as-value 'ns) (list (symbol->string 'name) ...))]))

;; =========================================================================
;; mk* helpers
;; =========================================================================
(define (mkif cond body)
  (nix-app (nix-ident "lib.mkIf") (list (as-value cond) (as-value body))))

(define (mkdefault v)
  (nix-app (nix-ident "lib.mkDefault") (list (as-value v))))

(define (mkforce v)
  (nix-app (nix-ident "lib.mkForce") (list (as-value v))))

(define (mkmerge . xs)
  (nix-app (nix-ident "lib.mkMerge") (list (nix-list (map as-value xs)))))

(define (mkenable desc)
  (nix-app (nix-ident "lib.mkEnableOption") (list (as-value desc))))

(define (mkopt #:type t #:default [d 'unset] #:desc [desc 'unset])
  (define entries
    (filter values
      (list (mk-entry "type" t)
            (and (not (eq? d 'unset)) (mk-entry "default" d))
            (and (not (eq? desc 'unset)) (mk-entry "description" desc)))))
  (nix-app (nix-ident "lib.mkOption") (list (nix-attrs entries))))

;; =========================================================================
;; Types — return AST nodes referencing lib.types.X
;; =========================================================================
(define (t-bool)         (nix-ident "lib.types.bool"))
(define (t-str)          (nix-ident "lib.types.str"))
(define (t-int)          (nix-ident "lib.types.int"))
(define (t-path)         (nix-ident "lib.types.path"))
(define (t-port)         (nix-ident "lib.types.port"))
(define (t-attrs)        (nix-ident "lib.types.attrs"))
(define (t-listof t)     (nix-app (nix-ident "lib.types.listOf") (list (as-value t))))
(define (t-attrsof t)    (nix-app (nix-ident "lib.types.attrsOf") (list (as-value t))))
(define (t-nullor t)     (nix-app (nix-ident "lib.types.nullOr") (list (as-value t))))
(define (t-enum . xs)    (nix-app (nix-ident "lib.types.enum")
                                  (list (nix-list (map as-value xs)))))
(define (t-submodule m)  (nix-app (nix-ident "lib.types.submodule") (list (as-value m))))

;; =========================================================================
;; Existing nisp surface, redefined to produce AST nodes
;; =========================================================================

;; (enable a.b.c) -> a.b.c.enable = true;
;; (enable a b c) -> three entries
(define-syntax (enable stx)
  (syntax-case stx ()
    [(_ path)         #'(mk-entry (string-append (symbol->string 'path) ".enable") #t)]
    [(_ p1 p2 ...)    #'(list (enable p1) (enable p2) ...)]))

;; (set path val) | (set path v1 v2 ...)
;; path can be a dotted identifier OR a string (for paths with quoted segments).
(define-syntax (set stx)
  (syntax-case stx ()
    [(_ path val)
     (cond [(identifier? #'path) #'(mk-entry (symbol->string 'path) val)]
           [else                 #'(mk-entry path val)])]
    [(_ path v1 v2 ...)
     (cond [(identifier? #'path) #'(mk-entry (symbol->string 'path) (lst v1 v2 ...))]
           [else                 #'(mk-entry path (lst v1 v2 ...))])]))

;; (service openssh) | (service pipewire (alsa #t) ...)
(define-syntax (service stx)
  (syntax-case stx ()
    [(_ name)
     #'(mk-entry (string-append "services." (symbol->string 'name) ".enable") #t)]
    [(_ name (k v) ...)
     #'(mk-entry (string-append "services." (symbol->string 'name))
                 (att (enable #t) (k v) ...))]))

;; (user "tom" (extraGroups "wheel") (shell (pkg "zsh")))
(define-syntax (user stx)
  (syntax-case stx ()
    [(_ name field ...)
     #'(mk-entry (string-append "users.users." name)
                 (att (isNormalUser #t) (user-field field) ...))]))

(define-syntax (user-field stx)
  (syntax-case stx ()
    [(_ (key v))         #'(list 'key v)]
    [(_ (key v1 v2 ...)) #'(list 'key (lst v1 v2 ...))]))

;; Wait — user-field is used with att, which expects (k v). Restructure:
;; we override att-entry generation. Simpler: just use att inside.
;; Above 'user' macro is fine if we rewrite to:
;;   (att (isNormalUser #t) field ...)
;; but field is (key val). Use att directly:

;; (packages vim git fd) -> environment.systemPackages = with pkgs; [ vim git fd ];
(define-syntax (packages stx)
  (syntax-case stx ()
    [(_ name ...)
     #'(mk-entry "environment.systemPackages"
                 (with-do (nix-ident "pkgs")
                          (lst (nix-ident (symbol->string 'name)) ...)))]))

(define (pkg name) (nix-ident (string-append "pkgs." name)))

;; =========================================================================
;; Module convenience
;; =========================================================================

;; (with-pkgs vim git fd) -> with pkgs; [ vim git fd ]
(define-syntax (with-pkgs stx)
  (syntax-case stx ()
    [(_ name ...)
     #'(with-do (nix-ident "pkgs")
                (lst (nix-ident (symbol->string 'name)) ...))]))

;; (imports a b c) -> imports = [ ./a ./b ./c ];   (paths if symbols, else as-is)
(define-syntax (imports stx)
  (syntax-case stx ()
    [(_ x ...) #'(mk-entry "imports" (lst (import-item x) ...))]))

(define-syntax (import-item stx)
  (syntax-case stx ()
    [(_ x)
     (cond
       [(string? (syntax->datum #'x)) #'(nix-path x)]
       [(identifier? #'x)             #'(nix-path (symbol->string 'x))]
       [else                          #'x])]))

;; (opts (path option-spec) ...) — set options.<path> = option-spec
(define-syntax (opts stx)
  (syntax-case stx ()
    [(_ (path spec) ...)
     #'(list (mk-entry (string-append "options." (symbol->string 'path)) spec) ...)]))

;; (cfg-block cfg-path body...) -> config = lib.mkIf <cfg-path>.enable { body... };
(define-syntax (cfg-block stx)
  (syntax-case stx ()
    [(_ cfg-path body ...)
     #'(mk-entry "config"
                 (mkif (nix-ident (string-append (symbol->string 'cfg-path) ".enable"))
                       (att* (flatten-entries (list body ...)))) )]))

;; Flatten arbitrary nested lists of entries.
(define (flatten-entries xs)
  (cond
    [(null? xs) '()]
    [(list? (car xs)) (append (flatten-entries (car xs)) (flatten-entries (cdr xs)))]
    [(nix-attr-entry? (car xs)) (cons (car xs) (flatten-entries (cdr xs)))]
    [else (error 'flatten-entries "expected nix-attr-entry, got ~a" (car xs))]))

;; (home-of username body...) -> home-manager.users.${username} = { config, ... }: { body... };
;; Inner `config` shadows so the body can reference the per-user HM config
;; (e.g. `config.lib.file.mkOutOfStoreSymlink`, `config.home.homeDirectory`).
(define-syntax (home-of stx)
  (syntax-case stx ()
    [(_ username body ...)
     #'(let ([config (nix-ident "config")])
         (mk-entry (list "home-manager" "users" username)
                   (nix-lambda (lp-attrs (list (list "config" #f)) #t #f)
                               (att* (flatten-entries (list body ...))))))]))

;; (home-of-bare username body...) -> home-manager.users.${username} = { body... };
;; No `{ config, ... }:` wrapper — body references the OUTER `config`.
;; Use this when the HM value doesn't need HM-scoped attrs.
(define-syntax (home-of-bare stx)
  (syntax-case stx ()
    [(_ username body ...)
     #'(mk-entry (list "home-manager" "users" username)
                 (att* (flatten-entries (list body ...))))]))

;; (sops-secret "name" (k v) ...) -> sops.secrets."name" = { ... };
(define-syntax (sops-secret stx)
  (syntax-case stx ()
    [(_ name (k v) ...)
     #'(mk-entry (string-append "sops.secrets.\"" name "\"")
                 (att (k v) ...))]))

(define-syntax (sops-template stx)
  (syntax-case stx ()
    [(_ name (k v) ...)
     #'(mk-entry (string-append "sops.templates.\"" name "\"")
                 (att (k v) ...))]))

;; =========================================================================
;; File-level forms — each .rkt file uses ONE of these as its sole top-level form
;; (or a sequence whose flatten is consumed by emit-toplevel).
;; =========================================================================

;; Wrap a result in a tag the emitter recognizes.
(struct nisp-file (kind data) #:transparent)

;; (module-file <ns> <name> body ...)
;;   -> { config, lib, pkgs, ... }:
;;      let cfg = config.myConfig.<ns>.<name>; in {
;;        options.myConfig.<ns>.<name> = ...;
;;        config = lib.mkIf cfg.enable { ... };
;;      }
;;
;; Inside body, allowed forms:
;;   (desc "...")              — sets the mkEnableOption description
;;   (extra-args sym ...)      — additional fn-set arglist entries (e.g. flakeRoot, inputs)
;;   (lets ([k v] ...))        — extra let bindings on top of `cfg`
;;   (option-attrs (name spec) ...) — extra options (besides .enable)
;;   (no-enable)               — skip the .enable / mkIf wrapper
;;   (config-body body...)     — body of `config = lib.mkIf cfg.enable { ... };`
;;   (raw-body body...)        — body merged AT TOP LEVEL (sibling of options/config)
(define-syntax (module-file stx)
  (syntax-case stx ()
    [(_ ns name body ...)
     #'(nisp-file 'module
                  (build-module-file 'modules 'ns 'name (list (mod-clause body) ...)))]))

(define-syntax (bundle-file stx)
  (syntax-case stx ()
    [(_ name body ...)
     #'(nisp-file 'module
                  (build-module-file 'bundles 'bundles 'name (list (mod-clause body) ...)))]))

;; Convert each body clause into a tagged pair. We can't use plain identifiers
;; everywhere because clauses like (extra-args inputs) need to read identifiers literally.
(define-syntax (mod-clause stx)
  (syntax-case stx (desc extra-args lets option-attrs no-enable config-body raw-body sub-modules sub-modules*)
    [(_ (desc str))
     #'(cons 'desc str)]
    [(_ (extra-args sym ...))
     #'(cons 'extra-args (list (symbol->string 'sym) ...))]
    [(_ (lets ([k v] ...)))
     #'(cons 'lets (list (list (symbol->string 'k) v) ...))]
    [(_ (option-attrs (n spec) ...))
     #'(cons 'option-attrs (list (cons (symbol->string 'n) spec) ...))]
    [(_ (no-enable))
     #'(cons 'no-enable #t)]
    [(_ (config-body body ...))
     #'(cons 'config-body (flatten-entries (list body ...)))]
    [(_ (raw-body body ...))
     #'(cons 'raw-body (flatten-entries (list body ...)))]
    [(_ (sub-modules m ...))
     ;; bundle helper: sub-modules vim git => mkDefault cfg.X.enable for each
     #'(cons 'sub-modules (list (symbol->string 'm) ...))]
    [(_ (sub-modules* (m default) ...))
     #'(cons 'sub-modules* (list (cons (symbol->string 'm) default) ...))]))

;; Build the file structure.
(define (build-module-file kind ns name clauses)
  (define (one k) (lookup clauses k))
  (define (all k) (lookup-all clauses k))
  (define desc (or (one 'desc) (symbol->string name)))
  (define extra-args (or (one 'extra-args) '()))
  (define extra-lets (or (one 'lets) '()))
  (define extra-opts (or (one 'option-attrs) '()))
  (define no-enable? (or (one 'no-enable) #f))
  (define config-body-entries
    (apply append (map cdr (filter (lambda (c) (eq? (car c) 'config-body)) clauses))))
  (define raw-body-entries
    (apply append (map cdr (filter (lambda (c) (eq? (car c) 'raw-body)) clauses))))
  (define sub-modules-list (or (one 'sub-modules) '()))
  (define sub-modules*-list (or (one 'sub-modules*) '()))

  ;; bundle-style sub-modules: produce option entries + config mkDefault settings.
  ;; Each sub-module gets a `.enable` option (matching the existing repo convention).
  (define implicit-opts
    (append
      (map (lambda (m) (cons (string-append m ".enable")
                              (mkopt #:type (t-bool) #:default #t
                                     #:desc (string-append "Enable " m))))
           sub-modules-list)
      (map (lambda (pr) (cons (string-append (car pr) ".enable")
                              (mkopt #:type (t-bool) #:default (cdr pr)
                                     #:desc (string-append "Enable " (car pr)))))
           sub-modules*-list)))

  (define implicit-cfg-entries
    (append
      (map (lambda (m)
             (mk-entry (string-append "myConfig.modules." m ".enable")
                       (mkdefault (nix-ident (string-append "cfg." m ".enable")))))
           sub-modules-list)
      (map (lambda (pr)
             (let ([m (car pr)])
               (mk-entry (string-append "myConfig.modules." m ".enable")
                         (mkdefault (nix-ident (string-append "cfg." m ".enable"))))))
           sub-modules*-list)))

  (define option-entries
    (append
      ;; .enable = mkEnableOption desc
      (if no-enable? '()
          (list (mk-entry (string-append "options.myConfig." (symbol->string ns)
                                          "." (symbol->string name) ".enable")
                          (mkenable desc))))
      ;; Other named options nested under the same path
      (map (lambda (pr)
             (let ([n (car pr)] [spec (cdr pr)])
               (mk-entry (string-append "options.myConfig." (symbol->string ns)
                                         "." (symbol->string name) "." n)
                         spec)))
           (append extra-opts implicit-opts))))

  (define cfg-path
    (string-append "config.myConfig." (symbol->string ns) "." (symbol->string name)))

  (define top-let-binds
    (cons (list "cfg" (nix-ident cfg-path))
          (map (lambda (b) (list (car b) (as-value (cadr b)))) extra-lets)))

  (define final-config-entries
    (append config-body-entries implicit-cfg-entries))

  (define cfg-entry
    (if no-enable?
        (if (null? final-config-entries) #f
            (list (mk-entry "config" (att* final-config-entries))))
        (if (null? final-config-entries) '()
            (list (mk-entry "config"
                            (mkif (nix-ident "cfg.enable") (att* final-config-entries)))))))

  (define top-entries
    (append option-entries
            (or cfg-entry '())
            raw-body-entries))

  ;; Module function: { config, lib, pkgs, [extra...], ... }: let cfg = ...; in { ... }
  (define module-args
    (append (list (list "config" #f) (list "lib" #f) (list "pkgs" #f))
            (map (lambda (a) (list a #f)) extra-args)))

  (define module-body (att* top-entries))
  (define wrapped (nix-let top-let-binds module-body))
  (nix-lambda (lp-attrs module-args #t #f) wrapped))

(define (lookup clauses key)
  (let loop ([cs clauses])
    (cond [(null? cs) #f]
          [(eq? (car (car cs)) key) (cdr (car cs))]
          [else (loop (cdr cs))])))

(define (lookup-all clauses key)
  (filter-map (lambda (c) (and (eq? (car c) key) (cdr c))) clauses))

;; (host-file body ...)
;; Just emits { lib, ... }: { body... } — pure setter blocks.
(define-syntax (host-file stx)
  (syntax-case stx ()
    [(_ body ...)
     #'(nisp-file 'module
                  (nix-lambda
                    (lp-attrs (list (list "lib" #f)) #t #f)
                    (att* (flatten-entries (list body ...)))))]))

;; (hm-file body ...) — emits a module that sets home-manager.users.<u> entries.
;; Mostly unused; prefer home-of inside a regular module-file.
(define-syntax (hm-file stx)
  (syntax-case stx ()
    [(_ body ...)
     #'(nisp-file 'module
                  (nix-lambda
                    (lp-attrs (list (list "config" #f) (list "lib" #f) (list "pkgs" #f)) #t #f)
                    (att* (flatten-entries (list body ...)))))]))

;; (raw-file expr) — emit a single AST expression, no wrapping
(define-syntax (raw-file stx)
  (syntax-case stx ()
    [(_ expr) #'(nisp-file 'raw expr)]))

;; (frag-file body ...) — emit a bare attrset (no function wrapper)
(define-syntax (frag-file stx)
  (syntax-case stx ()
    [(_ body ...)
     #'(nisp-file 'frag (att* (flatten-entries (list body ...))))]))

;; (flake-file (description "...") (inputs ...) (outputs ...))
;; Emits the standard flake.nix shape.
(define-syntax (flake-file stx)
  (syntax-case stx ()
    [(_ clause ...)
     #'(nisp-file 'flake (build-flake (list (flake-clause clause) ...)))]))

(define-syntax (flake-clause stx)
  (syntax-case stx (description inputs outputs)
    [(_ (description s))     #'(cons 'description s)]
    [(_ (inputs entry ...))  #'(cons 'inputs (list (input-entry entry) ...))]
    [(_ (outputs (arg ...) body ...))
     ;; outputs body is a sequence of expressions/entries.
     ;; If it's a single non-entry expression (e.g. a let-in), use as the body.
     ;; If it's a sequence of attr-entries, wrap in att*.
     #'(cons 'outputs (list (list (symbol->string 'arg) ...) (list body ...)))]))

;; Each input entry can be:
;;   (name url)
;;   (name url (follows input-name))
;;   (name url (follows input-name) (no-flake))
;;   (name (path "..."))   -- explicit path expr
(define-syntax (input-entry stx)
  (syntax-case stx (follows no-flake flake)
    [(_ (name url))
     #'(list (symbol->string 'name) url '())]
    [(_ (name url opt ...))
     #'(list (symbol->string 'name) url (list (input-opt opt) ...))]))

(define-syntax (input-opt stx)
  (syntax-case stx (follows no-flake flake)
    ;; (follows x)        => inputs.x.follows = "x"
    ;; (follows src tgt)  => inputs.src.follows = "tgt"
    [(_ (follows x))         #'(cons 'follows (cons (symbol->string 'x) (symbol->string 'x)))]
    [(_ (follows src tgt))   #'(cons 'follows (cons (symbol->string 'src) (symbol->string 'tgt)))]
    [(_ (no-flake))          #'(cons 'flake #f)]
    [(_ (flake b))           #'(cons 'flake b)]))

(define (build-flake clauses)
  (define description (lookup clauses 'description))
  (define inputs-list (or (lookup clauses 'inputs) '()))
  (define outputs-spec (lookup clauses 'outputs))
  ;; Build the inputs = { ... } attrset.
  (define inputs-entries
    (map (lambda (e)
           (define name (car e))
           (define url (cadr e))
           (define opts (caddr e))
           (define follows-pairs (filter-map (lambda (p) (and (eq? (car p) 'follows) (cdr p))) opts))
           (define flake-flag (lookup-pair opts 'flake))
           (define url-entry
             (mk-entry (string-append name ".url")
                       (if (string? url) (nix-string (list url)) url)))
           (define follows-entries
             (map (lambda (pair)
                    (let ([src (car pair)] [tgt (cdr pair)])
                      (mk-entry (string-append name ".inputs." src ".follows")
                                (nix-string (list tgt)))))
                  follows-pairs))
           (define flake-entry
             (and (not (eq? flake-flag no-flake-default-marker))
                  (boolean? flake-flag)
                  (mk-entry (string-append name ".flake") flake-flag)))
           (filter values (cons url-entry (append follows-entries (list flake-entry)))))
         inputs-list))
  (define inputs-flat (apply append inputs-entries))
  ;; Build outputs = { args }: body-expr.
  (define outputs-args (car outputs-spec))
  (define outputs-bodies (cadr outputs-spec))
  ;; If single non-entry body (e.g. let-in or attrs), use as-is.
  ;; Otherwise treat as a list of attr-entries and wrap.
  (define outputs-body
    (cond
      [(null? outputs-bodies) (att* '())]
      [(and (= 1 (length outputs-bodies))
            (not (nix-attr-entry? (car outputs-bodies))))
       (car outputs-bodies)]
      [else (att* (flatten-entries outputs-bodies))]))
  (define outputs-fn
    (nix-lambda
      (lp-attrs (map (lambda (a) (list a #f)) outputs-args) #t #f)
      outputs-body))
  ;; Top-level flake attrset
  (nix-attrs
    (append
      (if description
          (list (mk-entry "description" (nix-string (list description))))
          '())
      (list (mk-entry "inputs" (nix-attrs inputs-flat)))
      (list (mk-entry "outputs" outputs-fn)))))

(define no-flake-default-marker (gensym 'no-flake-flag))
(define (lookup-pair lst k)
  (let loop ([xs lst])
    (cond [(null? xs) (if (eq? k 'flake) no-flake-default-marker #f)]
          [(eq? (car (car xs)) k) (cdr (car xs))]
          [else (loop (cdr xs))])))

;; =========================================================================
;; Module-begin: collect top-level forms, emit Nix
;; =========================================================================
(define-syntax (nisp-module-begin stx)
  (syntax-case stx ()
    [(_ form ...)
     #'(#%module-begin
        (let ([forms (list form ...)])
          (display (emit-toplevel forms))))]))

(define (emit-toplevel forms)
  ;; Find the file form (last nisp-file in the list)
  (define files (filter nisp-file? forms))
  (cond
    [(null? files)
     ;; No file form — collect attr entries and emit as a frag.
     (define entries (flatten-entries (filter (lambda (x) (not (void? x))) forms)))
     (string-append (emit (att* entries) 0) "\n")]
    [else
     (define f (car (reverse files)))
     (define kind (nisp-file-kind f))
     (define data (nisp-file-data f))
     (case kind
       [(module flake)  (string-append (emit data 0) "\n")]
       [(raw)            (string-append (emit data 0) "\n")]
       [(frag)           (string-append (emit data 0) "\n")]
       [else (error 'emit-toplevel "unknown file kind: ~a" kind)])]))

;; =========================================================================
;; Emitter
;; =========================================================================
(define (indent n) (make-string (* 2 n) #\space))

(define (emit expr depth)
  (cond
    [(nix-bool? expr) (if (nix-bool-v expr) "true" "false")]
    [(nix-int? expr) (number->string (nix-int-v expr))]
    [(nix-null? expr) "null"]
    [(nix-string? expr) (emit-string expr depth)]
    [(nix-mstring? expr) (emit-mstring expr depth)]
    [(nix-path? expr) (nix-path-text expr)]
    [(nix-ident? expr) (nix-ident-name expr)]
    [(nix-list? expr) (emit-list expr depth)]
    [(nix-attrs? expr) (emit-attrs (nix-attrs-entries expr) depth #f)]
    [(nix-rec-attrs? expr) (emit-attrs (nix-rec-attrs-entries expr) depth #t)]
    [(nix-let? expr) (emit-let expr depth)]
    [(nix-with? expr) (emit-with expr depth)]
    [(nix-if? expr) (emit-if expr depth)]
    [(nix-app? expr) (emit-app expr depth)]
    [(nix-lambda? expr) (emit-lambda expr depth)]
    [(nix-binop? expr) (emit-binop expr depth)]
    [(nix-import? expr) (emit-import expr depth)]
    [(nix-inherit? expr) (emit-inherit expr depth)]
    [(boolean? expr) (if expr "true" "false")]
    [(string? expr) (string-append "\"" (escape-string expr) "\"")]
    [(number? expr) (number->string expr)]
    [(symbol? expr) (symbol->string expr)]
    [(list? expr) (emit-list (nix-list (map as-value expr)) depth)]
    [else (error 'emit "unknown expr: ~v" expr)]))

(define (escape-string s)
  (let* ([s (regexp-replace* #rx"\\\\" s "\\\\\\\\")]
         [s (regexp-replace* #rx"\"" s "\\\\\"")]
         [s (regexp-replace* #rx"\n" s "\\\\n")])
    s))

(define (emit-string ns depth)
  (define parts (nix-string-parts ns))
  (define rendered
    (apply string-append
      (map (lambda (p)
             (cond
               [(string? p) (escape-string p)]
               [else (string-append "${" (emit p depth) "}")]))
           parts)))
  (string-append "\"" rendered "\""))

(define (emit-mstring ms depth)
  (define lines (nix-mstring-lines ms))
  (define ind (indent (+ depth 1)))
  (define (render-line l)
    (cond
      [(string? l) l]
      [(nix-string? l)
       ;; Multi-part line: emit each part, with ${...} around non-string parts.
       (apply string-append
         (map (lambda (p)
                (if (string? p) p (string-append "${" (emit p depth) "}")))
              (nix-string-parts l)))]
      [else (string-append "${" (emit l depth) "}")]))
  (cond
    [(null? lines) "\"\""]
    [else
     (string-append
       "''\n"
       (string-join (map (lambda (l) (string-append ind (render-line l))) lines) "\n")
       "\n" (indent depth) "''")]))

(define (emit-list nl depth)
  (define items (nix-list-items nl))
  (define (one x d)
    ;; Parenthesize complex items so Nix parses them as a single list element.
    (parens-if-needed (emit x d) x))
  (cond
    [(null? items) "[ ]"]
    [(short-list? items depth)
     (string-append "[ "
                    (string-join (map (lambda (x) (one x depth)) items) " ")
                    " ]")]
    [else
     (define ind (indent (+ depth 1)))
     (string-append "[\n"
                    (string-join
                      (map (lambda (x) (string-append ind (one x (+ depth 1)))) items)
                      "\n")
                    "\n" (indent depth) "]")]))

(define (short-list? items depth)
  (and (<= (length items) 6)
       (andmap (lambda (x)
                 (or (nix-ident? x)
                     (nix-bool? x)
                     (nix-int? x)
                     (nix-null? x)
                     (and (nix-string? x)
                          (= (length (nix-string-parts x)) 1)
                          (string? (car (nix-string-parts x))))
                     (nix-path? x)))
               items)))

(define (emit-attrs entries depth rec?)
  (define tag (if rec? "rec {" "{"))
  (cond
    [(null? entries) (if rec? "rec { }" "{ }")]
    [else
     (define ind (indent (+ depth 1)))
     (string-append tag "\n"
                    (string-join
                      (map (lambda (e) (string-append ind (emit-entry e (+ depth 1)))) entries)
                      "\n")
                    "\n" (indent depth) "}")]))

(define (emit-entry e depth)
  (cond
    [(nix-inherit? e) (string-append (emit-inherit e depth) ";")]
    [else
     (define path (nix-attr-entry-path e))
     (define value (nix-attr-entry-value e))
     (string-append (emit-attr-path path depth)
                    " = "
                    (emit value depth)
                    ";")]))

(define (emit-attr-path path depth)
  (string-join
    (map (lambda (seg)
           (cond
             [(string? seg) seg]
             [else (string-append "${" (emit seg depth) "}")]))
         path)
    "."))

(define (emit-let nl depth)
  (define binds (nix-let-binds nl))
  (define body (nix-let-body nl))
  (define ind (indent (+ depth 1)))
  (define bind-lines
    (map (lambda (b)
           (string-append ind (car b) " = " (emit (cadr b) (+ depth 1)) ";"))
         binds))
  (string-append "let\n"
                 (string-join bind-lines "\n")
                 "\n" (indent depth) "in\n"
                 (indent depth)
                 (emit body depth)))

(define (emit-with nl depth)
  (string-append "with " (emit (nix-with-ns nl) depth) "; "
                 (emit (nix-with-body nl) depth)))

(define (emit-if expr depth)
  (string-append "if " (emit (nix-if-c expr) depth)
                 " then " (emit (nix-if-t expr) depth)
                 " else " (emit (nix-if-e expr) depth)))

(define (emit-app expr depth)
  (define f (nix-app-fn expr))
  (define args (nix-app-args expr))
  (define rendered-args
    (map (lambda (a) (parens-if-needed (emit a depth) a)) args))
  (string-append (parens-if-needed (emit f depth) f) " "
                 (string-join rendered-args " ")))

(define (parens-if-needed text node)
  (cond
    [(or (nix-app? node)
         (nix-lambda? node)
         (nix-let? node)
         (nix-with? node)
         (nix-if? node)
         (nix-binop? node))
     (string-append "(" text ")")]
    [else text]))

(define (emit-lambda expr depth)
  (define p (nix-lambda-params expr))
  (define body (nix-lambda-body expr))
  (cond
    ;; At depth 0 (file top), use blank line for module preamble readability
    [(and (zero? depth) (or (nix-let? body) (nix-attrs? body)))
     (string-append (emit-params p depth) ":\n\n" (emit body depth))]
    [else
     (string-append (emit-params p depth) ": " (emit body depth))]))

(define (emit-params p depth)
  (cond
    [(lp-simple? p) (lp-simple-name p)]
    [(lp-attrs? p)
     (define entries (lp-attrs-entries p))
     (define rest? (lp-attrs-rest? p))
     (define formals
       (map (lambda (e)
              (let ([n (car e)] [d (cadr e)])
                (cond [d (string-append n " ? " (emit d depth))]
                      [else n])))
            entries))
     (define inner (string-join (append formals (if rest? '("...") '())) ", "))
     (define base (string-append "{ " inner " }"))
     (cond [(lp-attrs-at-name p)
            (string-append base " @ " (lp-attrs-at-name p))]
           [else base])]))

(define (emit-binop expr depth)
  (define op (nix-binop-op expr))
  (define l (nix-binop-l expr))
  (define r (nix-binop-r expr))
  (string-append (parens-if-needed (emit l depth) l)
                 " " (symbol->string op) " "
                 (parens-if-needed (emit r depth) r)))

(define (emit-import expr depth)
  (string-append "import " (parens-if-needed (emit (nix-import-target expr) depth)
                                              (nix-import-target expr))))

(define (emit-inherit expr depth)
  (define ns (nix-inherit-ns expr))
  (define names (nix-inherit-names expr))
  (cond
    [ns (string-append "inherit (" (emit ns depth) ") "
                       (string-join names " "))]
    [else (string-append "inherit " (string-join names " "))]))
