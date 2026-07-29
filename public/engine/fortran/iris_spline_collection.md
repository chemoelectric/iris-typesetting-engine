# Fortran 2008 Piecewise Spline Collection Engine (`iris_spline_collection`)

## 1. Executive Summary
The `iris_spline_collection` module provides a standard Fortran 2008 (ISO/IEC 1539-1:2010) high-performance engine for managing collections of piecewise splines (e.g. glyph contours, font glyphs, CAD boundaries).

Key capabilities include:
- Pairwise contour intersection detection across internal contours or between distinct collections.
- Axis-aligned bounding box (AABB) spatial filtering for rapid rejection.
- Point-in-polygon containment testing via ray-casting.
- Topological nesting hierarchy computation (odd/even nesting levels).
- Automatic OpenType/TrueType winding auto-orientation (Even nesting = Counter-Clockwise outer contour; Odd nesting = Clockwise inner hole).

This module is designed in **structural isomorphism** with the R7RS Scheme `(iris spline-collection)` library.

---

## 2. Structural Isomorphism Matrix

| API Functionality | Fortran 2008 (`iris_spline_collection`) | R7RS Scheme (`(iris spline-collection)`) |
| :--- | :--- | :--- |
| **Initialize Collection** | `call collection_init(coll)` | `(make-spline-collection [splines])` |
| **Add Spline Contour** | `call collection_add_spline(coll, spline, status)` | `(collection-add-spline! coll spline)` |
| **Get Bounding Box** | `call collection_get_bbox(spline\|coll, minx, miny, maxx, maxy)` | `(spline-get-bbox spline)` |
| **Point-in-Spline Test** | `inside = collection_point_in_spline(spline, pt)` | `(collection-point-in-spline? spline pt)` |
| **Internal Intersections**| `call collection_find_intersections_internal(coll, res, [tol])` | `(collection-find-intersections-internal coll [tol])` |
| **Intersections Between** | `call collection_find_intersections_between(ca, cb, res, [tol])` | `(collection-find-intersections-between ca cb [tol])` |
| **Compute Hierarchy** | `call collection_compute_hierarchy(coll, [status])` | `(collection-compute-hierarchy! coll)` |
| **Auto-Orient OpenType** | `call collection_auto_orient_opentype(coll, [status])` | `(collection-auto-orient-opentype! coll)` |

---

## 3. Example Usage in Fortran 2008

```fortran
program test_spline_collection
  use iris_bezier_intersect
  use iris_spline
  use iris_spline_collection
  implicit none

  type(spline_collection_type)           :: glyph_o
  type(piecewise_spline_type)            :: outer_ring, inner_hole
  type(collection_intersect_result_type) :: inter_res
  integer                                :: status, i

  call collection_init(glyph_o)

  ! Build Outer Ring Contour (100x100)
  call spline_init(outer_ring)
  call spline_add_segment(outer_ring, bezier_make_cubic(bezier_make_point(0.0d0, 0.0d0), &
    bezier_make_point(100.0d0, 0.0d0), bezier_make_point(100.0d0, 100.0d0), bezier_make_point(0.0d0, 100.0d0)), status)
  call spline_close(outer_ring, status)

  ! Build Inner Hole Contour (50x50 centered)
  call spline_init(inner_hole)
  call spline_add_segment(inner_hole, bezier_make_cubic(bezier_make_point(25.0d0, 25.0d0), &
    bezier_make_point(75.0d0, 25.0d0), bezier_make_point(75.0d0, 75.0d0), bezier_make_point(25.0d0, 75.0d0)), status)
  call spline_close(inner_hole, status)

  ! Add contours to collection
  call collection_add_spline(glyph_o, outer_ring, status)
  call collection_add_spline(glyph_o, inner_hole, status)

  ! Auto-orient according to OpenType rules (Outer = CCW, Hole = CW)
  call collection_auto_orient_opentype(glyph_o, status)

  ! Output nesting levels
  print *, "Outer Ring Nesting Level:", glyph_o%nesting_levels(1) ! Expect 0
  print *, "Inner Hole Nesting Level:", glyph_o%nesting_levels(2) ! Expect 1

  ! Output orientation
  print *, "Outer Ring Rotation:", spline_get_rotation(glyph_o%splines(1)) ! Expect 1 (CCW)
  print *, "Inner Hole Rotation:", spline_get_rotation(glyph_o%splines(2)) ! Expect -1 (CW)
end program test_spline_collection
```

---

## 4. Architectural Standards & Compliance
- **ISO Standard**: Standard Fortran 2008 (ISO/IEC 1539-1:2010).
- **Structured Control**: Enforces single-entry/single-exit control constructs without `goto` constructs.
- **McCabe Complexity**: Each procedure strictly maintains a modified McCabe cyclomatic complexity $\le 10$.
- **Module Synchronization**: Maintained in strict synchronization with `/fortran/iris_spline_collection.f90`.
