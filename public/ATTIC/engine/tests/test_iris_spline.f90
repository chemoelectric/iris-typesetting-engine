!===============================================================================
! Program: test_iris_spline
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Automated Regression Test for Iris Piecewise Spline Engine
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
program test_iris_spline
  use, intrinsic :: iso_fortran_env, only: int32, real64
  use iris_bezier_intersect, only: point_2d_type, bezier_cubic_type, bezier_make_point, bezier_make_cubic
  use iris_spline
  implicit none

  type(piecewise_spline_type) :: sp
  type(bezier_cubic_type)     :: seg1, seg2, seg3
  type(point_2d_type)         :: p0, p1, p2, p3, p_eval
  type(continuity_report_type):: report
  integer(kind=int32)         :: status, exit_code, rot
  real(kind=real64)           :: area
  logical                     :: self_int

  exit_code = 0

  ! 1. Initialize Spline
  call spline_init(sp)

  ! 2. Create Segments forming a closed triangular contour
  ! Segment 1: (0,0) -> (10,0)
  p0 = bezier_make_point(0.0_real64, 0.0_real64)
  p1 = bezier_make_point(3.0_real64, 0.0_real64)
  p2 = bezier_make_point(7.0_real64, 0.0_real64)
  p3 = bezier_make_point(10.0_real64, 0.0_real64)
  seg1 = bezier_make_cubic(p0, p1, p2, p3)
  call spline_add_segment(sp, seg1, status)
  if (status /= SPLINE_OK) exit_code = 1

  ! Segment 2: (10,0) -> (5,10)
  p0 = bezier_make_point(10.0_real64, 0.0_real64)
  p1 = bezier_make_point(8.0_real64, 3.0_real64)
  p2 = bezier_make_point(7.0_real64, 7.0_real64)
  p3 = bezier_make_point(5.0_real64, 10.0_real64)
  seg2 = bezier_make_cubic(p0, p1, p2, p3)
  call spline_add_segment(sp, seg2, status)
  if (status /= SPLINE_OK) exit_code = 2

  ! Segment 3: (5,10) -> (0,0)
  p0 = bezier_make_point(5.0_real64, 10.0_real64)
  p1 = bezier_make_point(3.0_real64, 7.0_real64)
  p2 = bezier_make_point(2.0_real64, 3.0_real64)
  p3 = bezier_make_point(0.0_real64, 0.0_real64)
  seg3 = bezier_make_cubic(p0, p1, p2, p3)
  call spline_add_segment(sp, seg3, status)
  if (status /= SPLINE_OK) exit_code = 3

  ! 3. Close Spline
  call spline_close(sp, status)
  if (status /= SPLINE_OK .or. .not. sp%is_closed) then
    print *, "TEST FAIL: spline_close failed"
    exit_code = 4
  end if

  ! 4. Check Joint Continuity
  call spline_check_continuity(sp, DEFAULT_CONT_TOL, report)
  if (.not. report%c0_continuous) then
    print *, "TEST FAIL: C0 continuity check failed"
    exit_code = 5
  end if

  ! 5. Evaluate Spline
  p_eval = spline_eval(sp, 0.5_real64)

  ! 6. Check Self Intersections
  self_int = spline_self_intersects(sp, DEFAULT_CONT_TOL)
  if (self_int) then
    print *, "TEST FAIL: False self-intersection detected"
    exit_code = 6
  end if

  ! 7. Calculate Area & Rotation
  area = spline_calc_signed_area(sp)
  rot = spline_get_rotation(sp)
  if (rot /= SPLINE_ROTATION_CCW .and. rot /= SPLINE_ROTATION_CW) then
    print *, "TEST FAIL: Rotation sense detection error"
    exit_code = 7
  end if

  ! 8. Set Rotation
  call spline_set_rotation(sp, SPLINE_ROTATION_CW)

  if (exit_code == 0) then
    print *, "TEST PASS: Iris Piecewise Spline module API verified successfully."
  else
    stop 1
  end if
end program test_iris_spline
