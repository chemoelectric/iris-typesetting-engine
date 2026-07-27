!===============================================================================
! Program: kpsewhich_main
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Standalone Kpathsea Search CLI Tool (Installed in pkglibexecdir)
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
program kpsewhich_main
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

  character(len=512)    :: target_file
  character(len=256)    :: format_val
  character(len=1024)   :: resolved_path
  integer(kind=int32)   :: exit_code, cli_stat, pos_cnt, status
  logical               :: is_present

  exit_code = 0
  target_file = ""
  format_val = ""

  call cli_init_parser(parser, "kpsewhich", "Standalone Kpathsea Path Search Engine")

  call cli_add_option(parser, 'f', "format", CLI_REQ_ARG, "FMT", "File format type (e.g. tfm, otf, tex, pdf)")
  call cli_add_option(parser, 'h', "help", CLI_NO_ARG, "", "Display usage options and exit")

  call cli_parse(parser, cli_res)

  if (cli_res%status /= 0) then
    write(*, '(A)') "kpsewhich: argument parsing error: " // trim(cli_res%error_message)
    call cli_print_help(parser, output_unit)
    exit_code = 1
  else
    call cli_has_option(parser, cli_res, "help", is_present)
    if (is_present) then
      call cli_print_help(parser, output_unit)
      exit_code = 0
    else
      call cli_has_option(parser, cli_res, "format", is_present)
      if (is_present) then
        call cli_get_option(parser, cli_res, "format", format_val, cli_stat)
      end if

      call cli_positional_count(cli_res, pos_cnt)
      if (pos_cnt > 0) then
        call cli_get_positional(cli_res, 1, target_file, cli_stat)
        call kpse_search_file(target_file, format_val, resolved_path, status)
        if (status == KPSE_OK) then
          write(*, '(A)') trim(resolved_path)
          exit_code = 0
        else
          write(*, '(A)') "kpsewhich: file not found: " // trim(target_file)
          exit_code = 2
        end if
      else
        write(*, '(A)') "kpsewhich: missing search filename"
        call cli_print_help(parser, output_unit)
        exit_code = 1
      end if
    end if
  end if

  call cli_free(parser, cli_res)

  if (exit_code /= 0) stop 1
end program kpsewhich_main
