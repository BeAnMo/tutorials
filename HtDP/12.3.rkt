;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname |12.3|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
; 12.3 Word Games, Composition Illustrated
(require 2htdp/batch-io)

(define WORDS-LOCATION
  "/home/bammer/OSSU/SPD1x/ch12/words")

; individual word as a list item
(define WORDS-LIST (read-lines WORDS-LOCATION))

(define TEST-DICT (list "aa" "abc" "bort" "cub" "cort"
                        "def" "deaf" "leppard"))

; set vs list simple differences:
; set does not care about ordering
; set does not care about frequency of a value

; String -> List-of-Strings
; find all words that use the same letters as s
(check-member-of (alternative-words "cat")
                 (list "act" "cat")
                 (list "cat" "act"))
(check-satisfied (alternative-words "rat")
                  all-words-from-rat?)

(define (alternative-words s)
  (in-dictionary
   (words->strings (arrangements (string->word s)))))

; LOS -> Boolean
(define (all-words-from-rat? w)
  (and (member? "rat" w)
       (member? "art" w)
       (member? "tar" w)))

; List-of-words -> List-of-strings;
; turn all Words in LOW into Strings
(check-expect (words->strings '()) '())
(check-expect (words->strings
               (list
                (list "a" "s" "s")
                (list "f" "u" "c")))
              (list "ass" "fuc"))

(define (words->strings low)
  (cond
    [(empty? low) '()]
    [else
     (cons (word->string (first low))
           (words->strings (rest low)))]))

; LOS -> LOS
; pick out all those Strings that occur in the dictionary
(check-expect (in-dictionary (list "abc" "cort" "def")

(define (in-dictionary los) '())

; Word is one of:
; '()
; (cons 1String Word)

; List-of-Words is one of:
; '()
; (cons Word List-of-Words)

; Word -> List-of-Words
; find all rearrangements of Word
(define (arrangements word) (list word))

; String -> Word
; convert s to the chose word representation
(check-expect (string->word "") '())
(check-expect (string->word "a") (list "a"))
(check-expect (string->word "ass") (list "a" "s" "s"))

(define (string->word s)
  (explode s))

; Word -> String
; convert w to a string
(check-expect (word->string '()) "")
(check-expect (word->string (list "f" "u" "c")) "fuc")

(define (word->string w)
  (implode w))