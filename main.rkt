#lang racket/base

;; yaml2json - copyright 2018 DarrenN
;;
;; Super simple YAML to JSON converter, meant for use as a CLI command.
;; Will take a filename to open and pars or stdin.
;;
;; $ yaml2json alpha.yaml // will emit a JSON string in the terminal
;; $ yaml2json -o alpha.json alpha.yaml // will save JSON to alpha.json
;; $ cat alpha.yaml | yaml2json // will emit a JSON string in the terminal
;; $ cat .travis.yml | yaml2json | json_pp // will emit nicely formatted JSON

(require json
         yaml
         racket/bool
         racket/contract
         racket/contract/region
         racket/port)

;; Recursively convert hash -> hasheq which is a valid jsexpr?
(define/contract (hash->hasheq hsh)
  (-> any/c any/c)
  (cond [(list? hsh) (map hash->hasheq hsh)]
        [(not (or (hash? hsh) (list? hsh))) hsh]
        [else
         (let ([keys (hash-keys hsh)])
           (foldl (λ (key result)
                    (hash-set result (string->symbol key)
                              (hash->hasheq (hash-ref hsh key))))
                  (make-immutable-hasheq) keys))]))

;; Convert YAML to JSON and either send to stdout or to a file
(define/contract (run in-port filename)
  (-> port? (or/c string? boolean?) void?)
  (let* ([contents (port->string in-port)]
         [yaml (string->yaml contents)]
         [json (jsexpr->string (hash->hasheq yaml))])
    (if (false? filename)
        (displayln json (current-output-port))
        (call-with-output-file*
          filename
          (λ (out) (displayln json out))
          #:mode 'text #:exists 'replace))))


;//////////////////////////////////////////////////////////////////////////////
; PUBLIC

(module+ main
  (require racket/cmdline)

  (define output-filename (make-parameter #f))

  ;; Parse command line args
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

;//////////////////////////////////////////////////////////////////////////////
; TESTS

(module+ test
  (require rackunit
           racket/contract)

  (check-not-exn (λ () (contract-exercise hash->hasheq 100)))

  (for ([i (in-range 50)])
    (let ([x (contract-random-generate any/c)])
      (check-eq? x (hash->hasheq x) "output not equal to input?")))

  (define hsh (hash->hasheq (hash "alpha" 12 "β" (hash "gamma" 13))))
  (check-pred hash-eq? hsh "isn't a hash-eq?")
  (check-pred immutable? hsh "isn't immutable?")

  (check-not-exn (λ () (contract-exercise run 100)))

  (define yaml-port (open-input-string "
alpha: 12
beta:
 - gamma: 2
 - delta: phi
"))

  (define out (open-output-string))
  (parameterize ([current-output-port out])
    (run yaml-port #f)
    (check-equal?
     "{\"alpha\":12,\"beta\":[{\"gamma\":2},{\"delta\":\"phi\"}]}\n"
     (get-output-string out)
     "Parses yaml from input-port? into json string in output-port?")))
