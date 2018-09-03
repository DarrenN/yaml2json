yaml2json
=========

Racket flavored version of `yaml2json`

Super simple YAML to JSON converter, meant for use as a CLI command. Will take a filename to open and parse or read from `stdin`.

### To use:

``` shell
$ yaml2json alpha.yaml // will emit a JSON string in the terminal
$ yaml2json -o alpha.json alpha.yaml // will save JSON to alpha.json
$ cat alpha.yaml | yaml2json // will emit a JSON string in the terminal
$ cat .travis.yml | yaml2json | json_pp // will emit nicely formatted JSON
```

### To install:

``` shell
$ ./install.sh
```

The shell script will build a Racket binary and copy to `/usr/local/bin/yaml2json`.

### Prerequisites:

You will need a [Racket](https://racket-lang.org/).

### License

[LGPL](https://github.com/DarrenN/yaml2json/blob/master/LICENSE.txt)

<a href="https://racket-lang.org/"><img src="https://racket-lang.org/img/racket-logo.svg" width="100" height="100" alt="Racket logo" title="Racket" /></a>

---

Copyright 2018 Darren Newton
