!===============================================================================
! Module: iris_font_json
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Decoupled JSON AST Serialization Bridge for OpenType Fonts
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
module iris_font_json
  use, intrinsic :: iso_fortran_env, only: int16, int32, real64
  use iris_opentype
  use iris_json
  implicit none
  private

  ! Public API Procedures
  public :: otf_to_json
  public :: json_to_otf
  public :: otf_serialize_json

contains

  !-----------------------------------------------------------------------------
  ! Convert otf_font_type to json_value_type AST Object
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine otf_to_json(font, json_obj)
    type(otf_font_type), intent(in)   :: font
    type(json_value_type), intent(out):: json_obj

    type(json_value_type) :: head_obj, hhea_obj, name_obj, pegs_arr, peg_item, tmp_val
    integer(kind=int32)   :: i

    call json_create_object(json_obj)

    ! Convert head table
    call json_create_object(head_obj)
    call json_create_number(tmp_val, real(font%head%units_per_em, real64))
    call json_set_field(head_obj, "unitsPerEm", tmp_val)

    call json_create_number(tmp_val, real(font%head%x_min, real64))
    call json_set_field(head_obj, "xMin", tmp_val)

    call json_create_number(tmp_val, real(font%head%y_min, real64))
    call json_set_field(head_obj, "yMin", tmp_val)

    call json_create_number(tmp_val, real(font%head%x_max, real64))
    call json_set_field(head_obj, "xMax", tmp_val)

    call json_create_number(tmp_val, real(font%head%y_max, real64))
    call json_set_field(head_obj, "yMax", tmp_val)

    call json_set_field(json_obj, "head", head_obj)

    ! Convert hhea table
    call json_create_object(hhea_obj)
    call json_create_number(tmp_val, real(font%hhea%ascender, real64))
    call json_set_field(hhea_obj, "ascender", tmp_val)

    call json_create_number(tmp_val, real(font%hhea%descender, real64))
    call json_set_field(hhea_obj, "descender", tmp_val)

    call json_create_number(tmp_val, real(font%hhea%line_gap, real64))
    call json_set_field(hhea_obj, "lineGap", tmp_val)

    call json_set_field(json_obj, "hhea", hhea_obj)

    ! Convert Naming table
    call json_create_object(name_obj)
    call json_create_string(tmp_val, trim(font%family_name))
    call json_set_field(name_obj, "familyName", tmp_val)

    call json_create_string(tmp_val, trim(font%subfamily_name))
    call json_set_field(name_obj, "subfamilyName", tmp_val)

    call json_create_string(tmp_val, trim(font%full_name))
    call json_set_field(name_obj, "fullName", tmp_val)

    call json_create_string(tmp_val, trim(font%postscript_name))
    call json_set_field(name_obj, "postscriptName", tmp_val)

    call json_set_field(json_obj, "name", name_obj)

    ! Convert PEGS table
    call json_create_array(pegs_arr)
    do i = 1, font%num_pegs
      call json_create_object(peg_item)

      call json_create_number(tmp_val, real(font%pegs(i)%glyph_id, real64))
      call json_set_field(peg_item, "glyphId", tmp_val)

      call json_create_number(tmp_val, real(font%pegs(i)%left_peg_x, real64))
      call json_set_field(peg_item, "leftPegX", tmp_val)

      call json_create_number(tmp_val, real(font%pegs(i)%left_peg_y, real64))
      call json_set_field(peg_item, "leftPegY", tmp_val)

      call json_create_number(tmp_val, real(font%pegs(i)%right_peg_x, real64))
      call json_set_field(peg_item, "rightPegX", tmp_val)

      call json_create_number(tmp_val, real(font%pegs(i)%right_peg_y, real64))
      call json_set_field(peg_item, "rightPegY", tmp_val)

      call json_create_number(tmp_val, real(font%pegs(i)%optical_center_x, real64))
      call json_set_field(peg_item, "opticalCenterX", tmp_val)

      call json_add_element(pegs_arr, peg_item)
    end do
    call json_set_field(json_obj, "pegs", pegs_arr)
  end subroutine otf_to_json

  !-----------------------------------------------------------------------------
  ! Convert json_value_type AST Object to otf_font_type
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine json_to_otf(json_obj, font)
    type(json_value_type), intent(in) :: json_obj
    type(otf_font_type), intent(out)  :: font

    type(json_value_type) :: name_obj, val_item
    integer(kind=int32)   :: status
    character(len=256)    :: str_buf

    call otf_init_font(font, "ParsedFont")

    call json_get_field(json_obj, "name", name_obj, status)
    if (status == 0) then
      call json_get_field(name_obj, "familyName", val_item, status)
      if (status == 0) then
        call json_get_string(val_item, str_buf, status)
        if (status == 0) font%family_name = trim(str_buf)
      end if
      call json_get_field(name_obj, "subfamilyName", val_item, status)
      if (status == 0) then
        call json_get_string(val_item, str_buf, status)
        if (status == 0) font%subfamily_name = trim(str_buf)
      end if
    end if
  end subroutine json_to_otf

  !-----------------------------------------------------------------------------
  ! Direct helper to serialize OpenType structure into JSON text stream
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine otf_serialize_json(font, json_str)
    type(otf_font_type), intent(in) :: font
    character(len=*), intent(out)   :: json_str

    type(json_value_type) :: json_ast

    call otf_to_json(font, json_ast)
    call json_serialize(json_ast, json_str)
    call json_free(json_ast)
  end subroutine otf_serialize_json

end module iris_font_json
