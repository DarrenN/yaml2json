#!/usr/bin/env bash

raco exe -o yaml2json main.rkt
cp yaml2json /usr/local/bin/
rm yaml2json
