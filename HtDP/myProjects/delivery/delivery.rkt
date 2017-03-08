;**** Delivery App to replace python version ****
#lang racket
(require "./httpTest.rkt"
	 "./model.rkt"
	 racket/date)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;; DATA DEFINITIONS ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(define-struct shift [date deliveries weather holiday])
; Shift is a struct:
; (make-shift String List-of-Delivery Weather Boolean)
; interp. Shift is a collection of information related to a
; shift for delivery driving - MOBILE ONLY

(struct shift [date wage hours tips weather holiday] #:mutable)
; Simple-Shift is a struct
; (make-simple-shift String Number Number Number Weather Boolean)
; interp. a simpler version of a shift for use at home, rather
; than on the job

; CONSTANTS
(define WAGE 6.0)
(define CITY "Chicago,US")
(define PATH "delivery.db")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;; FUNCTIONS ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Void -> String
; Gets the current date as a string
(define (get-date)
  (date->string (seconds->date (current-seconds) #t)))

; String -> Weather
; Consumes a city name (CityName,CC) (CC = country abbrv)
; Produces a Weather struct of the current weather
; (ideally want weather info to spread over entire shift)
(define (create-weather city)
  (display "Getting today's weather...\n")
  (get-weather-info city))

; Input Port, String -> String|Number
; Allows user to enter a string  that represents a Shift field
; Returns a symbol representing said Shift field
(define (user-input s)
  (display (string-append "Enter " s "> "))
  (local ((define input (read (current-input-port))))
    (cond
     [(symbol? input) (symbol->string input)]
     [(number? input) input]
     [else "user-input: invalid input"])))
   
; Input Port -> Number
; Following functions get user input for numeric values
(define (get-hours)
  (user-input "hours"))

(define (get-wage)
  (user-input "wage"))

(define (get-tips)
  (user-input "tips"))

; Input Port -> Number (Boolean)
; Determines if a shift fell on a holiday
; Because SQLite does not accept true/false, 1/0 is used
(define (get-holiday)
  (display "Holiday? (y or n)> ")
  (local ((define input (symbol->string
			 (read (current-input-port)))))
    (cond
     [(string=? "y" input) 1]
     [(string=? "n" input) 0]
     [else (get-holiday)])))

; Input Port(s), Storage -> Void
; Launches a prompt to get user's shift info and
; inserts info into a DB
(define (create-shift a-store)
  (define the-weather (create-weather "Chicago,US"))
  (define the-date (get-date))
  
  (storage-insert-shift!
   #:storage a-store
   #:date the-date
   #:wage (get-wage)
   #:hours (get-hours)
   #:tips (get-tips)
   #:holiday? (get-holiday))

  ; deletes all duplicates except the first
  (storage-delete-duplicate-shifts! a-store the-date)
  ; deletes the possible unmatched weather entries
  (storage-delete-duplicate-weather! a-store)

  (define next-id (get-shift-id a-store))
  
  (storage-insert-weather!
   #:storage a-store
   #:shift-id next-id
   #:city (weather-city  the-weather)
   #:conditions (weather-desc  the-weather)
   #:temp (weather-temp  the-weather)
   #:temp-hi (weather-hi    the-weather)
   #:temp-lo (weather-lo    the-weather)))
  
;;;; test object
(define TEST0
  (shift
   "Tuesday, February 28th, 2017"
   6.0
   5
   75
   (make-weather "Chicago,US" "clear sky" 50.0 52.0 45.0)
   0))
; test run program:
