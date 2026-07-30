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
    character(len=256)  :: name = ""
  end type tex_token_type

  type :: tex_lexer_type
    type(tex_token_type), allocatable, dimension(:) :: tokens
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

    if (allocated(lexer%tokens)) deallocate(lexer%tokens)
    allocate(lexer%tokens(64))
    lexer%token_count = 0
  end subroutine tex_lexer_init

  !-----------------------------------------------------------------------------
  ! Subroutine: tex_tokenize
  ! Purpose: Scans input text buffer into TeX category code tokens according to TeX catcodes
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine tex_tokenize(lexer, source_text, token_count_out)
    type(tex_lexer_type), intent(inout) :: lexer
    character(len=*), intent(in)        :: source_text
    integer(kind=int32), intent(out)    :: token_count_out

    integer(kind=int32) :: src_len, pos, t_idx, cs_start, newline_count
    character(1)        :: ch
    character(len=256)  :: cs_name

    src_len = len(source_text)
    if (allocated(lexer%tokens)) deallocate(lexer%tokens)
    allocate(lexer%tokens(max(64, src_len)))
    lexer%token_count = 0
    t_idx = 0
    pos = 1
    newline_count = 0

    do while (pos <= src_len)
      ch = source_text(pos:pos)

      if (ch == char(10) .or. ch == char(13)) then
        newline_count = newline_count + 1
        if (newline_count == 2) then
          t_idx = t_idx + 1
          lexer%tokens(t_idx)%cat_code = CAT_ESCAPE
          lexer%tokens(t_idx)%name = "par"
        end if
        pos = pos + 1
      else
        if (ch /= ' ' .and. ch /= char(9)) newline_count = 0

        if (ch == '%') then
          ! Comment: skip to next newline
          do while (pos <= src_len .and. source_text(pos:pos) /= char(10) .and. source_text(pos:pos) /= char(13))
            pos = pos + 1
          end do
        else if (ch == '\') then
          pos = pos + 1
          if (pos <= src_len) then
            cs_start = pos
            if ((source_text(pos:pos) >= 'a' .and. source_text(pos:pos) <= 'z') .or. &
                (source_text(pos:pos) >= 'A' .and. source_text(pos:pos) <= 'Z')) then
              do while (pos <= src_len .and. &
                ((source_text(pos:pos) >= 'a' .and. source_text(pos:pos) <= 'z') .or. &
                 (source_text(pos:pos) >= 'A' .and. source_text(pos:pos) <= 'Z')))
                pos = pos + 1
              end do
              cs_name = source_text(cs_start : pos - 1)
            else
              cs_name = source_text(pos:pos)
              pos = pos + 1
            end if
            t_idx = t_idx + 1
            lexer%tokens(t_idx)%cat_code = CAT_ESCAPE
            lexer%tokens(t_idx)%name = trim(cs_name)
          end if
        else if (ch == '{') then
          t_idx = t_idx + 1
          lexer%tokens(t_idx)%cat_code = CAT_LEFT_BRACE
          lexer%tokens(t_idx)%name = "{"
          pos = pos + 1
        else if (ch == '}') then
          t_idx = t_idx + 1
          lexer%tokens(t_idx)%cat_code = CAT_RIGHT_BRACE
          lexer%tokens(t_idx)%name = "}"
          pos = pos + 1
        else if (ch == '$') then
          t_idx = t_idx + 1
          lexer%tokens(t_idx)%cat_code = CAT_MATH_SHIFT
          lexer%tokens(t_idx)%name = "$"
          pos = pos + 1
        else if ((ch >= 'a' .and. ch <= 'z') .or. (ch >= 'A' .and. ch <= 'Z')) then
          t_idx = t_idx + 1
          lexer%tokens(t_idx)%cat_code = CAT_LETTER
          lexer%tokens(t_idx)%name = ch
          pos = pos + 1
        else
          t_idx = t_idx + 1
          lexer%tokens(t_idx)%cat_code = CAT_OTHER
          lexer%tokens(t_idx)%name = ch
          pos = pos + 1
        end if
      end if
    end do

    lexer%token_count = t_idx
    token_count_out = t_idx
  end subroutine tex_tokenize

  !-----------------------------------------------------------------------------
  ! Subroutine: tex_lexer_free
  ! Purpose: Releases lexer dynamic structures
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine tex_lexer_free(lexer)
    type(tex_lexer_type), intent(inout) :: lexer

    if (allocated(lexer%tokens)) deallocate(lexer%tokens)
    lexer%token_count = 0
  end subroutine tex_lexer_free

end module iris_tex_lexer
