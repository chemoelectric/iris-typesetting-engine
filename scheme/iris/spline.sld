;;; ============================================================================
;;; Scheme Library: (iris spline)
;;; Standard: R7RS (ISO/IEC 30179) / Gauche Scheme (R7RS Mode)
;;; Domain: Piecewise Spline Engine with Explicit Closing Segment,
;;;         Joint Continuity Checking (C0, C1, C2), Self-Intersection
;;;         Detection, and Sense of Rotation Management
;;; Isomorphism: Structurally Isomorphic to Fortran 2008 iris_spline module
;;; Exemptions: R7RS Scheme functional code is exempt from single-exit rules.
;;; ============================================================================

(define-library (iris spline)
  (export
    make-piecewise-spline
    piecewise-spline?
    spline-segments
    spline-closed?
    spline-add-segment!
    spline-close!
    spline-check-continuity
    spline-eval
    spline-self-intersects?
    spline-calc-signed-area
    spline-get-rotation
    spline-set-rotation!)

  (import (scheme base)
          (scheme write)
          (scheme inexact)
          (iris bezier-intersect))

  (begin
    ;; -------------------------------------------------------------------------
    ;; Piecewise Spline Record Type
    ;; -------------------------------------------------------------------------
    (define-record-type <piecewise-spline>
      (make-spline-record segments closed? explicit-closing?)
      piecewise-spline?
      (segments spline-segments spline-segments-set!)
      (closed? spline-closed? spline-closed-set!)
      (explicit-closing? spline-explicit-closing? spline-explicit-closing-set!))

    (define (make-piecewise-spline . opts)
      (let ((segs (if (null? opts) '() (car opts)))
            (closed (if (or (null? opts) (null? (cdr opts))) #f (cadr opts))))
        (make-spline-record segs closed #f)))

    ;; -------------------------------------------------------------------------
    ;; Add Segment
    ;; -------------------------------------------------------------------------
    (define (spline-add-segment! spline curve)
      (spline-segments-set! spline (append (spline-segments spline) (list curve))))

    ;; -------------------------------------------------------------------------
    ;; Maintain Explicit Closing Segment
    ;; -------------------------------------------------------------------------
    (define (spline-close! spline)
      (when (not (spline-closed? spline))
        (spline-closed-set! spline #t)
        (let ((segs (spline-segments spline)))
          (when (not (null? segs))
            (let* ((last-seg (car (reverse segs)))
                   (first-seg (car segs))
                   (p-last (bezier-cubic-p3 last-seg))
                   (p-first (bezier-cubic-p0 first-seg))
                   (dx (- (point-2d-x p-first) (point-2d-x p-last)))
                   (dy (- (point-2d-y p-first) (point-2d-y p-last))))
              (when (or (> (abs dx) 1.0e-7) (> (abs dy) 1.0e-7))
                (let* ((c1 (make-point-2d (+ (point-2d-x p-last) (* (/ 1.0 3.0) dx))
                                         (+ (point-2d-y p-last) (* (/ 1.0 3.0) dy))))
                       (c2 (make-point-2d (+ (point-2d-x p-last) (* (/ 2.0 3.0) dx))
                                         (+ (point-2d-y p-last) (* (/ 2.0 3.0) dy))))
                       (closing-seg (make-bezier-cubic p-last c1 c2 p-first)))
                  (spline-segments-set! spline (append segs (list closing-seg)))
                  (spline-explicit-closing-set! spline #t))))))))

    ;; -------------------------------------------------------------------------
    ;; Joint Continuity Evaluator (C0, C1, C2)
    ;; -------------------------------------------------------------------------
    (define (spline-check-continuity spline . opts)
      (let* ((tol (if (null? opts) 1.0e-5 (car opts)))
             (segs (spline-segments spline))
             (num-segs (length segs)))
        (if (null? segs)
            (list (cons 'status 'empty) (cons 'max-continuity -1))
            (let* ((closed? (spline-closed? spline))
                   (num-joints (if closed? num-segs (- num-segs 1)))
                   (segs-vec (list->vector segs)))

              (let loop ((i 0)
                         (max-c0 0.0)
                         (max-c1 0.0)
                         (max-c2 0.0))
                (if (>= i num-joints)
                    (let* ((c0-ok? (<= max-c0 tol))
                           (c1-ok? (<= max-c1 tol))
                           (c2-ok? (<= max-c2 tol))
                           (max-level (cond ((not c0-ok?) -1)
                                            ((not c1-ok?) 0)
                                            ((not c2-ok?) 1)
                                            (else 2))))
                      `((c0-continuous . ,c0-ok?)
                        (c1-continuous . ,c1-ok?)
                        (c2-continuous . ,c2-ok?)
                        (max-continuity . ,max-level)
                        (max-c0-error . ,max-c0)
                        (max-c1-error . ,max-c1)
                        (max-c2-error . ,max-c2)))
                    (let* ((curr-s (vector-ref segs-vec i))
                           (next-idx (if (= (+ i 1) num-segs) 0 (+ i 1)))
                           (next-s (vector-ref segs-vec next-idx))

                           ;; C0 check: S_i(1) vs S_{i+1}(0)
                           (p3 (bezier-cubic-p3 curr-s))
                           (q0 (bezier-cubic-p0 next-s))
                           (err-c0 (sqrt (+ (expt (- (point-2d-x p3) (point-2d-x q0)) 2)
                                            (expt (- (point-2d-y p3) (point-2d-y q0)) 2))))

                           ;; C1 check: 3*(P3 - P2) vs 3*(Q1 - Q0)
                           (p2 (bezier-cubic-p2 curr-s))
                           (q1 (bezier-cubic-p1 next-s))
                           (d1-curr-x (* 3.0 (- (point-2d-x p3) (point-2d-x p2))))
                           (d1-curr-y (* 3.0 (- (point-2d-y p3) (point-2d-y p2))))
                           (d1-next-x (* 3.0 (- (point-2d-x q1) (point-2d-x q0))))
                           (d1-next-y (* 3.0 (- (point-2d-y q1) (point-2d-y q0))))
                           (err-c1 (sqrt (+ (expt (- d1-curr-x d1-next-x) 2)
                                            (expt (- d1-curr-y d1-next-y) 2))))

                           ;; C2 check: 6*(P3 - 2P2 + P1) vs 6*(Q2 - 2Q1 + Q0)
                           (p1 (bezier-cubic-p1 curr-s))
                           (q2 (bezier-cubic-p2 next-s))
                           (d2-curr-x (* 6.0 (+ (point-2d-x p3) (- (* 2.0 (point-2d-x p2))) (point-2d-x p1))))
                           (d2-curr-y (* 6.0 (+ (point-2d-y p3) (- (* 2.0 (point-2d-y p2))) (point-2d-y p1))))
                           (d2-next-x (* 6.0 (+ (point-2d-x q2) (- (* 2.0 (point-2d-x q1))) (point-2d-x q0))))
                           (d2-next-y (* 6.0 (+ (point-2d-y q2) (- (* 2.0 (point-2d-y q1))) (point-2d-y q0))))
                           (err-c2 (sqrt (+ (expt (- d2-curr-x d2-next-x) 2)
                                            (expt (- d2-curr-y d2-next-y) 2)))))

                      (loop (+ i 1)
                            (max max-c0 err-c0)
                            (max max-c1 err-c1)
                            (max max-c2 err-c2))))))))))

    ;; -------------------------------------------------------------------------
    ;; Evaluate Point on Piecewise Spline
    ;; -------------------------------------------------------------------------
    (define (spline-eval spline u)
      (let* ((segs (spline-segments spline))
             (len (length segs)))
        (if (= len 0)
            (make-point-2d 0.0 0.0)
            (let* ((clamped-u (max 0.0 (min (exact->inexact len) u)))
                   (seg-idx (min (- len 1) (inexact->exact (floor clamped-u))))
                   (local-t (- clamped-u seg-idx))
                   (target-seg (list-ref segs seg-idx)))
              (bezier-eval target-seg local-t)))))

    ;; -------------------------------------------------------------------------
    ;; Self-Intersection Check Functions
    ;; -------------------------------------------------------------------------
    (define (any-proc proc lst)
      (if (null? lst)
          #f
          (or (proc (car lst)) (any-proc proc (cdr lst)))))

    (define (check-segment-self-intersect curve tol)
      (let ((intersections (bezier-intersect curve curve tol)))
        (any-proc (lambda (pair)
                    (>= (abs (- (intersection-t1 pair) (intersection-t2 pair))) 0.05))
                  intersections)))

    (define (check-pair-intersect c1 c2 is-adjacent tol)
      (let ((intersections (bezier-intersect c1 c2 tol)))
        (any-proc (lambda (pair)
                    (let ((t1 (intersection-t1 pair))
                          (t2 (intersection-t2 pair)))
                      (if is-adjacent
                          (not (and (> t1 0.95) (< t2 0.05)))
                          #t)))
                  intersections)))

    (define (spline-self-intersects? spline . opts)
      (let* ((tol (if (null? opts) 1.0e-5 (car opts)))
             (segs (spline-segments spline))
             (n (length segs)))
        (if (zero? n)
            #f
            (or (any-proc (lambda (s) (check-segment-self-intersect s tol)) segs)
                (let ((segs-vec (list->vector segs))
                      (closed? (spline-closed? spline)))
                  (let loop-i ((i 0))
                    (if (>= i n)
                        #f
                        (let loop-j ((j (+ i 1)))
                          (if (>= j n)
                              (loop-i (+ i 1))
                              (let ((is-adj (or (= j (+ i 1))
                                                (and (= i 0) (= j (- n 1)) closed?))))
                                (if (check-pair-intersect (vector-ref segs-vec i)
                                                          (vector-ref segs-vec j)
                                                          is-adj
                                                          tol)
                                    #t
                                    (loop-j (+ j 1)))))))))))))

    ;; -------------------------------------------------------------------------
    ;; Sense of Rotation Functions
    ;; -------------------------------------------------------------------------
    (define (cubic-signed-area curve)
      (let* ((p0 (bezier-cubic-p0 curve))
             (p1 (bezier-cubic-p1 curve))
             (p2 (bezier-cubic-p2 curve))
             (p3 (bezier-cubic-p3 curve))
             (x0 (point-2d-x p0)) (y0 (point-2d-y p0))
             (x1 (point-2d-x p1)) (y1 (point-2d-y p1))
             (x2 (point-2d-x p2)) (y2 (point-2d-y p2))
             (x3 (point-2d-x p3)) (y3 (point-2d-y p3))
             (cp (lambda (xa ya xb yb) (- (* xa yb) (* ya xb)))))
        (* 0.5 (+ (* 0.3 (cp x0 y0 x1 y1))
                  (* 0.15 (cp x0 y0 x2 y2))
                  (* 0.05 (cp x0 y0 x3 y3))
                  (* 0.15 (cp x1 y1 x2 y2))
                  (* 0.15 (cp x1 y1 x3 y3))
                  (* 0.3 (cp x2 y2 x3 y3))))))

    (define (spline-calc-signed-area spline)
      (apply + (map cubic-signed-area (spline-segments spline))))

    (define (spline-get-rotation spline . opts)
      (let ((tol (if (null? opts) 1.0e-5 (car opts))))
        (cond ((or (null? (spline-segments spline)) (not (spline-closed? spline)))
               'not-closed)
              ((spline-self-intersects? spline tol)
               'self-intersecting)
              (else
               (let ((area (spline-calc-signed-area spline)))
                 (if (>= area 0.0)
                     'counter-clockwise
                     'clockwise))))))

    (define (spline-reverse-segment curve)
      (make-bezier-cubic (bezier-cubic-p3 curve)
                         (bezier-cubic-p2 curve)
                         (bezier-cubic-p1 curve)
                         (bezier-cubic-p0 curve)))

    (define (spline-set-rotation! spline target-rotation)
      (when (and (not (null? (spline-segments spline)))
                 (spline-closed? spline))
        (let* ((area (spline-calc-signed-area spline))
               (current-ccw? (>= area 0.0))
               (target-ccw? (or (eq? target-rotation 'counter-clockwise)
                                (eq? target-rotation 'ccw))))
          (when (not (eq? current-ccw? target-ccw?))
            (let* ((rev-segs (map spline-reverse-segment (reverse (spline-segments spline)))))
              (spline-segments-set! spline rev-segs)))))
      spline)))
