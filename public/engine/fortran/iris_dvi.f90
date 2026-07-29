! ==============================================================================
! Module: iris_dvi
! Standard: ISO Fortran 2008
! Description: TeX Device Independent (DVI v2) Output Generation Engine
!              Provides modular, low-level binary DVI opcode creation for
!              TeX-style macro-typography backends.
! ==============================================================================

module iris_dvi
  use, intrinsic :: iso_fortran_env, only: int8, int16, int32, real64
  implicit none
  private

  ! Public API Types
  public :: dvi_document_type

  ! Public API Procedures
  public :: dvi_init
  public :: dvi_begin_page
  public :: dvi_end_page
  public :: dvi_write_char
  public :: dvi_write_rule
  public :: dvi_define_font
  public :: dvi_select_font
  public :: dvi_move_right
  public :: dvi_move_down
  public :: dvi_push
  public :: dvi_pop
  public :: dvi_close

  ! DVI Format Opcodes (TeX DVI v2 Specification)
  integer(int8), parameter :: OP_DVI_SET_RULE = -124_int8   ! 132
  integer(int8), parameter :: OP_DVI_PUT_RULE = -119_int8   ! 137
  integer(int8), parameter :: OP_DVI_BOP      = -117_int8   ! 139
  integer(int8), parameter :: OP_DVI_EOP      = -116_int8   ! 140
  integer(int8), parameter :: OP_DVI_PUSH     = -115_int8   ! 141
  integer(int8), parameter :: OP_DVI_POP      = -114_int8   ! 142
  integer(int8), parameter :: OP_DVI_RIGHT4   = -110_int8   ! 146
  integer(int8), parameter :: OP_DVI_DOWN4    = -96_int8    ! 160
  integer(int8), parameter :: OP_DVI_FNT1     = -21_int8    ! 235
  integer(int8), parameter :: OP_DVI_FNT_DEF1 = -13_int8    ! 243
  integer(int8), parameter :: OP_DVI_PRE      = -9_int8     ! 247
  integer(int8), parameter :: OP_DVI_POST     = -8_int8     ! 248
  integer(int8), parameter :: OP_DVI_POST_POST= -7_int8     ! 249
  integer(int8), parameter :: OP_DVI_ID        = 2_int8
  integer(int8), parameter :: OP_DVI_TRAILER_PAD = -33_int8 ! 223

  ! DVI Font Metadata Record
  type :: dvi_font_type
    integer(int32) :: font_num = 0_int32
    integer(int32) :: checksum = 0_int32
    integer(int32) :: scale_sp = 0_int32
    integer(int32) :: design_sp = 0_int32
    character(len=64) :: font_name = ""
  end type dvi_font_type

  ! DVI Document Handle
  type :: dvi_document_type
    integer :: file_unit = -1
    integer(int32) :: byte_offset = 0_int32
    integer(int32) :: page_count = 0_int32
    integer(int32) :: last_bop_offset = -1_int32
    integer(int32) :: max_h_sp = 0_int32
    integer(int32) :: max_v_sp = 0_int32
    integer(int32) :: max_stack_depth = 0_int32
    integer(int32) :: current_stack_depth = 0_int32
    integer(int32) :: active_font_num = -1_int32
    integer :: font_count = 0
    type(dvi_font_type) :: fonts(32)
    logical :: page_open = .false.
    character(len=256) :: filename = ""
  end type dvi_document_type

contains

  ! Helper procedure: Write single byte to binary stream
  subroutine write_byte(unit_num, b_val, offset_acc, status)
    integer, intent(in) :: unit_num
    integer(int8), intent(in) :: b_val
    integer(int32), intent(inout) :: offset_acc
    integer, intent(out) :: status

    write(unit_num, iostat=status) b_val
    if (status == 0) then
      offset_acc = offset_acc + 1_int32
    end if
  end subroutine write_byte

  ! Helper procedure: Write 32-bit big-endian integer to binary stream
  subroutine write_int32_be(unit_num, val, offset_acc, status)
    integer, intent(in) :: unit_num
    integer(int32), intent(in) :: val
    integer(int32), intent(inout) :: offset_acc
    integer, intent(out) :: status
    integer(int8) :: b(4)

    b(1) = int(iand(ishft(val, -24), 255_int32), int8)
    b(2) = int(iand(ishft(val, -16), 255_int32), int8)
    b(3) = int(iand(ishft(val, -8), 255_int32), int8)
    b(4) = int(iand(val, 255_int32), int8)

    write(unit_num, iostat=status) b
    if (status == 0) then
      offset_acc = offset_acc + 4_int32
    end if
  end subroutine write_int32_be

  ! Helper procedure: Write font definition record to stream
  subroutine write_font_def(unit_num, font_rec, offset_acc, status)
    integer, intent(in) :: unit_num
    type(dvi_font_type), intent(in) :: font_rec
    integer(int32), intent(inout) :: offset_acc
    integer, intent(out) :: status
    integer :: name_len, idx
    integer(int8) :: b_code, b_len, b_zero

    name_len = len_trim(font_rec%font_name)
    b_code = OP_DVI_FNT_DEF1
    b_zero = 0_int8
    b_len = int(name_len, int8)

    call write_byte(unit_num, b_code, offset_acc, status)
    if (status /= 0) return

    b_code = int(iand(font_rec%font_num, 255_int32), int8)
    call write_byte(unit_num, b_code, offset_acc, status)
    if (status /= 0) return

    call write_int32_be(unit_num, font_rec%checksum, offset_acc, status)
    if (status /= 0) return

    call write_int32_be(unit_num, font_rec%scale_sp, offset_acc, status)
    if (status /= 0) return

    call write_int32_be(unit_num, font_rec%design_sp, offset_acc, status)
    if (status /= 0) return

    call write_byte(unit_num, b_zero, offset_acc, status)
    if (status /= 0) return

    call write_byte(unit_num, b_len, offset_acc, status)
    if (status /= 0) return

    do idx = 1, name_len
      b_code = int(iachar(font_rec%font_name(idx:idx)), int8)
      call write_byte(unit_num, b_code, offset_acc, status)
      if (status /= 0) return
    end do
  end subroutine write_font_def

  ! Initialize DVI Document and write Preamble
  subroutine dvi_init(doc, filename, status)
    type(dvi_document_type), intent(out) :: doc
    character(len=*), intent(in) :: filename
    integer, intent(out) :: status

    integer :: unit_num, idx
    character(len=32) :: comment
    integer :: c_len
    integer(int8) :: b_val

    comment = "TeS/Iris Engine DVI Output"
    c_len = len_trim(comment)
    status = 0

    open(newunit=unit_num, file=trim(filename), access='stream', &
         form='unformatted', status='replace', iostat=status)

    if (status /= 0) return

    doc%file_unit = unit_num
    doc%filename = trim(filename)
    doc%byte_offset = 0_int32
    doc%page_count = 0_int32
    doc%last_bop_offset = -1_int32

    ! Write Preamble (pre)
    call write_byte(unit_num, OP_DVI_PRE, doc%byte_offset, status)
    if (status /= 0) return

    call write_byte(unit_num, OP_DVI_ID, doc%byte_offset, status)
    if (status /= 0) return

    ! TeX standard numerator and denominator (25400000 / 473628672 sp per 100nm)
    call write_int32_be(unit_num, 25400000_int32, doc%byte_offset, status)
    if (status /= 0) return

    call write_int32_be(unit_num, 473628672_int32, doc%byte_offset, status)
    if (status /= 0) return

    ! Magnification (1000)
    call write_int32_be(unit_num, 1000_int32, doc%byte_offset, status)
    if (status /= 0) return

    ! Comment length and string
    b_val = int(c_len, int8)
    call write_byte(unit_num, b_val, doc%byte_offset, status)
    if (status /= 0) return

    do idx = 1, c_len
      b_val = int(iachar(comment(idx:idx)), int8)
      call write_byte(unit_num, b_val, doc%byte_offset, status)
      if (status /= 0) return
    end do
  end subroutine dvi_init

  ! Begin DVI Page (bop)
  subroutine dvi_begin_page(doc, count0, status)
    type(dvi_document_type), intent(inout) :: doc
    integer(int32), intent(in) :: count0
    integer, intent(out) :: status

    integer(int32) :: this_bop_offset, prev_bop, c_zero
    integer :: idx

    status = 0
    c_zero = 0_int32
    this_bop_offset = doc%byte_offset
    prev_bop = doc%last_bop_offset

    call write_byte(doc%file_unit, OP_DVI_BOP, doc%byte_offset, status)
    if (status /= 0) return

    ! Write \count0 to \count9
    call write_int32_be(doc%file_unit, count0, doc%byte_offset, status)
    if (status /= 0) return

    do idx = 1, 9
      call write_int32_be(doc%file_unit, c_zero, doc%byte_offset, status)
      if (status /= 0) return
    end do

    ! Write pointer to previous BOP
    call write_int32_be(doc%file_unit, prev_bop, doc%byte_offset, status)
    if (status /= 0) return

    doc%last_bop_offset = this_bop_offset
    doc%page_count = doc%page_count + 1_int32
    doc%page_open = .true.
    doc%current_stack_depth = 0_int32
  end subroutine dvi_begin_page

  ! End DVI Page (eop)
  subroutine dvi_end_page(doc, status)
    type(dvi_document_type), intent(inout) :: doc
    integer, intent(out) :: status

    status = 0
    if (.not. doc%page_open) return

    call write_byte(doc%file_unit, OP_DVI_EOP, doc%byte_offset, status)
    if (status == 0) then
      doc%page_open = .false.
    end if
  end subroutine dvi_end_page

  ! Write Single Character
  subroutine dvi_write_char(doc, char_code, status)
    type(dvi_document_type), intent(inout) :: doc
    integer, intent(in) :: char_code
    integer, intent(out) :: status

    integer(int8) :: b_val

    status = 0
    if (char_code >= 0 .and. char_code <= 127) then
      b_val = int(char_code, int8)
      call write_byte(doc%file_unit, b_val, doc%byte_offset, status)
    else
      ! Fallback for extended character sets using fnt/set opcodes
      b_val = int(iand(char_code, 255), int8)
      call write_byte(doc%file_unit, b_val, doc%byte_offset, status)
    end if
  end subroutine dvi_write_char

  ! Write Rule Box (set_rule)
  subroutine dvi_write_rule(doc, height_sp, width_sp, status)
    type(dvi_document_type), intent(inout) :: doc
    integer(int32), intent(in) :: height_sp
    integer(int32), intent(in) :: width_sp
    integer, intent(out) :: status

    status = 0
    call write_byte(doc%file_unit, OP_DVI_SET_RULE, doc%byte_offset, status)
    if (status /= 0) return

    call write_int32_be(doc%file_unit, height_sp, doc%byte_offset, status)
    if (status /= 0) return

    call write_int32_be(doc%file_unit, width_sp, doc%byte_offset, status)
  end subroutine dvi_write_rule

  ! Register and Write Font Definition
  subroutine dvi_define_font(doc, font_num, checksum, scale_sp, design_sp, font_name, status)
    type(dvi_document_type), intent(inout) :: doc
    integer(int32), intent(in) :: font_num
    integer(int32), intent(in) :: checksum
    integer(int32), intent(in) :: scale_sp
    integer(int32), intent(in) :: design_sp
    character(len=*), intent(in) :: font_name
    integer, intent(out) :: status

    status = 0
    if (doc%font_count < 32) then
      doc%font_count = doc%font_count + 1
      doc%fonts(doc%font_count)%font_num = font_num
      doc%fonts(doc%font_count)%checksum = checksum
      doc%fonts(doc%font_count)%scale_sp = scale_sp
      doc%fonts(doc%font_count)%design_sp = design_sp
      doc%fonts(doc%font_count)%font_name = trim(font_name)

      call write_font_def(doc%file_unit, doc%fonts(doc%font_count), doc%byte_offset, status)
    end if
  end subroutine dvi_define_font

  ! Select Active Font
  subroutine dvi_select_font(doc, font_num, status)
    type(dvi_document_type), intent(inout) :: doc
    integer(int32), intent(in) :: font_num
    integer, intent(out) :: status

    integer(int8) :: b_val

    status = 0
    if (font_num >= 0_int32 .and. font_num <= 63_int32) then
      ! fnt_num_0 to fnt_num_63 (171 to 234)
      b_val = int(171_int32 + font_num, int8)
      call write_byte(doc%file_unit, b_val, doc%byte_offset, status)
    else
      call write_byte(doc%file_unit, OP_DVI_FNT1, doc%byte_offset, status)
      if (status /= 0) return
      b_val = int(iand(font_num, 255_int32), int8)
      call write_byte(doc%file_unit, b_val, doc%byte_offset, status)
    end if

    if (status == 0) then
      doc%active_font_num = font_num
    end if
  end subroutine dvi_select_font

  ! Move Right (right4)
  subroutine dvi_move_right(doc, distance_sp, status)
    type(dvi_document_type), intent(inout) :: doc
    integer(int32), intent(in) :: distance_sp
    integer, intent(out) :: status

    status = 0
    call write_byte(doc%file_unit, OP_DVI_RIGHT4, doc%byte_offset, status)
    if (status /= 0) return

    call write_int32_be(doc%file_unit, distance_sp, doc%byte_offset, status)
  end subroutine dvi_move_right

  ! Move Down (down4)
  subroutine dvi_move_down(doc, distance_sp, status)
    type(dvi_document_type), intent(inout) :: doc
    integer(int32), intent(in) :: distance_sp
    integer, intent(out) :: status

    status = 0
    call write_byte(doc%file_unit, OP_DVI_DOWN4, doc%byte_offset, status)
    if (status /= 0) return

    call write_int32_be(doc%file_unit, distance_sp, doc%byte_offset, status)
  end subroutine dvi_move_down

  ! Push Stack State
  subroutine dvi_push(doc, status)
    type(dvi_document_type), intent(inout) :: doc
    integer, intent(out) :: status

    status = 0
    call write_byte(doc%file_unit, OP_DVI_PUSH, doc%byte_offset, status)
    if (status == 0) then
      doc%current_stack_depth = doc%current_stack_depth + 1_int32
      if (doc%current_stack_depth > doc%max_stack_depth) then
        doc%max_stack_depth = doc%current_stack_depth
      end if
    end if
  end subroutine dvi_push

  ! Pop Stack State
  subroutine dvi_pop(doc, status)
    type(dvi_document_type), intent(inout) :: doc
    integer, intent(out) :: status

    status = 0
    call write_byte(doc%file_unit, OP_DVI_POP, doc%byte_offset, status)
    if (status == 0 .and. doc%current_stack_depth > 0_int32) then
      doc%current_stack_depth = doc%current_stack_depth - 1_int32
    end if
  end subroutine dvi_pop

  ! Finalize and Close DVI File (post, font definitions, post_post)
  subroutine dvi_close(doc, status)
    type(dvi_document_type), intent(inout) :: doc
    integer, intent(out) :: status

    integer(int32) :: post_offset, post_post_offset
    integer(int16) :: total_pages_16, stack_depth_16
    integer :: idx, pad_count

    status = 0
    if (doc%file_unit < 0) return

    if (doc%page_open) then
      call dvi_end_page(doc, status)
      if (status /= 0) return
    end if

    post_offset = doc%byte_offset

    ! Write post command
    call write_byte(doc%file_unit, OP_DVI_POST, doc%byte_offset, status)
    if (status /= 0) return

    ! Pointer to last BOP
    call write_int32_be(doc%file_unit, doc%last_bop_offset, doc%byte_offset, status)
    if (status /= 0) return

    ! Numerator and Denominator
    call write_int32_be(doc%file_unit, 25400000_int32, doc%byte_offset, status)
    if (status /= 0) return

    call write_int32_be(doc%file_unit, 473628672_int32, doc%byte_offset, status)
    if (status /= 0) return

    ! Magnification
    call write_int32_be(doc%file_unit, 1000_int32, doc%byte_offset, status)
    if (status /= 0) return

    ! Max vertical and max horizontal dimensions (e.g. 10 inches in sp = 10 * 72.27 * 65536)
    call write_int32_be(doc%file_unit, 473628672_int32, doc%byte_offset, status)
    if (status /= 0) return

    call write_int32_be(doc%file_unit, 473628672_int32, doc%byte_offset, status)
    if (status /= 0) return

    ! Max stack depth (2 bytes big endian)
    stack_depth_16 = int(doc%max_stack_depth, int16)
    call write_byte(doc%file_unit, int(iand(ishft(stack_depth_16, -8), 255_int16), int8), doc%byte_offset, status)
    call write_byte(doc%file_unit, int(iand(stack_depth_16, 255_int16), int8), doc%byte_offset, status)
    if (status /= 0) return

    ! Total page count (2 bytes big endian)
    total_pages_16 = int(doc%page_count, int16)
    call write_byte(doc%file_unit, int(iand(ishft(total_pages_16, -8), 255_int16), int8), doc%byte_offset, status)
    call write_byte(doc%file_unit, int(iand(total_pages_16, 255_int16), int8), doc%byte_offset, status)
    if (status /= 0) return

    ! Repeat Font Definitions in Postamble
    do idx = 1, doc%font_count
      call write_font_def(doc%file_unit, doc%fonts(idx), doc%byte_offset, status)
      if (status /= 0) return
    end do

    post_post_offset = doc%byte_offset

    ! Write post_post command
    call write_byte(doc%file_unit, OP_DVI_POST_POST, doc%byte_offset, status)
    if (status /= 0) return

    ! Pointer to post command
    call write_int32_be(doc%file_unit, post_offset, doc%byte_offset, status)
    if (status /= 0) return

    ! DVI ID byte
    call write_byte(doc%file_unit, OP_DVI_ID, doc%byte_offset, status)
    if (status /= 0) return

    ! Trailer padding bytes (minimum 4 padding bytes of DVI_TRAILER_PAD / 223)
    pad_count = 4 + int(iand(doc%byte_offset + 4_int32, 3_int32))
    do idx = 1, pad_count
      call write_byte(doc%file_unit, OP_DVI_TRAILER_PAD, doc%byte_offset, status)
      if (status /= 0) return
    end do

    close(doc%file_unit)
    doc%file_unit = -1
  end subroutine dvi_close

end module iris_dvi
