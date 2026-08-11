!===============================================================================
! Program: test_iris_trip
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Automated Regression Test for TRIP Benchmark Suite
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
program test_iris_trip
  use, intrinsic :: iso_fortran_env, only: int32
  use iris_tex
  implicit none

  character(len=256)  :: rep_msg
  integer(kind=int32) :: status, exit_code

  exit_code = 0

  call tex_run_trip_test(status, rep_msg)
  if (status /= TEX_OK .or. index(rep_msg, "TRIP test passed") == 0) then
    print *, "TEST FAIL: tex_run_trip_test failed"
    exit_code = 1
  end if

  if (exit_code == 0) then
    print *, "TEST PASS: Iris TRIP benchmark diagnostic suite verified successfully."
  else
    stop 1
  end if
end program test_iris_trip
