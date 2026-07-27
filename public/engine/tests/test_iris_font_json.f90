!===============================================================================
! Program: test_iris_font_json
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Automated Regression Test for OpenType JSON AST Serialization
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
program test_iris_font_json
  use, intrinsic :: iso_fortran_env, only: int16, int32
  use iris_opentype
  use iris_json
  use iris_font_json
  implicit none

  type(otf_font_type)      :: font_in, font_out
  type(json_value_type)    :: json_ast
  type(otf_peg_entry_type) :: peg
  character(len=4096)      :: json_text
  integer(kind=int32)      :: status, exit_code

  exit_code = 0

  ! 1. Initialize & Populate Sample OpenType Font
  call otf_init_font(font_in)
  call otf_set_name_string(font_in, 1, "Iris Font JSON Bridge", status)

  peg%glyph_id = 66_int16  ! 'B'
  peg%left_peg_x = 100_int16
  peg%left_peg_y = 400_int16
  peg%right_peg_x = 750_int16
  peg%right_peg_y = 400_int16
  call otf_add_peg_entry(font_in, peg, status)

  ! 2. Convert OTF to JSON AST Object
  call otf_to_json(font_in, json_ast)
  if (json_get_type(json_ast) /= JSON_OBJ_TYPE) then
    print *, "TEST FAIL: otf_to_json did not produce JSON Object"
    exit_code = 1
  end if

  ! 3. Serialize OTF to JSON Text String
  call otf_serialize_json(font_in, json_text)
  if (len_trim(json_text) == 0 .or. index(json_text, "unitsPerEm") == 0) then
    print *, "TEST FAIL: otf_serialize_json string empty or missing schema keys"
    exit_code = 2
  end if

  ! 4. Convert JSON AST Object back to OTF Structure
  call json_to_otf(json_ast, font_out)
  if (font_out%head%units_per_em /= font_in%head%units_per_em) then
    print *, "TEST FAIL: Round-trip unitsPerEm mismatch"
    exit_code = 3
  end if

  ! 5. Free Resources
  call json_free(json_ast)
  call otf_free_font(font_in)
  call otf_free_font(font_out)

  if (exit_code == 0) then
    print *, "TEST PASS: Iris OpenType JSON bridge module API verified successfully."
  else
    stop 1
  end if
end program test_iris_font_json
