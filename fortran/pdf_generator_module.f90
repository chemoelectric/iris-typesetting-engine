!===============================================================================
! Module: pdf_generator_module
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Imperative Procedural API for PDF 1.7 Specification Engine
! Compliance: Single-entry/single-exit control constructs, zero goto constructs.
!             McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
module pdf_generator_module
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  implicit none
  private

  ! Public API Types
  public :: pdf_document_type

  ! Public API Procedures
  public :: pdf_init
  public :: pdf_add_page
  public :: pdf_write_text
  public :: pdf_draw_rect
  public :: pdf_close

  ! Constants
  integer(kind=int32), parameter :: MAX_OBJECTS = 1000
  integer(kind=int32), parameter :: MAX_PAGES = 100
  integer(kind=int32), parameter :: MAX_STREAM_LEN = 65536
  character(len=*), parameter :: PDF_HEADER = "%PDF-1.7"
  character(len=*), parameter :: PDF_BINARY_COMMENT = "%" // char(226) // char(227) // char(207) // char(211)

  ! Derived Type Definition for PDF Document Context
  type :: pdf_document_type
    character(len=256) :: filename
    integer(kind=int32) :: unit_num
    integer(kind=int32) :: object_count
    integer(kind=int64) :: byte_offset
    integer(kind=int64), dimension(MAX_OBJECTS) :: xref_offsets
    integer(kind=int32) :: page_count
    integer(kind=int32), dimension(MAX_PAGES) :: page_object_ids
    integer(kind=int32), dimension(MAX_PAGES) :: stream_object_ids
    character(len=MAX_STREAM_LEN) :: current_stream
    integer(kind=int32) :: stream_len
    real(kind=real64) :: current_page_width
    real(kind=real64) :: current_page_height
  end type pdf_document_type

contains

  !-----------------------------------------------------------------------------
  ! Subroutine: pdf_init
  ! Purpose: Initializes PDF document context and opens file unit.
  ! Control Structure: Single-entry / single-exit. Complexity <= 3.
  !-----------------------------------------------------------------------------
  subroutine pdf_init(pdf, out_filename, status)
    type(pdf_document_type), intent(out) :: pdf
    character(len=*), intent(in) :: out_filename
    integer(kind=int32), intent(out) :: status

    pdf%filename = trim(out_filename)
    pdf%unit_num = 99
    pdf%object_count = 0
    pdf%byte_offset = 0_int64
    pdf%xref_offsets = 0_int64
    pdf%page_count = 0
    pdf%page_object_ids = 0
    pdf%stream_object_ids = 0
    pdf%current_stream = ""
    pdf%stream_len = 0
    pdf%current_page_width = 612.0_real64   ! Default Letter width (pts)
    pdf%current_page_height = 792.0_real64  ! Default Letter height (pts)

    open(unit=pdf%unit_num, file=trim(pdf%filename), status="replace", &
         action="write", access="stream", iostat=status)

    if (status == 0) then
      call write_raw_string(pdf, PDF_HEADER // new_line('a'))
      call write_raw_string(pdf, PDF_BINARY_COMMENT // new_line('a'))
    end if

  end subroutine pdf_init

  !-----------------------------------------------------------------------------
  ! Subroutine: pdf_add_page
  ! Purpose: Flushes previous page stream if open, allocates new page context.
  ! Control Structure: Single-entry / single-exit. Complexity <= 5.
  !-----------------------------------------------------------------------------
  subroutine pdf_add_page(pdf, width, height)
    type(pdf_document_type), intent(inout) :: pdf
    real(kind=real64), intent(in) :: width
    real(kind=real64), intent(in) :: height

    ! Flush existing page stream if one is active
    if (pdf%page_count > 0) then
      call flush_current_page_objects(pdf)
    end if

    pdf%page_count = pdf%page_count + 1
    pdf%current_page_width = width
    pdf%current_page_height = height
    pdf%current_stream = ""
    pdf%stream_len = 0

  end subroutine pdf_add_page

  !-----------------------------------------------------------------------------
  ! Subroutine: pdf_write_text
  ! Purpose: Appends text rendering operator (BT ... ET) to active stream.
  ! Control Structure: Single-entry / single-exit. Complexity <= 4.
  !-----------------------------------------------------------------------------
  subroutine pdf_write_text(pdf, x, y, font_size, text_content)
    type(pdf_document_type), intent(inout) :: pdf
    real(kind=real64), intent(in) :: x
    real(kind=real64), intent(in) :: y
    real(kind=real64), intent(in) :: font_size
    character(len=*), intent(in) :: text_content

    character(len=512) :: buffer
    integer(kind=int32) :: buf_len

    write(buffer, '(A,F8.2,A,F8.2,A,F6.2,A,A,A)') &
      "BT /F1 ", font_size, " Tf ", x, " ", y, " Td (", trim(text_content), ") Tj ET" // new_line('a')
    
    buf_len = len_trim(buffer)
    call append_to_stream(pdf, buffer(1:buf_len))

  end subroutine pdf_write_text

  !-----------------------------------------------------------------------------
  ! Subroutine: pdf_draw_rect
  ! Purpose: Appends rectangle drawing operators (re f/S) to active stream.
  ! Control Structure: Single-entry / single-exit. Complexity <= 4.
  !-----------------------------------------------------------------------------
  subroutine pdf_draw_rect(pdf, x, y, w, h, fill_flag)
    type(pdf_document_type), intent(inout) :: pdf
    real(kind=real64), intent(in) :: x
    real(kind=real64), intent(in) :: y
    real(kind=real64), intent(in) :: w
    real(kind=real64), intent(in) :: h
    logical, intent(in) :: fill_flag

    character(len=256) :: buffer
    integer(kind=int32) :: buf_len

    if (fill_flag) then
      write(buffer, '(F8.2,A,F8.2,A,F8.2,A,F8.2,A)') x, " ", y, " ", w, " ", h, " re f" // new_line('a')
    else
      write(buffer, '(F8.2,A,F8.2,A,F8.2,A,F8.2,A)') x, " ", y, " ", w, " ", h, " re S" // new_line('a')
    end if

    buf_len = len_trim(buffer)
    call append_to_stream(pdf, buffer(1:buf_len))

  end subroutine pdf_draw_rect

  !-----------------------------------------------------------------------------
  ! Subroutine: pdf_close
  ! Purpose: Flushes open streams, writes catalog, pages, font, xref & trailer.
  ! Control Structure: Single-entry / single-exit. Complexity <= 6.
  !-----------------------------------------------------------------------------
  subroutine pdf_close(pdf, status)
    type(pdf_document_type), intent(inout) :: pdf
    integer(kind=int32), intent(out) :: status

    integer(kind=int32) :: catalog_id
    integer(kind=int32) :: pages_id
    integer(kind=int32) :: font_id
    integer(kind=int64) :: xref_start_offset

    ! Flush final page if present
    if (pdf%page_count > 0) then
      call flush_current_page_objects(pdf)
    end if

    ! Write Document Catalog (Obj 1)
    catalog_id = next_object_id(pdf)
    call record_object_offset(pdf, catalog_id)
    call write_raw_string(pdf, "1 0 obj" // new_line('a') // "<< /Type /Catalog /Pages 2 0 R >>" // new_line('a') // "endobj" // new_line('a'))

    ! Write Pages Tree (Obj 2)
    pages_id = next_object_id(pdf)
    call record_object_offset(pdf, pages_id)
    call write_pages_tree_object(pdf)

    ! Write Standard Base Font (Obj 3)
    font_id = next_object_id(pdf)
    call record_object_offset(pdf, font_id)
    call write_raw_string(pdf, "3 0 obj" // new_line('a') // &
      "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>" // new_line('a') // "endobj" // new_line('a'))

    ! Write Cross-Reference Table
    xref_start_offset = pdf%byte_offset
    call write_xref_table(pdf)

    ! Write Trailer Dictionary
    call write_trailer_dict(pdf, xref_start_offset)

    close(unit=pdf%unit_num, iostat=status)

  end subroutine pdf_close

  !=============================================================================
  ! PRIVATE HELPER PROCEDURES
  !=============================================================================

  function next_object_id(pdf) result(obj_id)
    type(pdf_document_type), intent(inout) :: pdf
    integer(kind=int32) :: obj_id

    pdf%object_count = pdf%object_count + 1
    obj_id = pdf%object_count

  end function next_object_id

  subroutine record_object_offset(pdf, obj_id)
    type(pdf_document_type), intent(inout) :: pdf
    integer(kind=int32), intent(in) :: obj_id

    if (obj_id >= 1 .and. obj_id <= MAX_OBJECTS) then
      pdf%xref_offsets(obj_id) = pdf%byte_offset
    end if

  end subroutine record_object_offset

  subroutine append_to_stream(pdf, str)
    type(pdf_document_type), intent(inout) :: pdf
    character(len=*), intent(in) :: str
    integer(kind=int32) :: str_len

    str_len = len(str)
    if (pdf%stream_len + str_len <= MAX_STREAM_LEN) then
      pdf%current_stream(pdf%stream_len + 1 : pdf%stream_len + str_len) = str
      pdf%stream_len = pdf%stream_len + str_len
    end if

  end subroutine append_to_stream

  subroutine flush_current_page_objects(pdf)
    type(pdf_document_type), intent(inout) :: pdf

    integer(kind=int32) :: stream_obj_id
    integer(kind=int32) :: page_obj_id
    character(len=256) :: header_buf

    ! 1. Write Content Stream Object
    stream_obj_id = next_object_id(pdf)
    call record_object_offset(pdf, stream_obj_id)
    pdf%stream_object_ids(pdf%page_count) = stream_obj_id

    write(header_buf, '(I0,A,I0,A)') stream_obj_id, " 0 obj" // new_line('a') // "<< /Length ", pdf%stream_len, " >>" // new_line('a') // "stream" // new_line('a')
    call write_raw_string(pdf, trim(header_buf))
    call write_raw_string(pdf, pdf%current_stream(1:pdf%stream_len))
    call write_raw_string(pdf, new_line('a') // "endstream" // new_line('a') // "endobj" // new_line('a'))

    ! 2. Write Page Object
    page_obj_id = next_object_id(pdf)
    call record_object_offset(pdf, page_obj_id)
    pdf%page_object_ids(pdf%page_count) = page_obj_id

    write(header_buf, '(I0,A,F7.2,A,F7.2,A,I0,A)') &
      page_obj_id, " 0 obj" // new_line('a') // &
      "<< /Type /Page /Parent 2 0 R /Resources << /Font << /F1 3 0 R >> >> /MediaBox [0 0 ", &
      pdf%current_page_width, " ", pdf%current_page_height, "] /Contents ", stream_obj_id, " 0 R >>" // new_line('a') // &
      "endobj" // new_line('a')
    
    call write_raw_string(pdf, trim(header_buf))

  end subroutine flush_current_page_objects

  subroutine write_pages_tree_object(pdf)
    type(pdf_document_type), intent(inout) :: pdf

    character(len=2048) :: kids_buf
    character(len=64) :: single_ref
    integer(kind=int32) :: idx

    kids_buf = "2 0 obj" // new_line('a') // "<< /Type /Pages /Count "
    write(single_ref, '(I0)') pdf%page_count
    kids_buf = trim(kids_buf) // trim(single_ref) // " /Kids ["

    do idx = 1, pdf%page_count
      write(single_ref, '(I0,A)') pdf%page_object_ids(idx), " 0 R "
      kids_buf = trim(kids_buf) // trim(single_ref)
    end do

    kids_buf = trim(kids_buf) // "] >>" // new_line('a') // "endobj" // new_line('a')
    call write_raw_string(pdf, trim(kids_buf))

  end subroutine write_pages_tree_object

  subroutine write_xref_table(pdf)
    type(pdf_document_type), intent(inout) :: pdf

    character(len=128) :: entry_buf
    integer(kind=int32) :: i

    call write_raw_string(pdf, "xref" // new_line('a'))
    write(entry_buf, '(A,I0)') "0 ", pdf%object_count + 1
    call write_raw_string(pdf, trim(entry_buf) // new_line('a'))

    ! Object 0 special entry
    call write_raw_string(pdf, "0000000000 65535 f " // new_line('a'))

    ! Objects 1 to N entries
    do i = 1, pdf%object_count
      write(entry_buf, '(I10.10,A)') pdf%xref_offsets(i), " 00000 n "
      call write_raw_string(pdf, trim(entry_buf) // new_line('a'))
    end do

  end subroutine write_xref_table

  subroutine write_trailer_dict(pdf, xref_offset)
    type(pdf_document_type), intent(inout) :: pdf
    integer(kind=int64), intent(in) :: xref_offset

    character(len=256) :: trailer_buf

    write(trailer_buf, '(A,I0,A,I0,A)') &
      "trailer" // new_line('a') // "<< /Size ", pdf%object_count + 1, " /Root 1 0 R >>" // new_line('a') // &
      "startxref" // new_line('a'), xref_offset, new_line('a') // "%%EOF" // new_line('a')

    call write_raw_string(pdf, trim(trailer_buf))

  end subroutine write_trailer_dict

  subroutine write_raw_string(pdf, str)
    type(pdf_document_type), intent(inout) :: pdf
    character(len=*), intent(in) :: str

    integer(kind=int32) :: str_len

    str_len = len(str)
    write(pdf%unit_num) str
    pdf%byte_offset = pdf%byte_offset + int(str_len, kind=int64)

  end subroutine write_raw_string

end module pdf_generator_module
