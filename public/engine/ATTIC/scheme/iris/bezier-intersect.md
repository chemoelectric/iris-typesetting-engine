# Scheme Bézier Clipping & S-Power Intersection Engine (`(iris bezier-intersect)`)

## 1. Executive Summary
The `(iris bezier-intersect)` R7RS-large Scheme library provides a functional data-structure interface for computing curve-curve intersections using **Bézier Clipping and S-Power Spline Curve Analysis**.

This library is designed in **structural isomorphism** with the Fortran 2008 `iris_bezier_intersect` module.

---

## 2. Structural Isomorphism Matrix

| API Functionality | R7RS Scheme (`(iris bezier-intersect)`) | Fortran 2008 (`iris_bezier_intersect`) |
| :--- | :--- | :--- |
| **Construct 2D Point** | `(make-point-2d x y)` | `pt = bezier_make_point(x, y)` |
| **Construct Cubic Curve** | `(make-bezier-cubic p0 p1 p2 p3)` | `curve = bezier_make_cubic(p0, p1, p2, p3)` |
| **Evaluate Parameter t** | `(bezier-eval curve t)` | `pt = bezier_eval(curve, t)` |
| **Subdivide Curve (de Casteljau)** | `(bezier-split curve)` | `call bezier_split(curve, left, right)` |
| **BBox Overlap Check** | `(bezier-bbox-overlap? c1 c2)` | `overlap = bezier_bbox_overlap(c1, c2)` |
| **Convert to S-Power Basis** | `(bezier->spower curve)` | `sp = bezier_to_spower(curve)` |
| **Intersect Curves** | `(bezier-intersect c1 c2 [tol])` | `call bezier_intersect(c1, c2, tol, res)` |

---

## 3. Example Usage in R7RS Scheme

```scheme
(import (scheme base)
        (scheme write)
        (iris bezier-intersect))

(let* ((p0 (make-point-2d 0.0 0.0))
       (p1 (make-point-2d 100.0 200.0))
       (p2 (make-point-2d 200.0 200.0))
       (p3 (make-point-2d 300.0 0.0))
       (c1 (make-bezier-cubic p0 p1 p2 p3))

       (q0 (make-point-2d 150.0 -50.0))
       (q1 (make-point-2d 150.0 100.0))
       (q2 (make-point-2d 150.0 200.0))
       (q3 (make-point-2d 150.0 250.0))
       (c2 (make-bezier-cubic q0 q1 q2 q3))

       (intersections (bezier-intersect c1 c2 1.0e-6)))

  (display "Intersection Count: ")
  (display (length intersections))
  (newline)

  (for-each
   (lambda (pair)
     (let ((pt (intersection-pt pair)))
       (display "Intersection at X=")
       (display (point-2d-x pt))
       (display ", Y=")
       (display (point-2d-y pt))
       (newline)))
   intersections))
```

---

## 4. Architectural Standards & Compliance
- **R7RS Conformance**: Standard Scheme library structure using `(define-library (iris bezier-intersect) ...)` with explicit exports.
- **Functional Exemption**: In accordance with system design rules, Scheme code is explicitly exempt from imperative single-exit control flow constraints.
- **Module Synchronization**: Maintained in strict synchronization with `/scheme/iris/bezier-intersect.sld` and `/fortran/iris_bezier_intersect.f90`.
