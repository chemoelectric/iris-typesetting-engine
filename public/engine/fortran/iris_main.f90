!===============================================================================
! Program: iris_main
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Unified Command Line Dispatcher for Iris Engine Suite
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
program iris_main
  use, intrinsic :: iso_fortran_env, only: int32, output_unit
  use iris_cli_args, only: cli_parser_type, cli_result_type, &
                           CLI_NO_ARG, CLI_REQ_ARG, &
                           cli_init_parser, cli_add_option, cli_add_mode, cli_parse, &
                           cli_has_option, cli_get_option, &
                           cli_positional_count, cli_get_positional, &
                           cli_print_help, cli_free
  implicit none

  type(cli_parser_type) :: parser
  type(cli_result_type) :: cli_res

  character(len=2048)   :: cmd_line, mode_name, arg_tmp
  integer(kind=int32)   :: arg_cnt, exit_code, cli_stat, pos_cnt
  logical               :: is_present

  exit_code = 0
  cmd_line = ""
  mode_name = ""
  arg_tmp = ""

  call cli_init_parser(parser, "iris", "Iris Typographic Engine - Unified Command System")

  call cli_add_mode(parser, "tex", "<file>", &
    "Compile TeX document using iris-tex", &
    "Dispatches to iris-tex to compile TeX source files (.tex) directly to PDF output.")

  call cli_add_mode(parser, "kpsewhich", "<file>", &
    "Search TeX path or format for file location using iris-kpsewhich", &
    "Dispatches to iris-kpsewhich to search TeX directory structure for specified files.")

  call cli_add_mode(parser, "trip", "", &
    "Run TRIP benchmark diagnostic suite using iris-trip", &
    "Dispatches to iris-trip to execute the TeX TRIP diagnostic test suite.")

  call cli_add_mode(parser, "compile", "[file]", &
    "Compile Iris markup or prose file to PDF using iris-compile", &
    "Dispatches to iris-compile to process Iris markup prose into typeset PDF documents.")

  call cli_add_option(parser, 'o', "output", CLI_REQ_ARG, "FILE", "Output PDF document filename (default: output.pdf)")
  call cli_add_option(parser, 'f', "font-size", CLI_REQ_ARG, "POINTS", "Base font size in points (default: 11.0)")
  call cli_add_option(parser, 'm', "format", CLI_REQ_ARG, "FMT", "Format specification")
  call cli_add_option(parser, 'h', "help", CLI_NO_ARG, "", "Display command line options and exit")

  call cli_parse(parser, cli_res)

  arg_cnt = command_argument_count()

  if (arg_cnt == 0) then
    call cli_print_help(parser, output_unit)
    exit_code = 0
  else
    call cli_positional_count(cli_res, pos_cnt)
    if (pos_cnt > 0) then
      call cli_get_positional(cli_res, 1, mode_name, cli_stat)
    end if

    call cli_has_option(parser, cli_res, "help", is_present)

    if (is_present .and. pos_cnt == 0) then
      call cli_print_help(parser, output_unit)
      exit_code = 0
    else if (trim(mode_name) == "help") then
      if (pos_cnt > 1) then
        call cli_get_positional(cli_res, 2, arg_tmp, cli_stat)
        cmd_line = "iris-" // trim(arg_tmp) // " --help"
        call execute_command_line(trim(cmd_line), exitstat=exit_code)
      else
        call cli_print_help(parser, output_unit)
        exit_code = 0
      end if
    else if (trim(mode_name) == "tex") then
      call build_forward_args(2, cmd_line)
      cmd_line = "iris-tex " // trim(cmd_line)
      call execute_command_line(trim(cmd_line), exitstat=exit_code)
    else if (trim(mode_name) == "kpsewhich") then
      call build_forward_args(2, cmd_line)
      cmd_line = "iris-kpsewhich " // trim(cmd_line)
      call execute_command_line(trim(cmd_line), exitstat=exit_code)
    else if (trim(mode_name) == "trip") then
      call build_forward_args(2, cmd_line)
      cmd_line = "iris-trip " // trim(cmd_line)
      call execute_command_line(trim(cmd_line), exitstat=exit_code)
    else if (trim(mode_name) == "compile") then
      call build_forward_args(2, cmd_line)
      cmd_line = "iris-compile " // trim(cmd_line)
      call execute_command_line(trim(cmd_line), exitstat=exit_code)
    else
      ! Default dispatch: compile mode
      call build_forward_args(1, cmd_line)
      cmd_line = "iris-compile " // trim(cmd_line)
      call execute_command_line(trim(cmd_line), exitstat=exit_code)
    end if
  end if

  call cli_free(parser, cli_res)
  if (exit_code /= 0) stop 1

contains

  subroutine build_forward_args(start_idx, out_str)
    integer(kind=int32), intent(in) :: start_idx
    character(len=*), intent(out)   :: out_str
    integer(kind=int32)             :: k, total
    character(len=512)              :: token

    out_str = ""
    total = command_argument_count()
    do k = start_idx, total
      call get_command_argument(k, token)
      if (len_trim(out_str) > 0) then
        out_str = trim(out_str) // " " // trim(token)
      else
        out_str = trim(token)
      end if
    end do
  end subroutine build_forward_args

end program iris_main

