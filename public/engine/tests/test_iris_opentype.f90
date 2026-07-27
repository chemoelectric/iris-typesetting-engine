!===============================================================================
! Program: test_iris_opentype
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Automated Regression Test for Iris Binary OpenType Engine
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
program test_iris_opentype
  use, intrinsic :: iso_fortran_env, only: int16, int32
  use iris_opentype
  implicit none

  type(otf_font_type)      :: font
  type(otf_peg_entry_type) :: peg_in, peg_out
  integer(kind=int32)      :: status, exit_code
  character(len=256)       :: name_val
  integer(kind=int16)      :: adv_w, lsb

  exit_code = 0

  ! 1. Initialize OpenType Font Data Structure
  call otf_init_font(font)

  ! 2. Set & Get Name Table Strings
  call otf_set_name_string(font, 1, "Iris Custom Test Font", status)
  if (status /= OTF_OK) then
    print *, "TEST FAIL: otf_set_name_string status"
    exit_code = 1
  end if

  call otf_get_name_string(font, 1, name_val, status)
  if (status /= OTF_OK .or. trim(name_val) /= "Iris Custom Test Font") then
    print *, "TEST FAIL: otf_get_name_string mismatch"
    exit_code = 2
  end if

  ! 3. Add Custom PEGS Table Entry
  peg_in%glyph_id = 65_int16  ! 'A'
  peg_in%left_peg_x = 120_int16
  peg_in%left_peg_y = 500_int16
  peg_in%right_peg_x = 880_int16
  peg_in%right_peg_y = 500_int16

  call otf_add_peg_entry(font, peg_in, status)
  if (status /= OTF_OK) then
    print *, "TEST FAIL: otf_add_peg_entry status"
    exit_code = 3
  end if

  ! 4. Query Peg Entry
  call otf_get_peg_entry(font, 65_int16, peg_out, status)
  if (status /= OTF_OK .or. peg_out%left_peg_x /= 120_int16) then
    print *, "TEST FAIL: otf_get_peg_entry data mismatch"
    exit_code = 4
  end if

  ! 5. Query Glyph Metrics
  call otf_get_glyph_metrics(font, 65_int16, adv_w, lsb, status)
  if (status /= OTF_OK) then
    print *, "TEST FAIL: otf_get_glyph_metrics status"
    exit_code = 5
  end if

  ! 6. Free Font Memory Resources
  call otf_free_font(font)

  if (exit_code == 0) then
    print *, "TEST PASS: Iris OpenType font module API verified successfully."
  else
    stop 1
  end if
end program test_iris_opentype
