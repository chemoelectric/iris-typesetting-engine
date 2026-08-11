!===============================================================================
! Program: test_iris_cli_args
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Automated Regression Test for Iris CLI Specification Engine
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
program test_iris_cli_args
  use, intrinsic :: iso_fortran_env, only: int32
  use iris_cli_args
  implicit none

  type(cli_parser_type) :: parser
  type(cli_result_type) :: result
  integer(kind=int32)   :: exit_code, status
  logical               :: has_opt
  character(len=256)    :: val_out

  exit_code = 0

  ! 1. Initialize Parser
  call cli_init_parser(parser, "iris", "Batch Typographic Microtypography Engine")

  ! 2. Add Options
  call cli_add_option(parser, 'o', "output", CLI_REQ_ARG, "Output PDF file path", "FILE")
  call cli_add_option(parser, 'v', "verbose", CLI_NO_ARG, "Verbose logging mode", "")
  call cli_add_option(parser, 'f', "font-size", CLI_OPT_ARG, "Font size in points", "SIZE")

  ! 3. Verify Spec Count
  if (parser%spec_count /= 3) then
    print *, "TEST FAIL: Option specification count mismatch"
    exit_code = 1
  end if

  ! 4. Parse Command Line Arguments
  call cli_parse(parser, result)

  ! Note: when run without arguments, status should be 0 and positional/option count recorded
  if (result%status /= 0) then
    print *, "TEST FAIL: cli_parse returned non-zero status"
    exit_code = 2
  end if

  ! 5. Test Inspector Defaults
  call cli_has_option(parser, result, "output", has_opt)
  if (has_opt) then
    call cli_get_option(parser, result, "output", val_out, status)
  end if

  ! 6. Free Resources
  call cli_free(result)

  if (exit_code == 0) then
    print *, "TEST PASS: Iris CLI arguments module API verified successfully."
  else
    stop 1
  end if
end program test_iris_cli_args
