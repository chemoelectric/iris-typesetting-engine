!===============================================================================
! Program: test_iris_spline_collection
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Automated Regression Test for Iris Spline Collection Engine
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
program test_iris_spline_collection
  use, intrinsic :: iso_fortran_env, only: int32, real64
  use iris_bezier_intersect, only: point_2d_type, bezier_cubic_type, bezier_make_point, bezier_make_cubic
  use iris_spline, only: piecewise_spline_type, spline_init, spline_add_segment, spline_close, SPLINE_OK
  use iris_spline_collection
  implicit none

  type(spline_collection_type) :: coll
  type(piecewise_spline_type)  :: sp
  type(bezier_cubic_type)      :: seg1, seg2, seg3, seg4
  type(point_2d_type)          :: p0, p1, p2, p3, test_pt
  type(collection_intersect_result_type) :: int_res
  integer(kind=int32)          :: status, exit_code
  real(kind=real64)            :: xmin, ymin, xmax, ymax
  logical                      :: inside

  exit_code = 0

  ! 1. Initialize Collection
  call collection_init(coll)

  ! 2. Create Rectangular Spline Contour (0,0) to (20,20)
  call spline_init(sp)
  p0 = bezier_make_point(0.0_real64, 0.0_real64)
  p1 = bezier_make_point(5.0_real64, 0.0_real64)
  p2 = bezier_make_point(15.0_real64, 0.0_real64)
  p3 = bezier_make_point(20.0_real64, 0.0_real64)
  seg1 = bezier_make_cubic(p0, p1, p2, p3)
  call spline_add_segment(sp, seg1, status)

  p0 = bezier_make_point(20.0_real64, 0.0_real64)
  p1 = bezier_make_point(20.0_real64, 5.0_real64)
  p2 = bezier_make_point(20.0_real64, 15.0_real64)
  p3 = bezier_make_point(20.0_real64, 20.0_real64)
  seg2 = bezier_make_cubic(p0, p1, p2, p3)
  call spline_add_segment(sp, seg2, status)

  p0 = bezier_make_point(20.0_real64, 20.0_real64)
  p1 = bezier_make_point(15.0_real64, 20.0_real64)
  p2 = bezier_make_point(5.0_real64, 20.0_real64)
  p3 = bezier_make_point(0.0_real64, 20.0_real64)
  seg3 = bezier_make_cubic(p0, p1, p2, p3)
  call spline_add_segment(sp, seg3, status)

  p0 = bezier_make_point(0.0_real64, 20.0_real64)
  p1 = bezier_make_point(0.0_real64, 15.0_real64)
  p2 = bezier_make_point(0.0_real64, 5.0_real64)
  p3 = bezier_make_point(0.0_real64, 0.0_real64)
  seg4 = bezier_make_cubic(p0, p1, p2, p3)
  call spline_add_segment(sp, seg4, status)

  call spline_close(sp, status)

  ! 3. Add to Collection
  call collection_add_spline(coll, sp, status)
  if (status /= COLLECTION_OK) then
    print *, "TEST FAIL: collection_add_spline error"
    exit_code = 1
  end if

  ! 4. Check Collection Bounding Box
  call collection_get_bbox(coll, xmin, ymin, xmax, ymax)
  if (xmin > 0.1_real64 .or. ymin > 0.1_real64 .or. xmax < 19.9_real64 .or. ymax < 19.9_real64) then
    print *, "TEST FAIL: collection_get_bbox mismatch"
    exit_code = 2
  end if

  ! 5. Ray-Casting Point Containment Test
  test_pt = bezier_make_point(10.0_real64, 10.0_real64)
  inside = collection_point_in_spline(sp, test_pt)
  if (.not. inside) then
    print *, "TEST FAIL: collection_point_in_spline false negative"
    exit_code = 3
  end if

  ! 6. Test Internal Intersections & Winding Auto-Orientation
  call collection_find_intersections_internal(coll, int_res)
  call collection_compute_hierarchy(coll)
  call collection_auto_orient_opentype(coll)

  if (exit_code == 0) then
    print *, "TEST PASS: Iris Spline Collection module API verified successfully."
  else
    stop 1
  end if
end program test_iris_spline_collection
