!===============================================================================
! Program: iris_main
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Unified Command Line Interface for Iris Engine Suite
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
program iris_main
  use, intrinsic :: iso_fortran_env, only: int32, real64, input_unit, output_unit
  use iris_cli_args, only: cli_parser_type, cli_result_type, &
                           CLI_NO_ARG, CLI_REQ_ARG, &
                           cli_init_parser, cli_add_option, cli_add_mode, cli_parse, &
                           cli_has_option, cli_get_option, &
                           cli_positional_count, cli_get_positional, &
                           cli_print_help, cli_free
  use iris_batch_engine, only: batch_config_type, batch_run_report_type, &
                               batch_init_config, batch_process_document, BATCH_OK
  use iris_kpsewhich, only: kpse_search_file, KPSE_OK
  use iris_tex, only: tex_engine_type, tex_init, tex_compile_string, tex_run_trip_test, tex_free, TEX_OK
  use iris_json, only: json_value_type, json_free
  use iris_dynamic_string, only: append_string_buffer
  implicit none

  type(cli_parser_type)       :: parser
  type(cli_result_type)       :: cli_res
  type(batch_config_type)     :: cfg
  type(batch_run_report_type) :: report
  type(tex_engine_type)       :: tex_eng
  type(json_value_type)       :: tex_ast

  character(len=512)          :: out_filename
  character(len=512)          :: in_filename
  character(len=512)          :: subcommand
  character(len=512)          :: fmt_opt
  character(len=:), allocatable :: doc_buffer
  character(len=2048)         :: line_buf
  character(len=64)           :: font_size_str
  character(len=1024)         :: resolved_path
  character(len=256)          :: trip_msg
  integer(kind=int32)         :: file_unit, io_stat, exit_code, cli_stat, pos_cnt
  integer(kind=int32)         :: buf_len, kpse_stat, tex_stat
  real(kind=real64)           :: val_size
  logical                     :: is_present

  exit_code = 0
  out_filename = "output.pdf"
  in_filename = ""
  subcommand = ""
  allocate(character(len=4096) :: doc_buffer)
  doc_buffer = ""
  buf_len = 0

  call batch_init_config(cfg)
  call cli_init_parser(parser, "iris", "Iris Typographic Engine - Unified Command System")

  call cli_add_mode(parser, "tex", "<file>", "Compile TeX document using Iris TeX Engine")
  call cli_add_mode(parser, "kpsewhich", "<file>", "Search TeX path or format for file location")
  call cli_add_mode(parser, "trip", "", "Run TRIP benchmark diagnostic suite")
  call cli_add_mode(parser, "[file]", "", "Compile Iris markup or prose file to PDF (default mode)")

  call cli_add_option(parser, 'o', "output", CLI_REQ_ARG, "FILE", "Output PDF document filename (default: output.pdf)")
  call cli_add_option(parser, 'f', "font-size", CLI_REQ_ARG, "POINTS", "Base font size in points (default: 11.0)")
  call cli_add_option(parser, 'm', "format", CLI_REQ_ARG, "FMT", "Format specification for kpsewhich/tex mode")
  call cli_add_option(parser, 'h', "help", CLI_NO_ARG, "", "Display command line options and exit")

  call cli_parse(parser, cli_res)

  if (cli_res%status /= 0) then
    write(*, '(A)') "iris: argument parsing error: " // trim(cli_res%error_message)
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
        call cli_get_positional(cli_res, 1, subcommand, cli_stat)
      end if

      if (trim(subcommand) == "kpsewhich") then
        ! Unified kpsewhich subcommand dispatch
        if (pos_cnt > 1) then
          call cli_get_positional(cli_res, 2, in_filename, cli_stat)
          fmt_opt = ""
          call cli_has_option(parser, cli_res, "format", is_present)
          if (is_present) then
            call cli_get_option(parser, cli_res, "format", fmt_opt, cli_stat)
          end if
          call kpse_search_file(in_filename, fmt_opt, resolved_path, kpse_stat)
          if (kpse_stat == KPSE_OK) then
            write(*, '(A)') trim(resolved_path)
            exit_code = 0
          else
            write(*, '(A)') "iris kpsewhich: file not found: " // trim(in_filename)
            exit_code = 2
          end if
        else
          write(*, '(A)') "iris kpsewhich: missing target filename"
          exit_code = 1
        end if
      else if (trim(subcommand) == "tex") then
        ! Unified TeX compilation subcommand dispatch
        if (pos_cnt > 1) then
          call cli_get_positional(cli_res, 2, in_filename, cli_stat)
          call tex_init(tex_eng, in_filename)
          call tex_compile_string(tex_eng, trim(in_filename), tex_ast, tex_stat)
          if (tex_stat == TEX_OK) then
            write(*, '(A, A)') "Iris TeX Engine: compiled ", trim(in_filename)
            exit_code = 0
          else
            write(*, '(A)') "iris tex: compilation error"
            exit_code = 3
          end if
          call json_free(tex_ast)
          call tex_free(tex_eng)
        else
          write(*, '(A)') "iris tex: missing TeX source file"
          exit_code = 1
        end if
      else if (trim(subcommand) == "trip") then
        ! Unified TRIP benchmark diagnostic test dispatch
        call tex_run_trip_test(tex_stat, trip_msg)
        if (tex_stat == TEX_OK) then
          write(*, '(A)') "Iris TeX Engine [TRIP Benchmark Suite]: " // trim(trip_msg)
          exit_code = 0
        else
          write(*, '(A)') "iris trip: TRIP benchmark diagnostic failure"
          exit_code = 4
        end if
      else
        ! Standard document processing route
        call cli_has_option(parser, cli_res, "output", is_present)
        if (is_present) then
          call cli_get_option(parser, cli_res, "output", out_filename, cli_stat)
        end if

        call cli_has_option(parser, cli_res, "font-size", is_present)
        if (is_present) then
          call cli_get_option(parser, cli_res, "font-size", font_size_str, cli_stat)
          read(font_size_str, *, iostat=io_stat) val_size
          if (io_stat == 0 .and. val_size > 0.0_real64) then
            cfg%font_size = val_size
          end if
        end if

        if (pos_cnt > 0) then
          in_filename = subcommand
          open(newunit=file_unit, file=trim(in_filename), status='old', action='read', iostat=io_stat)
          if (io_stat /= 0) then
            write(*, '(A)') "iris: cannot open input file: " // trim(in_filename)
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
          if (buf_len == 0) then
            doc_buffer = "[markup: prose] Empty document."
          end if

          call batch_process_document(doc_buffer, out_filename, cfg, report)

          if (report%status /= BATCH_OK .and. report%status /= 1) then
            write(*, '(A, A)') "iris: compilation error: ", trim(report%status_msg)
            exit_code = 3
          else
            write(*, '(A, A)') "Iris Batch Engine: Successfully compiled document to ", trim(out_filename)
          end if
        end if
      end if
    end if
  end if

  call cli_free(parser, cli_res)

  if (exit_code /= 0) stop 1
end program iris_main
