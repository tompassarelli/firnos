#!/usr/bin/env racket
#lang racket/base

;; firn — FirnOS config management CLI.
;;
;; Compile to a standalone binary with `./scripts/firn-build-bin`.
;;
;; CLI shape: a walkable entity-first graph. Every invocation is one
;; or more (node, edge, leaf) triples:
;;
;;   firn <node> <edge> <leaf> [<node> <edge> <leaf>]*
;;
;; e.g. `firn bundle status all`, `firn module enable swap`,
;;      `firn host rebuild whiterabbit`, `firn schema explain X`.
;;
;; If the final leaf is omitted, the edge's `default-leaf` fills in:
;;   'all          → literal "all"
;;   'current-host → (current-hostname), so `firn host rebuild` works
;;   #f            → leaf required; print usage and exit
;;
;; Each command lives in scripts/firn-cmds/*.rkt and exports a
;; `node-edges` list of walk-edge structs. firn.rkt concatenates them;
;; help text auto-groups by node so it never drifts from registered
;; handlers.
;;
;; Legacy shapes (firn status, firn rebuild, firn enable, ...) are
;; rewritten into the new walk by LEGACY-ALIASES below.

(require racket/list
         racket/format
         racket/string
         "firn-cmds/util.rkt"
         (prefix-in r:  "firn-cmds/rebuild.rkt")
         (prefix-in w:  "firn-cmds/watch.rkt")
         (prefix-in l:  "firn-cmds/list.rkt")
         (prefix-in t:  "firn-cmds/toggle.rkt")
         (prefix-in sc: "firn-cmds/scaffold.rkt")
         (prefix-in d:  "firn-cmds/diff.rkt")
         (prefix-in s:  "firn-cmds/secret.rkt")
         (prefix-in e:  "firn-cmds/explain.rkt")
         (prefix-in dr: "firn-cmds/doctor.rkt")
         (prefix-in u:  "firn-cmds/upgrade.rkt")
         (prefix-in p:  "firn-cmds/platforms.rkt")
         (prefix-in tg: "firn-cmds/tags.rkt")
         (prefix-in pl: "firn-cmds/pipeline.rkt"))

(define ALL-EDGES
  (append r:node-edges
          w:node-edges
          l:node-edges
          t:node-edges
          sc:node-edges
          d:node-edges
          s:node-edges
          e:node-edges
          dr:node-edges
          u:node-edges
          p:node-edges
          tg:node-edges
          pl:node-edges))

(define (lookup-edge node edge)
  (findf (λ (e) (and (equal? (walk-edge-node e) node)
                     (equal? (walk-edge-edge e) edge)))
         ALL-EDGES))

(define (nodes)
  (sort (remove-duplicates (map walk-edge-node ALL-EDGES)) string<?))

(define (edges-of node)
  (filter (λ (e) (equal? (walk-edge-node e) node)) ALL-EDGES))

;; ---------- dispatch ----------

(define (print-edge-usage e)
  (eprintf "Usage: fi ~a ~a ~a\n"
           (walk-edge-node e) (walk-edge-edge e) (walk-edge-leaf-shape e))
  (eprintf "  ~a\n" (walk-edge-desc e)))

(define (suggest-node node)
  (define ns (nodes))
  (eprintf "  available nodes: ~a\n" (string-join ns ", ")))

(define (suggest-edge node)
  (define es (edges-of node))
  (cond
    [(null? es)
     (eprintf "  no such node '~a'\n" node)
     (suggest-node node)]
    [else
     (eprintf "  edges on '~a': ~a\n" node
              (string-join (map walk-edge-edge es) ", "))]))

(define (dispatch tokens)
  (cond
    [(null? tokens) (cmd-help '())]
    [(< (length tokens) 2)
     (define node (car tokens))
     (cond
       [(member node (nodes))
        (printf "Edges on '~a':\n" node)
        (for ([e (in-list (edges-of node))])
          (printf "  fi ~a ~a ~a\n      ~a\n"
                  (walk-edge-node e) (walk-edge-edge e)
                  (walk-edge-leaf-shape e) (walk-edge-desc e)))]
       [else
        (eprintf "fi: incomplete walk; expected <node> <edge> [<leaf>]\n")
        (suggest-node node)
        (exit 1)])]
    [else
     (let loop ([tokens tokens])
       (cond
         [(null? tokens) (void)]
         [(< (length tokens) 2)
          (eprintf "fi: dangling token after a complete walk: ~a\n" (car tokens))
          (exit 1)]
         [else
          (define node (car tokens))
          (define edge (cadr tokens))
          (define e (lookup-edge node edge))
          (cond
            [(not e)
             (eprintf "fi: unknown walk '~a ~a'\n" node edge)
             (suggest-edge node)
             (exit 1)]
            [else
             (define rest (cddr tokens))
             (define def (resolve-default (walk-edge-default-leaf e)))
             ;; If the next two tokens already form a known (node, edge)
             ;; pair, the user is chaining and intends to omit this leaf.
             ;; Falls back to consuming the next token as leaf when no
             ;; chain follows.
             (define chained-next?
               (and (>= (length rest) 2)
                    (lookup-edge (car rest) (cadr rest))))
             (define-values (leaf next-rest)
               (cond
                 [(and def chained-next?) (values def rest)]
                 [(null? rest)
                  (cond
                    [def (values def '())]
                    [else
                     (eprintf "fi: '~a ~a' requires a leaf node\n" node edge)
                     (print-edge-usage e)
                     (exit 1)])]
                 [else (values (car rest) (cdr rest))]))
             ((walk-edge-handler e) leaf)
             (loop next-rest)])]))]))

;; ---------- legacy aliases ----------
;;
;; Each entry: (old-first-token, rewrite-fn). The rewrite-fn takes the
;; remaining argv (after the first token is consumed) and returns the
;; new token list, or #f to fall through.

(define LEGACY-ALIASES
  (list
    ;; firn status [host] [--bundles]
    (cons "status"
          (λ (args)
            (define bundles? (member "--bundles" args))
            (define rest (filter (λ (a) (not (equal? a "--bundles"))) args))
            (define host (and (pair? rest) (car rest)))
            (cond
              [bundles? (list "bundle" "status" "all")]
              [host     (list "host" "status" host)]
              [else     (list "host" "status")])))
    ;; firn enable <name> [host]
    (cons "enable"
          (λ (args)
            (cond
              [(null? args) #f]
              [else
               (define name (car args))
               (define kind (find-name-kind name))
               (case kind
                 [(module) (list "module" "enable" name)]
                 [(bundle) (list "bundle" "enable" name)]
                 [else #f])])))
    (cons "disable"
          (λ (args)
            (cond
              [(null? args) #f]
              [else
               (define name (car args))
               (define kind (find-name-kind name))
               (case kind
                 [(module) (list "module" "disable" name)]
                 [(bundle) (list "bundle" "disable" name)]
                 [else #f])])))
    ;; firn rebuild [host] [--skip-checks]
    (cons "rebuild"
          (λ (args)
            ;; Pass --skip-checks through by appending after the leaf;
            ;; host-rebuild handler reads it from its argv tail. Simplest:
            ;; pack everything into the leaf via a sentinel join.
            (cond
              [(member "--skip-checks" args)
               (define host (or (findf (λ (a) (not (equal? a "--skip-checks"))) args) "current"))
               (list "host" "rebuild" (string-append host "+skip"))]
              [else
               (define host (if (pair? args) (car args) "current"))
               (list "host" "rebuild" host)])))
    (cons "doctor"  (λ (_) (list "host"   "doctor")))
    (cons "gen"     (λ (_) (list "host"   "gen")))
    (cons "diff"    (λ (args)
                      (define semantic? (member "--semantic" args))
                      (define rest (filter (λ (a) (not (equal? a "--semantic"))) args))
                      (define target (if (pair? rest) (car rest) "all"))
                      (cond [semantic? (list "repo" "sdiff" target)]
                            [else      (list "repo" "diff" target)])))
    (cons "upgrade" (λ (args) (cond [(member "--dry-run" args) (list "repo" "upgrade" "dry-run")]
                                    [else                      (list "repo" "upgrade" "now")])))
    (cons "watch"   (λ (_) (list "repo" "watch")))
    (cons "list"    (λ (args)
                      (cond
                        [(member "--used" args)   (list "module" "list" "used"
                                                        "bundle" "list" "used")]
                        [(member "--unused" args) (list "module" "list" "unused"
                                                        "bundle" "list" "unused")]
                        [else                     (list "module" "list" "all"
                                                        "bundle" "list" "all")])))
    (cons "refs"    (λ (args)
                      (cond
                        [(null? args) #f]
                        [else (list "module" "refs" (car args))])))
    (cons "mod"     (λ (args)
                      (cond [(null? args) #f]
                            [else (list "module" "add" (car args))])))
    ;; old `firn bundle <name> <mod1> <mod2> ...` → `firn bundle add <name>+<mods>`.
    ;; Requires ≥ 2 args; the single-arg case is ambiguous with an
    ;; unknown-edge typo and is left to dispatch to error on.
    (cons "bundle"  (λ (args)
                      (cond
                        [(< (length args) 2) #f]
                        [(member (cadr args)
                                 '("add" "enable" "disable" "status" "refs" "list"))
                         #f]
                        [else
                         (define name (car args))
                         (define mods (cdr args))
                         (list "bundle" "add"
                               (string-append name "+" (string-join mods ",")))])))
    (cons "scaffold" (λ (args)
                       (cond [(< (length args) 2) #f]
                             [else (list "template" (car args) (cadr args))])))
    (cons "explain"  (λ (args)
                       (cond [(null? args) #f]
                             [else (list "schema" "explain" (string-join args " "))])))
    (cons "secret"   (λ (args)
                       (cond
                         [(null? args) #f]
                         [(equal? (car args) "list") (list "secret" "list" "all")]
                         [(equal? (car args) "show")
                          (cond [(null? (cdr args)) #f]
                                [else (list "secret" "show" (cadr args))])]
                         [else (list "secret" "edit" (car args))])))
    (cons "tags"     (λ (args)
                       (cond
                         [(null? args) (list "tag" "list" "all")]
                         [(equal? (car args) "--index")
                          (cond [(member "--stdout" args) (list "tag" "index" "stdout")]
                                [else                     (list "tag" "index" "repo")])]
                         [(equal? (car args) "--filter")
                          (cond [(null? (cdr args)) #f]
                                [else (list "tag" "filter" (cadr args))])]
                         [else (list "tag" "show" (car args))])))
    (cons "platforms" (λ (args)
                        (cond
                          [(null? args) (list "platform" "list" "all")]
                          [(equal? (car args) "darwin")     (list "platform" "list" "darwin")]
                          [(equal? (car args) "linux")      (list "platform" "list" "linux")]
                          [(equal? (car args) "--bundles")  (list "platform" "list" "bundles")]
                          [(equal? (car args) "--safelist") (list "platform" "safelist" "all")]
                          [else (list "platform" "show" (car args))])))
    (cons "build"    (λ (_) (list "repo" "build")))
    (cons "validate" (λ (_) (list "repo" "validate")))
    (cons "lint"     (λ (_) (list "repo" "lint")))
    (cons "impact"   (λ (args)
                       (define host (if (pair? args) (car args) "current"))
                       (list "host" "impact" host)))))

(define (maybe-legacy-rewrite tokens)
  ;; Returns the rewritten token list if the first token is a legacy
  ;; command name AND the second token is NOT a known edge of an entity
  ;; named by the first token (which would mean the user is already
  ;; using the entity-first shape).
  (cond
    [(null? tokens) tokens]
    [else
     (define first (car tokens))
     (define rest (cdr tokens))
     (cond
       ;; If first token is a registered node AND there's a 2nd token
       ;; that's a known edge of it, don't rewrite — they're using the
       ;; entity-first shape.
       [(and (member first (nodes))
             (pair? rest)
             (lookup-edge first (car rest)))
        tokens]
       [else
        (define alias (assoc first LEGACY-ALIASES))
        (cond
          [alias
           (define rewritten ((cdr alias) rest))
           (cond
             [rewritten rewritten]
             [else tokens])]
          [else tokens])])]))

;; ---------- help ----------

(define (cmd-help _args)
  (printf "fi — FirnOS config management\n\n")
  (printf "Usage:\n  fi <node> <edge> [<leaf>]  [<node> <edge> [<leaf>] ...]\n\n")
  (printf "Common shortcuts (default host is auto-detected):\n")
  (printf "  fi rebuild          build + validate + switch (current host)\n")
  (printf "  fi build            regenerate .nix from .rkt\n")
  (printf "  fi validate         lint + type/package/path check\n")
  (printf "  fi impact           what will rebuild, estimated time\n")
  (printf "  fi doctor           repo health check\n")
  (printf "  fi status           enabled modules/bundles\n")
  (printf "  fi enable <name>    toggle a module or bundle on\n")
  (printf "  fi disable <name>   toggle off\n")
  (printf "  fi diff             re-emit and diff vs committed .nix\n")
  (printf "  fi diff --semantic  option-level changelog\n")
  (printf "\nFull graph:\n\n")
  (for ([n (in-list (nodes))])
    (printf "~a\n" n)
    (define widest
      (apply max 0
             (map (λ (e) (string-length
                          (string-append (walk-edge-edge e) " "
                                         (walk-edge-leaf-shape e))))
                  (edges-of n))))
    (for ([e (in-list (edges-of n))])
      (define head (string-append (walk-edge-edge e) " " (walk-edge-leaf-shape e)))
      (printf "  ~a  ~a\n" (~a head #:min-width widest) (walk-edge-desc e)))
    (newline)))

;; ---------- main ----------

(define (main argv)
  (cond
    [(null? argv) (cmd-help argv)]
    [(member (car argv) '("help" "-h" "--help")) (cmd-help (cdr argv))]
    [else
     (dispatch (maybe-legacy-rewrite argv))]))

(main (vector->list (current-command-line-arguments)))
