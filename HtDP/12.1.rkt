;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname |12.1|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/batch-io)

;; Data definitions:
(define WORDS-LOCATION
  "/home/bammer/OSSU/SPD1x/ch12/words")

; individual word as a list item
(define WORDS-LIST (read-lines WORDS-LOCATION))

; Letter is one of:
; "a"
; ...
; "z"
; or a member? of this list:
(define LETTERS (explode "abcdefghijklmnopqrstuvwxyz"))

; LOW (list of words) is one of:
; '()
; (cons word LOW)

;;;; EX.195
; 1String, LOW -> Number
; counts the number of times a letter 'l' is the first
;     letter in a word in LOW
(check-expect (starts-with# "a" '()) 0)
(check-expect (starts-with# "a" (list "bark" "cark"))
              0)
(check-expect
 (starts-with# "a" (list "aarj" "barj" "carh"))
 1)
(check-expect
 (starts-with# "a" (list "ab" "af" "anus" "butt" "cork"))
 3)

;(define (starts-with# l low) 0)
(define (starts-with# l low)
  (cond
    [(empty? low) 0]
    [else
     (if (first-letter=? l (first low))
         (+ 1 (starts-with# l (rest low)))
         (starts-with# l (rest low)))]))

; 1String, String -> Boolean
; compares a letter with the first letter of a string
; does not account for letter case
(check-expect (first-letter=? "a" "anus") true)
(check-expect (first-letter=? "a" "butthole") false)

;(define (first-letter=? l s) false)
(define (first-letter=? l s)
  (string=? l
            (string-ith s 0)))

;;;; EX.196
(define-struct Letter-Count (l n))
; Let-Count is a structure
; (make-Letter-Count 1String Number)
; interp. the number of times a letter appears

; LOLC is one of:
; '()
; (cons Letter-Count LOLC)


; LOW -> LOLC (list of letter counts)
; takes a list of words and makes a new list
;     of Letter-Counts
; - runs through a list of words
;   - counts the number of words that start with 'a'
;   - creates a Letter-Count for number of 'a's
;   - adds new Letter-Count to output list
;   - repeats for 'b' - 'z'
(check-expect (count-by-letter '())
              (letters-to-L-C LETTERS '()))
;(check-expect
; (count-by-letter (list "aadvark" "auger" "buttdoug"))
; (list (make-Letter-Count "a" 2)
;       (make-Letter-Count "b" 1)))

;; count by letters is same output as letter-to-L-C

;(define (count-by-letter low) '())
(define (count-by-letter low)
  (letters-to-L-C LETTERS low))

; 1String, LOW -> Letter-Count
; makes a letter-count
(check-expect (create-L-C "a" (list "butt"))
              (make-Letter-Count "a" 0))
(check-expect
 (create-L-C "a" (list "abutt" "argh" "butt"))
 (make-Letter-Count "a" 2))
              
;(define (create-L-C l low) (make-Letter-Count l 0))
(define (create-L-C l low)
  (make-Letter-Count l (starts-with# l low)))

; LO1S (list of 1 strings), LOW -> LOLC
; runs through a list of 1strings and counts
;     each instance it is the first letter in a word
(check-expect
 (letters-to-L-C (list "a" "b")
                 (list "anus" "argh" "butt"))
 (list
  (make-Letter-Count "a" 2)
  (make-Letter-Count "b" 1)))

;(define (letters-to-L-C lo1s low) '())
(define (letters-to-L-C lo1s low)
  (cond
    [(empty? lo1s) '()]
    [else
     (cons (create-L-C (first lo1s) low)
           (letters-to-L-C (rest lo1s) low))]))

; LOW -> LOW
; once a letter has been counted in WORDS-LIST
;     remove from list to improve performance
(check-expect (remove-words-with "a" '()) '())
(check-expect
 (remove-words-with "a"
                    (list "abb" "abba" "snort" "weef"))
 (list "snort" "weef"))

;(define (remove-words-with l low) low)
(define (remove-words-with l low)
  (cond
    [(empty? low) '()]
    [else
     (if (first-letter=? l (first low))
         (remove-words-with l (rest low))
         (cons (first low)
               (remove-words-with l (rest low))))]))


;;;; EX.197
(define LC1 (make-Letter-Count "a" 1))
(define LC2 (make-Letter-Count "b" 4))
(define LC3 (make-Letter-Count "c" 2))
(define LC4 (make-Letter-Count "d" 0))

; LOW -> Letter-Count
; produces letter count for most numerous first letter
;     in word list
(check-expect
 (most-frequent (list "ab" "abba" "bard"))
 (make-Letter-Count "a" 2))

;(define (most-frequent low) (make-Letter-Count "a" 0))
(define (most-frequent low)
  (first (L-C-sort> (letters-to-L-C LETTERS low))))

; LOLC -> LOLC
; returns a LOLC sorted by most frequent first
(check-expect
 (L-C-sort>
  (list LC1))
  (list LC1))
(check-expect
 (L-C-sort> (list LC1 LC2 LC3))
 (list LC2 LC3 LC1))

;(define (L-C-sort> lolc) lolc)
(define (L-C-sort> lolc)
  (cond
    [(empty? lolc) '()]
    [else
     (insert-L-C (first lolc) (L-C-sort> (rest lolc)))]))

; Number, LOLC -> LOLC
; inserts Letter-Count into a sorted LOLC
(check-expect
 (insert-L-C LC1 (list LC2 LC3)) (list LC2 LC3 LC1))
(check-expect
 (insert-L-C LC1 '()) (list LC1))
(check-expect
 (insert-L-C LC2 (list LC3 LC1)) (list LC2 LC3 LC1))

;(define (insert-L-C lc lolc) lolc)
(define (insert-L-C lc lolc)
  (cond
    [(empty? lolc) (cons lc '())]
    [else (if (>= (Letter-Count-n lc)
                  (Letter-Count-n (first lolc)))
              (cons lc lolc)
              (cons (first lolc)
                    (insert-L-C lc (rest lolc))))]))

;; 's' is most frequent: 4532
; redesign most-frequent to pick the return the
;     letter used most instead of the first in a
;     sorted list

; LOW -> Letter-Count
; returns the most numerous letter in a LOW
(check-expect
 (most-frequent.v2 (list "ab" "abba" "bard"))
 (make-Letter-Count "a" 2))

(define (most-frequent.v2 low)
  (most-numerous-LC (letters-to-L-C LETTERS low)))

; LOLC -> LC
; returns the most numerous letter in a LOLC
(check-expect (most-numerous-LC (list LC2 LC1))
              LC2)

;(define (most-numerous-LC lolc)
;  (make-Letter-Count "" 0))
(define (most-numerous-LC lolc)
  (cond
    [(empty? (rest lolc)) (first lolc)]
    [else
     (if (>= (Letter-Count-n (first lolc))
             (Letter-Count-n (second lolc)))
         (most-numerous-LC (cons (first lolc)
                                 (rest (rest lolc))))
         (most-numerous-LC (rest lolc)))]))

;;;; EX.198
; redesign most-frequent functions to handle a list
;     of list of words instead of just a list of words

; low -> lolow
; consumes a dictionary (low) and produces a list of lists
; where the words in each list start with the same letter
(check-expect
 (words-by-first-letter (list "gag")) (list "gag"))
(check-expect
 (words-by-first-letter
  (list "ab" "abc" "biff" "cad" "cudd"))
 (list
  (list "ab" "abc")
  (list "biff")
  (list "cad" "cudd")))

(define (words-by-first-letter low) '())


; low -> low
; makes a new list by removing words with the same
; first letter as the first item in a list
(check-expect
 (lists-by-first-letter (list "gag")) (list "gag"))
(check-expect
 (lists-by-first-letter (list "ab" "aff" "bur"))
 (list "ab" "aff"))
(check-expect
 (lists-by-first-letter (list "ab" "bur" "cons"))
 (list "ab"))

(define (lists-by-first-letter low)
  (cond
    [(empty? (rest low)) '())]
    [else
     (if (first-letter=? 