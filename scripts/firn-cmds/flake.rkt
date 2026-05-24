#lang racket/base

;; firn-cmds/flake — visibility into flake inputs (purity, freshness, follows).
;;
;; `firn flake inputs`            shows each input, sorted by attention-needed
;; `firn flake inputs attention`  shows only inputs that need attention
;;
;; Sort order: impure → moving → stale (>90d) → tracked → pinned. The view
;; itself tells you where to look — top rows are what you should care about.
;;
;; Purity verdicts:
;;   ✓ pinned   — explicit rev in source URL (won't move on `nix flake update`)
;;   ✓ tracked  — branch ref in source URL (rev moves on update, but lock file
;;                has a concrete rev → pure-eval safe)
;;   ⚠ moving   — tracking a moving-target branch (master, main, unstable)
;;   ⚠ stale    — tracked, but locked rev hasn't been touched in 90+ days
;;   ✗ impure   — absolute path URL (`path:/...`) — breaks pure-eval

(require racket/list
         racket/string
         racket/format
         json
         "util.rkt")

(provide node-edges)

(define LOCK-PATH (build-path ROOT "flake.lock"))

(define MOVING-BRANCHES
  '("master" "main" "unstable" "nixos-unstable" "trunk"))

(define STALE-THRESHOLD-DAYS 90)

;; ---------- ANSI color (only when stdout is a TTY) ----------

(define (tty?) (terminal-port? (current-output-port)))

(define (color code s)
  (cond [(tty?) (format "\e[~am~a\e[0m" code s)]
        [else s]))

(define (green s)   (color 32 s))
(define (yellow s)  (color 33 s))
(define (red s)     (color 31 s))
(define (dim s)     (color 90 s))
(define (bold s)    (color 1 s))

;; ---------- verdicts ----------

(define (verdict-rank v)
  ;; Lower = needs more attention. Sort ascending.
  (case v
    [(impure)   0]
    [(moving)   1]
    [(stale)    2]
    [(tracked)  3]
    [(pinned)   4]
    [else       5]))

(define (verdict-glyph v)
  (case v
    [(pinned)   (green  "✓ pinned ")]
    [(tracked)  (green  "✓ tracked")]
    [(stale)    (yellow "⚠ stale  ")]
    [(moving)   (yellow "⚠ moving ")]
    [(impure)   (red    "✗ impure ")]
    [else       (dim    "? unknown")]))

(define (verdict-needs-attention? v)
  (memq v '(impure moving stale)))

;; ---------- freshness ----------

(define (seconds-ago ts) (- (current-seconds) ts))

(define (human-age s)
  (define mins (quotient s 60))
  (define hrs  (quotient mins 60))
  (define days (quotient hrs 24))
  (cond
    [(< s 60)     (format "~as ago" s)]
    [(< mins 60)  (format "~am ago" mins)]
    [(< hrs 24)   (format "~ah ago" hrs)]
    [(< days 30)  (format "~ad ago" days)]
    [(< days 365) (format "~amo ago" (quotient days 30))]
    [else         (format "~ay ago" (quotient days 365))]))

(define (age-days s) (quotient (quotient s 60) (* 60 24)))

(define (colorize-age age-secs str)
  (define d (age-days age-secs))
  (cond
    [(>= d STALE-THRESHOLD-DAYS) (red    str)]
    [(>= d 30)                   (yellow str)]
    [else                        (dim    str)]))

;; ---------- url shape ----------

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
    [(equal? type "git")
     (format "git+~a" (hash-ref orig 'url ""))]
    [(equal? type "path")
     (format "path:~a" (hash-ref orig 'path ""))]
    [else (format "~a:?" type)]))

(define (truncate-url u max-len)
  (cond [(<= (string-length u) max-len) u]
        [else (string-append (substring u 0 (- max-len 1)) "…")]))

;; ---------- verdict from original + age ----------

(define (compute-verdict orig age-secs)
  (define type (hash-ref orig 'type ""))
  (cond
    [(equal? type "path")
     (define p (hash-ref orig 'path ""))
     (if (and (positive? (string-length p)) (char=? (string-ref p 0) #\/))
         'impure
         'tracked)]
    [(hash-ref orig 'rev #f) 'pinned]
    [else
     (define ref (or (hash-ref orig 'ref #f)
                     (let ([u (hash-ref orig 'url #f)])
                       (and u (extract-ref-from-url u)))))
     (cond
       [(and ref (member (last-path-segment ref) MOVING-BRANCHES)) 'moving]
       [(and age-secs (>= (age-days age-secs) STALE-THRESHOLD-DAYS)) 'stale]
       [else 'tracked])]))

(define (extract-ref-from-url url)
  (define m (regexp-match #px"^(?:github|gitlab):[^/]+/[^/]+/([^?#]+)" url))
  (cond
    [m (list-ref m 1)]
    [else
     (define qm (regexp-match #px"\\?ref=([^&#]+)" url))
     (and qm (list-ref qm 1))]))

(define (last-path-segment s)
  (define parts (regexp-split #rx"/" s))
  (cond [(null? parts) s]
        [else (last parts)]))

;; ---------- flake.lock walk ----------

(define (load-lock)
  (cond
    [(not (file-exists? LOCK-PATH))
     (error 'firn-flake "no flake.lock at ~a" LOCK-PATH)]
    [else (call-with-input-file LOCK-PATH read-json)]))

(define (root-input-names lock)
  (define root-node (hash-ref (hash-ref lock 'nodes) (string->symbol (hash-ref lock 'root))))
  (sort (hash-keys (hash-ref root-node 'inputs (hash))) symbol<?))

(define (resolve-input-name lock name)
  (define root-node (hash-ref (hash-ref lock 'nodes) (string->symbol (hash-ref lock 'root))))
  (define entry (hash-ref (hash-ref root-node 'inputs (hash)) name))
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

(struct input-row (name url age-secs age-str verdict rev-short follows) #:transparent)

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
    (define verdict (compute-verdict orig age-secs))
    (input-row (symbol->string name) url age-secs age-str verdict rev-short
               (sort (follows-of lock lock-node-name) string<? #:key car))))

(define (sort-rows rows)
  ;; Primary: verdict rank (attention-needed first).
  ;; Secondary: age descending (oldest within same verdict first).
  (sort rows
        (lambda (a b)
          (define ra (verdict-rank (input-row-verdict a)))
          (define rb (verdict-rank (input-row-verdict b)))
          (cond
            [(< ra rb) #t]
            [(> ra rb) #f]
            [else
             (define aa (or (input-row-age-secs a) 0))
             (define ab (or (input-row-age-secs b) 0))
             (> aa ab)]))))

;; ---------- rendering ----------

(define (render-rows rows max-name-len max-url-len)
  (for ([r (in-list rows)])
    (printf "  ~a  ~a  ~a  ~a  ~a\n"
            (~a (input-row-name r) #:min-width max-name-len)
            (~a (truncate-url (input-row-url r) max-url-len) #:min-width max-url-len)
            (verdict-glyph (input-row-verdict r))
            (~a (colorize-age (or (input-row-age-secs r) 0) (input-row-age-str r))
                #:min-width 20 #:align 'right)
            (dim (format "(~a)" (input-row-rev-short r))))
    (for ([f (in-list (input-row-follows r))])
      (printf "  ~a    ~a inputs.~a.follows ~a\n"
              (make-string max-name-len #\space)
              (dim "↳")
              (dim (car f))
              (dim (cdr f))))))

(define (render-legend)
  (printf "\n~a\n" (bold "Legend"))
  (printf "  ~a  explicit rev in source URL — won't move on `nix flake update`\n" (verdict-glyph 'pinned))
  (printf "  ~a  branch ref — lock has concrete rev (pure-eval safe)\n" (verdict-glyph 'tracked))
  (printf "  ~a  tracked, but lock entry is >~a days old\n" (verdict-glyph 'stale) STALE-THRESHOLD-DAYS)
  (printf "  ~a  moving-target branch (master/main/unstable) — drifts fast\n" (verdict-glyph 'moving))
  (printf "  ~a  absolute path URL — breaks pure-eval; fix before pushing\n" (verdict-glyph 'impure)))

;; ---------- handlers ----------

(define (handle-flake-inputs leaf)
  (define attention-only? (member leaf '("attention" "todo")))
  (define lock (load-lock))
  (define all-rows (sort-rows (compute-rows lock)))
  (define rows (if attention-only?
                   (filter (lambda (r) (verdict-needs-attention? (input-row-verdict r))) all-rows)
                   all-rows))
  (cond
    [(null? rows)
     (cond [attention-only? (printf "~a no inputs need attention.\n" (green "✓"))]
           [else            (printf "firn flake inputs: no inputs found in flake.lock\n")])]
    [else
     (define max-name-len (apply max (map (lambda (r) (string-length (input-row-name r))) all-rows)))
     (define max-url-len 48)
     (cond
       [attention-only?
        (printf "~a (~a of ~a)\n\n"
                (bold "Flake inputs needing attention")
                (length rows) (length all-rows))]
       [else
        (printf "~a (~a total, sorted: attention-needed first)\n\n"
                (bold "Flake inputs") (length all-rows))])
     (render-rows rows max-name-len max-url-len)
     (cond
       [attention-only?
        (printf "\nRun `firn flake inputs` for the full list.\n")]
       [else
        (render-legend)
        (printf "\n`firn flake inputs attention` — filter to attention-needed only.\n")
        (printf "`firn repo upgrade dry-run` — see what `nix flake update` would change.\n")])]))

(define node-edges
  (list
   (walk-edge "flake" "inputs" "all|attention" 'all
              handle-flake-inputs
              "Show flake inputs (purity, freshness, follows). Leaf 'attention' filters to issues only.")))
