!===============================================================================
! Program: iris_main
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Command Line Batch Typographic Compiler for Iris Engine
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
program iris_main
  use, intrinsic :: iso_fortran_env, only: int32, real64, input_unit
  use iris_cli_args, only: cli_parser_type, cli_result_type, &
                           CLI_NO_ARG, CLI_REQ_ARG, &
                           cli_init_parser, cli_add_option, cli_parse, &
                           cli_has_option, cli_get_option, &
                           cli_positional_count, cli_get_positional, &
                           cli_print_help
  use iris_batch_engine, only: batch_config_type, batch_run_report_type, &
                               batch_init_config, batch_process_document, BATCH_OK
  implicit none

  type(cli_parser_type)       :: parser
  type(cli_result_type)       :: cli_res
  type(batch_config_type)     :: cfg
  type(batch_run_report_type) :: report

  character(len=512)          :: out_filename
  character(len=512)          :: in_filename
  character(len=65536)        :: doc_buffer
  character(len=512)          :: line_buf
  character(len=64)           :: font_size_str
  integer(kind=int32)         :: file_unit, io_stat, exit_code
  integer(kind=int32)         :: buf_len
  real(kind=real64)           :: val_size

  exit_code = 0
  out_filename = "output.pdf"
  in_filename = ""
  doc_buffer = ""
  buf_len = 0

  call batch_init_config(cfg)
  call cli_init_parser(parser, "iris", "Iris Typographic Engine - High-Performance Batch Compiler")

  call cli_add_option(parser, 'o', "output", CLI_REQ_ARG, "FILE", "Output PDF document filename (default: output.pdf)")
  call cli_add_option(parser, 'f', "font-size", CLI_REQ_ARG, "POINTS", "Base font size in points (default: 11.0)")
  call cli_add_option(parser, 'h', "help", CLI_NO_ARG, "", "Display command line options and exit")

  call cli_parse(parser, cli_res)

  if (cli_res%status /= 0) then
    write(*, '(A)') "iris: argument parsing error: " // trim(cli_res%error_message)
    call cli_print_help(parser)
    exit_code = 1
  else if (cli_has_option(cli_res, "help")) then
    call cli_print_help(parser)
    exit_code = 0
  else
    if (cli_has_option(cli_res, "output")) then
      call cli_get_option(cli_res, "output", out_filename)
    end if

    if (cli_has_option(cli_res, "font-size")) then
      call cli_get_option(cli_res, "font-size", font_size_str)
      read(font_size_str, *, iostat=io_stat) val_size
      if (io_stat == 0 .and. val_size > 0.0_real64) then
        cfg%font_size = val_size
      end if
    end if

    if (cli_positional_count(cli_res) > 0) then
      call cli_get_positional(cli_res, 1, in_filename)
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
              doc_buffer = trim(doc_buffer) // char(10) // trim(line_buf)
            else
              doc_buffer = trim(line_buf)
            end if
            buf_len = len_trim(doc_buffer)
          end if
        end do
        close(file_unit)
      end if
    else
      ! Read from standard input if no file positional argument provided
      do
        read(input_unit, '(A)', iostat=io_stat) line_buf
        if (io_stat /= 0) exit
        if (len_trim(line_buf) > 0) then
          if (buf_len > 0) then
            doc_buffer = trim(doc_buffer) // char(10) // trim(line_buf)
          else
            doc_buffer = trim(line_buf)
          end if
          buf_len = len_trim(doc_buffer)
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

  if (exit_code /= 0) stop 1
end program iris_main
