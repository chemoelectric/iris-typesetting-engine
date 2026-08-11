!===============================================================================
! Program: test_iris_svd
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Regression Test for Extended Hobby Spline and SVD Bridge Suite
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
program test_iris_svd
  use, intrinsic :: iso_fortran_env, only: int32, real64
  use iris_svd_fallback, only: iris_svd_fallback_solve
  use iris_svd_bridge, only: iris_svd_solve, iris_svd_set_solver, iris_svd_reset_to_fallback, iris_svd_use_lapack
  use iris_hobby_svd, only: hobby_knot_type, hobby_control_point_type, hobby_config_type, &
                            hobby_init_config, hobby_compute_spline_svd, HOBBY_OK
  implicit none

  type(hobby_knot_type)          :: knots(4)
  type(hobby_control_point_type) :: controls(4)
  type(hobby_config_type)        :: cfg
  real(kind=real64)              :: A(3, 3), b(3), x(3)
  integer(kind=int32)            :: status, exit_code, i

  exit_code = 0

  ! 1. Test Fallback SVD Direct Matrix System Solve
  A(1, :) = [4.0_real64, 1.0_real64, 0.0_real64]
  A(2, :) = [1.0_real64, 4.0_real64, 1.0_real64]
  A(3, :) = [0.0_real64, 1.0_real64, 4.0_real64]
  b = [5.0_real64, 6.0_real64, 5.0_real64]

  call iris_svd_fallback_solve(3, A, b, x, 1.0e-12_real64, status)
  if (status /= 0) then
    print *, "TEST FAIL: Direct fallback SVD solve failed"
    exit_code = 1
  end if

  if (abs(x(1) - 1.0_real64) > 1.0e-4_real64 .or. abs(x(2) - 1.0_real64) > 1.0e-4_real64) then
    print *, "TEST FAIL: Fallback SVD solution accuracy out of tolerance"
    exit_code = 2
  end if

  ! 2. Test SVD Bridge Dispatch
  call iris_svd_reset_to_fallback()
  call iris_svd_solve(3, A, b, x, 1.0e-12_real64, status)
  if (status /= 0) then
    print *, "TEST FAIL: Bridge dispatch SVD solve failed"
    exit_code = 3
  end if

#ifdef HAVE_LAPACK
  call iris_svd_use_lapack()
  call iris_svd_solve(3, A, b, x, 1.0e-12_real64, status)
  if (status /= 0) then
    print *, "TEST FAIL: LAPACK bridge SVD solve failed"
    exit_code = 6
  end if
#endif

  ! 3. Test Extended Hobby Spline SVD Computation
  call hobby_init_config(cfg)
  knots(1)%x = 0.0_real64;   knots(1)%y = 0.0_real64
  knots(2)%x = 100.0_real64; knots(2)%y = 0.0_real64
  knots(3)%x = 100.0_real64; knots(3)%y = 100.0_real64
  knots(4)%x = 0.0_real64;   knots(4)%y = 100.0_real64

  call hobby_compute_spline_svd(knots, 4, .true., cfg, controls, status)
  if (status /= HOBBY_OK) then
    print *, "TEST FAIL: Hobby SVD spline computation failed"
    exit_code = 4
  end if

  ! Verify control point generation
  do i = 1, 4
    if (controls(i)%alpha <= 0.0_real64 .or. controls(i)%beta <= 0.0_real64) then
      print *, "TEST FAIL: Invalid control point velocity handles"
      exit_code = 5
    end if
  end do

  if (exit_code == 0) then
    print *, "TEST PASS: Extended Hobby Spline and SVD Bridge API verified successfully."
  else
    stop 1
  end if
end program test_iris_svd
