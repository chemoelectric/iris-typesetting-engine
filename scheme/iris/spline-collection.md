# Scheme Piecewise Spline Collection Engine (`(iris spline-collection)`)

## 1. Executive Summary
The `(iris spline-collection)` R7RS-large Scheme library provides a functional data-structure interface for managing collections of piecewise splines, calculating pairwise intersections between contours, establishing topological containment hierarchies, and auto-orienting winding direction under OpenType rules.

This library is designed in **structural isomorphism** with the Fortran 2008 `iris_spline_collection` module.

---

## 2. Structural Isomorphism Matrix

| API Functionality | R7RS Scheme (`(iris spline-collection)`) | Fortran 2008 (`iris_spline_collection`) |
| :--- | :--- | :--- |
| **Initialize Collection** | `(make-spline-collection [splines])` | `call collection_init(coll)` |
| **Add Spline Contour** | `(collection-add-spline! coll spline)` | `call collection_add_spline(coll, spline, status)` |
| **Get Bounding Box** | `(spline-get-bbox spline)` | `call collection_get_bbox(spline, minx, maxx, miny, maxy)` |
| **Point-in-Spline Test** | `(collection-point-in-spline? spline pt)` | `inside = collection_point_in_spline(spline, pt)` |
| **Internal Intersections**| `(collection-find-intersections-internal coll [tol])` | `call collection_find_intersections_internal(coll, tol, res)` |
| **Intersections Between** | `(collection-find-intersections-between ca cb [tol])` | `call collection_find_intersections_between(ca cb tol res)` |
| **Compute Hierarchy** | `(collection-compute-hierarchy! coll)` | `call collection_compute_hierarchy(coll, status)` |
| **Auto-Orient OpenType** | `(collection-auto-orient-opentype! coll)` | `call collection_auto_orient_opentype(coll, status)` |

---

## 3. Example Usage in R7RS Scheme

```scheme
(import (scheme base)
        (scheme write)
        (iris bezier-intersect)
        (iris spline)
        (iris spline-collection))

(let ((glyph-o (make-spline-collection))
      (outer-ring (make-piecewise-spline))
      (inner-hole (make-piecewise-spline)))

  ;; Build Outer Ring Contour (100x100)
  (spline-add-segment! outer-ring
    (make-bezier-cubic (make-point-2d 0.0 0.0)
                       (make-point-2d 100.0 0.0)
                       (make-point-2d 100.0 100.0)
                       (make-point-2d 0.0 100.0)))
  (spline-close! outer-ring)

  ;; Build Inner Hole Contour (50x50)
  (spline-add-segment! inner-hole
    (make-bezier-cubic (make-point-2d 25.0 25.0)
                       (make-point-2d 75.0 25.0)
                       (make-point-2d 75.0 75.0)
                       (make-point-2d 25.0 75.0)))
  (spline-close! inner-hole)

  ;; Add contours to collection
  (collection-add-spline! glyph-o outer-ring)
  (collection-add-spline! glyph-o inner-hole)

  ;; Auto-orient according to OpenType rules (Outer = CCW, Hole = CW)
  (collection-auto-orient-opentype! glyph-o)

  ;; Check Rotational Orientations
  (display "Outer Ring Rotation: ")
  (write (spline-get-rotation (car (collection-splines glyph-o)))) ;; 'counter-clockwise
  (newline)

  (display "Inner Hole Rotation: ")
  (write (spline-get-rotation (cadr (collection-splines glyph-o)))) ;; 'clockwise
  (newline))
```

---

## 4. Architectural Standards & Compliance
- **R7RS Conformance**: Standard Scheme library structure using `(define-library (iris spline-collection) ...)` with explicit exports.
- **Functional Exemption**: In accordance with system design rules, Scheme code is explicitly exempt from imperative single-exit control flow constraints.
- **Module Synchronization**: Maintained in strict synchronization with `/scheme/iris/spline-collection.sld` and `/fortran/iris_spline_collection.f90`.
