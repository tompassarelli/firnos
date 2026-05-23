#lang racket/base

;; validator-test — integration tests for firn-validate's output.
;;
;; Each test runs firn-validate against a fixture .bnix with a known kind
;; of bug, then asserts the stderr contains the expected substrings:
;; the file:line:col anchor, the diagnostic text, and (where applicable)
;; the did-you-mean suggestion.
;;
;; Run:
;;   raco test tests/validator-test.rkt
;;
;; Requires .nisp-cache/schema.json to exist (from firn-extract-schema).
;; Submodule cache is auto-populated on first run via lazy expansion.

(require rackunit
         racket/path
         racket/port
         racket/system
         racket/string
         racket/runtime-path)

(define-runtime-path FIXTURES-DIR "fixtures")

;; Locate firn-validate relative to this test file. tests/ is one level
;; from the repo root, and scripts/firn-validate is there.
(define-runtime-path FIRN-VALIDATE "../scripts/firn-validate")

(define (run-validator fixture-name)
  ;; Returns (values stdout-string stderr-string exit-code).
  (define fixture (build-path FIXTURES-DIR fixture-name))
  (define out-port (open-output-string))
  (define err-port (open-output-string))
  (define rc
    (parameterize ([current-output-port out-port]
                   [current-error-port err-port])
      (system* (path->string FIRN-VALIDATE) (path->string fixture))))
  (values (get-output-string out-port)
          (get-output-string err-port)
          (if rc 0 1)))

(define (combined-output fixture-name)
  ;; Most validator output goes to stderr; concat for matching simplicity.
  (define-values (out err _) (run-validator fixture-name))
  (string-append out err))

(define-syntax-rule (check-output-contains fixture pat)
  (check-not-false
   (regexp-match? pat (combined-output fixture))
   (format "expected output of ~a to match ~v" fixture pat)))

(define-syntax-rule (check-output-clean fixture)
  (let-values ([(out err rc) (run-validator fixture)])
    (check-equal? rc 0 (format "expected ~a to validate clean, got rc=~a, err:\n~a"
                               fixture rc err))
    (check-not-false
     (regexp-match? #rx"clean" (string-append out err))
     (format "expected ~a output to mention 'clean'" fixture))))

;; ---------- Phase 1: unknown path ----------

(test-case "unknown path: file:line:col + did-you-mean"
  (check-output-contains "unknown-path.bnix"
    #rx"unknown-path\\.bnix:6:[0-9]+: unknown option services\\.pipwire\\.alsa\\.enable")
  (check-output-contains "unknown-path.bnix"
    #rx"did you mean: services\\.pipewire"))

;; ---------- Phase 2: type mismatch ----------

(test-case "bool option assigned a string"
  (check-output-contains "type-mismatch-bool.bnix"
    #rx"type-mismatch-bool\\.bnix:6:[0-9]+: type mismatch at services\\.openssh\\.enable")
  (check-output-contains "type-mismatch-bool.bnix"
    #rx"expected bool, got string"))

(test-case "enum value not in allowed set, with did-you-mean"
  (check-output-contains "enum-mismatch.bnix"
    #rx"enum-mismatch\\.bnix:6:[0-9]+: type mismatch at boot\\.loader\\.systemd-boot\\.consoleMode")
  (check-output-contains "enum-mismatch.bnix"
    #rx"\"atuo\" not in enum")
  (check-output-contains "enum-mismatch.bnix"
    #rx"did you mean \"auto\""))

(test-case "listOf int with string elements"
  (check-output-contains "listof-int-wrong-element.bnix"
    #rx"listof-int-wrong-element\\.bnix:6:[0-9]+: type mismatch at networking\\.firewall\\.allowedTCPPorts")
  (check-output-contains "listof-int-wrong-element.bnix"
    #rx"expected unsignedInt16, got string"))

(test-case "attrsOf str with nested attrset value"
  (check-output-contains "attrsof-leaf-nested.bnix"
    #rx"attrsof-leaf-nested\\.bnix:6:[0-9]+: type mismatch at hardware\\.alsa\\.deviceAliases")
  (check-output-contains "attrsof-leaf-nested.bnix"
    #rx"expected str, got attrset"))

;; ---------- Lazy submodule expansion ----------

(test-case "typo inside expanded submodule"
  (check-output-contains "submodule-typo.bnix"
    #rx"submodule-typo\\.bnix:6:[0-9]+: unknown option services\\.openssh\\.settings\\.PermitRotLogin")
  (check-output-contains "submodule-typo.bnix"
    #rx"did you mean: services\\.openssh\\.settings\\.PermitRootLogin"))

(test-case "typo via wildcard attrsOf submodule"
  (check-output-contains "attrsof-submodule-typo.bnix"
    #rx"attrsof-submodule-typo\\.bnix:6:[0-9]+: unknown option users\\.users\\.tom\\.shellz"))

;; ---------- happy path ----------

(test-case "clean fixture validates with rc=0"
  (check-output-clean "clean.bnix"))
