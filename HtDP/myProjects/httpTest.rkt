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
(define (make-city-info city-js)
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
(define (weather->output-port w)
  (str->out (weather->str w)))

; Port -> String
(define (input)
  (display "Enter a city name (ex. Chicago,US)> ")
  (local ((define city
	    (symbol->string (read (current-input-port))))
	  (define city-weather (get-city-info city)))
    (weather->output-port city-weather)))


; String -> Weather
(define (get-city-info city)
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
    
    (make-city-info city-js)))

(input)
