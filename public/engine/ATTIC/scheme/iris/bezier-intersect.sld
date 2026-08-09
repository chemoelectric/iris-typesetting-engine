;;; ============================================================================
;;; Scheme Library: (iris bezier-intersect)
;;; Standard: R7RS (ISO/IEC 30179) / Gauche Scheme (R7RS Mode)
;;; Domain: Bézier Clipping & S-Power Spline Curve Intersection Engine
;;; Isomorphism: Structurally Isomorphic to Fortran 2008 iris_bezier_intersect module
;;; Exemptions: R7RS Scheme functional code is exempt from single-exit rules.
;;; ============================================================================

(define-library (iris bezier-intersect)
  (export
    make-point-2d
    point-2d?
    point-2d-x
    point-2d-y
    make-bezier-cubic
    bezier-cubic?
    bezier-cubic-p0
    bezier-cubic-p1
    bezier-cubic-p2
    bezier-cubic-p3
    make-spower-cubic
    spower-cubic?
    spower-cubic-c0
    spower-cubic-c1
    spower-cubic-c2
    spower-cubic-c3
    bezier-eval
    bezier-split
    bezier-bbox-overlap?
    bezier->spower
    bezier-intersect)

  (import (scheme base)
          (scheme write)
          (scheme inexact))

  (begin
    ;; -------------------------------------------------------------------------
    ;; Record Definitions
    ;; -------------------------------------------------------------------------
    (define-record-type <point-2d>
      (make-point-2d x y)
      point-2d?
      (x point-2d-x point-2d-x-set!)
      (y point-2d-y point-2d-y-set!))

    (define-record-type <bezier-cubic>
      (make-bezier-cubic p0 p1 p2 p3)
      bezier-cubic?
      (p0 bezier-cubic-p0 bezier-cubic-p0-set!)
      (p1 bezier-cubic-p1 bezier-cubic-p1-set!)
      (p2 bezier-cubic-p2 bezier-cubic-p2-set!)
      (p3 bezier-cubic-p3 bezier-cubic-p3-set!))

    (define-record-type <spower-cubic>
      (make-spower-cubic c0 c1 c2 c3)
      spower-cubic?
      (c0 spower-cubic-c0)
      (c1 spower-cubic-c1)
      (c2 spower-cubic-c2)
      (c3 spower-cubic-c3))

    (define-record-type <intersection-pair>
      (make-intersection-pair t1 t2 pt)
      intersection-pair?
      (t1 intersection-t1)
      (t2 intersection-t2)
      (pt intersection-pt))

    ;; -------------------------------------------------------------------------
    ;; Curve Evaluation & Geometry Operations
    ;; -------------------------------------------------------------------------
    (define (bezier-eval curve t)
      (let* ((u (- 1.0 t))
             (u2 (* u u))
             (u3 (* u2 u))
             (t2 (* t t))
             (t3 (* t2 t))
             (b0 u3)
             (b1 (* 3.0 u2 t))
             (b2 (* 3.0 u t2))
             (b3 t3)
             (p0 (bezier-cubic-p0 curve))
             (p1 (bezier-cubic-p1 curve))
             (p2 (bezier-cubic-p2 curve))
             (p3 (bezier-cubic-p3 curve))
             (x (+ (* b0 (point-2d-x p0))
                   (* b1 (point-2d-x p1))
                   (* b2 (point-2d-x p2))
                   (* b3 (point-2d-x p3))))
             (y (+ (* b0 (point-2d-y p0))
                   (* b1 (point-2d-y p1))
                   (* b2 (point-2d-y p2))
                   (* b3 (point-2d-y p3)))))
        (make-point-2d x y)))

    (define (bezier-split curve)
      (let* ((p0 (bezier-cubic-p0 curve))
             (p1 (bezier-cubic-p1 curve))
             (p2 (bezier-cubic-p2 curve))
             (p3 (bezier-cubic-p3 curve))
             (m01 (make-point-2d (* 0.5 (+ (point-2d-x p0) (point-2d-x p1)))
                                 (* 0.5 (+ (point-2d-y p0) (point-2d-y p1)))))
             (m12 (make-point-2d (* 0.5 (+ (point-2d-x p1) (point-2d-x p2)))
                                 (* 0.5 (+ (point-2d-y p1) (point-2d-y p2)))))
             (m23 (make-point-2d (* 0.5 (+ (point-2d-x p2) (point-2d-x p3)))
                                 (* 0.5 (+ (point-2d-y p2) (point-2d-y p3)))))
             (m012 (make-point-2d (* 0.5 (+ (point-2d-x m01) (point-2d-x m12)))
                                  (* 0.5 (+ (point-2d-y m01) (point-2d-y m12)))))
             (m123 (make-point-2d (* 0.5 (+ (point-2d-x m12) (point-2d-x m23)))
                                  (* 0.5 (+ (point-2d-y m12) (point-2d-y m23)))))
             (mid  (make-point-2d (* 0.5 (+ (point-2d-x m012) (point-2d-x m123)))
                                  (* 0.5 (+ (point-2d-y m012) (point-2d-y m123))))))
        (cons (make-bezier-cubic p0 m01 m012 mid)
              (make-bezier-cubic mid m123 m23 p3))))

    (define (bezier-bbox-overlap? c1 c2)
      (let ((min1-x (min (point-2d-x (bezier-cubic-p0 c1)) (point-2d-x (bezier-cubic-p1 c1))
                         (point-2d-x (bezier-cubic-p2 c1)) (point-2d-x (bezier-cubic-p3 c1))))
            (max1-x (max (point-2d-x (bezier-cubic-p0 c1)) (point-2d-x (bezier-cubic-p1 c1))
                         (point-2d-x (bezier-cubic-p2 c1)) (point-2d-x (bezier-cubic-p3 c1))))
            (min1-y (min (point-2d-y (bezier-cubic-p0 c1)) (point-2d-y (bezier-cubic-p1 c1))
                         (point-2d-y (bezier-cubic-p2 c1)) (point-2d-y (bezier-cubic-p3 c1))))
            (max1-y (max (point-2d-y (bezier-cubic-p0 c1)) (point-2d-y (bezier-cubic-p1 c1))
                         (point-2d-y (bezier-cubic-p2 c1)) (point-2d-y (bezier-cubic-p3 c1))))
            (min2-x (min (point-2d-x (bezier-cubic-p0 c2)) (point-2d-x (bezier-cubic-p1 c2))
                         (point-2d-x (bezier-cubic-p2 c2)) (point-2d-x (bezier-cubic-p3 c2))))
            (max2-x (max (point-2d-x (bezier-cubic-p0 c2)) (point-2d-x (bezier-cubic-p1 c2))
                         (point-2d-x (bezier-cubic-p2 c2)) (point-2d-x (bezier-cubic-p3 c2))))
            (min2-y (min (point-2d-y (bezier-cubic-p0 c2)) (point-2d-y (bezier-cubic-p1 c2))
                         (point-2d-y (bezier-cubic-p2 c2)) (point-2d-y (bezier-cubic-p3 c2))))
            (max2-y (max (point-2d-y (bezier-cubic-p0 c2)) (point-2d-y (bezier-cubic-p1 c2))
                         (point-2d-y (bezier-cubic-p2 c2)) (point-2d-y (bezier-cubic-p3 c2)))))
        (not (or (< max1-x min2-x) (> min1-x max2-x)
                 (< max1-y min2-y) (> min1-y max2-y)))))

    (define (bezier->spower curve)
      (let* ((p0 (bezier-cubic-p0 curve))
             (p1 (bezier-cubic-p1 curve))
             (p2 (bezier-cubic-p2 curve))
             (p3 (bezier-cubic-p3 curve))
             (c0 (make-point-2d (point-2d-x p0) (point-2d-y p0)))
             (c1 (make-point-2d (* 3.0 (- (point-2d-x p1) (point-2d-x p0)))
                                (* 3.0 (- (point-2d-y p1) (point-2d-y p0)))))
             (c2 (make-point-2d (* 3.0 (+ (point-2d-x p2) (- (* 2.0 (point-2d-x p1))) (point-2d-x p0)))
                                (* 3.0 (+ (point-2d-y p2) (- (* 2.0 (point-2d-y p1))) (point-2d-y p0)))))
             (c3 (make-point-2d (+ (point-2d-x p3) (- (* 3.0 (point-2d-x p2))) (* 3.0 (point-2d-x p1)) (- (point-2d-x p0)))
                                (+ (point-2d-y p3) (- (* 3.0 (point-2d-y p2))) (* 3.0 (point-2d-y p1)) (- (point-2d-y p0))))))
        (make-spower-cubic c0 c1 c2 c3)))

    ;; -------------------------------------------------------------------------
    ;; Bézier Intersection Solver
    ;; -------------------------------------------------------------------------
    (define (bezier-intersect c1 c2 . opts)
      (let ((tol (if (null? opts) 1.0e-7 (car opts))))
        (let recur ((c1 c1) (c2 c2)
                    (t1-min 0.0) (t1-max 1.0)
                    (t2-min 0.0) (t2-max 1.0))
          (if (bezier-bbox-overlap? c1 c2)
              (if (and (< (- t1-max t1-min) tol)
                       (< (- t2-max t2-min) tol))
                  (list (make-intersection-pair (* 0.5 (+ t1-min t1-max))
                                               (* 0.5 (+ t2-min t2-max))
                                               (bezier-eval c1 0.5)))
                  (let* ((t1-mid (* 0.5 (+ t1-min t1-max)))
                         (t2-mid (* 0.5 (+ t2-min t2-max)))
                         (splits1 (bezier-split c1))
                         (splits2 (bezier-split c2))
                         (c1-l (car splits1)) (c1-r (cdr splits1))
                         (c2-l (car splits2)) (c2-r (cdr splits2)))
                    (append (recur c1-l c2-l t1-min t1-mid t2-min t2-mid)
                            (recur c1-l c2-r t1-min t1-mid t2-mid t2-max)
                            (recur c1-r c2-l t1-mid t1-max t2-min t2-mid)
                            (recur c1-r c2-r t1-mid t1-max t2-mid t2-max))))
              '()))))))
