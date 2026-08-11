!===============================================================================
! Program: test_iris_kpsewhich
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Automated Regression Test for Iris Kpathsea Locator Module
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
program test_iris_kpsewhich
  use, intrinsic :: iso_fortran_env, only: int32
  use iris_kpsewhich
  implicit none

  character(len=1024) :: res_path, font_path
  integer(kind=int32) :: status, exit_code

  exit_code = 0

  ! 1. Test Search Path Configuration
  call kpse_set_search_path(".:/usr/share/texmf:./fonts")

  ! 2. Test File Search
  call kpse_search_file("cmr10", "tfm", res_path, status)
  if (status /= KPSE_OK .or. len_trim(res_path) == 0) then
    print *, "TEST FAIL: kpse_search_file error"
    exit_code = 1
  end if

  ! 3. Test Font Locating
  call kpse_find_font("cmr10", font_path, status)
  if (status /= KPSE_OK .or. len_trim(font_path) == 0) then
    print *, "TEST FAIL: kpse_find_font error"
    exit_code = 2
  end if

  if (exit_code == 0) then
    print *, "TEST PASS: Iris Kpathsea module API verified successfully."
  else
    stop 1
  end if
end program test_iris_kpsewhich
