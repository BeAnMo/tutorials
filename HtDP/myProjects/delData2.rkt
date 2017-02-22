#lang racket
(require 2htdp/image)
(require 2htdp/batch-io)
; ---------------------------------
; **** CSV related defintions ****:
; ---------------------------------
; ---------------------------
; **** data definitions ****:
; ---------------------------
(define USER-INFO-CSV
  "/home/bammer/Desktop/appClass/user_info_lombard.csv")
(define USER-INFO-HEADER
  (first (read-csv-file USER-INFO-CSV)))
(define USER-INFO-LIST
  (rest (read-csv-file USER-INFO-CSV)))

(define-struct bar (bar-img))
; (make-bar Image)
; a graph-bar 8px wide & variable height

(define-struct shift
  (date hourly hours end start total tips wage))
; date   -> first U-I-L - String
; hourly -> second      - Number
; hours  -> third       - Number
; end    -> fourth      - Number
; start  -> fifth       - Number
; total  -> sixth       - Number
; tips   -> seventh     - Number
; wage   -> eighth      - Number


; --------------------
; **** functions ****:
; --------------------
; List-of-strings (CSV) -> Shift
; converts a CSV row to a Shift

;(define (csv->shifts lor) '())
(define (row->shift lor)
  (make-shift (first lor)
              (string->number (second  lor))
              (string->number (third   lor))
              (string->number (fourth  lor))
              (string->number (fifth   lor))
              (string->number (sixth   lor))
              (string->number (seventh lor))
              (string->number (eighth  lor))))

; List-of-rows (CSV) -> List-of-Shifts
; converts a list of CSV rows to a list of Shifts
(define (rows->shifts lor)
  (cond
    [(empty? lor) '()]
    [else
     (cons (row->shift (first lor))
           (rows->shifts (rest lor)))]))


; -------------------------
; **** list of Shifts ****:
(define SHIFT-LIST (rows->shifts USER-INFO-LIST))
; -------------------------


; Shift -> Image
; creates a bar for shift total a x-pos
(define (create-bar width amount style color)
  (make-bar
   (rectangle width amount style color)))

; Number, Shift, String, String Shift-field -> Image
; makes a bar representing a shift-total
(define (shift->image w a s c field)
  (create-bar w (field a) s c))

; List-of-shifts Number, String, String, Shift-field -> List-of-images
; converts shift totals into bars for a graph

;(define (shifts->images los n) '())
(define (shifts->images w los s c field)
  (cond
    [(empty? los) '()]
    [else
     (cons
      (shift->image w (first los) s c field)
      (shifts->images w (rest los) s c field))]))


; ---------------------------
; **** CSV calculations ****:
; ---------------------------
; List-of-Shifts, Shift-field -> Number
; calculates the totals for fields that take a Number
(define (totals los field)
  (cond
    [(empty? los) 0]
    [else
     (+ (field (first los))
        (totals (rest los) field))]))

; LOS, Shift-field, Comparison function -> Number
; filters LOS for lowest/highest value in a specified field
(define (get-leader los field compare)
  (cond
    [(empty? (rest los)) (field (first los))]
    [else
     (if (compare (field (first los))
             (field (second los)))
         (get-leader (cons (first los)
                           (rest (rest los))) field compare)
         (get-leader (rest los) field compare))]))


; ------------------------------------
; **** Graph related definitions ****:
; ------------------------------------
; ---------------------------
; **** data definitions ****:
; ---------------------------
(define WIDTH 800)
(define HEIGHT 200)
(define MTS (empty-scene WIDTH HEIGHT))

; totals & wages graphs
(define TOTAL-IMG-LIST (shifts->images 8 SHIFT-LIST "solid" "blue" shift-total))
(define WAGE-IMG-LIST (shifts->images 8 SHIFT-LIST "solid" "green" shift-wage))

; --------------------
; **** functions ****:
; --------------------
; List-of-images -> Image
; creates a graph of shift totals separated by
;     5px

;(define (create-graph loi n) MTS)
(define (create-graph loi)
  (cond
    [(empty? loi) (rectangle 5 0 "solid" "green")]
    [else
     (beside/align "bottom"
                   (bar-bar-img (first loi))
                   (create-graph (rest loi)))]))

; String, Number -> Image
(define (mk-txt str size)
  (text/font str size "black" "Ubuntu"
             'default 'normal 'normal #f))

; Image, Number -> Number
; get y-coord so image can rest on bottom of MTS
(define (bottom img h)
  (- h (/ (image-height img) 2)))


; -----------------
; **** images ****:
; -----------------
; overlays wage graph onto total graph
(define WAGE-TOTAL-OVERLAY
  (overlay/align "center" "bottom"
                 (create-graph WAGE-IMG-LIST)
                 (create-graph TOTAL-IMG-LIST)))

; red line at totals average
(define AVG-TOTAL-WTO
  (add-line WAGE-TOTAL-OVERLAY
   0 (- 155 77.98)
   (image-width WAGE-TOTAL-OVERLAY) (- 155 77.98) "red"))

; red lines @ avg & lowest
(define LO-AVG-WTO
  (add-line AVG-TOTAL-WTO 
            0 (- 155 28) (image-width WAGE-TOTAL-OVERLAY) (- 155 28) "red"))

; red lines at avg, lowest, & highest
(define HI-LO-AVG-WTO
  (add-line LO-AVG-WTO
	    0 0 (image-width WAGE-TOTAL-OVERLAY) 0 "red"))

; bottom coordinate for mts
(define WTO-BOTTOM (bottom WAGE-TOTAL-OVERLAY HEIGHT))
  
(define GRAPH-IMG (place-image
                   WAGE-TOTAL-OVERLAY
                   (/ WIDTH 2) WTO-BOTTOM
                   MTS))

(define GRAPH-IMG.v2 (place-image
                      (beside 
                       (above
                        (mk-txt "Highest" 20)
                        (mk-txt "$155" 12)
                        (mk-txt "Avg Total" 20)
                        (mk-txt "$77.90 per shift" 12)
                        (mk-txt "across 85 shifts" 12)
                        (mk-txt "Lowest" 20)
                        (mk-txt "$28" 12))
                       HI-LO-AVG-WTO)
                      (/ WIDTH 2) WTO-BOTTOM
                      MTS))
