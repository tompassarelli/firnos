#lang racket/base

(require racket/list
         racket/path
         racket/file
         racket/system
         racket/string
         (only-in nisp/validate
                  walk-syntax extract-from-form
                  path-ref-path path-ref-val-stx)
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
     (eprintf "fi diff: failed to evaluate ~a\n" (path->string rkt-path))
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
         [else (eprintf "fi diff: cannot resolve ~a\n" leaf) (exit 1)])]))
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

;; ============================================================================
;; Semantic diff — option-level change summary
;; ============================================================================

;; Stringify a value-type for display. Keeps it human-readable.
(define (val-display stx)
  (cond
    [(not stx) "<no value>"]
    [else
     (define dat (and (syntax? stx) (syntax->datum stx)))
     (cond
       [(boolean? dat) (if dat "true" "false")]
       [(exact-integer? dat) (number->string dat)]
       [(string? dat) dat]
       [(eq? dat 'null) "null"]
       [(pair? dat)
        (define lst (and (syntax? stx) (syntax->list stx)))
        (cond
          [(or (not lst) (null? lst)) "<expr>"]
          [else
           (define head (and (identifier? (car lst))
                             (syntax->datum (car lst))))
           (case head
             [(with-pkgs)
              (define pkg-names
                (filter-map
                 (λ (arg)
                   (define d (syntax->datum arg))
                   (cond
                     [(symbol? d) (symbol->string d)]
                     [(and (pair? d) (symbol? (car d)))
                      ;; e.g. (pkgs.foo) → "pkgs.foo"
                      (symbol->string (car d))]
                     [else #f]))
                 (cdr lst)))
              (string-append "[" (string-join pkg-names ", ") "]")]
             [(s ms)
              (define parts
                (filter-map
                 (λ (arg) (let ([d (syntax->datum arg)])
                            (and (string? d) d)))
                 (cdr lst)))
              (if (pair? parts)
                  (string-join parts "")
                  "<string>")]
             [(mkdefault mkforce)
              (if (pair? (cdr lst))
                  (val-display (cadr lst))
                  "<expr>")]
             [else
              ;; For identifiers like pkgs.foo or pkgs.unstable.bar
              (define full (format "~a" dat))
              (if (< (string-length full) 60)
                  full
                  "<expr>")])])]
       [(symbol? dat)
        ;; bare identifiers like pkgs.niri
        (symbol->string dat)]
       [else "<expr>"])]))

;; Read a .rkt file's content as a string from git HEAD. Returns #f if
;; the file is new (not in HEAD).
(define (git-show-head rel-path)
  (define out (open-output-string))
  (define err (open-output-string))
  (define ok?
    (parameterize ([current-output-port out]
                   [current-error-port err]
                   [current-directory ROOT])
      (system* (find-exe "git") "show" (string-append "HEAD:" rel-path))))
  (and ok? (get-output-string out)))

;; Parse a .rkt source string with read-syntax, collecting all path-refs.
;; Returns a hash: path-string → val-stx (last one wins for duplicates).
(define (extract-assignments source-str [source-name "input"])
  (define assignments (make-hash))
  (with-handlers ([exn:fail? (λ (_) assignments)])
    ;; Strip #lang line — read-syntax doesn't handle #lang
    (define-values (_lang-line rest)
      (let ([m (regexp-match-positions #rx"^#lang [^\n]*\n" source-str)])
        (cond [m (values (substring source-str 0 (cdar m))
                         (substring source-str (cdar m)))]
              [else (values "" source-str)])))
    (define port (open-input-string rest))
    (port-count-lines! port)
    (let loop ()
      (define stx (read-syntax source-name port))
      (unless (eof-object? stx)
        (walk-syntax stx
                     (λ (s in-hm?)
                       (unless in-hm?
                         (for ([pr (in-list (extract-from-form s))])
                           (hash-set! assignments
                                      (path-ref-path pr)
                                      (path-ref-val-stx pr))))))
        (loop)))
    assignments))

;; Compute the semantic diff between two source strings.
;; Returns a list of change entries: (list type path detail)
;;   type: '+ (added), '- (removed), '~ (changed)
(define (compute-semantic-changes old-src new-src)
  (define old-assigns (extract-assignments (or old-src "") "HEAD"))
  (define new-assigns (extract-assignments (or new-src "") "working"))
  (define changes '())
  ;; Find new and changed paths
  (for ([(path val-stx) (in-hash new-assigns)])
    (cond
      [(not (hash-has-key? old-assigns path))
       (set! changes (cons (list '+ path (val-display val-stx)) changes))]
      [else
       (define old-val-stx (hash-ref old-assigns path))
       (define old-repr (val-display old-val-stx))
       (define new-repr (val-display val-stx))
       (unless (equal? old-repr new-repr)
         (set! changes (cons (list '~ path
                                   (string-append old-repr " → " new-repr))
                             changes)))]))
  ;; Find removed paths
  (for ([(path val-stx) (in-hash old-assigns)])
    (unless (hash-has-key? new-assigns path)
      (set! changes (cons (list '- path (val-display val-stx)) changes))))
  ;; Sort by path for stable output
  (sort changes string<? #:key cadr))

(define (handle-repo-sdiff leaf)
  ;; Get list of modified/new/deleted .rkt files
  (define raw-output
    (parameterize ([current-directory ROOT])
      (sh-out "git" "diff" "--name-only" "HEAD")))
  (define new-files-output
    (parameterize ([current-directory ROOT])
      (sh-out "git" "ls-files" "--others" "--exclude-standard")))
  (define deleted-output
    (parameterize ([current-directory ROOT])
      (sh-out "git" "diff" "--name-only" "--diff-filter=D" "HEAD")))
  (define all-modified
    (filter (λ (s) (and (non-empty-string? s)
                        (regexp-match? #rx"\\.rkt$" s)
                        (not (regexp-match? #rx"^scripts/" s))
                        (not (regexp-match? #rx"^nisp/" s))))
            (append (string-split raw-output "\n")
                    (string-split new-files-output "\n"))))
  (define deleted-files
    (filter (λ (s) (and (non-empty-string? s)
                        (regexp-match? #rx"\\.rkt$" s)
                        (not (regexp-match? #rx"^scripts/" s))
                        (not (regexp-match? #rx"^nisp/" s))))
            (string-split deleted-output "\n")))
  ;; Filter to target if not "all"
  (define targets
    (cond
      [(equal? leaf "all")
       (remove-duplicates (append all-modified deleted-files))]
      [else
       (define r (resolve-rkt-source leaf))
       (cond
         [r (list (relative-to-repo r))]
         [else (eprintf "fi sdiff: cannot resolve ~a\n" leaf) (exit 1)])]))
  (when (null? targets)
    (printf "Semantic diff: no .rkt changes vs HEAD.\n")
    (exit 0))
  (printf "Semantic diff (working tree vs HEAD):\n\n")
  (define total-changes 0)
  (for ([rel-path (in-list (sort targets string<?))])
    (define abs-path (in-repo rel-path))
    (define is-deleted? (member rel-path deleted-files))
    (define old-src (git-show-head rel-path))
    (define new-src
      (cond
        [is-deleted? #f]
        [(file-exists? abs-path) (file->string abs-path)]
        [else #f]))
    (cond
      ;; Brand new file (not in HEAD)
      [(not old-src)
       (define assigns (extract-assignments (or new-src "") "new"))
       (unless (hash-empty? assigns)
         (printf "  ~a:\n" rel-path)
         (printf "    + enabled (newly created)\n")
         (for ([(path val-stx) (in-hash assigns)])
           (printf "    + ~a: ~a\n" path (val-display val-stx))
           (set! total-changes (add1 total-changes)))
         (newline))]
      ;; Deleted file
      [is-deleted?
       (define assigns (extract-assignments old-src "deleted"))
       (unless (hash-empty? assigns)
         (printf "  ~a:\n" rel-path)
         (printf "    - removed (file deleted)\n")
         (for ([(path val-stx) (in-hash assigns)])
           (printf "    - ~a: ~a\n" path (val-display val-stx))
           (set! total-changes (add1 total-changes)))
         (newline))]
      ;; Modified file
      [else
       (define changes (compute-semantic-changes old-src new-src))
       (unless (null? changes)
         (printf "  ~a:\n" rel-path)
         (for ([c (in-list changes)])
           (define type (car c))
           (define path (cadr c))
           (define detail (caddr c))
           (case type
             [(+) (printf "    + ~a: ~a (new)\n" path detail)]
             [(-) (printf "    - ~a: ~a (removed)\n" path detail)]
             [(~) (printf "    ~ ~a: ~a\n" path detail)])
           (set! total-changes (add1 total-changes)))
         (newline))]))
  (when (= total-changes 0)
    (printf "  (no option-level changes detected)\n"))
  (exit 0))

(define node-edges
  (list
   (walk-edge "repo" "diff" "<target>|all" 'all
              handle-repo-diff
              "re-emit Nix from .rkt and diff vs committed .nix")
   (walk-edge "repo" "sdiff" "<target>|all" 'all
              handle-repo-sdiff
              "semantic option-level diff of .rkt sources vs HEAD")))
