!===============================================================================
! Module: iris_markup_parser
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Mixed Markup & Natural Language Intent Disambiguation Engine
!               Supports TeX, LaTeX, ConTeXt, Troff/Groff, HTML, and Natural Prose
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
module iris_markup_parser
  use, intrinsic :: iso_fortran_env, only: int32, real64
  implicit none
  private

  ! Public Constants (Dialect Identifiers)
  integer(kind=int32), parameter, public :: DIALECT_UNKNOWN          = 0
  integer(kind=int32), parameter, public :: DIALECT_NATURAL_PROSE    = 1
  integer(kind=int32), parameter, public :: DIALECT_TEX_LATEX        = 2
  integer(kind=int32), parameter, public :: DIALECT_CONTEXT          = 3
  integer(kind=int32), parameter, public :: DIALECT_TROFF_GROFF      = 4
  integer(kind=int32), parameter, public :: DIALECT_TROFF            = 4
  integer(kind=int32), parameter, public :: DIALECT_HTML_XML         = 5

  ! Public Constants (AST Node Types)
  integer(kind=int32), parameter, public :: NODE_TYPE_TEXT           = 1
  integer(kind=int32), parameter, public :: NODE_TYPE_HEADING        = 2
  integer(kind=int32), parameter, public :: NODE_TYPE_PARAGRAPH      = 3
  integer(kind=int32), parameter, public :: NODE_TYPE_MATH           = 4
  integer(kind=int32), parameter, public :: NODE_TYPE_INTENT_ANNOT   = 5

  ! Public Derived Types
  public :: markup_token_type
  public :: parse_result_type

  ! Public API Procedures
  public :: detect_markup_dialect
  public :: parse_disambiguation_hint
  public :: parse_mixed_markup_text

  type :: markup_token_type
    integer(kind=int32) :: dialect = DIALECT_NATURAL_PROSE
    integer(kind=int32) :: node_type = NODE_TYPE_TEXT
    integer(kind=int32) :: heading_level = 0
    character(len=2048) :: content = ""
    character(len=128)  :: parameter = ""
  end type markup_token_type

  type :: parse_result_type
    type(markup_token_type), allocatable, dimension(:) :: tokens
    integer(kind=int32)     :: token_count = 0
    integer(kind=int32)     :: detected_dialect = DIALECT_NATURAL_PROSE
    logical                 :: ambiguity_detected = .false.
    character(len=256)      :: disambiguation_msg = ""
  end type parse_result_type

contains

  !-----------------------------------------------------------------------------
  ! Detect markup dialect based on structural syntax tokens
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  function detect_markup_dialect(text) result(dialect)
    character(len=*), intent(in) :: text
    integer(kind=int32)          :: dialect

    integer(kind=int32) :: len_text

    len_text = len_trim(text)
    dialect = DIALECT_NATURAL_PROSE

    if (len_text > 0) then
      if (index(text, "\starttext") > 0 .or. index(text, "\startchapter") > 0 .or. &
          index(text, "\setupbodyfont") > 0) then
        dialect = DIALECT_CONTEXT
      else if (index(text, "\documentclass") > 0 .or. index(text, "\begin{document}") > 0 .or. &
               index(text, "\section{") > 0 .or. index(text, "\textbf{") > 0 .or. &
               index(text, "\centerline") > 0 .or. index(text, "\hsize=") > 0 .or. &
               index(text, "\vsize=") > 0 .or. index(text, "\bye") > 0 .or. &
               index(text, "\bigskip") > 0 .or. index(text, "\bf ") > 0) then
        dialect = DIALECT_TEX_LATEX
      else if (index(text, ".TH ") == 1 .or. index(text, ".PP") == 1 .or. &
               index(text, ".SH") == 1 .or. index(text, "\fB") > 0 .or. &
               index(text, ".ms") > 0 .or. index(text, ".mm") > 0) then
        dialect = DIALECT_TROFF_GROFF
      else if (index(text, "<html>") > 0 .or. index(text, "<p>") > 0 .or. &
               index(text, "<h1>") > 0 .or. index(text, "<div>") > 0) then
        dialect = DIALECT_HTML_XML
      end if
    end if
  end function detect_markup_dialect

  !-----------------------------------------------------------------------------
  ! Parse inline natural language disambiguation hint e.g., [markup: troff]
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine parse_disambiguation_hint(text, dialect, hint_found)
    character(len=*), intent(in)  :: text
    integer(kind=int32), intent(out):: dialect
    logical, intent(out)          :: hint_found

    integer(kind=int32) :: pos_start, pos_end
    character(len=128)  :: hint_str

    dialect = DIALECT_UNKNOWN
    hint_found = .false.

    pos_start = index(text, "[markup:")
    if (pos_start == 0) pos_start = index(text, "[format:")

    if (pos_start > 0) then
      pos_end = index(text(pos_start:), "]")
      if (pos_end > 0) then
        hint_str = text(pos_start + 8 : pos_start + pos_end - 2)
        hint_found = .true.

        if (index(hint_str, "context") > 0) then
          dialect = DIALECT_CONTEXT
        else if (index(hint_str, "tex") > 0 .or. index(hint_str, "latex") > 0) then
          dialect = DIALECT_TEX_LATEX
        else if (index(hint_str, "troff") > 0 .or. index(hint_str, "groff") > 0 .or. &
                 index(hint_str, "ms") > 0) then
          dialect = DIALECT_TROFF_GROFF
        else if (index(hint_str, "html") > 0 .or. index(hint_str, "xml") > 0) then
          dialect = DIALECT_HTML_XML
        else if (index(hint_str, "prose") > 0 .or. index(hint_str, "natural") > 0) then
          dialect = DIALECT_NATURAL_PROSE
        end if
      end if
    end if
  end subroutine parse_disambiguation_hint

  !-----------------------------------------------------------------------------
  ! Parse mixed markup text into IIR token sequence
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine parse_mixed_markup_text(input_text, result_ast)
    character(len=*), intent(in)   :: input_text
    type(parse_result_type), intent(out) :: result_ast

    integer(kind=int32) :: hint_dialect, auto_dialect
    logical             :: has_hint

    result_ast%token_count = 0
    result_ast%ambiguity_detected = .false.
    result_ast%disambiguation_msg = ""

    ! Step 1: Check for explicit inline natural language hints
    call parse_disambiguation_hint(input_text, hint_dialect, has_hint)

    if (has_hint .and. hint_dialect /= DIALECT_UNKNOWN) then
      result_ast%detected_dialect = hint_dialect
    else
      auto_dialect = detect_markup_dialect(input_text)
      result_ast%detected_dialect = auto_dialect

      ! Detect potential syntax ambiguity
      if (index(input_text, "\") > 0 .and. index(input_text, ".") == 1 .and. auto_dialect == DIALECT_NATURAL_PROSE) then
        result_ast%ambiguity_detected = .true.
        result_ast%disambiguation_msg = "Ambiguous markup detected. Please insert '[markup: troff]' or '[markup: latex]' in prose."
      end if
    end if

    ! Step 2: Tokenize text into single root paragraph IIR AST
    allocate(result_ast%tokens(16))
    result_ast%token_count = 1
    result_ast%tokens(1)%dialect = result_ast%detected_dialect
    result_ast%tokens(1)%node_type = NODE_TYPE_PARAGRAPH
    result_ast%tokens(1)%parameter = ""

    if (result_ast%detected_dialect == DIALECT_CONTEXT .or. &
        result_ast%detected_dialect == DIALECT_TEX_LATEX) then
      call clean_context_markup(input_text, result_ast%tokens(1)%content)
      if (len_trim(result_ast%tokens(1)%content) == 0) then
        result_ast%tokens(1)%content = trim(input_text)
      end if
    else
      result_ast%tokens(1)%content = trim(input_text)
    end if
  end subroutine parse_mixed_markup_text

  !-----------------------------------------------------------------------------
  ! Subroutine: clean_context_markup
  ! Purpose: Removes ConTeXt/TeX comments, preamble commands, and extracts text/titles
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine clean_context_markup(raw_in, cleaned_out)
    character(len=*), intent(in)  :: raw_in
    character(len=*), intent(out) :: cleaned_out

    character(len=2048) :: line_buf
    integer(kind=int32) :: raw_len, pos, next_nl, out_pos, i, p1, p2

    raw_len = len_trim(raw_in)
    cleaned_out = ""
    out_pos = 1
    pos = 1

    do while (pos <= raw_len)
      next_nl = index(raw_in(pos:raw_len), char(10))
      if (next_nl == 0) then
        line_buf = raw_in(pos:raw_len)
        pos = raw_len + 1
      else
        line_buf = raw_in(pos : pos + next_nl - 1)
        pos = pos + next_nl
      end if

      i = len_trim(line_buf)
      if (i > 0) then
        if (line_buf(i:i) == char(13)) line_buf(i:i) = ' '
      end if

      p1 = index(line_buf, "%")
      if (p1 > 0) then
        if (p1 == 1 .or. line_buf(p1-1:p1-1) /= "\") then
          line_buf = line_buf(1 : p1 - 1)
        end if
      end if

      if (index(line_buf, "\starttext") > 0 .or. index(line_buf, "\stoptext") > 0 .or. &
          index(line_buf, "\setup") > 0 .or. index(line_buf, "\usemodule") > 0 .or. &
          index(line_buf, "\documentclass") > 0 .or. index(line_buf, "\usepackage") > 0 .or. &
          index(line_buf, "\begin{document}") > 0 .or. index(line_buf, "\end{document}") > 0 .or. &
          index(line_buf, "\stopchapter") > 0 .or. index(line_buf, "\stopsection") > 0 .or. &
          index(line_buf, "\hsize=") > 0 .or. index(line_buf, "\vsize=") > 0 .or. &
          trim(line_buf) == "\bigskip" .or. trim(line_buf) == "\bye" .or. &
          trim(line_buf) == "\par") then
        line_buf = ""
      end if

      if (index(line_buf, "\centerline{") > 0) then
        p1 = index(line_buf, "\centerline{") + 12
        p2 = index(line_buf(p1:), "}")
        if (p2 > 0) then
          line_buf = line_buf(p1 : p1 + p2 - 2)
        end if
      else if (index(line_buf, "title={") > 0) then
        p1 = index(line_buf, "title={") + 7
        p2 = index(line_buf(p1:), "}")
        if (p2 > 0) then
          line_buf = line_buf(p1 : p1 + p2 - 2) // new_line('a')
        end if
      else if (index(line_buf, "\chapter{") > 0) then
        p1 = index(line_buf, "\chapter{") + 9
        p2 = index(line_buf(p1:), "}")
        if (p2 > 0) then
          line_buf = line_buf(p1 : p1 + p2 - 2) // new_line('a')
        end if
      else if (index(line_buf, "\section{") > 0) then
        p1 = index(line_buf, "\section{") + 9
        p2 = index(line_buf(p1:), "}")
        if (p2 > 0) then
          line_buf = line_buf(p1 : p1 + p2 - 2) // new_line('a')
        end if
      end if

      do while (index(line_buf, "\bf ") > 0)
        p1 = index(line_buf, "\bf ")
        line_buf = line_buf(1:p1-1) // line_buf(p1+4:)
      end do

      do while (index(line_buf, "{\tt ") > 0)
        p1 = index(line_buf, "{\tt ")
        line_buf = line_buf(1:p1-1) // line_buf(p1+5:)
        p2 = index(line_buf(p1:), "}")
        if (p2 > 0) then
          line_buf = line_buf(1:p1+p2-2) // line_buf(p1+p2:)
        end if
      end do

      do while (index(line_buf, "{\bf ") > 0)
        p1 = index(line_buf, "{\bf ")
        line_buf = line_buf(1:p1-1) // line_buf(p1+5:)
        p2 = index(line_buf(p1:), "}")
        if (p2 > 0) then
          line_buf = line_buf(1:p1+p2-2) // line_buf(p1+p2:)
        end if
      end do

      if (len_trim(line_buf) > 0) then
        if (out_pos > 1) then
          cleaned_out(out_pos:out_pos) = char(10)
          out_pos = out_pos + 1
        end if
        p2 = len_trim(line_buf)
        if (out_pos + p2 <= len(cleaned_out)) then
          cleaned_out(out_pos : out_pos + p2 - 1) = line_buf(1:p2)
          out_pos = out_pos + p2
        end if
      end if
    end do

  end subroutine clean_context_markup

end module iris_markup_parser
