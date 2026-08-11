!===============================================================================
! Module: iris_cli_args
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Declarative Specification-Driven Command Line Argument Parser
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
module iris_cli_args
  use, intrinsic :: iso_fortran_env, only: int32
  implicit none
  private

  ! Public Parameter Constants for Option Argument Expectations
  integer(kind=int32), parameter, public :: CLI_NO_ARG  = 0
  integer(kind=int32), parameter, public :: CLI_REQ_ARG = 1
  integer(kind=int32), parameter, public :: CLI_OPT_ARG = 2

  ! Public Derived Types
  public :: cli_option_spec_type
  public :: cli_mode_spec_type
  public :: cli_parser_type
  public :: cli_result_type

  ! Public API Procedures
  public :: cli_init_parser
  public :: cli_add_option
  public :: cli_add_mode
  public :: cli_parse
  public :: cli_has_option
  public :: cli_get_option
  public :: cli_option_count
  public :: cli_positional_count
  public :: cli_get_positional
  public :: cli_print_help
  public :: cli_print_mode_help

  interface cli_free
    module procedure cli_free_parser
    module procedure cli_free_result
    module procedure cli_free_both
  end interface cli_free
  public :: cli_free

  integer(kind=int32), parameter :: MAX_OPTS  = 64
  integer(kind=int32), parameter :: MAX_MODES = 16
  integer(kind=int32), parameter :: MAX_ARGS  = 256
  integer(kind=int32), parameter :: STR_LEN   = 256

  type :: cli_option_spec_type
    character(len=1)       :: short_flag = ' '
    character(len=STR_LEN) :: long_flag  = ''
    integer(kind=int32)    :: arg_mode   = CLI_NO_ARG
    character(len=STR_LEN) :: help_text  = ''
    character(len=64)      :: value_name = ''
  end type cli_option_spec_type

  type :: cli_mode_spec_type
    character(len=64)      :: mode_name     = ''
    character(len=STR_LEN) :: mode_args     = ''
    character(len=STR_LEN) :: help_text     = ''
    character(len=1024)    :: detailed_help = ''
  end type cli_mode_spec_type

  type :: cli_parsed_opt_node
    integer(kind=int32)    :: spec_index = 0
    character(len=STR_LEN) :: value      = ''
  end type cli_parsed_opt_node

  type :: cli_parser_type
    type(cli_option_spec_type) :: specs(MAX_OPTS)
    integer(kind=int32)        :: spec_count = 0
    type(cli_mode_spec_type)   :: modes(MAX_MODES)
    integer(kind=int32)        :: mode_count = 0
    character(len=STR_LEN)     :: program_name = ''
    character(len=STR_LEN)     :: description = ''
  end type cli_parser_type

  type :: cli_result_type
    type(cli_parsed_opt_node) :: parsed_opts(MAX_ARGS)
    integer(kind=int32)       :: parsed_opt_count = 0
    character(len=STR_LEN)    :: positionals(MAX_ARGS)
    integer(kind=int32)       :: positional_count = 0
    integer(kind=int32)       :: status = 0 ! 0 = OK, -1 = Error
    character(len=STR_LEN)    :: error_message = ''
  end type cli_result_type

contains

  !-----------------------------------------------------------------------------
  ! Initialize a parser structure with program metadata
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine cli_init_parser(parser, program_name, description)
    type(cli_parser_type), intent(out) :: parser
    character(len=*), intent(in)       :: program_name
    character(len=*), intent(in)       :: description

    parser%spec_count = 0
    parser%mode_count = 0
    parser%program_name = trim(adjustl(program_name))
    parser%description = trim(adjustl(description))
  end subroutine cli_init_parser

  !-----------------------------------------------------------------------------
  ! Register an option specification in the parser
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine cli_add_option(parser, short_flag, long_flag, arg_mode, value_name, help_text)
    type(cli_parser_type), intent(inout) :: parser
    character(len=1), intent(in)         :: short_flag
    character(len=*), intent(in)         :: long_flag
    integer(kind=int32), intent(in)      :: arg_mode
    character(len=*), intent(in)         :: value_name
    character(len=*), intent(in)         :: help_text

    integer(kind=int32) :: idx

    if (parser%spec_count < MAX_OPTS) then
      parser%spec_count = parser%spec_count + 1
      idx = parser%spec_count
      parser%specs(idx)%short_flag = short_flag
      parser%specs(idx)%long_flag  = trim(adjustl(long_flag))
      parser%specs(idx)%arg_mode   = arg_mode
      parser%specs(idx)%value_name = trim(adjustl(value_name))
      parser%specs(idx)%help_text  = trim(adjustl(help_text))
    end if
  end subroutine cli_add_option

  !-----------------------------------------------------------------------------
  ! Register a mode / subcommand specification in the parser
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine cli_add_mode(parser, mode_name, mode_args, help_text, detailed_help)
    type(cli_parser_type), intent(inout)   :: parser
    character(len=*), intent(in)           :: mode_name
    character(len=*), intent(in)           :: mode_args
    character(len=*), intent(in)           :: help_text
    character(len=*), intent(in), optional :: detailed_help

    integer(kind=int32) :: idx

    if (parser%mode_count < MAX_MODES) then
      parser%mode_count = parser%mode_count + 1
      idx = parser%mode_count
      parser%modes(idx)%mode_name = trim(adjustl(mode_name))
      parser%modes(idx)%mode_args = trim(adjustl(mode_args))
      parser%modes(idx)%help_text = trim(adjustl(help_text))
      if (present(detailed_help)) then
        parser%modes(idx)%detailed_help = trim(adjustl(detailed_help))
      else
        parser%modes(idx)%detailed_help = ''
      end if
    end if
  end subroutine cli_add_mode

  !-----------------------------------------------------------------------------
  ! Helper: Match long flag name to spec index
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  function find_long_spec(parser, flag_str) result(match_idx)
    type(cli_parser_type), intent(in) :: parser
    character(len=*), intent(in)      :: flag_str
    integer(kind=int32)               :: match_idx
    integer(kind=int32)               :: i

    match_idx = 0
    do i = 1, parser%spec_count
      if (trim(parser%specs(i)%long_flag) == trim(flag_str)) then
        match_idx = i
        exit
      end if
    end do
  end function find_long_spec

  !-----------------------------------------------------------------------------
  ! Helper: Match short flag char to spec index
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  function find_short_spec(parser, flag_char) result(match_idx)
    type(cli_parser_type), intent(in) :: parser
    character(len=1), intent(in)      :: flag_char
    integer(kind=int32)               :: match_idx
    integer(kind=int32)               :: i

    match_idx = 0
    if (flag_char /= ' ') then
      do i = 1, parser%spec_count
        if (parser%specs(i)%short_flag == flag_char) then
          match_idx = i
          exit
        end if
      end do
    end if
  end function find_short_spec

  !-----------------------------------------------------------------------------
  ! Parse command line arguments into result structure
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine cli_parse(parser, res)
    type(cli_parser_type), intent(in) :: parser
    type(cli_result_type), intent(out) :: res

    integer(kind=int32)    :: num_args, arg_i, spec_idx, eq_pos
    character(len=STR_LEN) :: arg_str, next_arg, opt_key, opt_val
    logical                :: double_dash_seen, consume_next

    res%parsed_opt_count = 0
    res%positional_count = 0
    res%status = 0
    res%error_message = ''
    double_dash_seen = .false.

    num_args = command_argument_count()
    arg_i = 1

    do while (arg_i <= num_args)
      call get_command_argument(arg_i, arg_str)
      consume_next = .false.

      if (double_dash_seen) then
        ! Everything after -- is positional
        if (res%positional_count < MAX_ARGS) then
          res%positional_count = res%positional_count + 1
          res%positionals(res%positional_count) = trim(arg_str)
        end if
      else if (trim(arg_str) == '--') then
        double_dash_seen = .true.
      else if (len_trim(arg_str) > 2 .and. arg_str(1:2) == '--') then
        ! Long option
        opt_key = arg_str(3:)
        eq_pos = index(opt_key, '=')
        if (eq_pos > 0) then
          opt_val = opt_key(eq_pos+1:)
          opt_key = opt_key(1:eq_pos-1)
        else
          opt_val = ''
        end if

        spec_idx = find_long_spec(parser, opt_key)
        if (spec_idx > 0) then
          if (parser%specs(spec_idx)%arg_mode == CLI_REQ_ARG .and. eq_pos == 0) then
            if (arg_i < num_args) then
              arg_i = arg_i + 1
              call get_command_argument(arg_i, opt_val)
            else
              res%status = -1
              res%error_message = 'Missing required argument for --' // trim(opt_key)
            end if
          end if

          if (res%status == 0 .and. res%parsed_opt_count < MAX_ARGS) then
            res%parsed_opt_count = res%parsed_opt_count + 1
            res%parsed_opts(res%parsed_opt_count)%spec_index = spec_idx
            res%parsed_opts(res%parsed_opt_count)%value = trim(opt_val)
          end if
        else
          res%status = -1
          res%error_message = 'Unknown option --' // trim(opt_key)
        end if
      else if (len_trim(arg_str) >= 2 .and. arg_str(1:1) == '-') then
        ! Short option
        opt_key = arg_str(2:2)
        spec_idx = find_short_spec(parser, opt_key(1:1))
        if (spec_idx > 0) then
          if (len_trim(arg_str) > 2) then
            opt_val = arg_str(3:)
          else
            opt_val = ''
          end if

          if (parser%specs(spec_idx)%arg_mode == CLI_REQ_ARG .and. len_trim(opt_val) == 0) then
            if (arg_i < num_args) then
              arg_i = arg_i + 1
              call get_command_argument(arg_i, opt_val)
            else
              res%status = -1
              res%error_message = 'Missing required argument for -' // opt_key(1:1)
            end if
          end if

          if (res%status == 0 .and. res%parsed_opt_count < MAX_ARGS) then
            res%parsed_opt_count = res%parsed_opt_count + 1
            res%parsed_opts(res%parsed_opt_count)%spec_index = spec_idx
            res%parsed_opts(res%parsed_opt_count)%value = trim(opt_val)
          end if
        else
          res%status = -1
          res%error_message = 'Unknown option -' // opt_key(1:1)
        end if
      else
        ! Positional argument
        if (res%positional_count < MAX_ARGS) then
          res%positional_count = res%positional_count + 1
          res%positionals(res%positional_count) = trim(arg_str)
        end if
      end if

      arg_i = arg_i + 1
    end do
  end subroutine cli_parse

  !-----------------------------------------------------------------------------
  ! Check if an option was supplied on CLI
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine cli_has_option(parser, res, flag_query, present)
    type(cli_parser_type), intent(in)  :: parser
    type(cli_result_type), intent(in)  :: res
    character(len=*), intent(in)       :: flag_query
    logical, intent(out)               :: present

    integer(kind=int32) :: spec_idx, i

    present = .false.
    if (len_trim(flag_query) == 1) then
      spec_idx = find_short_spec(parser, flag_query(1:1))
    else
      spec_idx = find_long_spec(parser, flag_query)
    end if

    if (spec_idx > 0) then
      do i = 1, res%parsed_opt_count
        if (res%parsed_opts(i)%spec_index == spec_idx) then
          present = .true.
          exit
        end if
      end do
    end if
  end subroutine cli_has_option

  !-----------------------------------------------------------------------------
  ! Retrieve value for a given option
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine cli_get_option(parser, res, flag_query, val_out, status)
    type(cli_parser_type), intent(in)  :: parser
    type(cli_result_type), intent(in)  :: res
    character(len=*), intent(in)       :: flag_query
    character(len=*), intent(out)      :: val_out
    integer(kind=int32), intent(out)   :: status

    integer(kind=int32) :: spec_idx, i

    val_out = ''
    status = -1
    if (len_trim(flag_query) == 1) then
      spec_idx = find_short_spec(parser, flag_query(1:1))
    else
      spec_idx = find_long_spec(parser, flag_query)
    end if

    if (spec_idx > 0) then
      do i = 1, res%parsed_opt_count
        if (res%parsed_opts(i)%spec_index == spec_idx) then
          val_out = trim(res%parsed_opts(i)%value)
          status = 0
          exit
        end if
      end do
    end if
  end subroutine cli_get_option

  !-----------------------------------------------------------------------------
  ! Count occurrences of an option
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine cli_option_count(parser, res, flag_query, count)
    type(cli_parser_type), intent(in)  :: parser
    type(cli_result_type), intent(in)  :: res
    character(len=*), intent(in)       :: flag_query
    integer(kind=int32), intent(out)   :: count

    integer(kind=int32) :: spec_idx, i

    count = 0
    if (len_trim(flag_query) == 1) then
      spec_idx = find_short_spec(parser, flag_query(1:1))
    else
      spec_idx = find_long_spec(parser, flag_query)
    end if

    if (spec_idx > 0) then
      do i = 1, res%parsed_opt_count
        if (res%parsed_opts(i)%spec_index == spec_idx) then
          count = count + 1
        end if
      end do
    end if
  end subroutine cli_option_count

  !-----------------------------------------------------------------------------
  ! Query count of positional arguments
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine cli_positional_count(res, count)
    type(cli_result_type), intent(in) :: res
    integer(kind=int32), intent(out)  :: count

    count = res%positional_count
  end subroutine cli_positional_count

  !-----------------------------------------------------------------------------
  ! Query positional argument by index (1-based)
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine cli_get_positional(res, idx, val_out, status)
    type(cli_result_type), intent(in) :: res
    integer(kind=int32), intent(in)   :: idx
    character(len=*), intent(out)     :: val_out
    integer(kind=int32), intent(out)  :: status

    val_out = ''
    status = -1
    if (idx >= 1 .and. idx <= res%positional_count) then
      val_out = trim(res%positionals(idx))
      status = 0
    end if
  end subroutine cli_get_positional

  !-----------------------------------------------------------------------------
  ! Helper: Output multi-line string handling \n and linefeeds
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine print_multiline_str(str_in, unit_no)
    character(len=*), intent(in)    :: str_in
    integer(kind=int32), intent(in) :: unit_no

    character(len=STR_LEN) :: work_str, line_buf
    integer(kind=int32)    :: pos, nlen, buf_len

    work_str = adjustl(str_in)
    nlen = len_trim(work_str)
    line_buf = ""
    buf_len = 0
    pos = 1

    do while (pos <= nlen)
      if (pos < nlen .and. work_str(pos:pos+1) == '\n') then
        write(unit_no, '(A)') line_buf(1:buf_len)
        line_buf = ""
        buf_len = 0
        pos = pos + 2
      else if (work_str(pos:pos) == achar(10) .or. work_str(pos:pos) == achar(13)) then
        write(unit_no, '(A)') line_buf(1:buf_len)
        line_buf = ""
        buf_len = 0
        pos = pos + 1
      else
        buf_len = buf_len + 1
        if (buf_len <= STR_LEN) line_buf(buf_len:buf_len) = work_str(pos:pos)
        pos = pos + 1
      end if
    end do

    if (buf_len > 0) then
      write(unit_no, '(A)') line_buf(1:buf_len)
    end if
  end subroutine print_multiline_str

  !-----------------------------------------------------------------------------
  ! Format and output auto-generated help documentation
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine cli_print_help(parser, unit_no)
    type(cli_parser_type), intent(in) :: parser
    integer(kind=int32), intent(in)   :: unit_no

    integer(kind=int32)    :: i
    character(len=STR_LEN) :: opt_str, mode_str

    if (parser%mode_count > 0) then
      write(unit_no, '(A)') 'Usage: ' // trim(parser%program_name) // ' [OPTIONS] [MODE] [ARGUMENTS]'
    else
      write(unit_no, '(A)') 'Usage: ' // trim(parser%program_name) // ' [OPTIONS] [ARGUMENTS]'
    end if

    if (len_trim(parser%description) > 0) then
      call print_multiline_str(parser%description, unit_no)
    end if

    if (parser%mode_count > 0) then
      write(unit_no, '(A)') ''
      write(unit_no, '(A)') 'Modes / Subcommands:'
      do i = 1, parser%mode_count
        mode_str = '  ' // trim(parser%modes(i)%mode_name)
        if (len_trim(parser%modes(i)%mode_args) > 0) then
          mode_str = trim(mode_str) // ' ' // trim(parser%modes(i)%mode_args)
        end if

        if (len_trim(mode_str) < 28) then
          write(unit_no, '(A, A)') mode_str(1:28), trim(parser%modes(i)%help_text)
        else
          write(unit_no, '(A, 2X, A)') trim(mode_str), trim(parser%modes(i)%help_text)
        end if
      end do
    end if

    write(unit_no, '(A)') ''
    write(unit_no, '(A)') 'Options:'

    do i = 1, parser%spec_count
      opt_str = '  '
      if (parser%specs(i)%short_flag /= ' ') then
        opt_str = trim(opt_str) // '-' // parser%specs(i)%short_flag
        if (len_trim(parser%specs(i)%long_flag) > 0) then
          opt_str = trim(opt_str) // ', '
        end if
      else
        opt_str = trim(opt_str) // '    '
      end if

      if (len_trim(parser%specs(i)%long_flag) > 0) then
        opt_str = trim(opt_str) // '--' // trim(parser%specs(i)%long_flag)
      end if

      if (len_trim(parser%specs(i)%value_name) > 0) then
        opt_str = trim(opt_str) // ' <' // trim(parser%specs(i)%value_name) // '>'
      end if

      if (len_trim(opt_str) < 28) then
        write(unit_no, '(A, A)') opt_str(1:28), trim(parser%specs(i)%help_text)
      else
        write(unit_no, '(A, 2X, A)') trim(opt_str), trim(parser%specs(i)%help_text)
      end if
    end do
  end subroutine cli_print_help

  !-----------------------------------------------------------------------------
  ! Format and output mode-specific help documentation
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine cli_print_mode_help(parser, mode_name, unit_no)
    type(cli_parser_type), intent(in) :: parser
    character(len=*), intent(in)      :: mode_name
    integer(kind=int32), intent(in)   :: unit_no

    integer(kind=int32)    :: i, mode_idx
    character(len=STR_LEN) :: opt_str, norm_mode

    norm_mode = trim(adjustl(mode_name))
    mode_idx = 0
    do i = 1, parser%mode_count
      if (trim(parser%modes(i)%mode_name) == norm_mode) then
        mode_idx = i
        exit
      end if
    end do

    if (mode_idx > 0) then
      write(unit_no, '(A)') 'Usage: ' // trim(parser%program_name) // ' ' // &
                            trim(parser%modes(mode_idx)%mode_name) // ' ' // &
                            trim(parser%modes(mode_idx)%mode_args)
      write(unit_no, '(A)') ''
      call print_multiline_str(parser%modes(mode_idx)%help_text, unit_no)
      if (len_trim(parser%modes(mode_idx)%detailed_help) > 0) then
        write(unit_no, '(A)') ''
        call print_multiline_str(parser%modes(mode_idx)%detailed_help, unit_no)
      end if
      write(unit_no, '(A)') ''
      write(unit_no, '(A)') 'Options:'

      do i = 1, parser%spec_count
        opt_str = '  '
        if (parser%specs(i)%short_flag /= ' ') then
          opt_str = trim(opt_str) // '-' // parser%specs(i)%short_flag
          if (len_trim(parser%specs(i)%long_flag) > 0) then
            opt_str = trim(opt_str) // ', '
          end if
        else
          opt_str = trim(opt_str) // '    '
        end if

        if (len_trim(parser%specs(i)%long_flag) > 0) then
          opt_str = trim(opt_str) // '--' // trim(parser%specs(i)%long_flag)
        end if

        if (len_trim(parser%specs(i)%value_name) > 0) then
          opt_str = trim(opt_str) // ' <' // trim(parser%specs(i)%value_name) // '>'
        end if

        if (len_trim(opt_str) < 28) then
          write(unit_no, '(A, A)') opt_str(1:28), trim(parser%specs(i)%help_text)
        else
          write(unit_no, '(A, 2X, A)') trim(opt_str), trim(parser%specs(i)%help_text)
        end if
      end do
    else
      call cli_print_help(parser, unit_no)
    end if
  end subroutine cli_print_mode_help

  !-----------------------------------------------------------------------------
  ! Free / reset parser and result structures
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine cli_free_parser(parser)
    type(cli_parser_type), intent(inout) :: parser

    parser%spec_count = 0
    parser%mode_count = 0
  end subroutine cli_free_parser

  subroutine cli_free_result(res)
    type(cli_result_type), intent(inout) :: res

    res%parsed_opt_count = 0
    res%positional_count = 0
    res%status = 0
    res%error_message = ''
  end subroutine cli_free_result

  subroutine cli_free_both(parser, res)
    type(cli_parser_type), intent(inout) :: parser
    type(cli_result_type), intent(inout) :: res

    call cli_free_parser(parser)
    call cli_free_result(res)
  end subroutine cli_free_both

end module iris_cli_args
