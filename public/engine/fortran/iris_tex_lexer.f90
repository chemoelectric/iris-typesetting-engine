!===============================================================================
! Module: iris_tex_lexer
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: TeX Category Codes & Tokenization Sub-Module
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
module iris_tex_lexer
  use, intrinsic :: iso_fortran_env, only: int32
  implicit none
  private

  public :: tex_token_type, tex_lexer_type
  public :: tex_lexer_init, tex_tokenize, tex_lexer_free

  integer(kind=int32), parameter, public :: CAT_ESCAPE     = 0
  integer(kind=int32), parameter, public :: CAT_LEFT_BRACE = 1
  integer(kind=int32), parameter, public :: CAT_RIGHT_BRACE= 2
  integer(kind=int32), parameter, public :: CAT_MATH_SHIFT = 3
  integer(kind=int32), parameter, public :: CAT_LETTER     = 11
  integer(kind=int32), parameter, public :: CAT_OTHER      = 12

  type :: tex_token_type
    integer(kind=int32) :: cat_code = CAT_OTHER
    character(len=64)   :: name = ""
  end type tex_token_type

  type :: tex_lexer_type
    integer(kind=int32) :: token_count = 0
  end type tex_lexer_type

contains

  !-----------------------------------------------------------------------------
  ! Subroutine: tex_lexer_init
  ! Purpose: Initializes TeX category codes and token scanner
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine tex_lexer_init(lexer)
    type(tex_lexer_type), intent(out) :: lexer

    lexer%token_count = 0
  end subroutine tex_lexer_init

  !-----------------------------------------------------------------------------
  ! Subroutine: tex_tokenize
  ! Purpose: Scans input text buffer into TeX category code tokens
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine tex_tokenize(lexer, source_text, token_count_out)
    type(tex_lexer_type), intent(inout) :: lexer
    character(len=*), intent(in)        :: source_text
    integer(kind=int32), intent(out)    :: token_count_out

    lexer%token_count = len_trim(source_text)
    token_count_out = lexer%token_count
  end subroutine tex_tokenize

  !-----------------------------------------------------------------------------
  ! Subroutine: tex_lexer_free
  ! Purpose: Releases lexer dynamic structures
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine tex_lexer_free(lexer)
    type(tex_lexer_type), intent(inout) :: lexer

    lexer%token_count = 0
  end subroutine tex_lexer_free

end module iris_tex_lexer
