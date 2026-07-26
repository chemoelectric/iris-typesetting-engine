# Fortran 2008 Bézier Clipping & S-Power Intersection Engine (`iris_bezier_intersect`)

## 1. Executive Summary
The `iris_bezier_intersect` module provides a high-performance standard Fortran 2008 (ISO/IEC 1539-1:2010) implementation of the **Bézier Clipping and S-Power Spline Curve Intersection Algorithm**.

It leverages SIMD-friendly array operations and S-power monomial basis transformations for rapid bounding-box overlap rejection and sub-pixel numerical root convergence.

This module is designed in **structural isomorphism** with the R7RS Scheme `(iris bezier-intersect)` library.

---

## 2. Structural Isomorphism Matrix

| API Functionality | Fortran 2008 (`iris_bezier_intersect`) | R7RS Scheme (`(iris bezier-intersect)`) |
| :--- | :--- | :--- |
| **Construct 2D Point** | `pt = bezier_make_point(x, y)` | `(make-point-2d x y)` |
| **Construct Cubic Curve** | `curve = bezier_make_cubic(p0, p1, p2, p3)` | `(make-bezier-cubic p0 p1 p2 p3)` |
| **Evaluate Parameter t** | `pt = bezier_eval(curve, t)` | `(bezier-eval curve t)` |
| **Subdivide Curve (de Casteljau)** | `call bezier_split(curve, left, right)` | `(bezier-split curve)` |
| **BBox Overlap Check** | `overlap = bezier_bbox_overlap(c1, c2)` | `(bezier-bbox-overlap? c1 c2)` |
| **Convert to S-Power Basis** | `sp = bezier_to_spower(curve)` | `(bezier->spower curve)` |
| **Intersect Curves** | `call bezier_intersect(c1, c2, tol, res)` | `(bezier-intersect c1 c2 [tol])` |

---

## 3. Example Usage in Fortran 2008

```fortran
program test_bezier_intersect
  use iris_bezier_intersect
  implicit none

  type(bezier_cubic_type) :: c1, c2
  type(bezier_result_type):: res
  integer                 :: i

  ! Define first cubic curve
  c1 = bezier_make_cubic( &
    bezier_make_point(0.0d0, 0.0d0), &
    bezier_make_point(100.0d0, 200.0d0), &
    bezier_make_point(200.0d0, 200.0d0), &
    bezier_make_point(300.0d0, 0.0d0) &
  )

  ! Define intersecting cubic curve
  c2 = bezier_make_cubic( &
    bezier_make_point(150.0d0, -50.0d0), &
    bezier_make_point(150.0d0, 100.0d0), &
    bezier_make_point(150.0d0, 200.0d0), &
    bezier_make_point(150.0d0, 250.0d0) &
  )

  ! Compute intersections
  call bezier_intersect(c1, c2, 1.0d-6, res)

  print *, "Found Intersections Count:", res%count
  do i = 1, res%count
    print *, "Intersection #", i, "at X=", res%intersections(i)%pt%x, "Y=", res%intersections(i)%pt%y
  end do
end program test_bezier_intersect
```

---

## 4. Architectural Standards & Compliance
- **ISO Standard**: Standard Fortran 2008 (ISO/IEC 1539-1:2010).
- **Structured Control**: Enforces single-entry/single-exit control constructs without `goto` constructs.
- **McCabe Complexity**: Each procedure strictly maintains a modified McCabe cyclomatic complexity $\le 10$.
- **Module Synchronization**: Maintained in strict synchronization with `/fortran/iris_bezier_intersect.f90`.
