; DB model for Delivery App
#lang racket
(require db)

;;;; Test
;(struct shift [date wage hours tips weather holiday] #:mutable)

(struct storage (db))
; db is a SQLite connection

(struct app (storage id))
; storage is a Storage struct, id is an integer

; String -> Storage
; Takes path and creates a DB with tables 'shifts' & 'weather'
; if they don't already exist
(define (create-db path)
  (define the-db (sqlite3-connect #:database path
			      #:mode 'create))
  (define the-store (storage the-db))
  (unless (table-exists? the-db "shifts")
    (query-exec the-db
		(string-append
		 "CREATE TABLE shifts "
		 "(id INTEGER PRIMARY KEY, "
		 "date TEXT, wage REAL, hours REAL, tips REAL, "
		 "holiday BOOLEAN)")))
  (unless (table-exists? the-db "weather")
    (query-exec the-db
		(string-append
		 ; pid should be shift_id
		 "CREATE TABLE weather (shift_id INTEGER, "
		 "city TEXT, conditions TEXT, temp REAL, "
		 "hi REAL, lo REAL)")))
  the-store)

; Storage, String, Number, Number, Number, Boolean -> Void
; inserts a Shift into a DB
(define (storage-insert-shift! a-store date wage
			       hours tips holiday)
  (query-exec
   (storage-db a-store)
   (string-append
    "INSERT INTO shifts (date, wage, hours, tips, holiday) "
    "VALUES (?, ?, ?, ?, ?)")
   date wage hours tips holiday))

; Storage, Number, String, String, Number, Number, Number -> Void
; inserts a Weather into a DB
(define (storage-insert-weather! a-store
				 a-shift-id
				 city
				 conditions
				 temp hi lo)
  (query-exec
   (storage-db a-store)
   (string-append
    "INSERT INTO weather (shift_id, city, "
    "conditions, temp, hi, lo) "
    "VALUES (?, ?, ?, ?, ?, ?)")
   ; need pID to enter, match with shift ID
   ; pid is the relation to id in shifts, should be shift_id
   a-shift-id
   city conditions
   temp hi lo))

; Storage -> List-of-Apps
; Takes in a Storage struct, and retrieves the id number
; that corresponds with a Shift in the shift table
(define (app-stores a-store)
  (define (id->app an-id)
    (app a-store an-id))
  (map id->app
       (query-list (storage-db a-store)
		   "SELECT id FROM shifts")))

; Storage -> Number
; Queries the shift table for the last entry - MAX(id)
(define (get-shift-id a-store)
  (first (query-list (storage-db a-store)
		     "SELECT MAX(id) FROM shifts")))

(provide create-db
	 (struct-out storage)
	 storage-insert-shift!
	 storage-insert-weather!
	 get-shift-id
	 app-stores
	 app-id)
	 


















