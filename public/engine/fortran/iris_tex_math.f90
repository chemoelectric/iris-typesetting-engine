!===============================================================================
! Module: iris_tex_math
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: TeX Math Mode Typesetting & Formula Layout Sub-Module
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
module iris_tex_math
  use, intrinsic :: iso_fortran_env, only: int32, real64
  use iris_json, only: json_value_type, json_create_object, json_create_string, json_set_field
  implicit none
  private

  public :: tex_math_type
  public :: tex_math_init, tex_typeset_math, tex_math_free

  integer(kind=int32), parameter, public :: MATH_STYLE_DISPLAY = 0
  integer(kind=int32), parameter, public :: MATH_STYLE_TEXT    = 1
  integer(kind=int32), parameter, public :: MATH_STYLE_SCRIPT  = 2

  type :: tex_math_type
    integer(kind=int32) :: default_style = MATH_STYLE_DISPLAY
  end type tex_math_type

contains

  !-----------------------------------------------------------------------------
  ! Subroutine: tex_math_init
  ! Purpose: Initializes TeX math mode layout engine
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine tex_math_init(math_eng)
    type(tex_math_type), intent(out) :: math_eng

    math_eng%default_style = MATH_STYLE_DISPLAY
  end subroutine tex_math_init

  !-----------------------------------------------------------------------------
  ! Subroutine: tex_typeset_math
  ! Purpose: Formats inline and display mathematical formulas into AST nodes
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine tex_typeset_math(math_eng, formula_str, math_ast, status)
    type(tex_math_type), intent(inout) :: math_eng
    character(len=*), intent(in)       :: formula_str
    type(json_value_type), intent(out) :: math_ast
    integer(kind=int32), intent(out)   :: status

    type(json_value_type) :: form_val

    call json_create_object(math_ast)
    call json_create_string(form_val, trim(formula_str))
    call json_set_field(math_ast, "math_formula", form_val)

    status = 0
  end subroutine tex_typeset_math

  !-----------------------------------------------------------------------------
  ! Subroutine: tex_math_free
  ! Purpose: Releases math engine allocated resources
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine tex_math_free(math_eng)
    type(tex_math_type), intent(inout) :: math_eng

    math_eng%default_style = MATH_STYLE_DISPLAY
  end subroutine tex_math_free

end module iris_tex_math
