#lang racket/base

(module+ test
  (require rackunit))

;; Notice
;; To install (from within the package directory):
;;   $ raco pkg install
;; To install (once uploaded to pkgs.racket-lang.org):
;;   $ raco pkg install <<name>>
;; To uninstall:
;;   $ raco pkg remove <<name>>
;; To view documentation:
;;   $ raco docs <<name>>
;;
;; For your convenience, we have included a LICENSE.txt file, which links to
;; the GNU Lesser General Public License.
;; If you would prefer to use a different license, replace LICENSE.txt with the
;; desired license.
;;
;; Some users like to add a `private/` directory, place auxiliary files there,
;; and require them in `main.rkt`.
;;
;; See the current version of the racket style guide here:
;; http://docs.racket-lang.org/style/index.html

;; Code here

(module+ test
  ;; Tests to be run with raco test
  )

(module+ main
  (require json
           yaml
           racket/bool
           racket/cmdline
           racket/port)

  ;; Recursively convert hash -> hasheq which is a valid jsexpr?
  (define (hash->hasheq hsh)
    (cond [(list? hsh) (map hash->hasheq hsh)]
          [(not (or (hash? hsh) (list? hsh))) hsh]
          [else
           (let ([keys (hash-keys hsh)])
             (foldl (λ (key result)
                      (hash-set result (string->symbol key)
                                (hash->hasheq (hash-ref hsh key))))
                    (make-immutable-hasheq) keys))]))

  (define (run in-port filename)
    (let* ([contents (port->string in-port)]
           [yaml (string->yaml contents)]
           [json (jsexpr->string (hash->hasheq yaml))])
      (if (false? filename)
          (displayln json (current-output-port))
          (call-with-output-file*
            filename
            (λ (out) (displayln json out))
            #:mode 'text #:exists 'replace))))

  (define output-filename (make-parameter #f))

  (define convert-yaml
    (command-line
     #:program "yaml2json"
     #:once-each
     [("-o" "--output") out "Path to save JSON"
                        (output-filename out)]

     #:args filename ; expect one command-line argument: <filename>

     (run
      (if (null? filename)
          (current-input-port)
          (open-input-file (car filename)))
      (output-filename)))))
