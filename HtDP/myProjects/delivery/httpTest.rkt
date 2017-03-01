; Module for the weather info
#lang racket
(require racket/flonum
	 net/url
	 json)

; DATA DEFINITIONS:
;(weather String String Number Number)
(define-struct weather (city desc hi lo temp))
     

; FUNCTIONS:
; Number -> Number
(define (kelvin->fahren temp-k)
  (flround (- (* temp-k 9/5) 459.67)))

; JSExpr -> Weather
; Converts a JS expression to a Weather
(define (make-city-weather city-js)
  (make-weather
    (hash-ref city-js 'name)
    (hash-ref (first (hash-ref city-js 'weather)) 'description)
    (kelvin->fahren
     (hash-ref (hash-ref city-js 'main) 'temp_max))
    (kelvin->fahren
     (hash-ref (hash-ref city-js 'main) 'temp_min))
    (kelvin->fahren
     (hash-ref (hash-ref city-js 'main) 'temp))))
	  

; String|Number -> Ouput Port
; Converts an input to an output port
(define (str->out s)
  (cond
   [(string? s) 
    (display (string-append s "\n")
	     (current-output-port))]
   [(number? s)
    (display (string-append
	      (number->string s)
	      "\n")
	     (current-output-port))]
   [else
    (display "str->out: Input Not Valid\n"
	     (current-output-port))]))

; Weather -> String
; Creates a string from a Weather for display on an output port
(define (weather->str w)
  (string-append "City:        " (weather-city w) "\n"
		 "Conditions:  " (weather-desc w) "\n"
		 "Temperature: " (number->string
				  (weather-temp w)) "\n"
		 "High:        " (number->string
				  (weather-hi w)) "\n"
		 "Low:         " (number->string
			   (weather-lo w)) "\n"))

; Weather -> Output Port
; Displays a Weather on an output port
(define (weather->output-port w)
  (str->out (weather->str w)))

; Input Port -> Weather -> Output Port
; Testing function
(define (input)
  (display "Enter a city name (ex. Chicago,US)> ")
  (local ((define city
	    (symbol->string (read (current-input-port))))
	  (define city-weather (get-weather-info city)))
    (weather->output-port city-weather)))


; String -> Weather
; Takes a string "City\,CC" (where CC is 2 letter abbrv)
; Makes a GET request for weather data
; Returns a Weather with data from input city
(define (get-weather-info city)
  (local ((define city-url
	    (url "http" #f "api.openweathermap.org" #f #t
		 (list
		  (path/param "data" '())
		  (path/param "2.5" '())
		  (path/param "weather" '()))
		 `((q . ,city)
		   (APPID . "5c444bd5dc0ffc772bf5b32c7f511567"))
		 #f))
	  (define city-js (string->jsexpr
			   (port->string
			    (get-pure-port city-url)))))
    
    (make-city-weather city-js)))

(provide get-weather-info
	 (struct-out weather)
	 weather-city
	 weather-desc
	 weather-temp
	 weather-hi
	 weather-lo)