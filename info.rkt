#lang info
(define collection "yaml2json")
(define deps '("base"
               "yaml"
               "rackunit-lib"))
(define build-deps '("scribble-lib" "racket-doc"))
(define scribblings '(("scribblings/yaml2json.scrbl" ())))
(define pkg-desc "Simple utility to convert YAML to JSON")
(define version "0.1")
(define pkg-authors '(Darren_N))

(define racket-launcher-names '("yaml2json"))
(define racket-launcher-libraries '("main.rkt"))
