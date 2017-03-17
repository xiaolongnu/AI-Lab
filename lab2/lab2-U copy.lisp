;;;; CZ3005 2015 Semester 2: Lab 2 (Total Marks: 100)
;;;;
;;;; Due two weeks from the lab.
;;;;
;;;; Submission procedure will be announced during the lecture or the
;;;; lab session.
;;;;
;;;; This file is a loadable Lisp file.  You are to modify this file and
;;;; add your answers.  Then CHECK TO MAKE SURE that the file still loads
;;;; properly into the Lisp system.
;;;;
;;;; Name your lab 2 lisp code as  "LAB2-<YOUR_MATRICULATION_NUMBER>.lisp"
;;;;
;;;; Any line breaks due to word wrapping will be treated as errors.
;;;; Moral of the story: DO NOT USE WINDOWS NOTEPAD OR PICO.
;;;;
;;;; Before you submit your code, be sure to test it in GNU CLISP 2.49.
;;;; Lispworks 6.1 software installed on NTU machines is based on Clisp 2.49,
;;;; so if your code works there, it qualifies.
;;;;
;;;; If we cannot run your code, including our automatic checker, your answer
;;;; will not be considered at all. If our checker detects wrong output, you may
;;;; still get partial marks for such problem.
;;;;
;;;; You are NOT allowed to use external libraries in this assignment other than
;;;; the AIMA framework! If you choose to not use AIMA, you may find inspiration
;;;; in the robustness of the AIMA framework and model your problems using
;;;; the know-how and principles used in AIMA. You won't be penalized in any way
;;;; if you choose to write the answers from scratch.
;;;;
;;;; For those using AIMA, the framework will be loaded prior to checking your
;;;; solution! DO NOT load it again,
;;;; and DO NOT include any AIMA functions or code in your submission. This
;;;; would result in plagiarism detection and severe consequences.
;;;;
;;;; There are TWO questions in this homework assignment. Function definitions
;;;; of functions that will be checked are provided.
;;;;
;;;; COMMENT EXCESSIVELY -- 20% of marks for every task is awarded solely based
;;;; on sufficiently commented code! Comment both inline in your code and
;;;; comment each function and structure you write. Make sure we understand
;;;; the nitty-gritty of you answers.



;;;; INTRO

; The knight's tour problem is a problem of finding a sequence of moves of
; a knight on a chessboard such that the knight must not step on the same
; square more than once and the knight visits all the squares of the
; chessboard.

; See https://en.wikipedia.org/wiki/Knight%27s_tour for details



;;;; QUESTION 1

; On a MxN chessboard, given the initial coordinates, find one open
; knight's tour. Start with 5x5 chessboard. Note that here are no closed
; knight's tours on 5x5 chessboard.

; Use brute force algorithm, i.e. in every step, visit all the available
; squares (that have not been visited in any previous step).

; The input to your function is a list with four integers, indicating the
; starting position of the tour and the size of the chessboard.
; Coordinates range from 1 to M, resp 1 to N.

; The output is a list of length MxN consisting of cons of length 2,
; indicating the position on a chessboard visited by the knight. The first
; position is identical to (x y) from the input.

; Example:
;     (knights-tour-brute (1 1 5 5)) -> ((1 . 1) (3 . 2) (5 . 1) (4 . 3) ... )

; You are allowed to add any number of functions into this file, as the whole
; file will be loaded, but only the knights-tour-brute function will be checked
; for correctness. If the correctness check passes, the whole code will be
; checked for correct use of brute force method.

; All code in this assignment has to be your own. No external library is
; allowed.

; Test it on 5x5 chessboard, optionally on 6x6, 7x7 and 8x8 chessboard.

(unuse-package "EXT") ; In POXIS systems, there is a symbol conflict
(load "aima/aima.lisp")
; (load "labs/aima/aima.lisp")
(aima-load 'search)
(aima-compile 'search) ; in case of warnings, just "continue"
(test 'search)

(enqueue-at-front (make-q) '((list a b c))' (list 9 7 2))

(enqueue-by-priority que (list a b c) (list 9 7 2))


(enqueue-by-priority que '(a b c) (ra))

(enqueue-by-priority que '(((+ x 2) (+ y 1))) 'calc-priority)


(defun dra (c) (return-from dra 0) )


(defun ra (c) (random 10) )

(defun print-solution () 
(Progn
(print board)
(setf solution-array (make-array (* h w)))
(loop for i from 0 to (- h 1) do
(loop for j from 0 to (- w 1) do
(setf (aref solution-array (- (aref board i j) 1)) (cons i j))))
(print solution-array)
))


(defun legal-move (x y)
(and (<= 0 x) (< x h) (<= 0 y) (< y w) (null (aref board x y))))


(defun brute-solve (x y)
(if (legal-move x y)
(progn 
(incf moves)
(setf (aref board x y) moves)
(if (= totalmoves moves) (return-from brute-solve (print-solution)))
(brute-solve (+ x 2) (+ y 1))
(if (= totalmoves moves) (return-from brute-solve))
(brute-solve (+ x 2) (- y 1))
(if (= totalmoves moves) (return-from brute-solve))
(brute-solve (- x 1) (+ y 2))
(if (= totalmoves moves) (return-from brute-solve))
(brute-solve (+ x 1) (+ y 2))
(if (= totalmoves moves) (return-from brute-solve))
(brute-solve (+ x 1) (- y 2))
(if (= totalmoves moves) (return-from brute-solve))
(brute-solve (- x 1) (- y 2))
(if (= totalmoves moves) (return-from brute-solve))
(brute-solve (- x 2) (+ y 1))
(if (= totalmoves moves) (return-from brute-solve))
(brute-solve (- x 2) (- y 1))
(if (= totalmoves moves) (return-from brute-solve))
(decf moves)
(setf (aref board x y) nil)
(if (= moves 0) (return-from brute-solve (print "Fail")))
)))

(defun knights-tour-brute (x y m n)
(setq h n)
(setq w m)
(setf board (make-array (list m n)))
(setq totalmoves (* h w))
(setq moves 0)
(brute-solve x y)
)



;;;; QUESTION 2

; Since brute force approach is not very effective, we have to use something
; more sophisticated. A greedy best-first search with Warnsdorff's heuristic
; seems like significantly better approach.

; Warnsdorff's heuristic evaluates moves based on the number of available
; squares for the next move. Applying this heuristic to our greedy best-first
; search, we will always choose the move with the lowest number of subsequent
; moves from that square. Resolution of ties is not specified, you may choose
; randomly.

; You are again allowed to add any number of functions, but only the
; knights-tour-greedy function will be checked for correctness. If the
; correctness check passes, the whole code will be checked for correct
; use of greedy best-first search method.

; All code in this assignment has to be your own. No external library is
; allowed.

; Input and output formats remain the same.

; Test it on 8x8 chessboard, optionally on larger chessboards.

(brute-solve (+ x 2) (+ y 1))
(if (= totalmoves moves) (return-from brute-solve))
(brute-solve (+ x 2) (- y 1))
(if (= totalmoves moves) (return-from brute-solve))
(brute-solve (- x 1) (+ y 2))
(if (= totalmoves moves) (return-from brute-solve))
(brute-solve (+ x 1) (+ y 2))
(if (= totalmoves moves) (return-from brute-solve))
(brute-solve (+ x 1) (- y 2))
(if (= totalmoves moves) (return-from brute-solve))
(brute-solve (- x 1) (- y 2))
(if (= totalmoves moves) (return-from brute-solve))
(brute-solve (- x 2) (+ y 1))
(if (= totalmoves moves) (return-from brute-solve))
(brute-solve (- x 2) (- y 1))

(defun calc-priority (lis)
	(let ( (x (car lis)) (y (cdr lis)) (ctr 0) )
		(progn
			(mapcar #'legal-move 
				'( ((+ x 2) (+ y 1)) ((+ x 2) (- y 1)) ((- x 1) (+ y 2)) ((+ x 1) (+ y 2)) ((+ x 1) (- y 2)) ((- x 1) (- y 2)) ((- x 2) (+ y 1)) ((- x 2) (- y 1))  ))
			)
		)
	)


(defun calc-priority (lis)
(let ( (x (car lis)) (y (cdr lis)) (ctr 0) )
(progn
(if (legal-move (+ x 2) (+ y 1)) (incf ctr))
(if (legal-move (+ x 2) (- y 1)) (incf ctr))
(if (legal-move (- x 1) (+ y 2)) (incf ctr))
(if (legal-move (+ x 1) (+ y 2)) (incf ctr))
(if (legal-move (+ x 1) (- y 2)) (incf ctr))
(if (legal-move (- x 1) (- y 2)) (incf ctr))
(if (legal-move (- x 2) (+ y 1)) (incf ctr))
(if (legal-move (- x 2) (- y 1)) (incf ctr))
(return-from calc-priority ctr)
)
)
)

(defun knights-tour-brute (x y m n)
(setq h n)
(setq w m)
(setf board (make-array (list m n)))
(setq totalmoves (* h w))
(setq moves 0)
)

(mapcar #'legal-move (list (+ x 2) (+ x 2) (- x 1) (+ x 1) (+ x 1) (- x 1) (- x 2) (- x 2))  (list (+ y 1) (- y 1) (+ y 2) (+ y 2) (- y 2) (- y 2) (+ y 1) (- y 1)))

(mapcar #'legal-move (list (+ x 2)) (list (+ y 1)))

(mapcar #'legal-move 
				'( '((+ x 2) (+ y 1)) ((+ x 2) (- y 1)) ((- x 1) (+ y 2)) ((+ x 1) (+ y 2)) 

					((+ x 1) (- y 2)) ((- x 1) (- y 2)) ((- x 2) (+ y 1)) ((- x 2) (- y 1))  ))




(enqueue-by-priority q2 (list (cons 0 0)) 'calc-priority)


(defun tour (x y)
	(let (que (make-q))
		(progn 
			(incf moves)
			(setf (aref board x y) moves)
			(if (= totalmoves moves) (print-solution))

			(if (legal-move (+ x 2) (+ y 1) ) (enqueue-by-priority que (list (cons (+ x 2) (+ y 1) )) 'calc-priority))
			(if (legal-move (+ x 2) (- y 1) ) (enqueue-by-priority que (list (cons (+ x 2) (- y 1) )) 'calc-priority))
			(if (legal-move (- x 1) (+ y 2) ) (enqueue-by-priority que (list (cons (- x 1) (+ y 2) )) 'calc-priority))
			(if (legal-move (+ x 1) (+ y 2) ) (enqueue-by-priority que (list (cons (+ x 1) (+ y 2) )) 'calc-priority))

			

		)
	)
)

(defun tour (x y)
(let ((que (make-q)) )
(progn 
(incf moves)
(setf (aref board x y) moves)
(if (= totalmoves moves) (print-solution))

(if (legal-move (+ x 2) (+ y 1) ) (enqueue-by-priority que (list (cons (+ x 2) (+ y 1) )) 'calc-priority))
(if (legal-move (+ x 2) (- y 1) ) (enqueue-by-priority que (list (cons (+ x 2) (- y 1) )) 'calc-priority))
(if (legal-move (- x 1) (+ y 2) ) (enqueue-by-priority que (list (cons (- x 1) (+ y 2) )) 'calc-priority))
(if (legal-move (+ x 1) (+ y 2) ) (enqueue-by-priority que (list (cons (+ x 1) (+ y 2) )) 'calc-priority))

(if (legal-move (+ x 1) (- y 2) ) (enqueue-by-priority que (list (cons (+ x 1) (- y 2) )) 'calc-priority))
(if (legal-move (- x 1) (- y 2) ) (enqueue-by-priority que (list (cons (- x 1) (- y 2) )) 'calc-priority))
(if (legal-move (- x 2) (+ y 1) ) (enqueue-by-priority que (list (cons (- x 2) (+ y 1) )) 'calc-priority))
(if (legal-move (- x 2) (- y 1) ) (enqueue-by-priority que (list (cons (- x 2) (- y 1) )) 'calc-priority))

(print que)

)
)
)


(defun tour (x y)
(let ((que (make-q)) )
(progn 
(incf moves)
(setf (aref board x y) moves)
(if (= totalmoves moves) (return-from tour (print-solution)))

(if (legal-move (+ x 2) (+ y 1) ) (enqueue-by-priority que (list (cons (+ x 2) (+ y 1) )) 'calc-priority))
(if (legal-move (+ x 2) (- y 1) ) (enqueue-by-priority que (list (cons (+ x 2) (- y 1) )) 'calc-priority))
(if (legal-move (- x 1) (+ y 2) ) (enqueue-by-priority que (list (cons (- x 1) (+ y 2) )) 'calc-priority))
(if (legal-move (+ x 1) (+ y 2) ) (enqueue-by-priority que (list (cons (+ x 1) (+ y 2) )) 'calc-priority))

(if (legal-move (+ x 1) (- y 2) ) (enqueue-by-priority que (list (cons (+ x 1) (- y 2) )) 'calc-priority))
(if (legal-move (- x 1) (- y 2) ) (enqueue-by-priority que (list (cons (- x 1) (- y 2) )) 'calc-priority))
(if (legal-move (- x 2) (+ y 1) ) (enqueue-by-priority que (list (cons (- x 2) (+ y 1) )) 'calc-priority))
(if (legal-move (- x 2) (- y 1) ) (enqueue-by-priority que (list (cons (- x 2) (- y 1) )) 'calc-priority))
(print que)


(while (not (empty-queue? que) )
do  (let ( (ij (remove-front que)) )  (tour (car ij) (cdr ij) ) ) (if (= totalmoves moves) (return-from tour))  )

(decf moves)
(setf (aref board x y) nil)
(if (= moves 0) (return-from tour (print "Fail")))

)
)
)


(defun legal-move (x y)
(and (<= 0 x) (< x h) (<= 0 y) (< y w) (null (aref board x y))))

(defun knights-tour-greedy (x y m n)
(setq h n)
(setq w m)
(setf board (make-array (list m n)))
(setq totalmoves (* h w))
(setq moves 0)
(tour x y)
)


(defun heap-insert (heap item key)
"Put an item into a heap. [Page 150 CL&R]."
;; Note that ITEM is the value to be inserted, and KEY is a function
;; that extracts the numeric value from the item.
(vector-push-extend nil heap)
(let ((i (- (length heap) 1))
(val (funcall key item)))
(if (<= val 0) (return-from heap-insert))
(while (and (> i 0) (>= (heap-val heap (heap-parent i) key) val))
do (setf (aref heap i) (aref heap (heap-parent i))
i (heap-parent i)))
(setf (aref heap i) item)))



;;;; BONUS: [Additional up 15 points for better tie resolution]

; If you try your own heuristic for tie resolution, please describe thoroughly
; how it works.

; Or you can use an existing one. For example:
; http://slac.stanford.edu/pubs/slacpubs/0250/slac-pub-0261.pdf
