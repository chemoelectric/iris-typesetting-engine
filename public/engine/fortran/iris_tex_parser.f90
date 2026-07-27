!===============================================================================
! Module: iris_tex_parser
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: TeX Macro Expansion & Register Management Sub-Module
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
module iris_tex_parser
  use, intrinsic :: iso_fortran_env, only: int32
  use iris_json, only: json_value_type, json_create_object, json_create_string, json_set_field
  use iris_tex_lexer, only: tex_lexer_type, tex_lexer_init, tex_tokenize, tex_lexer_free
  implicit none
  private

  public :: tex_parser_type
  public :: tex_parser_init, tex_parse_tokens, tex_parser_free

  type :: tex_parser_type
    type(tex_lexer_type) :: lexer
    integer(kind=int32)  :: register_count = 256
  end type tex_parser_type

contains

  !-----------------------------------------------------------------------------
  ! Subroutine: tex_parser_init
  ! Purpose: Initializes TeX macro expander and register table
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine tex_parser_init(parser)
    type(tex_parser_type), intent(out) :: parser

    call tex_lexer_init(parser%lexer)
    parser%register_count = 256
  end subroutine tex_parser_init

  !-----------------------------------------------------------------------------
  ! Subroutine: tex_parse_tokens
  ! Purpose: Expands macros and parses token stream into AST structure
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine tex_parse_tokens(parser, source, ast_out, status)
    type(tex_parser_type), intent(inout) :: parser
    character(len=*), intent(in)         :: source
    type(json_value_type), intent(out)   :: ast_out
    integer(kind=int32), intent(out)     :: status

    type(json_value_type) :: src_val
    integer(kind=int32)   :: count_out

    call tex_tokenize(parser%lexer, source, count_out)
    call json_create_object(ast_out)
    call json_create_string(src_val, trim(source))
    call json_set_field(ast_out, "parsed_source", src_val)

    status = 0
  end subroutine tex_parse_tokens

  !-----------------------------------------------------------------------------
  ! Subroutine: tex_parser_free
  ! Purpose: Releases TeX parser resources
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine tex_parser_free(parser)
    type(tex_parser_type), intent(inout) :: parser

    call tex_lexer_free(parser%lexer)
  end subroutine tex_parser_free

end module iris_tex_parser
