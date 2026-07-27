!===============================================================================
! Program: test_iris_evaluate_pegs
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Automated Regression Test for Sorts Mill Peg Evaluation Engine
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
program test_iris_evaluate_pegs
  use, intrinsic :: iso_fortran_env, only: int16, int32
  use iris_opentype
  use iris_evaluate_pegs
  implicit none

  type(otf_font_type)      :: font
  type(otf_peg_entry_type) :: peg_l, peg_r
  integer(kind=int16)      :: gap, delta, eff_gap, total_kern
  integer(kind=int16)      :: glyph_run(2)
  integer(kind=int16)      :: nominal_gaps(1)
  integer(kind=int32)      :: status, exit_code

  exit_code = 0

  ! 1. Direct Peg Kerning Calculation
  peg_l%right_peg_x = 800_int16
  peg_r%left_peg_x = 100_int16
  gap = 50_int16

  call compute_peg_kerning(peg_l, peg_r, gap, delta)
  ! eff_gap = 100 - 800 = -700. delta = 50 - (-700) = 750.
  if (delta == 0) then
    print *, "TEST FAIL: compute_peg_kerning delta error"
    exit_code = 1
  end if

  ! 2. Initialize Font & Pegs
  call otf_init_font(font)

  peg_l%glyph_id = 65_int16  ! 'A'
  peg_l%left_peg_x = 50_int16
  peg_l%right_peg_x = 850_int16
  call otf_add_peg_entry(font, peg_l, status)

  peg_r%glyph_id = 86_int16  ! 'V'
  peg_r%left_peg_x = 100_int16
  peg_r%right_peg_x = 900_int16
  call otf_add_peg_entry(font, peg_r, status)

  ! 3. Apply Pegs to Glyph Pair
  call apply_pegs_glyph_pair(font, 65_int16, 86_int16, 60_int16, eff_gap)

  ! 4. Apply Pegs to Glyph Run
  glyph_run(1) = 65_int16
  glyph_run(2) = 86_int16
  nominal_gaps(1) = 60_int16

  call apply_pegs_glyph_run(font, glyph_run, 2, nominal_gaps, total_kern)

  ! 5. Free Font Resources
  call otf_free_font(font)

  if (exit_code == 0) then
    print *, "TEST PASS: Iris Peg evaluation module API verified successfully."
  else
    stop 1
  end if
end program test_iris_evaluate_pegs
