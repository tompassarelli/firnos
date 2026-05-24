#lang racket/base

;; firn-cmds/flake — visibility into flake inputs.
;;
;; `firn flake inputs` shows each input: source URL (as in flake.bnix),
;; how old the locked rev is, what other inputs it's pinned to follow,
;; and whether it's frozen at a specific commit.
;;
;; The view does NOT score inputs as "good" or "bad" — `nixpkgs-master`
;; tracking master is a deliberate choice, not a problem, even though
;; it'll move on every `nix flake update`. The only thing that gets
;; flagged separately is a hard error: an absolute filesystem path
;; (`path:/...`) that would actually break the build.

(require racket/list
         racket/string
         racket/format
         json
         "util.rkt")

(provide node-edges)

(define LOCK-PATH (build-path ROOT "flake.lock"))

;; ---------- ANSI color (only on TTY) ----------

(define (tty?) (terminal-port? (current-output-port)))
(define (color code s) (if (tty?) (format "\e[~am~a\e[0m" code s) s))
(define (dim s)  (color 90 s))
(define (red s)  (color 31 s))
(define (bold s) (color 1  s))

;; ---------- freshness ----------

(define (seconds-ago ts) (- (current-seconds) ts))

(define (human-age s)
  (define mins (quotient s 60))
  (define hrs  (quotient mins 60))
  (define days (quotient hrs 24))
  (cond
    [(< s 60)     (format "~as" s)]
    [(< mins 60)  (format "~am" mins)]
    [(< hrs 24)   (format "~ah" hrs)]
    [(< days 30)  (format "~ad" days)]
    [(< days 365) (format "~amo" (quotient days 30))]
    [else         (format "~ay" (quotient days 365))]))

;; ---------- URL rendering ----------

(define (original->url orig)
  (define type (hash-ref orig 'type ""))
  (define url  (hash-ref orig 'url #f))
  (cond
    [url url]
    [(equal? type "github")
     (define owner (hash-ref orig 'owner ""))
     (define repo  (hash-ref orig 'repo ""))
     (define ref   (or (hash-ref orig 'ref #f) (hash-ref orig 'rev #f)))
     (cond [ref  (format "github:~a/~a/~a" owner repo ref)]
           [else (format "github:~a/~a" owner repo)])]
    [(equal? type "gitlab")
     (format "gitlab:~a/~a" (hash-ref orig 'owner "") (hash-ref orig 'repo ""))]
    [(equal? type "git")    (format "git+~a" (hash-ref orig 'url ""))]
    [(equal? type "path")   (format "path:~a" (hash-ref orig 'path ""))]
    [else                   (format "~a:?" type)]))

(define (truncate-url u max-len)
  (cond [(<= (string-length u) max-len) u]
        [else (string-append (substring u 0 (- max-len 1)) "…")]))

;; ---------- broken-path detection (the only real error class) ----------

(define (broken-absolute-path? orig)
  (and (equal? (hash-ref orig 'type "") "path")
       (let ([p (hash-ref orig 'path "")])
         (and (positive? (string-length p)) (char=? (string-ref p 0) #\/)))))

(define (frozen-rev? orig)
  ;; True if the source URL has an explicit rev in it (won't move on
  ;; `nix flake update`). Different from the lock having a rev — every
  ;; lock has one. This is about the SOURCE being pinned.
  (hash-ref orig 'rev #f))

;; ---------- flake.lock walk ----------

(define (load-lock)
  (cond
    [(not (file-exists? LOCK-PATH))
     (error 'firn-flake "no flake.lock at ~a" LOCK-PATH)]
    [else (call-with-input-file LOCK-PATH read-json)]))

(define (root-node lock)
  (hash-ref (hash-ref lock 'nodes) (string->symbol (hash-ref lock 'root))))

(define (root-input-names lock)
  (sort (hash-keys (hash-ref (root-node lock) 'inputs (hash))) symbol<?))

(define (resolve-input-name lock name)
  (define entry (hash-ref (hash-ref (root-node lock) 'inputs (hash)) name))
  (cond [(string? entry) entry]
        [(list? entry)   (car entry)]
        [else            (symbol->string name)]))

(define (follows-of lock lock-node-name)
  (define node (hash-ref (hash-ref lock 'nodes) (string->symbol lock-node-name) #f))
  (cond
    [(not node) '()]
    [else
     (for/list ([(k v) (in-hash (hash-ref node 'inputs (hash)))]
                #:when (list? v))
       (cons (symbol->string k) (last v)))]))

;; ---------- row data ----------

(struct row (name url age-secs age-str rev-short orig follows) #:transparent)

(define (compute-rows lock)
  (for/list ([name (in-list (root-input-names lock))])
    (define lock-node-name (resolve-input-name lock name))
    (define node (hash-ref (hash-ref lock 'nodes) (string->symbol lock-node-name)))
    (define orig (hash-ref node 'original (hash)))
    (define locked (hash-ref node 'locked (hash)))
    (define url (original->url orig))
    (define last-mod (hash-ref locked 'lastModified #f))
    (define age-secs (and last-mod (seconds-ago last-mod)))
    (define age-str (if age-secs (human-age age-secs) "?"))
    (define rev-short
      (let ([r (hash-ref locked 'rev "?")])
        (substring r 0 (min 8 (string-length r)))))
    (row (symbol->string name) url age-secs age-str rev-short orig
         (sort (follows-of lock lock-node-name) string<? #:key car))))

;; Sort: newest first (most recently updated at top). User can read
;; top-to-bottom and see what's been touched recently.
(define (sort-rows rows)
  (sort rows < #:key (lambda (r) (or (row-age-secs r) (* 365 86400 10)))))

;; ---------- render ----------

(define (render-row r max-name max-url)
  (define url-str (truncate-url (row-url r) max-url))
  (define frozen? (frozen-rev? (row-orig r)))
  (define url-display (if frozen? (format "~a [frozen]" url-str) url-str))
  (printf "  ~a  ~a  ~a  ~a\n"
          (~a (row-name r) #:min-width max-name)
          (~a url-display #:min-width (+ max-url 9))
          (~a (row-age-str r) #:min-width 5 #:align 'right)
          (dim (format "  ~a" (row-rev-short r))))
  (for ([f (in-list (row-follows r))])
    (printf "  ~a  ~a\n"
            (make-string max-name #\space)
            (dim (format "└─ shares ~a" (cdr f))))))

(define (render-broken rows)
  (define broken (filter (lambda (r) (broken-absolute-path? (row-orig r))) rows))
  (cond
    [(null? broken) #f]
    [else
     (printf "~a ~a input~a with absolute path~a (would break the build):\n"
             (red "!")
             (length broken)
             (if (= 1 (length broken)) "" "s")
             (if (= 1 (length broken)) "" "s"))
     (for ([r (in-list broken)])
       (printf "    ~a: ~a\n" (row-name r) (row-url r)))
     (newline)
     #t]))

(define (handle-flake-inputs leaf)
  (define lock (load-lock))
  (define rows (compute-rows lock))
  (cond
    [(null? rows) (printf "No inputs in flake.lock.\n")]
    [else
     (render-broken rows)   ; only prints if there are broken entries
     (define max-name (apply max (map (lambda (r) (string-length (row-name r))) rows)))
     (define max-url  48)
     (printf "~a (~a, newest first)\n" (bold "flake inputs") (length rows))
     (printf "  ~a  ~a  ~a  ~a\n"
             (~a (dim "name") #:min-width max-name)
             (~a (dim "source") #:min-width (+ max-url 9))
             (~a (dim "age") #:min-width 5 #:align 'right)
             (dim "  rev"))
     (for ([r (in-list (sort-rows rows))])
       (render-row r max-name max-url))
     ;; Smart legend: only print rows that apply to what's actually shown.
     (define any-frozen? (ormap (lambda (r) (frozen-rev? (row-orig r))) rows))
     (define any-follows? (ormap (lambda (r) (pair? (row-follows r))) rows))
     (printf "\n")
     (printf "~a `nix flake update <name>` bumps one input, `nix flake update` bumps all.\n"
             (dim "→"))
     (when any-frozen?
       (printf "~a [frozen] = source URL pins a commit; not affected by `nix flake update`.\n"
               (dim "→")))
     (when any-follows?
       (printf "~a └─ shares X = this input is pinned to use our copy of X (deduping).\n"
               (dim "→")))]))

(define node-edges
  (list
   (walk-edge "flake" "inputs" "all" 'all
              (lambda (_) (handle-flake-inputs _))
              "List flake inputs: source, age, locked rev, follows, broken-path check.")))
