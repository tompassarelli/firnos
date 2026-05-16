#lang racket/base

;; firn-cmds/pipeline — edges for repo-level pipeline commands
;; (build, validate, lint). These wrap the standalone bash scripts in
;; scripts/ so they're accessible via `fi repo build`, etc.

(require "util.rkt")

(provide node-edges)

;; fi repo build [all]     — regenerate .nix from .rkt
;; fi repo validate [all]  — lint-nix + nisp validate (with auto package cache)
;; fi repo lint [all]      — syntax-check generated .nix only

(define (handle-repo-build _leaf)
  (printf ">> firn-build\n")
  (unless (sh (path->string (in-repo "scripts" "firn-build")))
    (eprintf "fi repo build: failed.\n") (exit 1)))

(define (handle-repo-validate _leaf)
  (printf ">> firn-validate\n")
  (unless (sh (path->string (in-repo "scripts" "firn-validate")))
    (eprintf "fi repo validate: failed.\n") (exit 1)))

(define (handle-repo-lint _leaf)
  (printf ">> firn-lint-nix\n")
  (unless (sh (path->string (in-repo "scripts" "firn-lint-nix")))
    (eprintf "fi repo lint: failed.\n") (exit 1)))

(define node-edges
  (list
   (walk-edge "repo" "build" "[all]" 'all
              handle-repo-build
              "regenerate .nix from .rkt sources")
   (walk-edge "repo" "validate" "[all]" 'all
              handle-repo-validate
              "lint .nix syntax + validate option paths, types, packages")
   (walk-edge "repo" "lint" "[all]" 'all
              handle-repo-lint
              "syntax-check generated .nix files")))
