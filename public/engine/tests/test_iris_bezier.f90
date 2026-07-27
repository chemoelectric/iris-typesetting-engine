!===============================================================================
! Program: test_iris_bezier
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Automated Regression Test for Iris Bézier Curve & Intersection
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
program test_iris_bezier
  use, intrinsic :: iso_fortran_env, only: int32, real64
  use iris_bezier_intersect
  implicit none

  type(point_2d_type)         :: p0, p1, p2, p3, p_eval
  type(bezier_cubic_type)     :: c1, c2, left_c, right_c
  type(spower_cubic_type)     :: spow
  type(bezier_result_type)    :: res
  integer(kind=int32)         :: exit_code
  logical                     :: overlap

  exit_code = 0

  ! 1. Point Constructor
  p0 = bezier_make_point(0.0_real64, 0.0_real64)
  p1 = bezier_make_point(0.0_real64, 10.0_real64)
  p2 = bezier_make_point(10.0_real64, 10.0_real64)
  p3 = bezier_make_point(10.0_real64, 0.0_real64)

  ! 2. Cubic Bézier Constructor
  c1 = bezier_make_cubic(p0, p1, p2, p3)

  ! 3. Point Evaluation at t=0.5
  p_eval = bezier_eval(c1, 0.5_real64)
  if (abs(p_eval%x - 5.0_real64) > 1.0e-5_real64 .or. abs(p_eval%y - 7.5_real64) > 1.0e-5_real64) then
    print *, "TEST FAIL: bezier_eval point mismatch at t=0.5"
    exit_code = 1
  end if

  ! 4. De Casteljau Sub-division
  call bezier_split(c1, 0.5_real64, left_c, right_c)
  if (abs(left_c%p3%x - p_eval%x) > 1.0e-5_real64 .or. abs(left_c%p3%y - p_eval%y) > 1.0e-5_real64) then
    print *, "TEST FAIL: bezier_split left endpoint mismatch"
    exit_code = 2
  end if

  ! 5. S-Power Polynomial Representation Conversion
  call bezier_to_spower(c1, spow)

  ! 6. Intersection with Intersecting Transverse Curve
  p0 = bezier_make_point(5.0_real64, -5.0_real64)
  p1 = bezier_make_point(5.0_real64, 5.0_real64)
  p2 = bezier_make_point(5.0_real64, 12.0_real64)
  p3 = bezier_make_point(5.0_real64, 15.0_real64)
  c2 = bezier_make_cubic(p0, p1, p2, p3)

  overlap = bezier_bbox_overlap(c1, c2)
  if (.not. overlap) then
    print *, "TEST FAIL: bezier_bbox_overlap false negative"
    exit_code = 3
  end if

  call bezier_intersect(c1, c2, DEFAULT_TOLERANCE, res)
  if (res%status /= BEZIER_OK .or. res%count < 1) then
    print *, "TEST FAIL: bezier_intersect failed to detect intersection"
    exit_code = 4
  end if

  call bezier_free_result(res)

  if (exit_code == 0) then
    print *, "TEST PASS: Iris Bézier intersection module API verified successfully."
  else
    stop 1
  end if
end program test_iris_bezier
