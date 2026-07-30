!===============================================================================
! Module: iris_c_pdf_io
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010) & ISO_C_BINDING
! Architecture: Fortran ISO_C_BINDING Bridge to CapyPDF 0.21.0 C23 Binding Layer
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
module iris_c_pdf_io
  use, intrinsic :: iso_c_binding, only: c_ptr, c_null_ptr, c_char, c_int8_t, c_int32_t, &
                                         c_int64_t, c_double, c_size_t, c_null_char, c_associated
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  implicit none
  private

  public :: pdf_c_stream_type
  public :: pdf_c_open
  public :: pdf_c_write_bytes
  public :: pdf_c_write_string
  public :: pdf_c_write_int
  public :: pdf_c_capy_add_page
  public :: pdf_c_capy_write_text
  public :: pdf_c_capy_draw_rect
  public :: pdf_c_capy_embed_font
  public :: pdf_c_get_offset
  public :: pdf_c_close

  type :: pdf_c_stream_type
    type(c_ptr) :: handle = c_null_ptr
  end type pdf_c_stream_type

  interface
    function c_iris_pdf_open_stream(filename) result(stream_ptr) bind(c, name="iris_pdf_open_stream")
      import :: c_ptr, c_char
      character(kind=c_char), intent(in) :: filename(*)
      type(c_ptr) :: stream_ptr
    end function c_iris_pdf_open_stream

    function c_iris_pdf_write_bytes(stream_ptr, data, length) result(status) bind(c, name="iris_pdf_write_bytes")
      import :: c_ptr, c_int8_t, c_size_t, c_int32_t
      type(c_ptr), value :: stream_ptr
      integer(kind=c_int8_t), intent(in) :: data(*)
      integer(kind=c_size_t), value :: length
      integer(kind=c_int32_t) :: status
    end function c_iris_pdf_write_bytes

    function c_iris_pdf_write_char_bytes(stream_ptr, data, length) result(status) bind(c, name="iris_pdf_write_bytes")
      import :: c_ptr, c_char, c_size_t, c_int32_t
      type(c_ptr), value :: stream_ptr
      character(kind=c_char), intent(in) :: data(*)
      integer(kind=c_size_t), value :: length
      integer(kind=c_int32_t) :: status
    end function c_iris_pdf_write_char_bytes

    function c_iris_pdf_write_string(stream_ptr, str) result(status) bind(c, name="iris_pdf_write_string")
      import :: c_ptr, c_char, c_int32_t
      type(c_ptr), value :: stream_ptr
      character(kind=c_char), intent(in) :: str(*)
      integer(kind=c_int32_t) :: status
    end function c_iris_pdf_write_string

    function c_iris_pdf_write_formatted_int(stream_ptr, val) result(status) bind(c, name="iris_pdf_write_formatted_int")
      import :: c_ptr, c_int64_t, c_int32_t
      type(c_ptr), value :: stream_ptr
      integer(kind=c_int64_t), value :: val
      integer(kind=c_int32_t) :: status
    end function c_iris_pdf_write_formatted_int

    function c_iris_pdf_capy_add_page(stream_ptr, width, height) result(status) bind(c, name="iris_pdf_capy_add_page")
      import :: c_ptr, c_double, c_int32_t
      type(c_ptr), value :: stream_ptr
      real(kind=c_double), value :: width, height
      integer(kind=c_int32_t) :: status
    end function c_iris_pdf_capy_add_page

    function c_iris_pdf_capy_write_text(stream_ptr, x, y, font_size, text) result(status) bind(c, name="iris_pdf_capy_write_text")
      import :: c_ptr, c_double, c_char, c_int32_t
      type(c_ptr), value :: stream_ptr
      real(kind=c_double), value :: x, y, font_size
      character(kind=c_char), intent(in) :: text(*)
      integer(kind=c_int32_t) :: status
    end function c_iris_pdf_capy_write_text

    function c_iris_pdf_capy_draw_rect(stream_ptr, x, y, w, h, fill_flag) result(status) bind(c, name="iris_pdf_capy_draw_rect")
      import :: c_ptr, c_double, c_int32_t
      type(c_ptr), value :: stream_ptr
      real(kind=c_double), value :: x, y, w, h
      integer(kind=c_int32_t), value :: fill_flag
      integer(kind=c_int32_t) :: status
    end function c_iris_pdf_capy_draw_rect

    function c_iris_pdf_capy_embed_font(stream_ptr, font_name, data, len) result(status) bind(c, name="iris_pdf_capy_embed_font")
      import :: c_ptr, c_char, c_int8_t, c_size_t, c_int32_t
      type(c_ptr), value :: stream_ptr
      character(kind=c_char), intent(in) :: font_name(*)
      integer(kind=c_int8_t), intent(in) :: data(*)
      integer(kind=c_size_t), value :: len
      integer(kind=c_int32_t) :: status
    end function c_iris_pdf_capy_embed_font

    function c_iris_pdf_get_offset(stream_ptr) result(offset) bind(c, name="iris_pdf_get_offset")
      import :: c_ptr, c_int64_t
      type(c_ptr), value :: stream_ptr
      integer(kind=c_int64_t) :: offset
    end function c_iris_pdf_get_offset

    function c_iris_pdf_close_stream(stream_ptr) result(status) bind(c, name="iris_pdf_close_stream")
      import :: c_ptr, c_int32_t
      type(c_ptr), value :: stream_ptr
      integer(kind=c_int32_t) :: status
    end function c_iris_pdf_close_stream
  end interface

contains

  !-----------------------------------------------------------------------------
  ! Subroutine: pdf_c_open
  ! Purpose: Opens binary PDF file via CapyPDF 0.21.0 C23 stream I/O backend
  ! Control Structure: Single-entry / single-exit. Complexity <= 3.
  !-----------------------------------------------------------------------------
  subroutine pdf_c_open(stream, filename, status)
    type(pdf_c_stream_type), intent(out) :: stream
    character(len=*), intent(in)         :: filename
    integer(kind=int32), intent(out)     :: status

    character(kind=c_char, len=len_trim(filename)+1) :: c_filename

    c_filename = trim(filename) // c_null_char
    stream%handle = c_iris_pdf_open_stream(c_filename)

    if (c_associated(stream%handle)) then
      status = 0
    else
      status = -1
    end if

  end subroutine pdf_c_open

  !-----------------------------------------------------------------------------
  ! Subroutine: pdf_c_write_bytes
  ! Purpose: Writes raw byte buffer via C23 stream layer
  ! Control Structure: Single-entry / single-exit. Complexity <= 3.
  !-----------------------------------------------------------------------------
  subroutine pdf_c_write_bytes(stream, data, length, status)
    type(pdf_c_stream_type), intent(in) :: stream
    integer(kind=c_int8_t), intent(in)  :: data(*)
    integer(kind=int64), intent(in)     :: length
    integer(kind=int32), intent(out)    :: status

    if (c_associated(stream%handle)) then
      status = int(c_iris_pdf_write_bytes(stream%handle, data, int(length, c_size_t)), int32)
    else
      status = -1
    end if

  end subroutine pdf_c_write_bytes

  !-----------------------------------------------------------------------------
  ! Subroutine: pdf_c_write_string
  ! Purpose: Writes Fortran string to C binary stream without padding
  ! Control Structure: Single-entry / single-exit. Complexity <= 3.
  !-----------------------------------------------------------------------------
  subroutine pdf_c_write_string(stream, str, status)
    type(pdf_c_stream_type), intent(in) :: stream
    character(len=*), intent(in)         :: str
    integer(kind=int32), intent(out)     :: status

    integer(kind=c_size_t) :: s_len

    if (c_associated(stream%handle)) then
      s_len = int(len(str), c_size_t)
      if (s_len > 0_c_size_t) then
        status = int(c_iris_pdf_write_char_bytes(stream%handle, str, s_len), int32)
      else
        status = 0
      end if
    else
      status = -1
    end if

  end subroutine pdf_c_write_string

  !-----------------------------------------------------------------------------
  ! Subroutine: pdf_c_write_int
  ! Purpose: Formats integer tightly without spaces via C stream layer
  ! Control Structure: Single-entry / single-exit. Complexity <= 3.
  !-----------------------------------------------------------------------------
  subroutine pdf_c_write_int(stream, val, status)
    type(pdf_c_stream_type), intent(in) :: stream
    integer(kind=int64), intent(in)     :: val
    integer(kind=int32), intent(out)    :: status

    if (c_associated(stream%handle)) then
      status = int(c_iris_pdf_write_formatted_int(stream%handle, int(val, c_int64_t)), int32)
    else
      status = -1
    end if

  end subroutine pdf_c_write_int

  !-----------------------------------------------------------------------------
  ! Subroutine: pdf_c_capy_add_page
  ! Purpose: Adds page using CapyPDF 0.21.0 C API binding
  ! Control Structure: Single-entry / single-exit. Complexity <= 3.
  !-----------------------------------------------------------------------------
  subroutine pdf_c_capy_add_page(stream, width, height, status)
    type(pdf_c_stream_type), intent(in) :: stream
    real(kind=real64), intent(in)       :: width, height
    integer(kind=int32), intent(out)    :: status

    if (c_associated(stream%handle)) then
      status = int(c_iris_pdf_capy_add_page(stream%handle, real(width, c_double), real(height, c_double)), int32)
    else
      status = -1
    end if

  end subroutine pdf_c_capy_add_page

  !-----------------------------------------------------------------------------
  ! Subroutine: pdf_c_capy_write_text
  ! Purpose: Writes text using CapyPDF 0.21.0 C API binding
  ! Control Structure: Single-entry / single-exit. Complexity <= 3.
  !-----------------------------------------------------------------------------
  subroutine pdf_c_capy_write_text(stream, x, y, font_size, text_str, status)
    type(pdf_c_stream_type), intent(in) :: stream
    real(kind=real64), intent(in)       :: x, y, font_size
    character(len=*), intent(in)        :: text_str
    integer(kind=int32), intent(out)    :: status

    character(kind=c_char, len=len_trim(text_str)+1) :: c_text

    if (c_associated(stream%handle)) then
      c_text = trim(text_str) // c_null_char
      status = int(c_iris_pdf_capy_write_text(stream%handle, real(x, c_double), real(y, c_double), &
                                               real(font_size, c_double), c_text), int32)
    else
      status = -1
    end if

  end subroutine pdf_c_capy_write_text

  !-----------------------------------------------------------------------------
  ! Subroutine: pdf_c_capy_draw_rect
  ! Purpose: Draws rectangle using CapyPDF 0.21.0 C API binding
  ! Control Structure: Single-entry / single-exit. Complexity <= 3.
  !-----------------------------------------------------------------------------
  subroutine pdf_c_capy_draw_rect(stream, x, y, w, h, fill_flag, status)
    type(pdf_c_stream_type), intent(in) :: stream
    real(kind=real64), intent(in)       :: x, y, w, h
    integer(kind=int32), intent(in)     :: fill_flag
    integer(kind=int32), intent(out)    :: status

    if (c_associated(stream%handle)) then
      status = int(c_iris_pdf_capy_draw_rect(stream%handle, real(x, c_double), real(y, c_double), &
                                              real(w, c_double), real(h, c_double), fill_flag), int32)
    else
      status = -1
    end if

  end subroutine pdf_c_capy_draw_rect

  !-----------------------------------------------------------------------------
  ! Subroutine: pdf_c_capy_embed_font
  ! Purpose: Embeds font binary using CapyPDF 0.21.0 C API binding
  ! Control Structure: Single-entry / single-exit. Complexity <= 3.
  !-----------------------------------------------------------------------------
  subroutine pdf_c_capy_embed_font(stream, font_name, data, len, status)
    type(pdf_c_stream_type), intent(in) :: stream
    character(len=*), intent(in)        :: font_name
    integer(kind=c_int8_t), intent(in)  :: data(*)
    integer(kind=int64), intent(in)     :: len
    integer(kind=int32), intent(out)    :: status

    character(kind=c_char, len=len_trim(font_name)+1) :: c_name

    if (c_associated(stream%handle)) then
      c_name = trim(font_name) // c_null_char
      status = int(c_iris_pdf_capy_embed_font(stream%handle, c_name, data, int(len, c_size_t)), int32)
    else
      status = -1
    end if

  end subroutine pdf_c_capy_embed_font

  !-----------------------------------------------------------------------------
  ! Function: pdf_c_get_offset
  ! Purpose: Queries exact byte offset from CapyPDF C23 stream handle
  ! Control Structure: Single-entry / single-exit. Complexity <= 3.
  !-----------------------------------------------------------------------------
  function pdf_c_get_offset(stream) result(offset)
    type(pdf_c_stream_type), intent(in) :: stream
    integer(kind=int64)                  :: offset

    if (c_associated(stream%handle)) then
      offset = int(c_iris_pdf_get_offset(stream%handle), int64)
    else
      offset = -1_int64
    end if

  end function pdf_c_get_offset

  !-----------------------------------------------------------------------------
  ! Subroutine: pdf_c_close
  ! Purpose: Closes CapyPDF stream handle and serializes output document
  ! Control Structure: Single-entry / single-exit. Complexity <= 3.
  !-----------------------------------------------------------------------------
  subroutine pdf_c_close(stream, status)
    type(pdf_c_stream_type), intent(inout) :: stream
    integer(kind=int32), intent(out)        :: status

    if (c_associated(stream%handle)) then
      status = int(c_iris_pdf_close_stream(stream%handle), int32)
      stream%handle = c_null_ptr
    else
      status = 0
    end if

  end subroutine pdf_c_close

end module iris_c_pdf_io
