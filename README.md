# showdown

In search of a robust, productive programming language.

## requirements

robust: static typing, stable apis, experienced developers
stable: mature, future-proof, backwards compatible, standardised, widely deployed, open-source, funded
efficient: close to native speed, light on memory, multithreaded
interactive: repl support, automatic compilation, live coding
scripting: single file apps, vim-friendly, fast startup
ecosystem: package manager, large package library, active community
portable: console, desktop, web, mobile, embedded, any os
distribution: easy to share and install packages and binaries
syntax: readable syntax, point-free syntax, infix syntax
api: clean api, clean semantics, less ooo

## language comparisons

| language     | stable | robust | effici | intera | script | eco    | port   | dist   | syntax | api 
|--------------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------
| java         | *      | *      | *      | ~      | x      | *      | +      | -      | ~      | -      
| lisp         | *      | ~      | *      | *      | +      | ~      | ~      | x      | -      | +      
| scheme       | *      | ~      | *      | *      | +      | -      | ~      | ~      | -      | ~      
| c            | *      | ~      | *      | x      | -      | +      | ~      | -      | ~      | -      
| c++          | *      | ~      | *      | x      | x      | ~      | ~      | -      | ~      | ~      
| sh           | *      | -      | ~      | -      | *      | -      | +      | -      | -      | -      
| javascript   | +      | -      | -      | +      | +      | +      | *      | +      | -      | -      
| bash         | +      | x      | ~      | ~      | *      | -      | ~      | x      | -      | -      
| kotlin       | ~      | +      | *      | -      | ~      | +      | +      | -      | +      | ~      
| rust         | ~      | +      | *      | -      |        |        |        | *      |        |
| go           | ~      | +      | *      | -      |        |        |        |        |        |
| typescript   | ~      | ~      | -      |        |        |        |        |        |        |
| python       | ~      | -      | -      | +      | +      | +      | ~      | +      | ~      | +      
| clojure      | -      | ~      | ~      | +      | -      | +      | ~      |        | ~      | ~      
| ruby         | -      | ~      | -      | *      | +      | ~      | ~      | +      | ~      |
| racket       | -      | ~      | +      | *      | +      | ~      | ~      | ~      | -      | *      
| julia        | -      | -      | +      | *      | +      | ~      | ~      | *      | +      | ~      
| dart
| dylan
| lua

## performance

script start-up times

    12.358 $ time kotlin -e 0
    5.561 $ time planck -e "(+ 1 1)"
    5.387 $ time kotlin zero.main.kts // kotlin compiles and caches .main.kts files
    4.807 $ time jshell zero.jsh
    4.624 $ time racket -I typed/racket -e 0
    3.487 $ time groovy -e 0
    3.256 $ time clj -e "(+ 1 1)"
    1.992 $ time kawa -e "(+ 1 1)"
    1.799 $ time java Zero.java // java 11
    1.573 $ time nodejs -e 0
    1.425 $ time ( javac Zero.java; java Zero; ) // jdk 1.8
    1.395 $ time racket -e 0
    1.380 $ time kscript zero.kts
    0.577 $ time lumo -e 0
    0.546 $ time java -jar zero-scala-3.1.2.jar
    0.490 $ time kotlin ZeroKt // byte-compiled
    0.425 $ time racket -I racket/base -e 0
    0.419 $ time drip -cp /usr/share/java/clojure.jar clojure.main -e "(+ 1 1)"
    0.412 $ time julia-1.7 -e0
    0.332 $ time racket zero.rkt // #lang racket/base; raco make plus.rkt
    0.299 $ time java -cp bsh-2.0b4.jar bsh.Interpreter zero.bsh // jdk-17
    0.295 $ time cargo script zero.rs
    0.228 $ time java_launcher Zero // compiled on demand jdk-1.8
    0.177 $ time java Zero // byte-compiled jdk-1.8
    0.168 $ time java_launcher Zero // compiled on demand jdk-17
    0.150 $ time java -cp kotlin-stdlin.jar:zero.kt.jar ZeroKt // java 17.0.2, kotlin 1.7.0
    0.044 $ time scm -e0
    0.033 $ time python -c0
    0.020 $ time sbcl --noinform --eval 0 --quit
    0.016 $ time csi -e 0
    0.013 $ time ./graal-zero // native-image
    0.010 $ time awk "BEGIN { 0 }"
    0.008 $ time ksh -c ''
    0.008 $ time bash -c ''
    0.007 $ time ./rust-zero // compiled
    0.007 $ time ./zero.kexe // kotlin 1.7.0 native
    0.006 $ time bc <<< '0'
    0.006 $ time sh -c '' // dash

memory footprint

    203844 kB $ /usr/bin/time --format "%M kB" kotlin-1.6.0 -e 0
    152796 kB $ /usr/bin/time --format "%M kB" julia-1.7 -e0
    147868 kB $ /usr/bin/time --format "%M kB" racket-7.2 -I typed/racket -e 0
    136664 kB $ /usr/bin/time --format "%M kB" kotlin-1.6.0 zero.main.kts
     71684 kB $ /usr/bin/time --format "%M kB" scala-3.1.2 zero.jar
     67280 kB $ /usr/bin/time --format "%M kB" racket-7.2 -e 0
     45108 kB $ /usr/bin/time --format "%M kB" kotlin-1.7.0 zero.kt.jar
     33832 kB $ /usr/bin/time --format "%M kB" java -jar zero.kt.jar
     34752 kB $ /usr/bin/time --format "%M kB" nodejs-10.21.0 -e 0
     33432 kB $ /usr/bin/time --format "%M kB" java Zero // java 17.0.2 
     28772 kB $ /usr/bin/time --format "%M kB" racket-7.2 -I racket/base -e 0
     19148 kB $ /usr/bin/time --format "%M kB" sbcl-1.4.16 --noinform --eval 0 --quit
      9248 kB $ /usr/bin/time --format "%M kB" python-3.7.3 -c0
      7628 kB $ /usr/bin/time --format "%M kB" csi-4.13 -e 0
      6908 kB $ /usr/bin/time --format "%M kB" ./graal-zero // native-image
      6576 kB $ /usr/bin/time --format "%M kB" python-2.7.16 -c0
      3760 kB $ /usr/bin/time --format "%M kB" awk "BEGIN { 0 }"
      3508 kB $ /usr/bin/time --format "%M kB" ksh -c ''
      3008 kB $ /usr/bin/time --format "%M kB" bash -c ''
      2172 kB $ /usr/bin/time --format "%M kB" ./zero.kexe // kotlin-1.7.0 native
      1920 kB $ /usr/bin/time --format "%M kB" bc <<< '0'
      1420 kB $ /usr/bin/time --format "%M kB" dash -c ''

