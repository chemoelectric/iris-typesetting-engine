# Fortran 2008 Piecewise Spline Engine, Continuity & Winding Rotation Verifier (`iris_spline`)

## 1. Executive Summary
The `iris_spline` module provides a standard Fortran 2008 (ISO/IEC 1539-1:2010) piecewise spline layout engine with explicit closing segment tracking, $C^0, C^1, C^2$ joint continuity verification, self-intersection detection, and winding sense of rotation management.

It automatically maintains explicit closing segments for closed splines, detects curve self-intersections via Bézier clipping, computes exact Green's theorem signed areas, and manages orientation (Clockwise vs Counter-Clockwise).

This module is designed in **structural isomorphism** with the R7RS Scheme `(iris spline)` library.

---

## 2. Structural Isomorphism Matrix

| API Functionality | Fortran 2008 (`iris_spline`) | R7RS Scheme (`(iris spline)`) |
| :--- | :--- | :--- |
| **Initialize Spline** | `call spline_init(spline)` | `(make-piecewise-spline [segments closed?])` |
| **Add Segment** | `call spline_add_segment(spline, curve, status)` | `(spline-add-segment! spline curve)` |
| **Close Spline** | `call spline_close(spline, status)` | `(spline-close! spline)` |
| **Check Continuity** | `call spline_check_continuity(spline, tol, report)` | `(spline-check-continuity spline [tol])` |
| **Evaluate Parameter** | `pt = spline_eval(spline, u)` | `(spline-eval spline u)` |
| **Self-Intersection Check**| `self_intersect = spline_self_intersects(spline [tol])` | `(spline-self-intersects? spline [tol])` |
| **Signed Area** | `area = spline_calc_signed_area(spline)` | `(spline-calc-signed-area spline)` |
| **Get Rotation Sense** | `rot = spline_get_rotation(spline [tol])` | `(spline-get-rotation spline [tol])` |
| **Set Rotation Sense** | `call spline_set_rotation(spline, target_rot, status)` | `(spline-set-rotation! spline target_rot)` |

---

## 3. Rotation Sense Constants

| Constant | Value | Description |
| :--- | :--- | :--- |
| `SPLINE_ROTATION_CCW` | `1` | Counter-Clockwise rotation sense |
| `SPLINE_ROTATION_CW` | `-1` | Clockwise rotation sense |
| `SPLINE_ROTATION_NOT_CLOSED` | `0` | Open spline (rotation undefined) |
| `SPLINE_ROTATION_SELF_INTERSECTING` | `-2` | Curve self-intersects (rotation sense ill-defined) |

---

## 4. Example Usage in Fortran 2008

```fortran
program test_spline
  use iris_bezier_intersect
  use iris_spline
  implicit none

  type(piecewise_spline_type) :: spline
  type(bezier_cubic_type)     :: seg1, seg2, seg3, seg4
  type(continuity_report_type):: report
  integer                     :: status, rot
  logical                     :: self_intersect

  call spline_init(spline)

  ! Add square segments
  seg1 = bezier_make_cubic(bezier_make_point(0.0d0, 0.0d0), bezier_make_point(33d0, 0d0), bezier_make_point(66d0, 0d0), bezier_make_point(100.0d0, 0.0d0))
  seg2 = bezier_make_cubic(bezier_make_point(100.0d0, 0.0d0), bezier_make_point(100d0, 33d0), bezier_make_point(100d0, 66d0), bezier_make_point(100.0d0, 100.0d0))
  seg3 = bezier_make_cubic(bezier_make_point(100.0d0, 100.0d0), bezier_make_point(66d0, 100d0), bezier_make_point(33d0, 100d0), bezier_make_point(0.0d0, 100.0d0))
  seg4 = bezier_make_cubic(bezier_make_point(0.0d0, 100.0d0), bezier_make_point(0d0, 66d0), bezier_make_point(0d0, 33d0), bezier_make_point(0.0d0, 0.0d0))

  call spline_add_segment(spline, seg1, status)
  call spline_add_segment(spline, seg2, status)
  call spline_add_segment(spline, seg3, status)
  call spline_add_segment(spline, seg4, status)

  ! Explicitly close spline
  call spline_close(spline, status)

  ! Self-intersection check
  self_intersect = spline_self_intersects(spline)
  print *, "Self Intersects:", self_intersect

  ! Sense of Rotation check
  rot = spline_get_rotation(spline)
  print *, "Rotation Sense:", rot  ! Expect 1 (SPLINE_ROTATION_CCW)

  ! Enforce Clockwise rotation
  call spline_set_rotation(spline, SPLINE_ROTATION_CW, status)
  rot = spline_get_rotation(spline)
  print *, "New Rotation Sense:", rot  ! Expect -1 (SPLINE_ROTATION_CW)
end program test_spline
```

---

## 5. Architectural Standards & Compliance
- **ISO Standard**: Standard Fortran 2008 (ISO/IEC 1539-1:2010).
- **Structured Control**: Enforces single-entry/single-exit control constructs without `goto` constructs.
- **McCabe Complexity**: Each procedure strictly maintains a modified McCabe cyclomatic complexity $\le 10$.
- **Module Synchronization**: Maintained in strict synchronization with `/fortran/iris_spline.f90`.
