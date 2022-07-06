#!/usr/bin/racket 
#lang jamaica sweet-exp racket
;; vim: syntax=scheme

require fluent/unicode racket/list

;;
;; main
;;
module+ main
  (parse-journal (current-input-port) (e : e → car → substring 0 8 → string>=? "20220617")) → sort-journal → print-journal
  ;;(parse-journal) → sort-journal → print-journal

module+ test
  require rackunit
  define invalid-header "202101202210 KEP  │ read a file line by line in racket"
  define valid-header "20210120_2210 KEP  │ read a file line by line in racket"
  define valid-header-with-priority "20210120_2210 KEP +│ read a file line by line in racket"
  define valid-header-with-hashtag "20210120_2210 KEP  │ read a file line by line in racket #racket @kathmandu room"
  define valid-header-with-datemod "20210120_2210<KEP  │ read a file line by line in racket"
  define valid-header-with-lf (valid-header → string-append "\n")
  define valid-header-with-modeline ("//vim: blah blah\n" → string-append valid-header)
  define two-valid-headers (valid-header → string-append "\n" valid-header)
  define valid-body "line 1\nline 2\nanything can go here"
  define valid-entry (valid-header → string-append "\n\n" valid-body "\n\n")
  define two-valid-entries (valid-entry → string-append valid-entry)

;;
;; parse-journal: parses all the entries in the input stream and return a list of entries
;; include? defines a filter function
;;
module+ test
  invalid-header → parse-journal-from-string → check-equal? `()
  valid-header → parse-journal-from-string → check-equal? `(($valid-header . ""))
  two-valid-headers → parse-journal-from-string → check-equal? `(($valid-header . "") ($valid-header . ""))
  valid-entry → parse-journal-from-string → check-equal? `(($valid-header . $valid-body))
  two-valid-entries → parse-journal-from-string → check-equal? `(($valid-header . $valid-body) ($valid-header . $valid-body))
  two-valid-entries → parse-journal-from-string (e : #f) → check-equal? `()

define (parse-journal [in (current-input-port)] [include? (e : #t)] [result `()])
  let ([entry (parse-entry in)])
    if (entry → eof-object?)
      result → reverse
      if (entry → include?)
        parse-journal in include? (cons entry result)
        parse-journal in include? result

define (parse-journal-from-string string [include? (e : #t)])
  string → open-input-string → parse-journal include?

;;
;; parse-entry: parse the next journal entry from the input stream
;; lines before the first journal entry are ignored
;;
module+ test
  invalid-header → parse-entry-from-string → check-equal? eof 
  valid-header → parse-entry-from-string → check-equal? `($valid-header . "")
  valid-header-with-lf → parse-entry-from-string → check-equal? `($valid-header . "")
  two-valid-headers → parse-entry-from-string → check-equal? `($valid-header . "")
  valid-header-with-modeline → parse-entry-from-string → check-equal? `($valid-header . "")
  valid-entry → parse-entry-from-string → check-equal? `($valid-header . $valid-body)

define (parse-entry [in (current-input-port)])
  let ([header (read-line in)])
    if (header → eof-object?)
      eof
      if (header → journal-header?)
        cons header (parse-body in)
        parse-entry in

define (parse-entry-from-string string) 
  string → open-input-string → parse-entry


;;
;; parse-body: reads and returns one journal entry body from the input stream
;; stopping at the next header line, or end of file
;;
module+ test
  "" → parse-body-from-string → check-equal? ""
  " " → parse-body-from-string → check-equal? ""
  "line 1" → parse-body-from-string → check-equal? "line 1"
  "line 1\nline 2" → parse-body-from-string → check-equal? "line 1\nline 2"
  "  \n line 1\nline 2\n" → parse-body-from-string → check-equal? "line 1\nline 2"
  valid-header → parse-body-from-string → check-equal? ""
  ("line 1\nline 2\n" → string-append valid-header) → parse-body-from-string → check-equal? "line 1\nline 2"
  ("line 1\nline 2\n" → string-append valid-header "\nline 3") → parse-body-from-string → check-equal? "line 1\nline 2"

define (parse-body [in (current-input-port)] [result ""])
  if ((peek-string 59 0 in) → journal-header?)
    result → string-trim
    let ([line (read-line in)])
      if (line → eof-object?)
        result → string-trim
        parse-body in (result → string-append line "\n")

define (parse-body-from-string string)
  string → open-input-string → parse-body

;;
;; journal-header?: test if a string is a journal header
;;
module+ test
  eof → journal-header? → check-false
  "foo" → journal-header? → check-false
  invalid-header → journal-header? → check-false
  valid-header → journal-header? → check-true
  valid-header-with-priority → journal-header? → check-true
  valid-header-with-hashtag → journal-header? → check-true
  valid-header-with-datemod → journal-header? → check-true
  valid-header-with-lf → journal-header? → check-true

define (journal-header? line)
  if (line → eof-object?)
    #f
    line ⇒ regexp-match? #px"^[[:digit:]X?_]{13}[!<> ]... .│"

;;
;; sort journal entries by date
;;
define (sort-journal entries)
  entries → sort (e1 e2 : e1 → before? e2)


;;
;; before?: decide if one entry is before another, using the sequence field only
;; if the sequence field is equal, before? returns false, which is required to support
;; stable sorting
;;
module+ test
  define e-20200120-2209 ("20200120_2209 KEP  │ x" → parse-entry-from-string)
  define e-20210120-2209 ("20210120_2209 KEP  │ x" → parse-entry-from-string)
  define e-20210120-2210 ("20210120_2210 KEP  │ x" → parse-entry-from-string)
  define e-20210120-2210Z ("20210120_2210 ZZZ  │ x" → parse-entry-from-string)
  define e-20210120-2211 ("20210120_2211 KEP  │ x" → parse-entry-from-string)
  define e-20220120-2210 ("20220120_2210 KEP  │ x" → parse-entry-from-string)
  e-20200120-2209 → before? e-20210120-2209 → check-true 
  e-20210120-2209 → before? e-20210120-2210 → check-true
  e-20210120-2210 → before? e-20210120-2209 → check-false
  e-20210120-2210 → before? e-20210120-2210Z → check-false
  e-20210120-2210Z → before? e-20210120-2210 → check-false
  e-20210120-2210 → before? e-20210120-2211 → check-true
  e-20210120-2211 → before? e-20220120-2210 → check-true

define (before? e1 e2)
  e1 → car → substring 0 13 → string<? (e2 → car → substring 0 13)

define (print-journal entries)
  entries → iterate print-entry

define (print-entry entry)
  entry → car → displayln
  unless (entry → cdr → eq? "")
    (newline)
    (entry → cdr → displayln)
    (newline)
