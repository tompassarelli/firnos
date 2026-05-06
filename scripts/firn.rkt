#!/usr/bin/env racket
#lang racket/base

;; firn — FirnOS config management CLI.
;;
;; Compile to a standalone binary with `./scripts/firn-build-bin`.
;;
;; Each command implementation lives in scripts/firn-cmds/*.rkt. Each
;; cmd module exports a `commands` list of (cmd name usage desc fn)
;; entries; this file imports each module under a unique prefix and
;; concatenates them. Help text and dispatch both read from that one
;; list, so the CLI's surface can never go out of sync with what's
;; actually wired up — adding a new command means writing one module
;; and adding it to ALL-CMDS below.

(require racket/list
         racket/format
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
         (prefix-in tg: "firn-cmds/tags.rkt"))

(define ALL-CMDS
  (append r:commands
          w:commands
          l:commands
          t:commands
          sc:commands
          d:commands
          s:commands
          e:commands
          dr:commands
          u:commands
          p:commands
          tg:commands))

(define (cmd-help _args)
  (printf "firn — FirnOS config management\n\n")
  (printf "Usage:\n  firn <command> [args...]\n\n")
  (printf "Commands:\n")
  (define widest
    (apply max
           (map (λ (c)
                  (string-length
                   (string-append (cmd-name c)
                                  (if (zero? (string-length (cmd-usage c))) ""
                                      (string-append " " (cmd-usage c))))))
                ALL-CMDS)))
  (for ([c (in-list ALL-CMDS)])
    (define head
      (string-append (cmd-name c)
                     (if (zero? (string-length (cmd-usage c))) ""
                         (string-append " " (cmd-usage c)))))
    (printf "  ~a  ~a\n" (~a head #:min-width widest) (cmd-desc c))))

(define (find-cmd name)
  (findf (λ (c) (equal? (cmd-name c) name)) ALL-CMDS))

(define (main argv)
  (cond
    [(null? argv) (cmd-help argv)]
    [else
     (define name (car argv))
     (define rest (cdr argv))
     (cond
       [(member name '("help" "-h" "--help")) (cmd-help rest)]
       [(find-cmd name) => (λ (c) ((cmd-fn c) rest))]
       [else
        (eprintf "firn: unknown command '~a'\n\n" name)
        (cmd-help rest)
        (exit 1)])]))

(main (vector->list (current-command-line-arguments)))
