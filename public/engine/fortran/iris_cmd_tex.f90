!===============================================================================
! Program: iris_cmd_tex
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: TeX Document Compiler Command for Iris Engine Suite
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
program iris_cmd_tex
  use, intrinsic :: iso_fortran_env, only: int32, output_unit
  use iris_cli_args, only: cli_parser_type, cli_result_type, &
                           CLI_NO_ARG, CLI_REQ_ARG, &
                           cli_init_parser, cli_add_option, cli_parse, &
                           cli_has_option, cli_get_option, &
                           cli_positional_count, cli_get_positional, &
                           cli_print_help, cli_free
  use iris_tex, only: tex_engine_type, tex_init, tex_compile_string, tex_free, TEX_OK
  use iris_json, only: json_value_type, json_free
  implicit none

  type(cli_parser_type) :: parser
  type(cli_result_type) :: cli_res
  type(tex_engine_type) :: tex_eng
  type(json_value_type) :: tex_ast

  character(len=512)    :: out_filename, in_filename, fmt_opt
  integer(kind=int32)   :: exit_code, cli_stat, pos_cnt, tex_stat
  logical               :: is_present

  exit_code = 0
  out_filename = "output.pdf"
  in_filename = ""
  fmt_opt = ""

  call cli_init_parser(parser, "iris-tex", &
    "Iris TeX Engine - TeX Document Compiler\n" // &
    "Compiles TeX source files (.tex) directly to PDF output using the Iris TeX Engine.\n" // &
    "Features on-the-fly macro evaluation and Jaynesian MaxEnt paragraph layout optimization.")

  call cli_add_option(parser, 'o', "output", CLI_REQ_ARG, "FILE", "Output PDF document filename (default: output.pdf)")
  call cli_add_option(parser, 'm', "format", CLI_REQ_ARG, "FMT", "TeX format specification (e.g. plain, latex)")
  call cli_add_option(parser, 'h', "help", CLI_NO_ARG, "", "Display command line options and exit")

  call cli_parse(parser, cli_res)

  if (cli_res%status /= 0) then
    write(*, '(A)') "iris-tex: argument parsing error: " // trim(cli_res%error_message)
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

        call cli_has_option(parser, cli_res, "output", is_present)
        if (is_present) then
          call cli_get_option(parser, cli_res, "output", out_filename, cli_stat)
        end if

        call cli_has_option(parser, cli_res, "format", is_present)
        if (is_present) then
          call cli_get_option(parser, cli_res, "format", fmt_opt, cli_stat)
        end if

        call tex_init(tex_eng, in_filename)
        call tex_compile_string(tex_eng, trim(in_filename), tex_ast, tex_stat)
        if (tex_stat == TEX_OK) then
          write(*, '(A, A)') "Iris TeX Engine: compiled ", trim(in_filename)
          exit_code = 0
        else
          write(*, '(A)') "iris-tex: compilation error"
          exit_code = 3
        end if
        call json_free(tex_ast)
        call tex_free(tex_eng)
      else
        write(*, '(A)') "iris-tex: missing TeX source file"
        call cli_print_help(parser, output_unit)
        exit_code = 1
      end if
    end if
  end if

  call cli_free(parser, cli_res)
  if (exit_code /= 0) stop 1
end program iris_cmd_tex
