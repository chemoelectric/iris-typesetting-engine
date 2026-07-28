!===============================================================================
! Program: iris_cmd_trip
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: TRIP Benchmark Diagnostic Command for Iris Engine Suite
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
program iris_cmd_trip
  use, intrinsic :: iso_fortran_env, only: int32, output_unit
  use iris_cli_args, only: cli_parser_type, cli_result_type, &
                           CLI_NO_ARG, &
                           cli_init_parser, cli_add_option, cli_parse, &
                           cli_has_option, cli_print_help, cli_free
  use iris_tex, only: tex_run_trip_test, TEX_OK
  implicit none

  type(cli_parser_type) :: parser
  type(cli_result_type) :: cli_res

  character(len=256)    :: trip_msg
  integer(kind=int32)   :: exit_code, tex_stat
  logical               :: is_present

  exit_code = 0

  call cli_init_parser(parser, "iris-trip", &
    "Iris TeX Engine - TRIP Benchmark Diagnostic Suite\n" // &
    "Executes the TeX TRIP diagnostic test suite to validate internal TeX parser correctness,\n" // &
    "register state, and mathematical typesetting engine accuracy against Knuthian standards.")

  call cli_add_option(parser, 'h', "help", CLI_NO_ARG, "", "Display command line options and exit")

  call cli_parse(parser, cli_res)

  if (cli_res%status /= 0) then
    write(*, '(A)') "iris-trip: argument parsing error: " // trim(cli_res%error_message)
    call cli_print_help(parser, output_unit)
    exit_code = 1
  else
    call cli_has_option(parser, cli_res, "help", is_present)
    if (is_present) then
      call cli_print_help(parser, output_unit)
      exit_code = 0
    else
      call tex_run_trip_test(tex_stat, trip_msg)
      if (tex_stat == TEX_OK) then
        write(*, '(A)') "Iris TeX Engine [TRIP Benchmark Suite]: " // trim(trip_msg)
        exit_code = 0
      else
        write(*, '(A)') "iris-trip: TRIP benchmark diagnostic failure"
        exit_code = 4
      end if
    end if
  end if

  call cli_free(parser, cli_res)
  if (exit_code /= 0) stop 1
end program iris_cmd_trip
