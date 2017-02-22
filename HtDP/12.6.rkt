;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname |12.6|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
; 12.6 Simple Tetris
(require 2htdp/universe)
(require 2htdp/image)

;; CONSTANTS:
(define WIDTH 14) ; # of block horizontally
(define HEIGHT (- 20 1))
(define SIZE 10)  ; blocks are squares
(define SCENE-SIZE (* WIDTH SIZE))

(define SPEED SIZE)

(define MTS (empty-scene (* SIZE WIDTH) (* SIZE 20)))

(define BLOCK
  (overlay
   (square (- SIZE 1) "solid" "red")
   (square SIZE "outline" "black")))

; shapes
; need to convert shapes to lists of blocks?
(define SQR (above (beside BLOCK BLOCK)
                      (beside BLOCK BLOCK)))
(define TEE (above (beside BLOCK BLOCK BLOCK) BLOCK))
(define LINE (above BLOCK BLOCK BLOCK BLOCK))
(define ELL (beside/align "bottom" (above BLOCK BLOCK BLOCK) BLOCK))
(define ZEE (beside/align "bottom"
                          (above/align "right"
                                       (beside BLOCK BLOCK)
                                       BLOCK)
                          BLOCK))
(define ESS (beside/align "bottom"
                          BLOCK
                          (above/align "left"
                                       (beside BLOCK BLOCK)
                                       BLOCK)))

(define-struct tetris (block landscape))
(define-struct block (x y))

; Tetris is a structure:
; (make-tetris Block Landscape)
; Landscape is one of:
; '()
; (cons Block Landscape)
; Block is a structure:
; (make-block N N)

; interp. (make-block) depicts a block whose
; left corner is (* x SIZE) pixels from the left
; and (* y SIZE) pixels from the top;
; (make-tetris b0 (list b1 b2 ...)) means b0 is
; the dropping block, while b1, b2, and ... are
; resting

; examples:
; non block
(define b0 (make-block (- 10) (- 10)))
; falling block - 5 blocks from left & 5 from top
(define bd0 (make-block (* 5 SIZE) (* 5 SIZE)))
; falling block - left side, 5 from top
(define bd1 (make-block (* 1 SIZE) (* 5 SIZE)))
; landed block, left corner
(define b1 (make-block (* 1 SIZE) (* HEIGHT SIZE)))
; landed block, right corner
(define b2 (make-block (* (- WIDTH 1) SIZE)
                       (* HEIGHT SIZE)))
; landed block, middle
(define b3 (make-block (* (/ WIDTH 2) SIZE)
                       (* (- HEIGHT 1) SIZE)))
; empty landscape
(define t0 (make-tetris b0 '()))
; 1 falling block
(define t1 (make-tetris bd0 '()))
; 1 landed left corner, no falling
(define t3 (make-tetris b0 (list b1)))
; 1 landed left corner, 1 falling left side
(define t4 (make-tetris bd1 (list b1)))
; 2 landed left & right coners, 1 falling middle
(define t5 (make-tetris bd0 (list b1 b2)))
; 2 landed left corner, 1 falling left side
(define t6 (make-tetris bd0 (list
                             (make-block
                              (* 1 SIZE) (* (- HEIGHT 1)
                                            SIZE))
                             b1)))

;; FUNCTIONS:
; Tetris -> Image
; converts current instance of Tetris to an image
(check-expect (tetris-render t0) MTS)
(check-expect (tetris-render t1)
              (place-image BLOCK 50 50 MTS))
(check-expect (tetris-render t3)
              (place-image BLOCK
                           SIZE (* HEIGHT SIZE)
                           MTS))
(check-expect
 (tetris-render t4)
 (place-image BLOCK SIZE (* SIZE 5)
              (place-image BLOCK
                           SIZE (* HEIGHT SIZE)
                           MTS)))
(check-expect
 (tetris-render t5)
 (place-image
  BLOCK
  (* 5 SIZE) (* 5 SIZE)
  (place-image
   BLOCK
   SIZE (* HEIGHT SIZE)
   (place-image
    BLOCK
    (* (- WIDTH 1) SIZE)
    (* HEIGHT SIZE)
    MTS))))
               
;(define (tetris-render t) MTS)
(define (tetris-render t)
  (cond
    [(empty? (tetris-landscape t))
     (place-image BLOCK
                  (block-x (tetris-block t))
                  (block-y (tetris-block t))
                  MTS)]
    [else
     (place-image
      BLOCK
      (block-x (first (tetris-landscape t)))
      (block-y (first (tetris-landscape t)))
      (tetris-render
       (make-tetris
        (tetris-block t)
        (rest (tetris-landscape t)))))]))

; EX.221
; create interactive program which has blocks dropping
; in a straight line from the top and landing on the
; floor

; call with (make-tetris BLOCK LANDSCAPE)
(define NEW-BLOCK (make-block (* 5 SIZE) (- SIZE)))
(define (main t)
  (big-bang t
            (on-tick tetris-tock 0.5)
            (to-draw tetris-render)
            (stop-when game-over)
            (on-key move-piece)))

; Tetris -> Tetris
; consumes a tetris and produces a new tetris based
; on the advancement of a block to the bottom of the
; scene. Once at bottom, the block becomes part of the
; current landscape
(check-expect (tetris-tock (make-tetris NEW-BLOCK '()))
              (make-tetris (make-block (* 5 SIZE) 0) '())) 
(check-expect (tetris-tock t1)
              (make-tetris
               (make-block (* 5 SIZE)
                           (+ SPEED (* 5 SIZE)))
               '()))

;(define (tetris-tock t) t)
(define (tetris-tock t)
(cond
  [(>= (block-y (tetris-block t)) (* HEIGHT SIZE))
   (make-tetris NEW-BLOCK
                (cons (tetris-block t) (tetris-landscape t)))]
  [(member? (make-block (block-x (tetris-block t))
                        (+ SIZE (block-y (tetris-block t))))
            (tetris-landscape t))
   (make-tetris
    NEW-BLOCK
   (cons (tetris-block t) (tetris-landscape t)))]
  [else
   (make-tetris (make-block (block-x (tetris-block t))
                            (+ SPEED (block-y (tetris-block t))))
                (tetris-landscape t))]))

; Tetris -> boolean
; produces true if the landscape height exceeds the MTS
(define GO1 (make-tetris
             (make-block 50 -10)
             (list
              (make-block 50 0)
              (make-block 50 10)
              (make-block 50 20)
              (make-block 50 30)
              (make-block 50 40)
              (make-block 50 50)
              (make-block 50 60)
              (make-block 50 70)
              (make-block 50 80)
              (make-block 50 90)
              (make-block 10 90))))
; check if a block's y coordinate is less than 10
(check-expect (game-over t4) false)
(check-expect (game-over GO1) true)

(define (game-over t)
  (cond
    [(empty? (tetris-landscape t)) false]
    [else
     (if (ten-or-less? (first (tetris-landscape t)))
         true
         (game-over (make-tetris (tetris-block t)
                                 (rest (tetris-landscape t)))))]))

; Block -> boolean
; checks y coordinate, if less than block's size, produce true
(define (ten-or-less? b)
  (> SIZE (block-y b)))

; tetris -> tetris
; consumes a tetris, produce a new tetris on key press
; up rotates 90deg clockwise
; right and left move laterally
; down increases drop speed
(check-expect (move-piece t1 "space") t1)
(check-expect (move-piece t1 "right")
              (make-tetris
               (make-block (+ SIZE (block-x (tetris-block t1)))
                           (block-y (tetris-block t1)))
               '()))
(check-expect (move-piece t1 "left")
              (make-tetris
               (make-block (- (block-x (tetris-block t1)) SIZE)
                           (block-y (tetris-block t1)))
               '()))
; add "down" & "up"
                              
;(define (move-piece t ke) t)
(define (move-piece t ke)
  (cond
    [(string=? ke "left") (make-move t "left")]
    [(string=? ke "right") (make-move t "right")]
    [else t]))

; tetris, string -> tetris
; consumes a tetris and string, produces a new tetris with a new
; x coordinate for the block based on the string's direction
;(left or right)
(define (make-move t s)
  (if (string=? s "left")
      (make-tetris (make-block (- (block-x (tetris-block t)) SIZE)
                               (block-y (tetris-block t)))
                   (tetris-landscape t))
      (make-tetris (make-block (+ (block-x (tetris-block t)) SIZE)
                               (block-y (tetris-block t)))
                   (tetris-landscape t))))
; need to limit block's ability to move off screen
; block can only be place at 0 - WIDTH