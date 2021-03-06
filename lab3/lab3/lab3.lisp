;;;; CZ3005 2015 Semester 2: Lab 3

; Make sure your working directory is labs

(unuse-package "EXT") ; In POXIS systems, there is a symbol conflict
; from now on, to quit, use (ext:quit) instead of (quit)
(load "aima/aima.lisp")
; (load "labs/aima/aima.lisp")
(aima-load '(agents search))
(aima-compile '(agents search)) ; in case of warnings, just "continue"
(test 'agents)
(test 'search)

; The following lab uses lots of code from AIMA
; Go through the source code of the following files from the search module
; of AIMA to get the general ideas used in the framework

; /aima/agents/environments/basic-env.lisp
; /aima/agents/environments/grid-env.lisp
; /aima/agents/environments/vacuum.lisp



;;;; ENVIRONMENT

; run-environment:: Basic environment simulator. It gives each agent its
; percept, gets an action from each agent, and updates the environment. It also
; keeps score for each agent, and optionally displays intermediate results.

; Run the random (default) vacuum agent in the vacuum environment
; Defualt vacuum agent is random-vacuum-agent: "A very stupid agent: ignore percept and choose a random action."
; Defualt dirt probability at each square = .25
; Percept is a three-element sequence: bump, dirt and home

(run-environment (make-vacuum-world
    :max-steps 10))
; Do not print the intermediate states
(run-environment (make-vacuum-world
    :stream nil))

; Use :CSPEC (custom specification) to set the dirt probability
; at each square
(run-environment (make-vacuum-world
    :cspec '((at all (P 0.9 dirt)))
    :max-steps 10))




;;;; VACUUM AGENTS

;;; An agent is something that perceives and acts.  As such, each agent has a
;;; slot to hold its current percept, and its current action.  The action
;;; will be handed back to the environment simulator to perform (if legal).
;;; Each agent also has a slot for the agent program, and one for its score
;;; as determined by the performance measure.

; (defstructure agent
;   "Agents take actions (based on percepts and the agent program) and receive
;   a score (based on the performance measure).  An agent has a body which can
;   take action, and a program to choose the actions, based on percepts."
;   (program #'nothing)           ; fn: percept -> action
;   (body (make-agent-body))
;   (score 0)
;   (percept nil)
;   (action nil)
;   (name nil))

;;;; Some simple agents for the vacuum world

; (defstructure (random-vacuum-agent
;    (:include agent
;     (program
;      #'(lambda (percept)
;      (declare (ignore percept))
;      (random-element
;       '(suck forward (turn right) (turn left) shut-off))))))
;   "A very stupid agent: ignore percept and choose a random action.")


; (defstructure (reactive-vacuum-agent
;    (:include agent
;     (program
;      #'(lambda (percept)
;    (destructuring-bind (bump dirt home) percept
;      (cond (dirt 'suck)
;      (home (random-element '(shut-off forward (turn right))))
;      (bump (random-element '((turn right) (turn left))))
;      (t (random-element '(forward forward forward
;                 (turn right) (turn left))))))))))
;   "When you bump, turn randomly; otherwise mostly go forward, but
;   occasionally turn.  Always suck when there is dirt.")


; Use :ASPEC (agent specification) to set the agent type
(run-environment (make-vacuum-world
    :aspec '(reactive-vacuum-agent)))

; Compare two agents
(agent-trials 'make-vacuum-world
    '(reactive-vacuum-agent random-vacuum-agent)
    :n 10)


; Interactive agent

; We now define our own interactive agent. Try it by typing in one of the
; legal moves: '(suck forward (turn left) (turn right) shut-off))

(defun ask-user-vacuum (percept)
  "Ask the user what action to take."
  (format t "~&Percept is ~A; action? " percept)
  (parse-line (read-line)))

(defun parse-line (string)
  (if (or (null string) (equal "" string)) nil
    (let ((read (multiple-value-list (read-from-string string))))
      (if (car read) (cons (car read) (parse-line (subseq string (cadr read)))) nil ))))

(defstructure (ask-user-vacuum-agent (:include agent (program 'ask-user-vacuum)))
  "An agent that asks the user to type in an action.")

(run-environment (make-vacuum-world
    :aspec '(ask-user-vacuum-agent)
    :max-steps 10))


;;;; VACUUM AGENTS WITH GPS

; What if our vacuum machine has a GPS device?
; Let's define a new world, where all vacuum machines know their position and
; heading.
(defstructure (vacuum-world-gps (:include vacuum-world)))

; We now define the the get-percept method of vacuum-world-gps structure
; Method get-percept is called in run-environment
; Note that percept how consists of 5 variables:
;   bump, dirt, home, location, heading
(defmethod get-percept ((env vacuum-world-gps) agent)
  (let ((loc (object-loc (agent-body agent)))
        (heading (object-heading (agent-body agent))))
    (append (call-next-method) (list loc heading))))

(run-environment (make-vacuum-world-gps
    :aspec '(ask-user-vacuum-agent)
    :max-steps 10))


; In a world with GPS, what is a random vacuum agent going to do?
(run-environment (make-vacuum-world-gps
    :aspec '(random-vacuum-agent)
    :max-steps 10))

; And how about a reactive agent?

; We have to define the reactive agent so that it is compatible with
; our new environment with gps
; When you bump, turn randomly; otherwise mostly go forward, but
; occasionally turn.  Always suck when there is dirt.
(defstructure (reactive-vacuum-agent-with-gps
   (:include agent
    (program #'reactive-vacuum-agent-with-gps-program))))

(defun reactive-vacuum-agent-with-gps-program (percept)
     (destructuring-bind (bump dirt home loc heading) (subseq percept 0 5)
       (cond (dirt 'suck)
         (home (random-element '(shut-off forward (turn right))))
         (bump (random-element '((turn right) (turn left))))
         (t (random-element '(forward forward forward
                          (turn right) (turn left)))))))

(run-environment (make-vacuum-world-gps
    :aspec '(reactive-vacuum-agent-with-gps)
    :max-steps 10))


; Let's define our own agent. He's going to use his GPS to navigate
; around the grid
; If I'm at home and not heading up, turn right. If I just bumped into
; something, turn right. Otherwise I go forward.
(defstructure (dumb-traversal-vacuum-agent-with-gps
  (:include agent
    (program #'dumb-traversal-vacuum-agent-with-gps-program))))

(defun dumb-traversal-vacuum-agent-with-gps-program (percept)
     (destructuring-bind (bump dirt home loc heading) (subseq percept 0 5)
       (cond (dirt 'suck)
         ((and (not (equal heading (@ 0 1))) home) '(turn right))
         (bump '(turn right))
         (t 'forward))))

(run-environment (make-vacuum-world-gps
    :aspec '(dumb-traversal-vacuum-agent-with-gps)
    :max-steps 64))

; It is obvious that this agent is not the best one. It only walks around
; the perimeter of the grid and doesn't suck any dirt inside the grid.
; It also doesn't stop at home and continues walking until the end of the
; vacuum world.


;;;; VACUUM WORLD WITH RADAR

; What if our agents could see the whole grid?
; Let's give our agents one last upgrade - a powerful radar!

; Define a world, where all agents have a radar
(defstructure (vacuum-world-radar (:include vacuum-world-gps)))

; Define get-percept method of vacuum-world-radar
; The percept how gets a 2D array of all dirts and a home location
(defmethod get-percept ((env vacuum-world-radar) agent)
  (let ((grid (copy-array (vacuum-world-grid env)))
        (home (grid-environment-start env)))
    (append (call-next-method) (list grid (grid-environment-start env)))))

(defstructure (dumb-traversal-vacuum-agent-with-radar
  (:include agent
    (program #'dumb-traversal-vacuum-agent-with-radar-program))))

(defun dumb-traversal-vacuum-agent-with-radar-program (percept)
    (destructuring-bind (bump dirt home loc heading radar home-loc) percept
        (let ((go-to-dirt (find-some-in-grid radar 'DIRT))
              (go-to-home home-loc))
            (let ((turn (turn-towards-dirt loc heading
                    (if go-to-dirt go-to-dirt go-to-home))))
                (cond
                    (turn turn)
                    (dirt 'suck)
                    ((and (not go-to-dirt) home) 'shut-off)
                    (t 'forward)
                    )))))

(defun find-some-in-grid (radar type)
    (dotimes (x (car (array-dimensions radar)))
        (dotimes (y (cadr (array-dimensions radar)))
            (let ((elems (aref radar x y)))
                (dolist (e elems)
                    (when (eq (type-of e) type)
                        (return-from find-some-in-grid (list x y)))) nil))))

(defun turn-towards-dirt (loc heading go-to-dirt)
    (let ((vdiff (- (first go-to-dirt) (first loc)))
          (hdiff (if (= (- (first go-to-dirt) (first loc)) 0)
                     (- (second go-to-dirt) (second loc))
                     0))
          (vheading (first heading))
          (hheading (second heading)))
        (let ((vdiffn (if (= vdiff 0) 0 (/ vdiff (abs vdiff))))
              (hdiffn (if (= hdiff 0) 0 (/ hdiff (abs hdiff)))))
            (let ((cprodz
                (-  (* vdiffn hheading)
                    (* hdiffn vheading))))
                ; (format t "~%loc: ~A, heading: ~A, go-to-dirt: ~A, cprodz: ~A, diffn: ~A ~A ~%" loc heading go-to-dirt cprodz vdiffn hdiffn)
                (cond
                    ((or (= (abs (- vdiffn vheading)) 2)
                        (= (abs (- hdiffn hheading)) 2)) '(turn right))
                    ((> cprodz 0) '(turn right))
                    ((< cprodz 0) '(turn left))
                    (t nil))))))

(run-environment (make-vacuum-world-radar
    :aspec '(dumb-traversal-vacuum-agent-with-radar)
    :max-steps 64))

; How does our dumb-traversal-vacuum-agent-with-radar compare to the previous
; agent dumb-traversal-vacuum-agent-with-gps?

(agent-trials 'make-vacuum-world-radar
         '(dumb-traversal-vacuum-agent-with-gps dumb-traversal-vacuum-agent-with-radar) :n 4)





;;;; ADVERSARIAL SEARCH

; So far we have only been interested in a single agent in the grid at
; a time. Let's have two agents now. When one of them sucks dirt, the
; other one has to go get dirt elsewhere.

; We also use a simplified model this time. The score is evaluated according
; to the following two rules:
;       * -1 point for every turn (including successful suck)
;       * +10 points for successful suck

; The state model is simplified. There are no walls now.

; The percept is simplified as well. Dirt is described by a list of locations.
; Both agents can see each other and know each other's score.

; The scoring function is simplified:
;   +10 points for sucking dirt
;   =1 points for any other action if agent is still on (not shut-off yet)
; There is no home nor any penalty for not returning home. But the points
; gain for dirt is reduced, creating a decision factor between shutting off
; or running for dirt that may be too far away or sucked by the opponent.

; VERY IMPORTANT !!!
; Read thoroughly through:
;     * aima/search/environments/vacuum-game.lisp
; then come back here!


; Here we run two random agents against each other
(run-game (make-vacuum-game) :agents '(random-game-agent random-game-agent))

; How about human controlled agents?
; Try to run the following code and control your agent by typing one of
; the legal moves. Can you beat a random agent?
; To stop the simulation, just use shut-off move.
(run-game (make-vacuum-game) :agents '(human-game-agent random-game-agent))



; Let's now build our own agent based on minimax

; VERY IMPORTANT !!!
; Read thoroughly through:
;    * aima/search/algorithms/minimax.lisp
;    * aima/search/agents/vacuum-agent.lisp
; then come back here!


(run-environment (make-game-environment
    :max-steps 8
    :game (make-vacuum-game :dirt-probability 0.5)
    :agents '(minimax-cutoff-vacuum-agent random-game-agent)))
