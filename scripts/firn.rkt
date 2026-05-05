#!/usr/bin/env racket
#lang racket/base

;; firn — FirnOS config management CLI.
;;
;; Compile to a standalone binary with `./scripts/firn-build-bin`.
;;
;; Command implementations live in scripts/firn-cmds/*.rkt; this module
;; is just argv dispatch. Each command module imports util.rkt for
;; shared helpers (ROOT, sh, listing helpers, etc.).

(require "firn-cmds/rebuild.rkt"
         "firn-cmds/list.rkt"
         "firn-cmds/secret.rkt"
         "firn-cmds/toggle.rkt"
         "firn-cmds/diff.rkt"
         "firn-cmds/watch.rkt"
         "firn-cmds/scaffold.rkt"
         "firn-cmds/explain.rkt"
         "firn-cmds/doctor.rkt"
         "firn-cmds/upgrade.rkt")

(define (cmd-help _args)
  (printf #<<HELP
firn — FirnOS config management

Usage:
  firn <command> [args...]

Commands:
  rebuild [host] [--skip-checks]  firn-build + validate, then nixos-rebuild + tag
  watch                       re-run validator on .rkt save (no external deps)
  list                        list all modules and bundles
  list --used                 show modules/bundles in use and where
  list --unused               show unreferenced modules/bundles
  refs <name>                 show what references a module/bundle
  mod <name>                  scaffold a minimal module (.rkt)
  bundle <name> <mods...>     scaffold a new bundle (.rkt)
  scaffold <pat> <name>       template scaffold (service|submodule|home|host)
  diff [target...]            re-emit Nix from .rkt and diff vs committed .nix
  secret <name|list|show>     sops edit / list / decrypt
  gen                         current and next generation numbers
  enable <name> [host]        toggle a module/bundle on in host config
  disable <name> [host]       toggle a module/bundle off in host config
  status [host]               list enabled modules/bundles for host
  explain <path|err-line>     show schema entry + references for an option
  doctor                      run repo health checks (untracked, stale, validator)
  upgrade [--dry-run]         flake update + schema-diff vs previous + validate

HELP
  ))

(define (main argv)
  (cond
    [(null? argv) (cmd-help argv)]
    [else
     (define cmd (car argv))
     (define rest (cdr argv))
     (case cmd
       [("rebuild")     (cmd-rebuild rest)]
       [("watch")       (cmd-watch rest)]
       [("list")        (cmd-list rest)]
       [("refs")        (cmd-refs rest)]
       [("mod")         (cmd-mod rest)]
       [("bundle")      (cmd-bundle rest)]
       [("scaffold")    (cmd-scaffold rest)]
       [("diff")        (cmd-diff rest)]
       [("secret")      (cmd-secret rest)]
       [("gen")         (cmd-gen rest)]
       [("enable")      (cmd-enable rest)]
       [("disable")     (cmd-disable rest)]
       [("status")      (cmd-status rest)]
       [("explain")     (cmd-explain rest)]
       [("doctor")      (cmd-doctor rest)]
       [("upgrade")     (cmd-upgrade rest)]
       [("help" "-h" "--help") (cmd-help rest)]
       [else
        (eprintf "firn: unknown command '~a'\n\n" cmd)
        (cmd-help rest)
        (exit 1)])]))

(main (vector->list (current-command-line-arguments)))
