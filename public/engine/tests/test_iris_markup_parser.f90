!===============================================================================
! Program: test_iris_markup_parser
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Automated Regression Test for Iris Markup & Dialect Parser
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
program test_iris_markup_parser
  use, intrinsic :: iso_fortran_env, only: int32
  use iris_markup_parser
  implicit none

  type(parse_result_type) :: parse_ast
  character(len=1024)     :: doc_text
  integer(kind=int32)     :: exit_code

  exit_code = 0

  ! 1. Test troff Markup Dialect Detection
  doc_text = ".TH IRIS 1" // char(10) // &
             ".SH NAME" // char(10) // &
             "iris - Microtypography batch processing system"

  call parse_mixed_markup_text(doc_text, parse_ast)
  if (parse_ast%detected_dialect /= DIALECT_TROFF) then
    print *, "TEST FAIL: troff dialect detection failed"
    exit_code = 1
  end if

  ! 2. Test ConTeXt Dialect Detection
  doc_text = "\starttext" // char(10) // &
             "\startchapter[title={Electromagnetic Field Interaction}]" // char(10) // &
             "\stoptext"

  call parse_mixed_markup_text(doc_text, parse_ast)
  if (parse_ast%detected_dialect /= DIALECT_CONTEXT) then
    print *, "TEST FAIL: ConTeXt dialect detection failed"
    exit_code = 2
  end if

  ! 3. Test LaTeX Dialect Detection
  doc_text = "\documentclass{article}" // char(10) // &
             "\begin{document}" // char(10) // &
             "\section{Unified Field Dynamics}" // char(10) // &
             "\end{document}"

  call parse_mixed_markup_text(doc_text, parse_ast)
  if (parse_ast%detected_dialect /= DIALECT_TEX_LATEX) then
    print *, "TEST FAIL: LaTeX dialect detection failed"
    exit_code = 3
  end if

  ! 4. Test Natural Prose Dialect
  doc_text = "This is a plain prose document for microtypography processing."
  call parse_mixed_markup_text(doc_text, parse_ast)
  if (parse_ast%detected_dialect /= DIALECT_NATURAL_PROSE) then
    print *, "TEST FAIL: Natural prose dialect detection failed"
    exit_code = 4
  end if

  if (exit_code == 0) then
    print *, "TEST PASS: Iris Markup parser module API verified successfully."
  else
    stop 1
  end if
end program test_iris_markup_parser
