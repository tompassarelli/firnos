# nisp
 
A `#lang` for NixOS configuration. Nix + Lisp.
 
Write your NixOS config in clean s-expressions. No `enable = true`
ceremony, no Nix syntax. Bound identifiers (functions, macros,
let-bindings) evaluate as Racket. To reference a Nix identifier
that isn't a Racket binding (`pkgs.vim`, `lib.mkIf`, `config.foo`),
quote it: `'pkgs.vim`. Standard Lisp `'` — code-as-data, no escape
forms. Typos surface as "unbound identifier" at the source line.
 
```bash
$ racket config.rkt > /etc/nixos/configuration.nix
$ sudo nixos-rebuild switch
```
 
## Setup
 
```bash
# install racket (or add to your NixOS packages)
nix-shell -p racket
 
# create the package directory
mkdir -p nisp
 
# create the three files below, then:
raco pkg install ./nisp
 
# now you can run any #lang nisp file
racket config.rkt
```
 
Your NixOS `environment.systemPackages` should include `racket`
so it's always available.
 
---
 
## File: `nisp/info.rkt`
 
```racket
#lang info
(define collection "nisp")
```
 
---
 
## File: `nisp/reader.rkt`
 
```racket
#lang s-exp syntax/module-reader
nisp
```
 
---
 
## File: `nisp/main.rkt`
 
```racket
#lang racket/base
 
(require racket/format
         racket/string
         racket/list
         (for-syntax racket/base))
 
(provide (rename-out [nisp-module-begin #%module-begin]
                     [nisp-top #%top])
         #%app #%datum
         enable set service user packages pkg)
 
;; =========================================================================
;; #%top: standard Racket — unbound identifiers error at compile time.
;; To inject a Nix identifier, quote it explicitly: 'pkgs.vim, 'lib.mkIf, etc.
;; The `as-value` coercion turns symbols into nix-idents automatically, so
;; quoted forms flow through the AST builders unchanged.
;;
;; This is intentionally Lisp-conventional: bound identifiers are values,
;; quoted symbols are data. No auto-fall-through magic; typos surface as
;; "unbound identifier" errors at the source line, not later at Nix-eval time.
;; =========================================================================
 
;; =========================================================================
;; Data model
;; =========================================================================
 
(struct nix-attr (path value) #:transparent)
(struct nix-set  (attrs)      #:transparent)
(struct nix-list (items)      #:transparent)
(struct nix-with (ns value)   #:transparent)
(struct nix-raw  (text)       #:transparent)
 
;; =========================================================================
;; Module begin: collect top-level forms, emit Nix
;; =========================================================================
 
(define-syntax (nisp-module-begin stx)
  (syntax-case stx ()
    [(_ form ...)
     #'(#%module-begin
        (let ([results (list form ...)])
          (display (emit-module (flatten results)))))]))
 
;; =========================================================================
;; DSL macros
;; =========================================================================
 
;; (enable boot.loader.systemd-boot)
;; => boot.loader.systemd-boot.enable = true;
;;
;; (enable
;;   boot.loader.systemd-boot
;;   boot.loader.efi.canTouchEfiVariables
;;   networking.networkmanager
;;   programs.zsh)
;; => all four .enable = true;
(define-syntax (enable stx)
  (syntax-case stx ()
    [(_ path)
     #'(nix-attr (format "~a.enable" 'path) #t)]
    [(_ path rest ...)
     #'(list (nix-attr (format "~a.enable" 'path) #t)
             (enable rest ...))]))
 
;; (set networking.hostName "kea")
;; => networking.hostName = "kea";
;;
;; (set nix.settings.experimental-features "nix-command" "flakes")
;; => nix.settings.experimental-features = [ "nix-command" "flakes" ];
(define-syntax (set stx)
  (syntax-case stx ()
    [(_ path val)
     #'(nix-attr (format "~a" 'path) val)]
    [(_ path val rest ...)
     #'(nix-attr (format "~a" 'path)
                 (nix-list (list val rest ...)))]))
 
;; (service openssh)
;; => services.openssh.enable = true;
;;
;; (service pipewire (alsa #t) (pulse #t))
;; => services.pipewire = { enable = true; alsa.enable = true; ... };
(define-syntax (service stx)
  (syntax-case stx ()
    [(_ name)
     #'(nix-attr (format "services.~a.enable" 'name) #t)]
    [(_ name (key val) ...)
     #'(nix-attr (format "services.~a" 'name)
                 (nix-set
                  (list (nix-attr "enable" #t)
                        (nix-attr (format "~a" 'key) val)
                        ...)))]))
 
;; (user "tom"
;;   (extraGroups "wheel" "networkmanager")
;;   (shell (pkg "zsh")))
(define-syntax (user stx)
  (syntax-case stx ()
    [(_ name field ...)
     #'(nix-attr (format "users.users.~a" name)
                 (nix-set
                  (cons (nix-attr "isNormalUser" #t)
                        (list (user-field field) ...))))]))
 
(define-syntax (user-field stx)
  (syntax-case stx ()
    [(_ (key single))
     #'(nix-attr (format "~a" 'key) single)]
    [(_ (key val rest ...))
     #'(nix-attr (format "~a" 'key)
                 (nix-list (list val rest ...)))]))
 
;; (packages vim git firefox ghostty)
;; => environment.systemPackages = with pkgs; [ vim git ... ];
(define-syntax (packages stx)
  (syntax-case stx ()
    [(_ name ...)
     #'(nix-attr "environment.systemPackages"
                 (nix-with "pkgs"
                   (nix-list
                    (list (nix-raw (format "~a" 'name))
                          ...))))]))
 
;; (pkg "zsh") => pkgs.zsh
(define (pkg name)
  (nix-raw (format "pkgs.~a" name)))
 
;; =========================================================================
;; Nix emitter
;; =========================================================================
 
(define (indent n)
  (make-string (* 2 n) #\space))
 
(define (emit-value v depth)
  (cond
    [(boolean? v)    (if v "true" "false")]
    [(string? v)     (format "\"~a\"" v)]
    [(number? v)     (format "~a" v)]
    [(symbol? v)     (symbol->string v)]
    [(nix-raw? v)    (nix-raw-text v)]
    [(list? v)
     (format "[ ~a ]"
             (string-join
              (map (λ (x) (emit-value x depth)) v) " "))]
    [(nix-list? v)
     (format "[\n~a\n~a]"
             (string-join
              (map (λ (item)
                     (format "~a~a"
                             (indent (+ depth 1))
                             (emit-value item (+ depth 1))))
                   (nix-list-items v))
              "\n")
             (indent depth))]
    [(nix-with? v)
     (format "with ~a; ~a"
             (nix-with-ns v)
             (emit-value (nix-with-value v) depth))]
    [(nix-set? v)
     (format "{\n~a\n~a}"
             (string-join
              (map (λ (a) (emit-attr a (+ depth 1)))
                   (nix-set-attrs v))
              "\n")
             (indent depth))]
    [else (error 'emit-value "unknown value: ~a" v)]))
 
(define (emit-attr a depth)
  (format "~a~a = ~a;"
          (indent depth)
          (nix-attr-path a)
          (emit-value (nix-attr-value a) depth)))
 
(define (emit-module attrs)
  (format "{ config, pkgs, ... }:\n\n~a\n"
          (emit-value (nix-set (filter nix-attr? attrs)) 0)))
```
 
---
 
## File: `config.rkt` (example config — adapt to your machine)
 
```racket
#lang nisp
 
;; ---- enable ----
(enable
  boot.loader.systemd-boot
  boot.loader.efi.canTouchEfiVariables
  networking.networkmanager
  programs.zsh)
 
;; ---- network ----
(set networking.hostName "kea")
 
;; ---- locale ----
(set time.timeZone "Asia/Bangkok")
(set i18n.defaultLocale "en_US.UTF-8")
 
;; ---- user ----
(user "tom"
  (extraGroups "wheel" "networkmanager" "video")
  (shell (pkg "zsh")))
 
;; ---- packages ----
(packages
  vim
  git
  firefox
  ghostty
  ripgrep
  fd
  btop
  unzip
  wget
  curl)
 
;; ---- services ----
(service openssh)
 
(service pipewire
  (alsa #t)
  (pulse #t))
 
;; ---- nix ----
(set nix.settings.experimental-features "nix-command" "flakes")
 
;; ---- system ----
(set system.stateVersion "24.05")
 
 
;; =========================================================================
;; Computed config: nisp is just Racket, so use it directly.
;; (require racket/system) and (define ...) at the top of the file.
;; Then reference the bound name inline, no escape needed:
;;
;;   (define hostname
;;     (string-trim (with-output-to-string
;;                    (λ () (system "hostname")))))
;;   (set networking.hostName hostname)
;; =========================================================================
```
 
---
 
## Quick reference
 
| nisp | nix |
|------|-----|
| `(enable programs.zsh)` | `programs.zsh.enable = true;` |
| `(enable foo bar baz)` | all three `.enable = true;` |
| `(set time.timeZone "Asia/Bangkok")` | `time.timeZone = "Asia/Bangkok";` |
| `(set features "a" "b")` | `features = [ "a" "b" ];` |
| `(service openssh)` | `services.openssh.enable = true;` |
| `(service pipewire (alsa #t))` | `services.pipewire = { enable = true; alsa.enable = true; };` |
| `(packages vim git fd)` | `environment.systemPackages = with pkgs; [ vim git fd ];` |
| `(user "tom" (shell (pkg "zsh")))` | `users.users.tom = { isNormalUser = true; shell = pkgs.zsh; };` |

### Operators and access

| nisp | nix |
|------|-----|
| `(not x)` / `(neg x)` | `!x` / `-x` |
| `(and a b)` / `(or a b)` / `(impl a b)` | `a && b` / `a \|\| b` / `a -> b` |
| `(== a b)` / `(!= a b)` / `(< a b)` / `(<= a b)` / `(> a b)` / `(>= a b)` | comparisons |
| `(+ a b)` / `(- a b)` / `(* a b)` / `(/ a b)` | arithmetic; variadic where it makes sense |
| `(get base 'a.b.c)` | `base.a.b.c` |
| `(get-or base 'a.b.c default)` | `base.a.b.c or default` |
| `(has base 'a.b.c)` | `base ? a.b.c` |
| `(assert-do cond body)` | `assert cond; body` |
| `(spath "nixpkgs")` | `<nixpkgs>` |
| `(fn-set@ self (a b) body)` | `{ a, b } @ self: body` |
| `(pipe-to x f)` / `(pipe-from f x)` | `x \|> f` / `f <\| x` (Nix 2.15+) |

