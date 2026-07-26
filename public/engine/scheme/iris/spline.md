# Scheme Piecewise Spline Engine, Continuity & Winding Rotation Verifier (`(iris spline)`)

## 1. Executive Summary
The `(iris spline)` R7RS-large Scheme library provides a functional data-structure interface for managing open and closed piecewise splines, maintaining explicit closing segments, checking $C^0, C^1, C^2$ joint continuity, detecting self-intersections, and managing winding rotation sense.

This library is designed in **structural isomorphism** with the Fortran 2008 `iris_spline` module.

---

## 2. Structural Isomorphism Matrix

| API Functionality | R7RS Scheme (`(iris spline)`) | Fortran 2008 (`iris_spline`) |
| :--- | :--- | :--- |
| **Initialize Spline** | `(make-piecewise-spline [segments closed?])` | `call spline_init(spline)` |
| **Add Segment** | `(spline-add-segment! spline curve)` | `call spline_add_segment(spline, curve, status)` |
| **Close Spline** | `(spline-close! spline)` | `call spline_close(spline, status)` |
| **Check Continuity** | `(spline-check-continuity spline [tol])` | `call spline_check_continuity(spline, tol, report)` |
| **Evaluate Parameter** | `(spline-eval spline u)` | `pt = spline_eval(spline, u)` |
| **Self-Intersection Check**| `(spline-self-intersects? spline [tol])` | `self_intersect = spline_self_intersects(spline [tol])` |
| **Signed Area** | `(spline-calc-signed-area spline)` | `area = spline_calc_signed_area(spline)` |
| **Get Rotation Sense** | `(spline-get-rotation spline [tol])` | `rot = spline_get_rotation(spline [tol])` |
| **Set Rotation Sense** | `(spline-set-rotation! spline target_rot)` | `call spline_set_rotation(spline, target_rot, status)` |

---

## 3. Example Usage in R7RS Scheme

```scheme
(import (scheme base)
        (scheme write)
        (iris bezier-intersect)
        (iris spline))

(let ((spline (make-piecewise-spline))
      (p0 (make-point-2d 0.0 0.0))
      (p1 (make-point-2d 100.0 0.0))
      (p2 (make-point-2d 100.0 100.0))
      (p3 (make-point-2d 0.0 100.0)))

  ;; Add square cubic segments
  (spline-add-segment! spline (make-bezier-cubic p0 (make-point-2d 33.3 0.0) (make-point-2d 66.6 0.0) p1))
  (spline-add-segment! spline (make-bezier-cubic p1 (make-point-2d 100.0 33.3) (make-point-2d 100.0 66.6) p2))
  (spline-add-segment! spline (make-bezier-cubic p2 (make-point-2d 66.6 100.0) (make-point-2d 33.3 100.0) p3))
  (spline-add-segment! spline (make-bezier-cubic p3 (make-point-2d 0.0 66.6) (make-point-2d 0.0 33.3) p0))

  ;; Explicitly close spline
  (spline-close! spline)

  ;; Self-intersection check
  (display "Self Intersects: ")
  (write (spline-self-intersects? spline))
  (newline)

  ;; Get sense of rotation
  (display "Sense of Rotation: ")
  (write (spline-get-rotation spline)) ;; Returns 'counter-clockwise
  (newline)

  ;; Reverse sense of rotation to clockwise
  (spline-set-rotation! spline 'clockwise)
  (display "New Sense of Rotation: ")
  (write (spline-get-rotation spline)) ;; Returns 'clockwise
  (newline))
```

---

## 4. Architectural Standards & Compliance
- **R7RS Conformance**: Standard Scheme library structure using `(define-library (iris spline) ...)` with explicit exports.
- **Functional Exemption**: In accordance with system design rules, Scheme code is explicitly exempt from imperative single-exit control flow constraints.
- **Module Synchronization**: Maintained in strict synchronization with `/scheme/iris/spline.sld` and `/fortran/iris_spline.f90`.
