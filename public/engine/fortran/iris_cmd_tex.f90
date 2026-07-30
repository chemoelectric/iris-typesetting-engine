!===============================================================================
! Program: iris_cmd_tex
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: TeX Document Compiler Command for Iris Engine Suite
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
program iris_cmd_tex
  use, intrinsic :: iso_fortran_env, only: int32, input_unit, output_unit
  use iris_cli_args, only: cli_parser_type, cli_result_type, &
                           CLI_NO_ARG, CLI_REQ_ARG, &
                           cli_init_parser, cli_add_option, cli_parse, &
                           cli_has_option, cli_get_option, &
                           cli_positional_count, cli_get_positional, &
                           cli_print_help, cli_free
  use iris_tex, only: tex_engine_type, tex_init, tex_compile_string, tex_free, TEX_OK
  use iris_batch_engine, only: batch_config_type, batch_run_report_type, &
                               batch_init_config, batch_process_document, &
                               batch_process_dvi, BATCH_OK
  use iris_dynamic_string, only: append_string_buffer
  use iris_json, only: json_value_type, json_free
  implicit none

  type(cli_parser_type)         :: parser
  type(cli_result_type)         :: cli_res
  type(tex_engine_type)         :: tex_eng
  type(json_value_type)         :: tex_ast
  type(batch_config_type)       :: batch_cfg
  type(batch_run_report_type)   :: batch_report

  character(len=512)            :: out_filename, in_filename, fmt_opt, out_fmt
  character(len=:), allocatable :: doc_buffer
  character(len=2048)           :: line_buf
  integer(kind=int32)           :: exit_code, cli_stat, pos_cnt, tex_stat, o_len
  integer(kind=int32)           :: file_unit, io_stat, buf_len
  logical                       :: is_present, use_dvi_mode

  exit_code = 0
  out_filename = "output.pdf"
  in_filename = ""
  fmt_opt = ""
  out_fmt = ""
  use_dvi_mode = .false.
  buf_len = 0

  call batch_init_config(batch_cfg)

  call cli_init_parser(parser, "iris-tex", &
    "Iris TeX Engine - TeX Document Compiler\n" // &
    "Compiles TeX source files (.tex) to PDF or DVI output using the Iris TeX Engine.\n" // &
    "Features on-the-fly macro evaluation and Jaynesian MaxEnt paragraph layout optimization.")

  call cli_add_option(parser, 'o', "output", CLI_REQ_ARG, "FILE", "Output document filename (default: output.pdf or output.dvi)")
  call cli_add_option(parser, 'm', "format", CLI_REQ_ARG, "FMT", "TeX format specification (e.g. plain, latex)")
  call cli_add_option(parser, 'f', "output-format", CLI_REQ_ARG, "FMT", "Output format: pdf or dvi")
  call cli_add_option(parser, 'd', "dvi", CLI_NO_ARG, "", "Produce DVI output format instead of PDF")
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
      call cli_has_option(parser, cli_res, "output", is_present)
      if (is_present) then
        call cli_get_option(parser, cli_res, "output", out_filename, cli_stat)
      end if

      call cli_has_option(parser, cli_res, "format", is_present)
      if (is_present) then
        call cli_get_option(parser, cli_res, "format", fmt_opt, cli_stat)
      end if

      call cli_has_option(parser, cli_res, "output-format", is_present)
      if (is_present) then
        call cli_get_option(parser, cli_res, "output-format", out_fmt, cli_stat)
      end if

      call cli_has_option(parser, cli_res, "dvi", is_present)
      if (is_present .or. trim(out_fmt) == "dvi") then
        use_dvi_mode = .true.
      end if

      o_len = len_trim(out_filename)
      if (o_len >= 4) then
        if (out_filename(o_len-3:o_len) == ".dvi") use_dvi_mode = .true.
      end if

      call cli_positional_count(cli_res, pos_cnt)
      if (pos_cnt > 0) then
        call cli_get_positional(cli_res, 1, in_filename, cli_stat)
        open(newunit=file_unit, file=trim(in_filename), status='old', action='read', iostat=io_stat)
        if (io_stat /= 0) then
          write(*, '(A)') "iris-tex: cannot open input file: " // trim(in_filename)
          exit_code = 2
        else
          do
            read(file_unit, '(A)', iostat=io_stat) line_buf
            if (io_stat /= 0) exit
            if (len_trim(line_buf) > 0) then
              if (buf_len > 0) then
                call append_string_buffer(doc_buffer, buf_len, char(10) // trim(line_buf))
              else
                call append_string_buffer(doc_buffer, buf_len, trim(line_buf))
              end if
            end if
          end do
          close(file_unit)
        end if
      else
        ! Read standard input
        do
          read(input_unit, '(A)', iostat=io_stat) line_buf
          if (io_stat /= 0) exit
          if (len_trim(line_buf) > 0) then
            if (buf_len > 0) then
              call append_string_buffer(doc_buffer, buf_len, char(10) // trim(line_buf))
            else
              call append_string_buffer(doc_buffer, buf_len, trim(line_buf))
            end if
          end if
        end do
      end if

      if (exit_code == 0) then
        if (buf_len > 0) then
          doc_buffer = doc_buffer(1:buf_len)
        else
          doc_buffer = "\hello world"
        end if

        call tex_init(tex_eng, in_filename)
        call tex_compile_string(tex_eng, doc_buffer, tex_ast, tex_stat)

        if (use_dvi_mode) then
          call batch_process_dvi(doc_buffer, out_filename, batch_cfg, batch_report)
        else
          call batch_process_document(doc_buffer, out_filename, batch_cfg, batch_report)
        end if

        if (tex_stat == TEX_OK .and. (batch_report%status == BATCH_OK .or. batch_report%status == 1)) then
          if (len_trim(in_filename) > 0) then
            write(*, '(A, A, A, A)') "Iris TeX Engine: Successfully compiled ", trim(in_filename), " -> ", trim(out_filename)
          else
            write(*, '(A, A)') "Iris TeX Engine: Successfully compiled stdin -> ", trim(out_filename)
          end if
          exit_code = 0
        else
          write(*, '(A)') "iris-tex: compilation error"
          exit_code = 3
        end if

        call json_free(tex_ast)
        call tex_free(tex_eng)
      end if
    end if
  end if

  call cli_free(parser, cli_res)
  if (exit_code /= 0) stop 1
end program iris_cmd_tex
