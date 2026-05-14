#lang racket/base

(require racket/list
         racket/path
         racket/file
         racket/system
         "util.rkt")

(provide resolve-rkt-source node-edges)

(define (resolve-rkt-source name)
  ;; Resolve a user-facing name to a .rkt path. Accepts:
  ;;   - bare name       → modules/<name>/default.rkt or bundles/<name>/default.rkt
  ;;   - module/<name>   → modules/<name>/default.rkt
  ;;   - bundle/<name>   → bundles/<name>/default.rkt
  ;;   - host/<name>     → hosts/<name>/configuration.rkt
  ;;   - flake           → flake.rkt
  ;;   - relative path   → as-is
  (cond
    [(equal? name "flake") (in-repo "flake.rkt")]
    [(regexp-match #rx"^module[s]?/(.+)$" name)
     => (λ (m) (in-repo "modules" (cadr m) "default.rkt"))]
    [(regexp-match #rx"^bundle[s]?/(.+)$" name)
     => (λ (m) (in-repo "bundles" (cadr m) "default.rkt"))]
    [(regexp-match #rx"^host[s]?/(.+)$" name)
     => (λ (m) (in-repo "hosts" (cadr m) "configuration.rkt"))]
    [(regexp-match #rx"\\.rkt$" name)
     (cond [(file-exists? name) (string->path name)]
           [(file-exists? (in-repo name)) (in-repo name)]
           [else #f])]
    [else
     (define candidates
       (list (in-repo "modules" name "default.rkt")
             (in-repo "bundles" name "default.rkt")
             (in-repo "hosts" name "configuration.rkt")))
     (or (findf file-exists? candidates) #f)]))

(define (rkt->nix-path rkt)
  (define s (path->string rkt))
  (cond
    [(regexp-match? #rx"\\.rkt$" s)
     (string->path (regexp-replace #rx"\\.rkt$" s ".nix"))]
    [else (error 'rkt->nix-path "not a .rkt file: ~a" s)]))

(define (re-emit-nix rkt-path)
  (define out (open-output-string))
  (define err (open-output-string))
  (define ok?
    (parameterize ([current-output-port out]
                   [current-error-port err])
      (system* (find-exe "racket") (path->string rkt-path))))
  (cond
    [ok? (get-output-string out)]
    [else
     (eprintf "firn diff: failed to evaluate ~a\n" (path->string rkt-path))
     (eprintf "~a" (get-output-string err))
     #f]))

(define (diff-one rkt-path)
  (define nix-path (rkt->nix-path rkt-path))
  (define fresh (re-emit-nix rkt-path))
  (cond
    [(not fresh) 'error]
    [(not (file-exists? nix-path))
     (printf "=== ~a ===\n" (relative-to-repo nix-path))
     (printf "(no committed .nix — would create)\n")
     'different]
    [else
     (define committed (file->string nix-path))
     (cond
       [(equal? fresh committed) 'same]
       [else
        (define tmp (make-temporary-file "firn-diff-~a.nix"))
        (with-output-to-file tmp #:exists 'replace
          (λ () (display fresh)))
        (printf "=== ~a ===\n" (relative-to-repo nix-path))
        (flush-output)
        (system* (find-exe "diff") "-u" "--color=always"
                 (path->string nix-path) (path->string tmp))
        (delete-file tmp)
        'different])]))

(define (handle-repo-diff leaf)
  (define targets
    (cond
      [(equal? leaf "all")
       (sort
        (for/list ([f (in-directory ROOT)]
                   #:when (let ([s (path->string f)])
                            (and (regexp-match? #rx"\\.rkt$" s)
                                 (not (regexp-match? #rx"/scripts/" s))
                                 (not (regexp-match? #rx"/tests/" s))
                                 (not (regexp-match? #rx"/\\.firn-build/" s))
                                 (not (regexp-match? #rx"/\\.direnv/" s))
                                 (not (regexp-match? #rx"/\\.git/" s))
                                 (not (regexp-match? #rx"/result" s))
                                 (with-handlers ([exn:fail? (λ (_) #f)])
                                   (regexp-match?
                                    #rx"^#lang nisp"
                                    (call-with-input-file f
                                      (λ (p) (read-line p))))))))
          f)
        path<?)]
      [else
       (define r (resolve-rkt-source leaf))
       (cond
         [r (list r)]
         [else (eprintf "firn diff: cannot resolve ~a\n" leaf) (exit 1)])]))
  (define same 0)
  (define diff 0)
  (define err 0)
  (for ([rkt (in-list targets)])
    (case (diff-one rkt)
      [(same) (set! same (+ same 1))]
      [(different) (set! diff (+ diff 1))]
      [(error) (set! err (+ err 1))]))
  (printf "\nfirn diff: ~a unchanged, ~a differ, ~a error(s)\n" same diff err)
  (exit (if (or (> diff 0) (> err 0)) 1 0)))

(define node-edges
  (list
   (walk-edge "repo" "diff" "<target>|all" 'all
              handle-repo-diff
              "re-emit Nix from .rkt and diff vs committed .nix")))
