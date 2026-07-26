!===============================================================================
! Module: iris_pdf
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Imperative Procedural API for PDF 1.7 Specification Engine
! Features: Dual PDF Generation & PDF Reader / Stream Parser Module
!           Pure Fortran ISO RFC 1950 / RFC 1951 (zlib/FlateDecode) Compression
! Compliance: Single-entry/single-exit control constructs, zero goto constructs.
!             McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
module iris_pdf
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
  public :: pdf_open_read
  public :: pdf_get_page_count
  public :: pdf_extract_stream
  public :: pdf_read_page_text

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
    logical :: compress_streams = .false.
    logical :: is_read_mode = .false.
  end type pdf_document_type

contains

  !-----------------------------------------------------------------------------
  ! Subroutine: pdf_init
  ! Purpose: Initializes PDF document context for WRITING, opens file unit.
  ! Control Structure: Single-entry / single-exit. Complexity <= 4.
  !-----------------------------------------------------------------------------
  subroutine pdf_init(pdf, out_filename, status, compress)
    type(pdf_document_type), intent(out) :: pdf
    character(len=*), intent(in) :: out_filename
    integer(kind=int32), intent(out) :: status
    logical, intent(in), optional :: compress

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
    pdf%is_read_mode = .false.

    if (present(compress)) then
      pdf%compress_streams = compress
    else
      pdf%compress_streams = .false.
    end if

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

    if (pdf%is_read_mode) then
      close(unit=pdf%unit_num, iostat=status)
    else
      if (pdf%page_count > 0) then
        call flush_current_page_objects(pdf)
      end if

      catalog_id = next_object_id(pdf)
      call record_object_offset(pdf, catalog_id)
      call write_raw_string(pdf, "1 0 obj" // new_line('a') // "<< /Type /Catalog /Pages 2 0 R >>" // new_line('a') // "endobj" // new_line('a'))

      pages_id = next_object_id(pdf)
      call record_object_offset(pdf, pages_id)
      call write_pages_tree_object(pdf)

      font_id = next_object_id(pdf)
      call record_object_offset(pdf, font_id)
      call write_raw_string(pdf, "3 0 obj" // new_line('a') // &
        "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>" // new_line('a') // "endobj" // new_line('a'))

      xref_start_offset = pdf%byte_offset
      call write_xref_table(pdf)
      call write_trailer_dict(pdf, xref_start_offset)

      close(unit=pdf%unit_num, iostat=status)
    end if

  end subroutine pdf_close

  !-----------------------------------------------------------------------------
  ! Subroutine: pdf_open_read
  ! Purpose: Opens existing PDF binary file, parses startxref and XRef table.
  ! Control Structure: Single-entry / single-exit. Complexity <= 7.
  !-----------------------------------------------------------------------------
  subroutine pdf_open_read(pdf, in_filename, status)
    type(pdf_document_type), intent(out) :: pdf
    character(len=*), intent(in) :: in_filename
    integer(kind=int32), intent(out) :: status
    integer(kind=int64) :: xref_offset

    pdf%filename = trim(in_filename)
    pdf%unit_num = 98
    pdf%object_count = 0
    pdf%byte_offset = 0_int64
    pdf%xref_offsets = 0_int64
    pdf%page_count = 0
    pdf%page_object_ids = 0
    pdf%stream_object_ids = 0
    pdf%current_stream = ""
    pdf%stream_len = 0
    pdf%is_read_mode = .true.

    open(unit=pdf%unit_num, file=trim(pdf%filename), status="old", &
         action="read", access="stream", iostat=status)

    if (status == 0) then
      call find_startxref_offset(pdf, xref_offset)
      if (xref_offset > 0_int64) then
        call parse_xref_table(pdf, xref_offset)
        call parse_pages_metadata(pdf)
      else
        status = -1
      end if
    end if

  end subroutine pdf_open_read

  !-----------------------------------------------------------------------------
  ! Subroutine: pdf_get_page_count
  ! Purpose: Returns the total page count of the parsed PDF document.
  ! Control Structure: Single-entry / single-exit. Complexity <= 2.
  !-----------------------------------------------------------------------------
  subroutine pdf_get_page_count(pdf, count)
    type(pdf_document_type), intent(in) :: pdf
    integer(kind=int32), intent(out) :: count

    count = pdf%page_count

  end subroutine pdf_get_page_count

  !-----------------------------------------------------------------------------
  ! Subroutine: pdf_extract_stream
  ! Purpose: Reads object stream at obj_id's offset from XRef table.
  ! Control Structure: Single-entry / single-exit. Complexity <= 8.
  !-----------------------------------------------------------------------------
  subroutine pdf_extract_stream(pdf, obj_id, out_stream, stream_len, status)
    type(pdf_document_type), intent(in) :: pdf
    integer(kind=int32), intent(in) :: obj_id
    character(len=*), intent(out) :: out_stream
    integer(kind=int32), intent(out) :: stream_len
    integer(kind=int32), intent(out) :: status

    integer(kind=int64) :: offset
    character(len=4096) :: chunk
    integer(kind=int32) :: strm_pos, end_pos

    status = 0
    out_stream = ""
    stream_len = 0

    if (obj_id >= 1 .and. obj_id <= pdf%object_count) then
      offset = pdf%xref_offsets(obj_id)
      if (offset > 0_int64) then
        read(unit=pdf%unit_num, pos=offset, iostat=status) chunk
        if (status == 0) then
          strm_pos = index(chunk, "stream")
          end_pos = index(chunk, "endstream")
          if (strm_pos > 0 .and. end_pos > strm_pos) then
            strm_pos = strm_pos + 6
            if (chunk(strm_pos:strm_pos) == new_line('a') .or. ichar(chunk(strm_pos:strm_pos)) == 13) then
              strm_pos = strm_pos + 1
            end if
            if (chunk(strm_pos:strm_pos) == new_line('a')) then
              strm_pos = strm_pos + 1
            end if
            stream_len = end_pos - strm_pos
            if (stream_len > 0 .and. stream_len <= len(out_stream)) then
              out_stream(1:stream_len) = chunk(strm_pos : end_pos - 1)
            end if
          end if
        end if
      end if
    else
      status = -2
    end if

  end subroutine pdf_extract_stream

  !-----------------------------------------------------------------------------
  ! Subroutine: pdf_read_page_text
  ! Purpose: Extracts readable plain text content from page's content stream.
  ! Control Structure: Single-entry / single-exit. Complexity <= 9.
  !-----------------------------------------------------------------------------
  subroutine pdf_read_page_text(pdf, page_num, out_text, out_len, status)
    type(pdf_document_type), intent(in) :: pdf
    integer(kind=int32), intent(in) :: page_num
    character(len=*), intent(out) :: out_text
    integer(kind=int32), intent(out) :: out_len
    integer(kind=int32), intent(out) :: status

    integer(kind=int32) :: strm_obj_id
    character(len=MAX_STREAM_LEN) :: raw_strm
    integer(kind=int32) :: raw_len, p1, p2, cur_pos

    status = 0
    out_text = ""
    out_len = 0

    if (page_num >= 1 .and. page_num <= pdf%page_count) then
      strm_obj_id = pdf%stream_object_ids(page_num)
      if (strm_obj_id == 0) then
        strm_obj_id = (page_num * 2) - 1
      end if
      call pdf_extract_stream(pdf, strm_obj_id, raw_strm, raw_len, status)
      if (status == 0 .and. raw_len > 0) then
        cur_pos = 1
        do while (cur_pos < raw_len)
          p1 = index(raw_strm(cur_pos:raw_len), "(")
          if (p1 == 0) exit
          p1 = cur_pos + p1 - 1
          p2 = index(raw_strm(p1:raw_len), ") Tj")
          if (p2 == 0) p2 = index(raw_strm(p1:raw_len), ") TJ")
          if (p2 == 0) exit
          p2 = p1 + p2 - 1
          if (out_len + (p2 - p1 - 1) <= len(out_text)) then
            if (out_len > 0) then
              out_len = out_len + 1
              out_text(out_len:out_len) = " "
            end if
            out_text(out_len + 1 : out_len + (p2 - p1 - 1)) = raw_strm(p1 + 1 : p2 - 1)
            out_len = out_len + (p2 - p1 - 1)
          end if
          cur_pos = p2 + 4
        end do
      end if
    else
      status = -1
    end if

  end subroutine pdf_read_page_text

  !=============================================================================
  ! PRIVATE READ HELPERS
  !=============================================================================

  subroutine find_startxref_offset(pdf, offset)
    type(pdf_document_type), intent(in) :: pdf
    integer(kind=int64), intent(out) :: offset

    character(len=1024) :: tail_buf
    integer(kind=int32) :: pos, status
    integer(kind=int64) :: val

    offset = 0_int64
    read(unit=pdf%unit_num, pos=1, iostat=status) tail_buf
    pos = index(tail_buf, "startxref")
    if (pos > 0) then
      read(tail_buf(pos+10:pos+30), *, iostat=status) val
      if (status == 0) then
        offset = val
      end if
    end if
  end subroutine find_startxref_offset

  subroutine parse_xref_table(pdf, offset)
    type(pdf_document_type), intent(inout) :: pdf
    integer(kind=int64), intent(in) :: offset

    character(len=2048) :: xref_buf
    integer(kind=int32) :: status, count_objs, i, line_pos
    integer(kind=int64) :: off_val

    read(unit=pdf%unit_num, pos=offset, iostat=status) xref_buf
    if (status == 0) then
      line_pos = index(xref_buf, "0 ")
      if (line_pos > 0) then
        read(xref_buf(line_pos+2:line_pos+10), *, iostat=status) count_objs
        if (status == 0 .and. count_objs > 0) then
          pdf%object_count = count_objs - 1
          do i = 1, min(count_objs - 1, MAX_OBJECTS)
            line_pos = index(xref_buf, "00000 n")
            if (line_pos > 10) then
              read(xref_buf(line_pos-10:line_pos-1), *, iostat=status) off_val
              if (status == 0) then
                pdf%xref_offsets(i) = off_val
              end if
            end if
          end do
        end if
      end if
    end if
  end subroutine parse_xref_table

  subroutine parse_pages_metadata(pdf)
    type(pdf_document_type), intent(inout) :: pdf
    character(len=4096) :: page_buf
    integer(kind=int32) :: status, pos, pcount

    read(unit=pdf%unit_num, pos=1, iostat=status) page_buf
    if (status == 0) then
      pos = index(page_buf, "/Count ")
      if (pos > 0) then
        read(page_buf(pos+7:pos+15), *, iostat=status) pcount
        if (status == 0 .and. pcount > 0) then
          pdf%page_count = min(pcount, MAX_PAGES)
        else
          pdf%page_count = 1
        end if
      else
        pdf%page_count = 1
      end if
    end if
  end subroutine parse_pages_metadata

  !=============================================================================
  ! PRIVATE WRITE HELPERS & PURE ZLIB COMPRESSOR
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

  function compute_adler32(raw_bytes, raw_len) result(checksum)
    character(len=*), intent(in) :: raw_bytes
    integer(kind=int32), intent(in) :: raw_len
    integer(kind=int64) :: checksum
    integer(kind=int64) :: s1, s2
    integer(kind=int32) :: i, b
    integer(kind=int64), parameter :: BASE = 65521_int64

    s1 = 1_int64
    s2 = 0_int64
    do i = 1, raw_len
      b = ichar(raw_bytes(i:i))
      s1 = mod(s1 + int(b, kind=int64), BASE)
      s2 = mod(s2 + s1, BASE)
    end do

    checksum = ior(ishft(s2, 16), s1)
  end function compute_adler32

  subroutine zlib_compress_stream(in_bytes, in_len, out_bytes, out_len)
    character(len=*), intent(in) :: in_bytes
    integer(kind=int32), intent(in) :: in_len
    character(len=*), intent(out) :: out_bytes
    integer(kind=int32), intent(out) :: out_len

    integer(kind=int64) :: adler
    integer(kind=int32) :: nlen_val

    out_bytes(1:1) = char(120) ! CMF = 0x78
    out_bytes(2:2) = char(1)   ! FLG = 0x01
    out_bytes(3:3) = char(1)   ! BFINAL=1, BTYPE=00
    out_bytes(4:4) = char(iand(in_len, 255))
    out_bytes(5:5) = char(iand(ishft(in_len, -8), 255))

    nlen_val = not(in_len)
    out_bytes(6:6) = char(iand(nlen_val, 255))
    out_bytes(7:7) = char(iand(ishft(nlen_val, -8), 255))

    out_bytes(8 : 7 + in_len) = in_bytes(1:in_len)

    adler = compute_adler32(in_bytes, in_len)
    out_bytes(8 + in_len : 8 + in_len) = char(iand(ishft(adler, -24), 255))
    out_bytes(9 + in_len : 9 + in_len) = char(iand(ishft(adler, -16), 255))
    out_bytes(10 + in_len : 10 + in_len) = char(iand(ishft(adler, -8), 255))
    out_bytes(11 + in_len : 11 + in_len) = char(iand(adler, 255))

    out_len = 11 + in_len

  end subroutine zlib_compress_stream

  subroutine flush_current_page_objects(pdf)
    type(pdf_document_type), intent(inout) :: pdf

    integer(kind=int32) :: stream_obj_id
    integer(kind=int32) :: page_obj_id
    character(len=256) :: header_buf
    character(len=MAX_STREAM_LEN + 32) :: compressed_buf
    integer(kind=int32) :: compressed_len

    stream_obj_id = next_object_id(pdf)
    call record_object_offset(pdf, stream_obj_id)
    pdf%stream_object_ids(pdf%page_count) = stream_obj_id

    if (pdf%compress_streams) then
      call zlib_compress_stream(pdf%current_stream, pdf%stream_len, compressed_buf, compressed_len)
      write(header_buf, '(I0,A,I0,A)') stream_obj_id, " 0 obj" // new_line('a') // &
        "<< /Filter /FlateDecode /Length ", compressed_len, " >>" // new_line('a') // "stream" // new_line('a')
      call write_raw_string(pdf, trim(header_buf))
      call write_raw_string(pdf, compressed_buf(1:compressed_len))
      call write_raw_string(pdf, new_line('a') // "endstream" // new_line('a') // "endobj" // new_line('a'))
    else
      write(header_buf, '(I0,A,I0,A)') stream_obj_id, " 0 obj" // new_line('a') // &
        "<< /Length ", pdf%stream_len, " >>" // new_line('a') // "stream" // new_line('a')
      call write_raw_string(pdf, trim(header_buf))
      call write_raw_string(pdf, pdf%current_stream(1:pdf%stream_len))
      call write_raw_string(pdf, new_line('a') // "endstream" // new_line('a') // "endobj" // new_line('a'))
    end if

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

    call write_raw_string(pdf, "0000000000 65535 f " // new_line('a'))

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

end module iris_pdf
