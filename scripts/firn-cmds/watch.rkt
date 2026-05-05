#lang racket/base

(require racket/list
         racket/path
         racket/system
         "util.rkt")

(provide cmd-watch)

(define (descend? d)
  (define s (path->string d))
  (not (or (regexp-match? #rx"/\\.git$"        s)
           (regexp-match? #rx"/\\.direnv$"     s)
           (regexp-match? #rx"/\\.firn-build$" s)
           (regexp-match? #rx"/scripts$"       s)
           (regexp-match? #rx"/tests$"         s)
           (regexp-match? #rx"/result"         s))))

(define (gather-nisp-rkts)
  (sort
   (for/list ([f (in-directory ROOT descend?)]
              #:when (and (regexp-match? #rx"\\.rkt$" (path->string f))
                          (with-handlers ([exn:fail? (λ (_) #f)])
                            (regexp-match?
                             #rx"^#lang nisp"
                             (call-with-input-file f
                               (λ (p) (read-line p)))))))
     f)
   path<?))

(define (cmd-watch _args)
  (file-stream-buffer-mode (current-output-port) 'line)
  (define files (gather-nisp-rkts))
  (printf "firn watch: monitoring ~a .rkt file(s)... (Ctrl-C to exit)\n"
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
       (loop (gather-nisp-rkts))]
      [else
       (loop (gather-nisp-rkts))])))
