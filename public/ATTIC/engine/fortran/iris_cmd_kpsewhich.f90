!===============================================================================
! Program: iris_cmd_kpsewhich
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Kpathsea File Resolver Command for Iris Engine Suite
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
program iris_cmd_kpsewhich
  use, intrinsic :: iso_fortran_env, only: int32, output_unit
  use iris_cli_args, only: cli_parser_type, cli_result_type, &
                           CLI_NO_ARG, CLI_REQ_ARG, &
                           cli_init_parser, cli_add_option, cli_parse, &
                           cli_has_option, cli_get_option, &
                           cli_positional_count, cli_get_positional, &
                           cli_print_help, cli_free
  use iris_kpsewhich, only: kpse_search_file, KPSE_OK
  implicit none

  type(cli_parser_type) :: parser
  type(cli_result_type) :: cli_res

  character(len=512)    :: in_filename, fmt_opt
  character(len=1024)   :: resolved_path
  integer(kind=int32)   :: exit_code, cli_stat, pos_cnt, kpse_stat
  logical               :: is_present

  exit_code = 0
  in_filename = ""
  fmt_opt = ""

  call cli_init_parser(parser, "iris-kpsewhich", &
    "Iris TeX Engine - Kpathsea File Resolver\n" // &
    "Searches TeX directory structure and system TeX Live installation for specified\n" // &
    "font metrics (.tfm), macro packages (.tex, .cls, .sty), or format files (.fmt).")

  call cli_add_option(parser, 'm', "format", CLI_REQ_ARG, "FMT", "Format specification for kpsewhich search mode")
  call cli_add_option(parser, 'h', "help", CLI_NO_ARG, "", "Display command line options and exit")

  call cli_parse(parser, cli_res)

  if (cli_res%status /= 0) then
    write(*, '(A)') "iris-kpsewhich: argument parsing error: " // trim(cli_res%error_message)
    call cli_print_help(parser, output_unit)
    exit_code = 1
  else
    call cli_has_option(parser, cli_res, "help", is_present)
    if (is_present) then
      call cli_print_help(parser, output_unit)
      exit_code = 0
    else
      call cli_positional_count(cli_res, pos_cnt)
      if (pos_cnt > 0) then
        call cli_get_positional(cli_res, 1, in_filename, cli_stat)

        call cli_has_option(parser, cli_res, "format", is_present)
        if (is_present) then
          call cli_get_option(parser, cli_res, "format", fmt_opt, cli_stat)
        end if

        call kpse_search_file(in_filename, fmt_opt, resolved_path, kpse_stat)
        if (kpse_stat == KPSE_OK) then
          write(*, '(A)') trim(resolved_path)
          exit_code = 0
        else
          write(*, '(A)') "iris-kpsewhich: file not found: " // trim(in_filename)
          exit_code = 2
        end if
      else
        write(*, '(A)') "iris-kpsewhich: missing target filename"
        call cli_print_help(parser, output_unit)
        exit_code = 1
      end if
    end if
  end if

  call cli_free(parser, cli_res)
  if (exit_code /= 0) stop 1
end program iris_cmd_kpsewhich
