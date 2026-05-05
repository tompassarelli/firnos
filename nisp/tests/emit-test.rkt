#lang racket/base

;; emit-test — exercise every nisp surface form and AST node by checking
;; the rendered Nix matches the expected string. Run with:
;;
;;   raco test nisp/tests/emit-test.rkt
;;   racket nisp/tests/emit-test.rkt
;;
;; These tests bypass the #lang nisp module-begin and call the emitter on
;; values built via the surface forms — so they verify the AST + emitter
;; without going through file-level scaffolding.

(require rackunit
         (only-in nisp
                  ;; literals + atoms
                  s ms p nl
                  ;; compound
                  lst att rec-att merge concat-list cat bop
                  ;; expressions
                  if-then let-in with-do fn fn-set fn-set-rest fn-set@
                  call inh inh-from
                  ;; ops
                  not neg and or impl
                  == != < > <= >= + - * /
                  get get-or has assert-do spath pipe-to pipe-from
                  ;; mk*
                  mkif mkdefault mkforce mkmerge mkenable mkopt
                  ;; types
                  t-bool t-str t-int t-listof t-nullor t-enum
                  ;; AST + emitter
                  emit nix-ident nix-int nix-bool nix-string nix-null nix-path))

(define (e v) (emit v 0))

;; ---------- atoms ----------

(test-case "literals"
  (check-equal? (e (nix-bool #t)) "true")
  (check-equal? (e (nix-bool #f)) "false")
  (check-equal? (e (nix-int 42)) "42")
  (check-equal? (e (nix-int -7)) "-7")
  (check-equal? (e (nix-null)) "null")
  (check-equal? (e (nl)) "null")
  (check-equal? (e (nix-string '("hello"))) "\"hello\"")
  (check-equal? (e (p "./foo")) "./foo")
  (check-equal? (e (p "/abs/path")) "/abs/path"))

(test-case "string interpolation"
  (check-equal? (e (s "hello, " (nix-ident "name"))) "\"hello, ${name}\"")
  (check-equal? (e (s "a" "b")) "\"ab\"")
  (check-equal? (e (s "x = " 42)) "\"x = ${42}\""))

(test-case "multi-line strings"
  (check-equal? (e (ms "line one" "line two"))
                "''\n  line one\n  line two\n''"))

;; ---------- compounds ----------

(test-case "lists"
  (check-equal? (e (lst)) "[ ]")
  (check-equal? (e (lst 1 2 3)) "[ 1 2 3 ]")
  (check-equal? (e (lst "a" "b")) "[ \"a\" \"b\" ]"))

(test-case "attrsets"
  (check-equal? (e (att (a 1) (b 2))) "{\n  a = 1;\n  b = 2;\n}")
  (check-equal? (e (att)) "{ }")
  (check-equal? (e (rec-att (a 1) (b 2))) "rec {\n  a = 1;\n  b = 2;\n}"))

;; ---------- binary ops ----------

(test-case "merge / concat / cat"
  (check-equal? (e (merge (att (a 1)) (att (b 2))))
                "{\n  a = 1;\n} // {\n  b = 2;\n}")
  (check-equal? (e (concat-list (lst 1) (lst 2))) "[ 1 ] ++ [ 2 ]")
  (check-equal? (e (cat (s "a") (s "b"))) "\"a\" + \"b\""))

(test-case "comparison"
  (check-equal? (e (== (nix-ident "x") 1)) "x == 1")
  (check-equal? (e (!= (nix-ident "x") 2)) "x != 2")
  (check-equal? (e (< (nix-ident "x") 3)) "x < 3")
  (check-equal? (e (> (nix-ident "x") 4)) "x > 4")
  (check-equal? (e (<= (nix-ident "x") 5)) "x <= 5")
  (check-equal? (e (>= (nix-ident "x") 6)) "x >= 6"))

(test-case "boolean"
  (check-equal? (e (and (nix-ident "a") (nix-ident "b"))) "a && b")
  (check-equal? (e (or  (nix-ident "a") (nix-ident "b"))) "a || b")
  (check-equal? (e (impl (nix-ident "a") (nix-ident "b"))) "a -> b")
  (check-equal? (e (and (nix-ident "a") (nix-ident "b") (nix-ident "c")))
                "(a && b) && c"))

(test-case "arithmetic"
  (check-equal? (e (+ 1 2)) "1 + 2")
  (check-equal? (e (- 5 2)) "5 - 2")
  (check-equal? (e (* 3 4)) "3 * 4")
  (check-equal? (e (/ 10 2)) "10 / 2")
  (check-equal? (e (+ 1 2 3)) "(1 + 2) + 3"))

;; ---------- unary ----------

(test-case "unary"
  (check-equal? (e (not (nix-ident "x"))) "!x")
  (check-equal? (e (neg 5)) "-5")
  (check-equal? (e (- 7)) "-7")
  (check-equal? (e (not (== (nix-ident "a") (nix-ident "b"))))
                "!(a == b)"))

;; ---------- attr access ----------

(test-case "get / get-or / has"
  (check-equal? (e (get (nix-ident "cfg") 'services.nginx.enable))
                "cfg.services.nginx.enable")
  (check-equal? (e (get-or (nix-ident "cfg") 'services.foo.port 80))
                "cfg.services.foo.port or 80")
  (check-equal? (e (has (nix-ident "cfg") 'services.bar))
                "cfg ? services.bar"))

;; ---------- assert / spath ----------

(test-case "assert"
  (check-equal? (e (assert-do (> (nix-ident "n") 0) (nix-ident "body")))
                "assert n > 0; body"))

(test-case "search path"
  (check-equal? (e (spath "nixpkgs")) "<nixpkgs>"))

(test-case "pipe operators"
  (check-equal? (e (pipe-to (nix-ident "x") (nix-ident "f"))) "x |> f")
  (check-equal? (e (pipe-from (nix-ident "f") (nix-ident "x"))) "f <| x")
  (check-equal? (e (pipe-to (pipe-to (nix-ident "x") (nix-ident "f")) (nix-ident "g")))
                "(x |> f) |> g"))

;; ---------- expressions ----------

(test-case "if-then-else"
  (check-equal? (e (if-then #t 1 2)) "if true then 1 else 2"))

(test-case "let-in"
  (check-equal? (e (let-in ([x 1]) (cat x 2)))
                "let\n  x = 1;\nin\nx + 2"))

(test-case "with"
  (check-equal? (e (with-do (nix-ident "pkgs") (lst (nix-ident "vim"))))
                "with pkgs; [ vim ]"))

;; ---------- lambdas ----------

(test-case "single-arg lambda"
  (check-equal? (e (fn x x)) "x: x"))

(test-case "curried lambda"
  (check-equal? (e (fn (a b) (+ a b))) "a: b: a + b"))

(test-case "set-pattern lambda"
  (check-equal? (e (fn-set (a b) (+ a b)))
                "{ a, b }: a + b"))

(test-case "set-pattern with default"
  (check-equal? (e (fn-set (a (b 5)) b))
                "{ a, b ? 5 }: b"))

(test-case "set-pattern with rest"
  (check-equal? (e (fn-set-rest (a b) a))
                "{ a, b, ... }: a"))

(test-case "at-pattern"
  (check-equal? (e (fn-set@ self (a b) self))
                "{ a, b } @ self: self"))

(test-case "function application"
  (check-equal? (e (call (nix-ident "f") 1 2)) "f 1 2")
  (check-equal? (e (call (nix-ident "f") (lst 1 2))) "f [ 1 2 ]"))

;; ---------- inherit ----------

(test-case "inherit"
  (check-equal? (e (att (inh a b))) "{\n  inherit a b;\n}")
  (check-equal? (e (att (inh-from pkgs vim git)))
                "{\n  inherit (pkgs) vim git;\n}"))

;; ---------- mk helpers ----------

(test-case "mkif / mkdefault / mkforce / mkmerge"
  (check-equal? (e (mkif (nix-ident "cond") (nix-ident "body")))
                "lib.mkIf cond body")
  (check-equal? (e (mkdefault 1)) "lib.mkDefault 1")
  (check-equal? (e (mkforce (lst 1 2))) "lib.mkForce [ 1 2 ]")
  (check-equal? (e (mkmerge (nix-ident "a") (nix-ident "b")))
                "lib.mkMerge [ a b ]"))

(test-case "mkenable / mkopt"
  (check-equal? (e (mkenable "thing"))
                "lib.mkEnableOption \"thing\"")
  (check-equal? (e (mkopt #:type (t-bool) #:default #f #:desc "x"))
                "lib.mkOption {\n  type = lib.types.bool;\n  default = false;\n  description = \"x\";\n}"))

;; ---------- type ctors ----------

(test-case "types"
  (check-equal? (e (t-bool)) "lib.types.bool")
  (check-equal? (e (t-listof (t-str))) "lib.types.listOf lib.types.str")
  (check-equal? (e (t-nullor (t-int))) "lib.types.nullOr lib.types.int")
  (check-equal? (e (t-enum "a" "b")) "lib.types.enum [ \"a\" \"b\" ]"))

;; ---------- precedence / parens ----------

(test-case "parens around nested binops"
  (check-equal? (e (and (== (nix-ident "x") 1)
                        (or (> (nix-ident "y") 0)
                            (has (nix-ident "cfg") 'foo.bar))))
                "(x == 1) && ((y > 0) || (cfg ? foo.bar))"))

(test-case "parens around if as binop arg"
  (check-equal? (e (cat (if-then #t (s "a") (s "b")) (s "c")))
                "(if true then \"a\" else \"b\") + \"c\""))
