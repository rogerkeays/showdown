#!/usr/bin/racket
#lang racket

(require threading)
(require rackunit)
(require json)

(define (read-metadata file)
  (with-output-to-string 
    (lambda () (system* "/usr/bin/ffprobe" "-of" "json" "-v" "quiet" "-show_format" file))))

(define (parse-id3 metadata)
  (~> metadata
      (string->jsexpr)
      (hash-ref 'format)
      (hash-ref 'tags)))

(module+ test
  (check-equal? (normalise-field "rock.alternative") "rock-alternative")
  (check-equal? (normalise-field "We Are All On Drugs") "we-are-all-on-drugs"))

(define (normalise-field field)
  (~> field
      (string-replace "." "-")
      (string-replace " " "-")
      (string-downcase)))

(module+ test
  (~> (create-filename '#hasheq((TRACKTOTAL . "")
                                          (album . "Make Believe")
                                          (artist . "Weezer")
                                          (date . "2005")
                                          (genre . "rock.alternative")
                                          (title . "We Are All On Drugs")
                                          (track . "2")))
      (check-equal? "rock-alternative.2.weezer.we-are-all-on-drugs.mp3"))
  (~> (create-filename '#hasheq((TRACKTOTAL . "")
                                          (album . "Make Believe")
                                          (artist . "Weezer")
                                          (date . "2005")
                                          (genre . "rock.alternative")
                                          (title . "We Are All On Drugs")))
       (check-equal? "rock-alternative.0.weezer.we-are-all-on-drugs.mp3")))

(define (create-filename id3)
  (~> (list (~> (~> id3 (hash-ref 'genre "unknown")) normalise-field)
            (~> (~> id3 (hash-ref 'track "0")) normalise-field)
            (normalise-field (hash-ref id3 'artist "unknown"))
            (normalise-field (hash-ref id3 'title "unknown")))
      (string-join ".")
      (string-append ".mp3")))

(for ([source (current-command-line-arguments)])
   (rename-file-or-directory source (create-filename (parse-id3 (read-metadata source))) #t))

