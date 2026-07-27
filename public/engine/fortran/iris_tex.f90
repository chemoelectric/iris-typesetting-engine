!===============================================================================
! Module: iris_tex
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Modular TeX Master Facade Engine
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
module iris_tex
  use, intrinsic :: iso_fortran_env, only: int32, real64
  use iris_json, only: json_value_type, json_create_object, json_create_string, &
                       json_set_field
  use iris_kpsewhich, only: kpse_search_file, KPSE_OK
  use iris_tex_lexer, only: tex_lexer_type, tex_lexer_init, tex_tokenize, tex_lexer_free
  use iris_tex_parser, only: tex_parser_type, tex_parser_init, tex_parse_tokens, tex_parser_free
  use iris_tex_math, only: tex_math_type, tex_math_init, tex_typeset_math, tex_math_free
  use iris_tex_trip, only: tex_run_trip_suite
  implicit none
  private

  public :: tex_engine_type, tex_init, tex_compile_string, tex_run_trip_test, tex_free

  integer(kind=int32), parameter, public :: TEX_OK = 0
  integer(kind=int32), parameter, public :: TEX_ERR = 1

  type :: tex_engine_type
    type(tex_parser_type) :: parser
    type(tex_math_type)   :: math_eng
    character(len=512)    :: jobname = "iris_job"
    character(len=256)    :: format_name = "plain"
    real(kind=real64)     :: hsize = 468.0_real64 ! 6.5 inches in points
    real(kind=real64)     :: vsize = 648.0_real64 ! 9.0 inches in points
    integer(kind=int32)   :: token_count = 0
  end type tex_engine_type

contains

  !-----------------------------------------------------------------------------
  ! Subroutine: tex_init
  ! Purpose: Initializes TeX engine state and default dimension parameters
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine tex_init(engine, jobname)
    type(tex_engine_type), intent(out) :: engine
    character(len=*), intent(in)       :: jobname

    call tex_parser_init(engine%parser)
    call tex_math_init(engine%math_eng)
    engine%jobname = trim(jobname)
    engine%format_name = "plain"
    engine%hsize = 468.0_real64
    engine%vsize = 648.0_real64
    engine%token_count = 0
  end subroutine tex_init

  !-----------------------------------------------------------------------------
  ! Subroutine: tex_compile_string
  ! Purpose: Modular TeX compilation of input buffer into AST representation
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine tex_compile_string(engine, tex_source, ast_out, status)
    type(tex_engine_type), intent(inout) :: engine
    character(len=*), intent(in)         :: tex_source
    type(json_value_type), intent(out)   :: ast_out
    integer(kind=int32), intent(out)     :: status

    call tex_parse_tokens(engine%parser, tex_source, ast_out, status)
    engine%token_count = len_trim(tex_source)
  end subroutine tex_compile_string

  !-----------------------------------------------------------------------------
  ! Subroutine: tex_run_trip_test
  ! Purpose: Runs Knuth's TRIP diagnostic benchmark suite via sub-module
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine tex_run_trip_test(status, report_msg)
    integer(kind=int32), intent(out) :: status
    character(len=*), intent(out)    :: report_msg

    call tex_run_trip_suite(status, report_msg)
  end subroutine tex_run_trip_test

  !-----------------------------------------------------------------------------
  ! Subroutine: tex_free
  ! Purpose: Releases TeX engine heap allocated structures
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine tex_free(engine)
    type(tex_engine_type), intent(inout) :: engine

    call tex_parser_free(engine%parser)
    call tex_math_free(engine%math_eng)
    engine%jobname = ""
    engine%token_count = 0
  end subroutine tex_free

end module iris_tex
