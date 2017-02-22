;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname |12.5|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
; 12.5 Feeding Worms
(require 2htdp/image)
(require 2htdp/universe)

; Constants:
(define MTS (empty-scene 500 500))

(define WORM-RADIUS 10)
(define WORM-BODY (circle WORM-RADIUS "solid" "red"))

(define SPEED (* WORM-RADIUS 2))

(define GAME-OVER (text "GAME OVER" 30 "indigo"))

; data definitions:
(define-struct worm (x y dir))
; x:   Number
; y:   Number
; dir: String
; worm's coordinates and direction on MTS


; functions:
; call with (make-worm Number Number String)
(define (main w)
  (big-bang w
            (on-tick   tock 0.5)
            (to-draw   rend)
            (on-key    move)
            (stop-when passed-wall? game-over)))

; worm -> worm
; advance worm 1 diameter
(check-expect (tock (make-worm 10 10 "down"))
              (make-worm 10 (+ 10 SPEED) "down"))
(check-expect (tock (make-worm 100 100 "right"))
              (make-worm (+ 100 SPEED) 100 "right"))

;(define (tock w) w)
(define (tock w)
  (cond
    [(string=? "up" (worm-dir w))
     (make-worm (worm-x w) (- (worm-y w) SPEED) (worm-dir w))]
    [(string=? "down" (worm-dir w))
     (make-worm (worm-x w) (+ (worm-y w) SPEED) (worm-dir w))]
    [(string=? "left" (worm-dir w))
     (make-worm (- (worm-x w) SPEED) (worm-y w) (worm-dir w))]
    [(string=? "right" (worm-dir w))
     (make-worm (+ (worm-x w) SPEED) (worm-y w) (worm-dir w))]
    [else w]))

; worm -> image
; render current state of the worm
(check-expect (rend (make-worm 100 100 "up"))
              (place-image WORM-BODY
                           100 100
                           MTS))

;(define (rend w) MTS)
(define (rend w)
  (place-image WORM-BODY
               (worm-x w) (worm-y w)
               MTS))

; worm, ke -> worm
; set new direction of worm base on arrow key inputs
(check-expect (move (make-worm 100 100 "down") "up")
              (make-worm 100 100 "up"))

;(define (move w ke) w)
(define (move w ke)
  (if (or
       (string=? "up"    ke)
       (string=? "down"  ke)
       (string=? "left"  ke)
       (string=? "right" ke))
      (make-worm (worm-x w) (worm-y w) ke)
      w))

; worm -> boolean
; produces true if the worm has passed the wall boundaries
(check-expect (passed-wall? (make-worm 100 100 "up")) false)
(check-expect (passed-wall? (make-worm -10 100 "left")) true)
(check-expect (passed-wall? (make-worm 100 -10 "up")) true)

(define (passed-wall? w)
  (or
   (or (< (worm-x w) 0) (> (worm-x w) (image-width MTS)))
   (or (< (worm-y w) 0) (> (worm-x w) (image-height MTS)))))

; worm -> image
; displays GAME-OVER image when worm cross wall boundary
(define (game-over w)
  (place-image GAME-OVER
               (/ (image-width MTS) 2)
               (/ (image-height MTS) 2)
               MTS))
