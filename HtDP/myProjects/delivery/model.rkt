; DB model for Delivery App
#lang racket
(require db)

(struct storage (db))
; db is a SQLite connection

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
		 "CREATE TABLE weather (pid INTEGER, "
		 "city TEXT, conditions TEXT, temp REAL, "
		 "hi REAL, lo REAL)")))
  the-store)

; Storage, String, Number, Number, Number, Boolean -> Void
; inserts a Shift into a DB
(define (storage-insert-shift! a-store dt wg hr tp hd)
  (query-exec
   (storage-db a-store)
   (string-append
    "INSERT INTO shifts (date, wage, hours, tips, holiday) "
    "VALUES (?, ?, ?, ?, ?)")
   dt wg hr tp hd))

; Storage, String, String, Number, Number, Number -> Void
; inserts a Weather into a DB
(define (storage-insert-weather! a-store cy cd t th tl)
  (query-exec
   (storage-db a-store)
   (string-append
    "INSERT INTO weather (pid, city, conditions, temp, hi, lo) "
    "VALUES (?, ?, ?, ?, ?, ?)")
   cy cd t th tl))


(provide create-db
	 storage-insert-shift!
	 storage-insert-weather!)
	 


















