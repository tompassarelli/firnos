#lang racket/base

(require racket/list
         racket/path
         racket/system
         "util.rkt")

(provide node-edges)

(define (descend? d)
  (define s (path->string d))
  (not (or (regexp-match? #rx"/\\.git$"        s)
           (regexp-match? #rx"/\\.direnv$"     s)
           (regexp-match? #rx"/\\.firn-build$" s)
           (regexp-match? #rx"/scripts$"       s)
           (regexp-match? #rx"/tests$"         s)
           (regexp-match? #rx"/result"         s))))

(define (gather-bnix-files)
  (sort
   (for/list ([f (in-directory ROOT descend?)]
              #:when (regexp-match? #rx"\\.bnix$" (path->string f)))
     f)
   path<?))

(define (handle-repo-watch _leaf)
  (file-stream-buffer-mode (current-output-port) 'line)
  (define files (gather-bnix-files))
  (printf "firn watch: monitoring ~a .bnix file(s)... (Ctrl-C to exit)\n"
          (length files))
  (let loop ([files files])
    (define evts (map filesystem-change-evt files))
    (define ready (apply sync evts))
    (define idx (for/or ([e (in-list evts)] [i (in-naturals)]
                         #:when (eq? e ready))
                  i))
    (define changed (and idx (list-ref files idx)))
    (for ([e (in-list evts)]) (filesystem-change-evt-cancel e))
    (cond
      [(and changed (file-exists? changed))
       (printf "\n>> ~a changed\n" (relative-to-repo changed))
       (flush-output)
       (system* (find-exe "racket")
                (path->string (in-repo "scripts" "firn-validate"))
                (path->string changed))
       (loop (gather-bnix-files))]
      [else
       (loop (gather-bnix-files))])))

(define node-edges
  (list
   (walk-edge "repo" "watch" "all" 'all
              handle-repo-watch
              "re-run validator on .rkt save (no external deps)")))
