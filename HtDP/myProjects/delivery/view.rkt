#lang web-server
(require (prefix-in dispatch: web-server/dispatch)
         (prefix-in dispatch-log: web-server/dispatchers/dispatch-log)
         (prefix-in xexpr: web-server/http/xexpr)
         (prefix-in servlet: web-server/servlet-env)
         (prefix-in mime: web-server/private/mime-types)
         (prefix-in req: web-server/http/request-structs)
         (prefix-in res: web-server/http/response-structs)
         (prefix-in resconf: web-server/configuration/responders)
         (prefix-in dis-files: web-server/dispatchers/dispatch-files)
         (prefix-in json: json))

; Request -> Xexpr
(define (not-found-route request)
  (xexpr:response/xexpr
   `(html (body (h2 "Page not found :(")))))

; Request -> Xexpr
(define (home-route request)
  (xexpr:response/xexpr
   #:preamble #"<!DOCTYPE html>"
   `(html
     (head
      (link ((rel "stylesheet")
             (href "css/style.css")))
      (script ((src "js/app.js"))))
     (body
      (h2 "Welcome")
      (button ((id "info"))
              "Click for Info")
      (p ((id "display")))))))

; Request -> File(?)
; loads a static file
(define (get-static-file request)
  (resconf:file-response 200 #"OK" request))

; Request -> JSON
; Takes a GET request and responds with JSON of shift info
(define (get-info req)
  (resconf:file-response
   200 #"OK"
   (json:write-json #hash((hello . "hey there")))))

(define (info-get req)
  (res:response
   200 #"OK" (current-seconds) #"application/javascript"
   empty
   (lambda (port)
     (json:write-json #hash((hello . "hey there")) port))))
     ;(write-string "hello" port))))

(define (info-get2 req)
  (res:response/output
   (lambda (port)
     (json:write-json #hash((hello . "hey there")) port))
   #:code 200
   #:message #"OK"
   #:seconds (current-seconds)
   #:mime-type #"application/json"
   #:headers empty))

; URL -> Xexpr?
; binds route-url to the appropriate route?
(define-values (route-dispatch route-url)
  (dispatch:dispatch-rules
   [("") home-route]
   [("js/app.js") get-static-file]
   [("style.css") get-static-file]
   [("info") info-get2]
   [("test.json") get-static-file]
   [else not-found-route]))

; Request -> (Logs request), Function
; Takes in a request, logs it, and pass it to the appropriate route
(define (start req)
  (display (dispatch-log:apache-default-format req))
  ;(display (req:request-method req))
  (display (filter-for-type req))
  (flush-output)
  (route-dispatch req))

; Request -> Mime-type
; filters HTTP request for the proper mime-type
(define (filter-for-type req)
  (local ((define header-list (req:request-headers/raw req)))
    (req:header-value
     (req:headers-assq #"Accept" header-list))))
          

(servlet:serve/servlet
 start
 #:launch-browser? #f
 ; if servlet-reqexp is used, there is no access
 ; to the static files, but can get JSON output
 ; otherwise, can get static files but not JSON
 #:servlet-path "/"
 ;#:servlet-regexp #rx""
 #:extra-files-paths (list (build-path "static"))
 #:servlet-current-directory "/"
 #:stateless? #t)
