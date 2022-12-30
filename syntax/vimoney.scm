#!/usr/bin/csi -s

(require-extension utf8)
(require-extension posix)          ; setenv
(require-extension srfi-13)        ; string-trim
(require-extension embedded-test)  ; tests

(setenv "TESTS" "1")
(setenv "TESTS_VERBOSE" "1")
;(setenv "TEST_GROUPS" "")

(define *default-currency* "AUD")

;====================
(define-record entry 
  date
  time
  location
  polarity
  from-account
  to-account
  description
  units
  amount
  currency
  value
  comment)


;====================
(test-group string-cut
  (test (string-cut "abcdefg" 0 0) "")
  (test (string-cut "abcdefg" 0 1) "a")
  (test (string-cut "abcdefg" 0 2) "ab")
  (test (string-cut "abcdefg" 1 0) "")
  (test (string-cut "abcdefg" 1 1) "b")
  (test (string-cut "abcdefg" 1 2) "bc")
  (test (string-cut "abcdefg" 6 0) "")
  (test (string-cut "abcdefg" 6 1) "g")
  (test (string-cut "abcdefg" 6 2) "g")
  (test (string-cut "abcdefg" 7 1) "")
  (test (string-cut " bcdefg" 0 7) "bcdefg")
  (test (string-cut "abcdef " 0 7) "abcdef")
  (test (string-cut "abcdefg" -1 1) ""))

(define (string-cut string start chars)
  (handle-exceptions e "" 
    (string-trim-both
      (substring string start (min (string-length string) (+ start chars))))))


;====================
(test-group parse-entry
  (let ((line "2018-05-22 11:56 KL klia2 airport      = citibank cash   │ atm withdrawal                       MYR 150         AUD 50.10"))
    (test (entry-date (parse-entry line)) "2018-05-22")
    (test (entry-time (parse-entry line)) "11:56")
    (test (entry-location (parse-entry line)) "KL klia2 airport")
    (test (entry-polarity (parse-entry line)) "=")
    (test (entry-from-account (parse-entry line)) "citibank")
    (test (entry-to-account (parse-entry line)) "cash")
    (test (entry-description (parse-entry line)) "atm withdrawal")
    (test (entry-units (parse-entry line)) "MYR")
    (test (entry-amount (parse-entry line)) "150")
    (test (entry-currency (parse-entry line)) "AUD")
    (test (entry-value (parse-entry line)) "50.10")
    (test (entry-comment (parse-entry line)) ""))
  (let ((line "2018-05-22 11:56 KL klia2 airport      = citibank        │ atm withdrawal                       MYR 150         AUD 50.10"))
    (test (entry-to-account (parse-entry line)) "")))

(define (parse-entry line)
  (make-entry
    (string-cut line 0 10)     ; date
    (string-cut line 11 5)     ; time
    (string-cut line 17 21)    ; location
    (string-cut line 39 1)     ; polarity
    (car (string-split (string-cut line 41 15)))                              ; from-account is required
    (handle-exceptions e "" (cadr (string-split (string-cut line 41 15))))    ; to-account may be empty
    (string-cut line 59 36)    ; description
    (string-cut line 96 3)     ; units
    (string-cut line 100 11)   ; amount
    (string-cut line 112 3)    ; currency
    (string-cut line 116 11)   ; value
    (string-cut line 128 (string-length line))))


;====================
(define (parse-lines port entries)
  (let ((line (read-line port)))
    (cond
      ((eof-object? line) (reverse entries))                            ; stop condition
      ((string=? (substring line 0 2) "//") (parse-lines port entries)) ; ignore comments
      (else (parse-lines port (cons (parse-entry line) entries))))))    ; build the list


;====================
(define (parse-file filename)
  (parse-lines (open-input-file filename) '()))


;====================
(test-group swap-entry-values
  (let ((test-entry (make-entry "1970-01-01" "00:00" "KL" "=" "citibank" "cash" "atm withdrawal" "AUD" "10" "MYR" "50" "")))
    (test (entry-units test-entry) "AUD")
    (test (entry-amount test-entry) "10")
    (test (entry-currency test-entry) "MYR")
    (test (entry-value test-entry) "50")
    (test (entry-units (swap-entry-values test-entry)) "MYR")
    (test (entry-amount (swap-entry-values test-entry)) "50")
    (test (entry-currency (swap-entry-values test-entry)) "AUD")
    (test (entry-value (swap-entry-values test-entry)) "10")))

(define (swap-entry-values entry)
  (make-entry
    (entry-date entry)
    (entry-time entry)
    (entry-location entry)
    (entry-polarity entry)
    (entry-from-account entry)
    (entry-to-account entry)
    (entry-description entry)
    (entry-currency entry)   ; new units
    (entry-value entry)      ; new amount
    (entry-units entry)      ; new currency
    (entry-amount entry)     ; new value
    (entry-comment entry)))


;====================
(test-group fix-entry-values
  (let ((test-entry (make-entry "1970-01-01" "00:00" "KL" "=" "citibank" "cash" "atm withdrawal" "AUD" "10" "MYR" "50" "")))
    (test (entry-units (fix-entry-values test-entry "MYR")) "AUD")
    (test (entry-amount (fix-entry-values test-entry "MYR")) "10")
    (test (entry-currency (fix-entry-values test-entry "MYR")) "MYR")
    (test (entry-value (fix-entry-values test-entry "MYR")) "50")
    (test (entry-units (fix-entry-values test-entry "AUD")) "MYR")
    (test (entry-amount (fix-entry-values test-entry "AUD")) "50")
    (test (entry-currency (fix-entry-values test-entry "AUD")) "AUD")
    (test (entry-value (fix-entry-values test-entry "AUD")) "10"))
  (let ((test-entry (make-entry "1970-01-01" "00:00" "KL" "=" "citibank" "cash" "atm withdrawal" "" "" "MYR" "50" "")))
    (test (entry-units (fix-entry-values test-entry "AUD")) "MYR")
    (test (entry-amount (fix-entry-values test-entry "AUD")) "50")
    (test (entry-currency (fix-entry-values test-entry "AUD")) "")
    (test (entry-value (fix-entry-values test-entry "AUD")) "")))

(define (fix-entry-values entry default-currency)
  (cond
    ((string=? (entry-currency entry) default-currency) entry)
    ((string=? (entry-units entry) default-currency) (swap-entry-values entry))
    ((string=? (entry-units entry) "") (swap-entry-values entry))
    (else entry))) ; no match for default currency, cannot fix

(define (fix-entry-values-default entry)
  (fix-entry-values entry *default-currency*))


;====================
(test-group entry-to-string
  (test (entry-to-string 
    (make-entry "1970-01-01" "00:00" "KL" "=" "citibank" "cash" "atm withdrawal" "MYR" "50" "AUD" "15.10" ""))
    "1970-01-01 00:00 KL                    = citibank cash   │ atm withdrawal                       MYR 50          AUD 15.10"))

(define (entry-to-string entry)
  (string-trim-right
    (string-append
      (string-pad-right (entry-date entry) 11)
      (string-pad-right (entry-time entry) 6)
      (string-pad-right (entry-location entry) 22)
      (string-pad-right (entry-polarity entry) 2)
      (string-pad-right (string-append (entry-from-account entry) " " (entry-to-account entry)) 16) "│ "
      (string-pad-right (entry-description entry) 37)
      (string-pad-right (entry-units entry) 4)
      (string-pad-right (entry-amount entry) 12)
      (string-pad-right (entry-currency entry) 4)
      (string-pad-right (entry-value entry) 12)
      (entry-comment entry))))

    
;====================
(define (export-entries entries port)
  (map (lambda (x) (write (entry-to-string x) port) (newline port)) entries))

(define (export-entries-stdout entries)
  (export-entries entries (current-output-port)))


;====================
;(export-entries (map fix-entry-values-default (parse-file "/home/octopus/game/refactor/accounts/compacted.1.log")) (open-output-file "/tmp/cashflow.export.log"))

(run-tests)

