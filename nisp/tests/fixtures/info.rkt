#lang info
;; Fixtures are run as subprocesses by validator-test.rkt — don't let
;; `raco test` invoke them directly (they'd emit Nix to stdout, which
;; isn't a test pass/fail signal).
(define test-omit-paths 'all)
