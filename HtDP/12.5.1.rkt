;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname 12.5.1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
; 12.5 Feeding Worms
(require 2htdp/image)
(require 2htdp/universe)

; Constants:
(define MTS (empty-scene 500 500))

(define WORM-RADIUS 10)
(define WORM-BODY (circle WORM-RADIUS "solid" "red"))

(define APPLE (circle WORM-RADIUS "solid" "green"))

(define SPEED (* WORM-RADIUS 2))

(define GAME-OVER (text "GAME OVER" 30 "indigo"))

; data definitions:
(define-struct worm (x y dir))
; x:   Number
; y:   Number
; dir: String
; worm's coordinates and direction on MTS

; LOW is one of:
; '()
; (cons worm LOT)
(define WT1 (list (make-worm 100 100 "right")))
(define WT2 (list (make-worm 120 100 "right")
                  (make-worm 100 100 "right")))
(define WT3 (list (make-worm 120 100 "right")
                  (make-worm 100 100 "right")
                  (make-worm 100 80  "down")))

(define-struct world (w f))
; w: current state of the worm - LOW
; f: current state of the food - posn?
; interp. the that of both worm and food on MTS

; functions:
; call with:
;(main (make-world
;         (list (make-worm 100 100 "right"))
;         (make-posn 400 400)))

(define (main w)
  (big-bang w
            (on-tick   tock 0.25)
            (to-draw   rend)
            (on-key    move)
            (state     true)
            (stop-when worm-status game-over)))

; wmt -> wmt
; advance worm 1 diameter
(check-expect (new-low WT1)
              (list (make-worm (+ 100 SPEED) 100 "right")))
(check-expect (new-low WT2)
              (list (make-worm (+ 120 SPEED) 100 "right")
                    (make-worm (+ 100 SPEED) 100 "right")))

; when worm is turn 180deg, it loses a segment for a tick
;(define (tock w) w)
(define (new-low w)
  (cond
    [(string=? "up" (worm-dir (first w)))
     (add-head-y w "up" (- (worm-y (first w)) SPEED))]
    [(string=? "down" (worm-dir (first w)))
     (add-head-y w "down" (+ (worm-y (first w)) SPEED))]
    [(string=? "left" (worm-dir (first w)))
     (add-head-x w "left" (- (worm-x (first w)) SPEED))]
    [(string=? "right" (worm-dir (first w)))
     (add-head-x w "right" (+ (worm-x (first w)) SPEED))]
    [else w]))

; low, direction, operation -> low
; consumes a low, direction, and operation (+ or -),
; produces a new head and removes the old tail
(define (add-head-y low dir y-val)
  (cond
    [(empty? low) '()]
    [else
     (cons (make-worm
            (worm-x (first low))
            y-val
            dir)
           (rem-tail low))]))

(define (add-head-x low dir x-val)
  (cond
    [(empty? low) '()]
    [else
     (cons (make-worm
            x-val
            (worm-y (first low))
            dir)
           (rem-tail low))]))

; low -> low
; consumes a list of worms, produces new list without the
; last worm
(check-expect (rem-tail WT1) '())
(check-expect (rem-tail WT2)
              (list (make-worm 120 100 "right")))
(check-expect (rem-tail WT3)
              (list (make-worm 120 100 "right")
                    (make-worm 100 100 "right")))

(define (rem-tail low)
  (cond
    [(empty? (rest low)) '()]
    [else
     (cons (first low)
           (rem-tail (rest low)))]))

; low -> image
; render current state of the worm
(check-expect (rend-worm (list (make-worm 100 100 "up")))
              (place-image WORM-BODY
                           100 100
                           MTS))
(check-expect
 (rend-worm WT3)
 (place-image WORM-BODY 120 100
              (place-image WORM-BODY 100 100
                           (place-image WORM-BODY 100 80
                                        MTS))))

;(define (rend low) MTS)
(define (rend-worm low)
  (cond
    [(empty? low) MTS]
    [else
     (place-image WORM-BODY
                  (worm-x (first low))
                  (worm-y (first low))
                  (rend-worm (rest low)))]))

; low, ke -> low
; set new direction of worm base on arrow key inputs
(check-expect (move (make-world
                     (list (make-worm 100 100 "down"))
                     (make-posn 1 1))
              "up")
              (make-world
               (list (make-worm 100 100 "up"))
               (make-posn 1 1)))

;(define (move low ke) low)
(define (move w ke)
  (if (or
       (string=? "up"    ke)
       (string=? "down"  ke)
       (string=? "left"  ke)
       (string=? "right" ke))
      (make-world
       (cons (make-worm
              (worm-x (first (world-w w)))
              (worm-y (first (world-w w)))
              ke)
             (rest (world-w w)))
       (world-f w))
      (world-w w)))

; low -> boolean
; produces true if the worm has passed the wall boundaries
(check-expect (passed-wall?
               (list (make-worm 100 100 "up"))) false)
(check-expect (passed-wall?
               (list (make-worm -10 100 "left"))) true)
(check-expect (passed-wall?
               (list (make-worm 100 -10 "up"))) true)

(define (passed-wall? w)
  (or
   (or (< (worm-x (first w)) 0)
       (> (worm-x (first w)) (image-width MTS)))
   (or (< (worm-y (first w)) 0)
       (> (worm-x (first w)) (image-height MTS)))))

; low, worm -> boolean
; consumes an low, split between the first and the rest
; produces true if the first worm is equal to the
; x & y coordinates to any other worm in the list
; produces false is rest of low is empty or no matching worm
(check-expect (ate-self? (list (make-worm 100 80 "up")
                               (make-worm 100 60 "up"))
                         (make-worm 100 100 "up"))
              false)
(check-expect (ate-self? (list (make-worm 100 100 "down")
                               (make-worm 100 100 "up")
                               (make-worm 100 80 "up"))
                         (make-worm 100 100 "down"))
              true)

(define (ate-self? low w)
  (cond
    [(empty? low) false]
    [else
     (if
      (and (= (worm-x w) (worm-x (first low)))
           (= (worm-y w) (worm-y (first low))))
      true
      (ate-self? (rest low) w))]))

; low -> boolean
; consumes a list of worms and produces true
; if the worm has hit a wall or
; the first worm shares x & y coordinates with another
; worm on the list
(define (worm-status w)
  (or (passed-wall? (world-w w))
      (ate-self? (rest (world-w w))
                 (first (world-w w)))))

; worm -> image
; displays GAME-OVER image when worm cross wall boundary
(define (game-over w)
  (place-image GAME-OVER
               (/ (image-width MTS) 2)
               (/ (image-height MTS) 2)
               MTS))

;;;; EX.219
; posn -> posn
; ???
(check-satisfied (food-create (make-posn 1 1))
                 not-equal-1-1?)

(define (food-create p)
  (food-check-create
   p (make-posn (* (* 2 WORM-RADIUS)
                   (random (/ (image-width MTS)
                              (* 2 WORM-RADIUS))))
                (* (* 2 WORM-RADIUS)
                   (random (/ (image-height MTS)
                              (* 2 WORM-RADIUS)))))))

; posn, posn -> posn
; generative recursion
; ???
(define (food-check-create p candidate)
  (if (equal? p candidate) (food-create p) candidate))

; posn -> boolean
; use for testing only
(define (not-equal-1-1? p)
  (not (and (= (posn-x p) 1) (= (posn-y p) 1))))

; world -> world
; updates the world on a tick
(define (tock w)
  (if (ate-apple? w)
      (make-world (new-low (add-tail (world-w w)))
                  (food-create (world-f w)))
      (make-world (new-low (world-w w))
                  (world-f w))))

; world -> image
; renders current state of the world
(define (rend w)
  (place-image
   APPLE
   (posn-x (world-f w))
   (posn-y (world-f w))
   (rend-worm (world-w w))))

; world -> boolean
; compares the x & y coords of the head of the worm and
; placement of the apple, produces true if they are the same
(define (ate-apple? w)
  (and
   (= (worm-x (first (world-w w)))
      (posn-x (world-f w)))
   (= (worm-y (first (world-w w)))
      (posn-y (world-f w)))))

; world -> low
; consumes a world state, produces a new world state
; where once an apple is eaten, the worm grows a new tail
; segment
(check-expect (add-tail
               (list (make-worm 100 100 "right")))
              (list (make-worm 100 100 "right")
                    (make-worm 100 100 "right")))

(define (add-tail low)
   (rev (cons (make-worm
               (worm-x (first low))
               (worm-y (first low))
               (worm-dir (first low)))
              (rev low))))
; need to reverse the LOW, insert at the front and
; then reverse again

; LOW -> LOW
; produces a reversed version of the given list
(check-expect
 (rev (cons "a" (cons "b" (cons "c" '()))))
 (cons "c" (cons "b" (cons "a" '()))))

(define (rev low)
  (cond
    [(empty? low) '()]
    [else
     (add-at-end (rev (rest low)) (first low))]))

; LOW, Worm -> LOW
; creates a new list by adding s to the end of l
(check-expect
 (add-at-end (cons "c" (cons "b" '())) "a")
 (cons "c" (cons "b" (cons "a" '()))))

(define (add-at-end low worm)
  (cond
    [(empty? low) (cons worm '())]
    [else
     (cons (first low)
           (add-at-end (rest low) worm))]))

