;;; ============================================================================
;;; Scheme Library: (iris spline-collection)
;;; Standard: R7RS (ISO/IEC 30179) / Gauche Scheme (R7RS Mode)
;;; Domain: Piecewise Spline Collection Engine, Pairwise Contour Intersections,
;;;         Ray-Casting Containment Hierarchy & OpenType Winding Auto-Orientation
;;; Isomorphism: Structurally Isomorphic to Fortran 2008 iris_spline_collection module
;;; Exemptions: R7RS Scheme functional code is exempt from single-exit rules.
;;; ============================================================================

(define-library (iris spline-collection)
  (export
    make-spline-collection
    spline-collection?
    collection-splines
    collection-nesting-levels
    collection-add-spline!
    spline-get-bbox
    collection-point-in-spline?
    collection-find-intersections-internal
    collection-find-intersections-between
    collection-compute-hierarchy!
    collection-auto-orient-opentype!)

  (import (scheme base)
          (scheme write)
          (scheme inexact)
          (iris bezier-intersect)
          (iris spline))

  (begin
    ;; -------------------------------------------------------------------------
    ;; Collection Record Type
    ;; -------------------------------------------------------------------------
    (define-record-type <spline-collection>
      (make-collection-record splines nesting-levels)
      spline-collection?
      (splines collection-splines collection-splines-set!)
      (nesting-levels collection-nesting-levels collection-nesting-levels-set!))

    (define (make-spline-collection . opts)
      (let ((spls (if (null? opts) '() (car opts))))
        (make-collection-record spls (make-vector (length spls) 0))))

    (define (collection-add-spline! coll spline)
      (let* ((spls (append (collection-splines coll) (list spline)))
             (n (length spls)))
        (collection-splines-set! coll spls)
        (collection-nesting-levels-set! coll (make-vector n 0))
        coll))

    ;; -------------------------------------------------------------------------
    ;; Bounding Box Calculation
    ;; -------------------------------------------------------------------------
    (define (spline-get-bbox spline)
      (let ((segs (spline-segments spline)))
        (if (null? segs)
            '(0.0 0.0 0.0 0.0)
            (let loop ((segs segs)
                       (min-x 1.0e10) (max-x -1.0e10)
                       (min-y 1.0e10) (max-y -1.0e10))
              (if (null? segs)
                  (list min-x max-x min-y max-y)
                  (let* ((seg (car segs))
                         (p0 (bezier-cubic-p0 seg))
                         (p1 (bezier-cubic-p1 seg))
                         (p2 (bezier-cubic-p2 seg))
                         (p3 (bezier-cubic-p3 seg))
                         (x0 (point-2d-x p0)) (y0 (point-2d-y p0))
                         (x1 (point-2d-x p1)) (y1 (point-2d-y p1))
                         (x2 (point-2d-x p2)) (y2 (point-2d-y p2))
                         (x3 (point-2d-x p3)) (y3 (point-2d-y p3)))
                    (loop (cdr segs)
                          (min min-x x0 x1 x2 x3)
                          (max max-x x0 x1 x2 x3)
                          (min min-y y0 y1 y2 y3)
                          (max max-y y0 y1 y2 y3))))))))

    (define (bbox-overlap? bbox1 bbox2)
      (let ((min1-x (car bbox1)) (max1-x (cadr bbox1))
            (min1-y (caddr bbox1)) (max1-y (cadddr bbox1))
            (min2-x (car bbox2)) (max2-x (cadr bbox2))
            (min2-y (caddr bbox2)) (max2-y (cadddr bbox2)))
        (not (or (< max1-x min2-x) (> min1-x max2-x)
                 (< max1-y min2-y) (> min1-y max2-y)))))

    ;; -------------------------------------------------------------------------
    ;; Point Containment Test (Ray Casting)
    ;; -------------------------------------------------------------------------
    (define (collection-point-in-spline? spline pt)
      (let ((px (point-2d-x pt))
            (py (point-2d-y pt))
            (segs (spline-segments spline)))
        (let loop ((segs segs) (crossings 0))
          (if (null? segs)
              (odd? crossings)
              (let* ((seg (car segs))
                     (x0 (point-2d-x (bezier-cubic-p0 seg)))
                     (y0 (point-2d-y (bezier-cubic-p0 seg)))
                     (x3 (point-2d-x (bezier-cubic-p3 seg)))
                     (y3 (point-2d-y (bezier-cubic-p3 seg))))
                (if (not (eq? (> y0 py) (> y3 py)))
                    (let ((x-intersect (+ (* (/ (- x3 x0) (+ (- y3 y0) 1.0e-12)) (- py y0)) x0)))
                      (if (< px x-intersect)
                          (loop (cdr segs) (+ crossings 1))
                          (loop (cdr segs) crossings)))
                    (loop (cdr segs) crossings)))))))

    ;; -------------------------------------------------------------------------
    ;; Intersections Between Splines
    ;; -------------------------------------------------------------------------
    (define (intersect-two-splines s1 idx1 s2 idx2 tol)
      (let ((b1 (spline-get-bbox s1))
            (b2 (spline-get-bbox s2)))
        (if (not (bbox-overlap? b1 b2))
            '()
            (let* ((segs1 (spline-segments s1))
                   (segs2 (spline-segments s2))
                   (n1 (length segs1))
                   (n2 (length segs2))
                   (vec1 (list->vector segs1))
                   (vec2 (list->vector segs2))
                   (closed1? (spline-closed? s1)))
              (let loop-k1 ((k1 0) (acc '()))
                (if (>= k1 n1)
                    acc
                    (let loop-k2 ((k2 0) (acc acc))
                      (if (>= k2 n2)
                          (loop-k1 (+ k1 1) acc)
                          (if (and (= idx1 idx2) (< k2 k1))
                              (loop-k2 (+ k2 1) acc)
                              (let* ((is-adj (and (= idx1 idx2)
                                                  (or (= k2 (+ k1 1))
                                                      (and (= k1 0) (= k2 (- n1 1)) closed1?))))
                                     (sub-res (bezier-intersect (vector-ref vec1 k1)
                                                                (vector-ref vec2 k2)
                                                                tol))
                                     (filtered (let filter ((pts sub-res))
                                                 (if (null? pts)
                                                     '()
                                                     (let* ((pair (car pts))
                                                            (t1 (intersection-t1 pair))
                                                            (t2 (intersection-t2 pair))
                                                            (pt (intersection-pt pair)))
                                                       (if (and is-adj (> t1 0.95) (< t2 0.05))
                                                           (filter (cdr pts))
                                                           (cons `((spline-idx1 . ,idx1)
                                                                   (seg-idx1 . ,(+ k1 1))
                                                                   (t1 . ,t1)
                                                                   (spline-idx2 . ,idx2)
                                                                   (seg-idx2 . ,(+ k2 1))
                                                                   (t2 . ,t2)
                                                                   (point . ,pt))
                                                                 (filter (cdr pts)))))))))
                                (loop-k2 (+ k2 1) (append acc filtered)))))))))))))

    (define (collection-find-intersections-internal coll . opts)
      (let* ((tol (if (null? opts) 1.0e-5 (car opts)))
             (spls (collection-splines coll))
             (n (length spls))
             (vec (list->vector spls)))
        (let loop-i ((i 0) (acc '()))
          (if (>= i n)
              acc
              (let loop-j ((j i) (acc acc))
                (if (>= j n)
                    (loop-i (+ i 1) acc)
                    (let ((res (intersect-two-splines (vector-ref vec i) (+ i 1)
                                                       (vector-ref vec j) (+ j 1)
                                                       tol)))
                      (loop-j (+ j 1) (append acc res)))))))))

    (define (collection-find-intersections-between coll-a coll-b . opts)
      (let* ((tol (if (null? opts) 1.0e-5 (car opts)))
             (spls-a (collection-splines coll-a))
             (spls-b (collection-splines coll-b))
             (na (length spls-a))
             (nb (length spls-b))
             (vec-a (list->vector spls-a))
             (vec-b (list->vector spls-b)))
        (let loop-i ((i 0) (acc '()))
          (if (>= i na)
              acc
              (let loop-j ((j 0) (acc acc))
                (if (>= j nb)
                    (loop-i (+ i 1) acc)
                    (let ((res (intersect-two-splines (vector-ref vec-a i) (+ i 1)
                                                       (vector-ref vec-b j) (+ j 1)
                                                       tol)))
                      (loop-j (+ j 1) (append acc res)))))))))

    ;; -------------------------------------------------------------------------
    ;; Topological Nesting Hierarchy
    ;; -------------------------------------------------------------------------
    (define (collection-compute-hierarchy! coll)
      (let* ((spls (collection-splines coll))
             (n (length spls))
             (vec (list->vector spls))
             (levels (make-vector n 0)))
        (let loop-i ((i 0))
          (if (>= i n)
              (begin
                (collection-nesting-levels-set! coll levels)
                coll)
              (let* ((target-spline (vector-ref vec i))
                     (segs (spline-segments target-spline)))
                (if (null? segs)
                    (begin
                      (vector-set! levels i 0)
                      (loop-i (+ i 1)))
                    (let* ((test-pt (bezier-cubic-p0 (car segs)))
                           (depth (let loop-j ((j 0) (cnt 0))
                                    (if (>= j n)
                                        cnt
                                        (if (= i j)
                                            (loop-j (+ j 1) cnt)
                                            (if (collection-point-in-spline? (vector-ref vec j) test-pt)
                                                (loop-j (+ j 1) (+ cnt 1))
                                                (loop-j (+ j 1) cnt)))))))
                      (vector-set! levels i depth)
                      (loop-i (+ i 1)))))))))

    ;; -------------------------------------------------------------------------
    ;; OpenType/TrueType Auto-Orientation (Even = CCW, Odd = CW)
    ;; -------------------------------------------------------------------------
    (define (collection-auto-orient-opentype! coll)
      (collection-compute-hierarchy! coll)
      (let* ((spls (collection-splines coll))
             (levels (collection-nesting-levels coll))
             (n (length spls))
             (vec (list->vector spls)))
        (let loop ((i 0))
          (when (< i n)
            (let* ((depth (vector-ref levels i))
                   (spline (vector-ref vec i))
                   (target-rot (if (even? depth) 'counter-clockwise 'clockwise)))
              (spline-set-rotation! spline target-rot)
              (loop (+ i 1)))))
        coll))))
