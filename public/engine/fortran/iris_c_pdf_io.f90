!===============================================================================
! Module: iris_c_pdf_io
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010) & ISO_C_BINDING
! Architecture: Fortran ISO_C_BINDING Bridge to ISO C23 Binary Stream I/O
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
module iris_c_pdf_io
  use, intrinsic :: iso_c_binding, only: c_ptr, c_null_ptr, c_char, c_int8_t, c_int32_t, &
                                         c_int64_t, c_size_t, c_null_char, c_associated
  use, intrinsic :: iso_fortran_env, only: int32, int64
  implicit none
  private

  public :: pdf_c_stream_type
  public :: pdf_c_open
  public :: pdf_c_write_bytes
  public :: pdf_c_write_string
  public :: pdf_c_write_int
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
  ! Purpose: Opens binary PDF file via ISO C23 stream I/O backend
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
  ! Purpose: Writes raw byte buffer via ISO C23 stream layer
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

    character(kind=c_char, len=len_trim(str)+1) :: c_str

    if (c_associated(stream%handle)) then
      c_str = trim(str) // c_null_char
      status = int(c_iris_pdf_write_string(stream%handle, c_str), int32)
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
  ! Function: pdf_c_get_offset
  ! Purpose: Queries exact byte offset from C23 stream handle
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
  ! Purpose: Closes C23 stream handle and flushes output buffer
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
