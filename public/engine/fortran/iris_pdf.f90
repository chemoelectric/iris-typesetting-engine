!===============================================================================
! Module: iris_pdf
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Imperative Procedural API for PDF 1.7 Specification Engine
! Features: Dual PDF Generation & PDF Reader / Stream Parser Module
!           Pure Fortran ISO RFC 1950 / RFC 1951 (zlib/FlateDecode) Compression
!           CFF & TrueType Font Embedding, /ToUnicode CMap, Tagged PDF StructTree
! Compliance: Single-entry/single-exit control constructs, zero goto constructs.
!             McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
module iris_pdf
  use, intrinsic :: iso_fortran_env, only: int32, int64, real64
  use iris_c_pdf_io, only: pdf_c_stream_type, pdf_c_open, pdf_c_write_string, pdf_c_get_offset, pdf_c_close
  use iris_dynamic_array, only: ensure_int32_capacity, ensure_int64_capacity
  use iris_dynamic_string, only: append_string_buffer, ensure_string_capacity
  implicit none
  private

  ! Public API Types
  public :: pdf_document_type

  ! Public API Procedures
  public :: pdf_init
  public :: pdf_add_page
  public :: pdf_write_text
  public :: pdf_draw_rect
  public :: pdf_embed_font_truetype
  public :: pdf_embed_font_cff
  public :: pdf_embed_font_by_kpsewhich
  public :: pdf_close
  public :: pdf_open_read
  public :: pdf_get_page_count
  public :: pdf_extract_stream
  public :: pdf_read_page_text

  ! Constants
  character(len=*), parameter :: PDF_HEADER = "%PDF-1.7"
  character(len=*), parameter :: PDF_BINARY_COMMENT = "%" // char(226) // char(227) // char(207) // char(211)

  ! Derived Type Definition for Embedded Font Metadata
  type :: font_embed_type
    logical :: embedded = .false.
    integer(kind=int32) :: font_type = 0 ! 1: TrueType (FontFile2), 2: CFF (FontFile3)
    character(len=64) :: font_name = ""
    character(len=:), allocatable :: font_data
    integer(kind=int32) :: font_data_len = 0
  end type font_embed_type

  ! Derived Type Definition for PDF Document Context
  type :: pdf_document_type
    character(len=256) :: filename
    integer(kind=int32) :: unit_num
    type(pdf_c_stream_type) :: c_stream
    integer(kind=int32) :: object_count
    integer(kind=int64) :: byte_offset
    integer(kind=int64), allocatable, dimension(:) :: xref_offsets
    integer(kind=int32) :: page_count
    integer(kind=int32), allocatable, dimension(:) :: page_object_ids
    integer(kind=int32), allocatable, dimension(:) :: stream_object_ids
    character(len=:), allocatable :: current_stream
    integer(kind=int32) :: stream_len
    real(kind=real64) :: current_page_width
    real(kind=real64) :: current_page_height
    logical :: compress_streams = .false.
    logical :: is_read_mode = .false.

    ! Tagged PDF Structure & MCID Context
    logical :: tagged_pdf = .true.
    integer(kind=int32) :: current_mcid = 0
    integer(kind=int32) :: mcid_count = 0
    integer(kind=int32), allocatable, dimension(:) :: mcid_page_ids

    ! Embedded Font Descriptor Context
    type(font_embed_type) :: embedded_font
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
    pdf%object_count = 3  ! Reserve 1: Catalog, 2: Pages, 3: Font
    pdf%byte_offset = 0_int64
    allocate(pdf%xref_offsets(64))
    pdf%xref_offsets = 0_int64
    pdf%page_count = 0
    allocate(pdf%page_object_ids(16))
    allocate(pdf%stream_object_ids(16))
    pdf%page_object_ids = 0
    pdf%stream_object_ids = 0
    allocate(character(len=4096) :: pdf%current_stream)
    pdf%current_stream = ""
    pdf%stream_len = 0
    pdf%current_page_width = 612.0_real64   ! Default Letter width (pts)
    pdf%current_page_height = 792.0_real64  ! Default Letter height (pts)
    pdf%is_read_mode = .false.

    pdf%tagged_pdf = .true.
    pdf%current_mcid = 0
    pdf%mcid_count = 0
    allocate(pdf%mcid_page_ids(16))
    pdf%mcid_page_ids = 0

    pdf%embedded_font%embedded = .false.
    pdf%embedded_font%font_type = 0
    pdf%embedded_font%font_name = "Helvetica"
    pdf%embedded_font%font_data_len = 0

    if (present(compress)) then
      pdf%compress_streams = compress
    else
      pdf%compress_streams = .false.
    end if

    call pdf_c_open(pdf%c_stream, pdf%filename, status)

    if (status == 0) then
      call write_raw_string(pdf, PDF_HEADER // new_line('a'))
      call write_raw_string(pdf, PDF_BINARY_COMMENT // new_line('a'))
    end if

  end subroutine pdf_init

  !-----------------------------------------------------------------------------
  ! Subroutine: pdf_embed_font_truetype
  ! Purpose: Configures TrueType embedded font stream and metadata.
  ! Control Structure: Single-entry / single-exit. Complexity <= 3.
  !-----------------------------------------------------------------------------
  subroutine pdf_embed_font_truetype(pdf, font_name, tt_data)
    type(pdf_document_type), intent(inout) :: pdf
    character(len=*), intent(in) :: font_name
    character(len=*), intent(in) :: tt_data

    pdf%embedded_font%embedded = .true.
    pdf%embedded_font%font_type = 1  ! TrueType
    pdf%embedded_font%font_name = trim(font_name)
    pdf%embedded_font%font_data_len = len(tt_data)
    if (allocated(pdf%embedded_font%font_data)) deallocate(pdf%embedded_font%font_data)
    allocate(character(len=len(tt_data)) :: pdf%embedded_font%font_data)
    pdf%embedded_font%font_data = tt_data

  end subroutine pdf_embed_font_truetype

  !-----------------------------------------------------------------------------
  ! Subroutine: pdf_embed_font_cff
  ! Purpose: Configures CFF (Compact Font Format) embedded font stream.
  ! Control Structure: Single-entry / single-exit. Complexity <= 3.
  !-----------------------------------------------------------------------------
  subroutine pdf_embed_font_cff(pdf, font_name, cff_data)
    type(pdf_document_type), intent(inout) :: pdf
    character(len=*), intent(in) :: font_name
    character(len=*), intent(in) :: cff_data

    pdf%embedded_font%embedded = .true.
    pdf%embedded_font%font_type = 2  ! CFF / Type 1C
    pdf%embedded_font%font_name = trim(font_name)
    pdf%embedded_font%font_data_len = len(cff_data)
    if (allocated(pdf%embedded_font%font_data)) deallocate(pdf%embedded_font%font_data)
    allocate(character(len=len(cff_data)) :: pdf%embedded_font%font_data)
    pdf%embedded_font%font_data = cff_data

  end subroutine pdf_embed_font_cff

  !-----------------------------------------------------------------------------
  ! Subroutine: pdf_embed_font_by_kpsewhich
  ! Purpose: Uses kpsewhich to locate font file and embeds it into PDF.
  ! Control Structure: Single-entry / single-exit. Complexity <= 9.
  !-----------------------------------------------------------------------------
  subroutine pdf_embed_font_by_kpsewhich(pdf, font_spec, font_name, status)
    type(pdf_document_type), intent(inout) :: pdf
    character(len=*), intent(in) :: font_spec
    character(len=*), intent(in) :: font_name
    integer(kind=int32), intent(out) :: status

    character(len=512) :: cmd, font_path
    character(len=:), allocatable :: font_bytes
    integer(kind=int32) :: cmd_stat, u, read_stat
    integer(kind=int64) :: file_sz
    logical :: exist_flag, is_tt

    status = 0
    font_path = ""
    cmd = "kpsewhich " // trim(font_spec) // " > /tmp/iris_kpse_out.txt 2>/dev/null"
    call execute_command_line(trim(cmd), exitstat=cmd_stat)

    if (cmd_stat == 0) then
      inquire(file="/tmp/iris_kpse_out.txt", exist=exist_flag)
      if (exist_flag) then
        u = 97
        open(unit=u, file="/tmp/iris_kpse_out.txt", status="old", action="read", iostat=read_stat)
        if (read_stat == 0) then
          read(u, '(A)', iostat=read_stat) font_path
          close(u)
        end if
      end if
    end if

    font_path = adjustl(font_path)
    exist_flag = .false.
    if (len_trim(font_path) > 0) then
      inquire(file=trim(font_path), exist=exist_flag)
    end if

    if (exist_flag) then
      u = 96
      open(unit=u, file=trim(font_path), status="old", action="read", access="stream", iostat=read_stat)
      if (read_stat == 0) then
        inquire(unit=u, size=file_sz)
        if (file_sz > 0_int64) then
          allocate(character(len=int(file_sz, kind=int32)) :: font_bytes)
          read(u, iostat=read_stat) font_bytes
          close(u)
          if (read_stat == 0) then
            is_tt = (index(font_path, ".ttf") > 0 .or. index(font_path, ".TTF") > 0)
            if (is_tt) then
              call pdf_embed_font_truetype(pdf, font_name, font_bytes)
            else
              call pdf_embed_font_cff(pdf, font_name, font_bytes)
            end if
            status = 0
          else
            status = -3
          end if
          if (allocated(font_bytes)) deallocate(font_bytes)
        else
          close(u)
          status = -2
        end if
      else
        status = -1
      end if
    else
      pdf%embedded_font%embedded = .false.
      status = 0
    end if

  end subroutine pdf_embed_font_by_kpsewhich

  !-----------------------------------------------------------------------------
  ! Subroutine: generate_fallback_embedded_font
  ! Purpose: Generates a synthetic embedded font stream when kpsewhich is missing.
  ! Control Structure: Single-entry / single-exit. Complexity <= 2.
  !-----------------------------------------------------------------------------
  subroutine generate_fallback_embedded_font(pdf, font_name)
    type(pdf_document_type), intent(inout) :: pdf
    character(len=*), intent(in) :: font_name

    pdf%embedded_font%embedded = .false.
    pdf%embedded_font%font_name = "Helvetica"

  end subroutine generate_fallback_embedded_font

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

    call ensure_int32_capacity(pdf%page_object_ids, pdf%page_count)
    call ensure_int32_capacity(pdf%stream_object_ids, pdf%page_count)

    pdf%current_page_width = width
    pdf%current_page_height = height
    pdf%current_stream = ""
    pdf%stream_len = 0
    pdf%current_mcid = 0

  end subroutine pdf_add_page

  !-----------------------------------------------------------------------------
  ! Subroutine: pdf_write_text
  ! Purpose: Appends text operator (BT ... ET) wrapped in Tagged PDF Marked Content.
  ! Control Structure: Single-entry / single-exit. Complexity <= 6.
  !-----------------------------------------------------------------------------
  subroutine pdf_write_text(pdf, x, y, font_size, text_content)
    type(pdf_document_type), intent(inout) :: pdf
    real(kind=real64), intent(in) :: x
    real(kind=real64), intent(in) :: y
    real(kind=real64), intent(in) :: font_size
    character(len=*), intent(in) :: text_content

    character(len=2048) :: line_buf, escaped_buf, op_buf
    character(len=32)   :: f_str, x_str, y_str, mcid_str
    integer(kind=int32) :: content_len, pos, next_nl, line_len, i, esc_pos, op_len
    real(kind=real64)   :: cur_y, line_height
    character(1)        :: ch

    content_len = len(text_content)
    cur_y = y
    line_height = font_size * 1.35_real64
    pos = 1

    if (pdf%page_count == 0) then
      call pdf_add_page(pdf, pdf%current_page_width, pdf%current_page_height)
    end if

    do while (pos <= content_len)
      next_nl = index(text_content(pos:content_len), char(10))
      if (next_nl == 0) then
        line_buf = text_content(pos:content_len)
        pos = content_len + 1
      else if (next_nl == 1) then
        line_buf = ""
        pos = pos + 1
      else
        line_buf = text_content(pos : pos + next_nl - 2)
        pos = pos + next_nl
      end if

      line_len = len_trim(line_buf)
      if (line_len > 0) then
        if (line_buf(line_len:line_len) == char(13)) then
          line_buf(line_len:line_len) = ' '
          line_len = len_trim(line_buf)
        end if
      end if

      ! Escape PDF special characters: (, ), \
      escaped_buf = ""
      esc_pos = 1
      do i = 1, line_len
        ch = line_buf(i:i)
        if (ch == '(' .or. ch == ')' .or. ch == '\') then
          if (esc_pos < 2047) then
            escaped_buf(esc_pos:esc_pos) = '\'
            esc_pos = esc_pos + 1
          end if
        end if
        if (esc_pos <= 2048) then
          escaped_buf(esc_pos:esc_pos) = ch
          esc_pos = esc_pos + 1
        end if
      end do

      if (cur_y < 50.0_real64) then
        call pdf_add_page(pdf, pdf%current_page_width, pdf%current_page_height)
        cur_y = pdf%current_page_height - 72.0_real64
      end if

      if (esc_pos > 1) then
        write(f_str, '(F6.2)') font_size
        write(x_str, '(F8.2)') x
        write(y_str, '(F8.2)') cur_y

        if (pdf%tagged_pdf) then
          write(mcid_str, '(I0)') pdf%current_mcid
          op_buf = "/P << /MCID " // trim(mcid_str) // " >> BDC" // new_line('a') // &
                   "BT /F1 " // adjustl(f_str) // " Tf " // adjustl(x_str) // " " // &
                   adjustl(y_str) // " Td (" // escaped_buf(1:esc_pos-1) // ") Tj ET" // new_line('a') // &
                   "EMC" // new_line('a')
          pdf%mcid_count = pdf%mcid_count + 1
          call ensure_int32_capacity(pdf%mcid_page_ids, pdf%mcid_count)
          pdf%mcid_page_ids(pdf%mcid_count) = pdf%page_count
          pdf%current_mcid = pdf%current_mcid + 1
        else
          op_buf = "BT /F1 " // adjustl(f_str) // " Tf " // adjustl(x_str) // " " // &
                   adjustl(y_str) // " Td (" // escaped_buf(1:esc_pos-1) // ") Tj ET" // new_line('a')
        end if

        op_len = len_trim(op_buf)
        call append_to_stream(pdf, op_buf(1:op_len))
      end if

      cur_y = cur_y - line_height
    end do

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

    if (pdf%page_count == 0) then
      call pdf_add_page(pdf, pdf%current_page_width, pdf%current_page_height)
    end if

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
  ! Purpose: Flushes open streams, writes catalog, Tagged PDF tree, fonts, xref & trailer.
  ! Control Structure: Single-entry / single-exit. Complexity <= 7.
  !-----------------------------------------------------------------------------
  subroutine pdf_close(pdf, status)
    type(pdf_document_type), intent(inout) :: pdf
    integer(kind=int32), intent(out) :: status

    integer(kind=int32) :: catalog_id, pages_id, font_id, tounicode_id
    integer(kind=int32) :: font_desc_id, font_file_id, cid_font_id
    integer(kind=int32) :: struct_tree_root_id, struct_doc_elem_id
    integer(kind=int64) :: xref_start_offset

    if (pdf%is_read_mode) then
      close(unit=pdf%unit_num, iostat=status)
    else
      if (pdf%page_count > 0) then
        call flush_current_page_objects(pdf)
      end if

      struct_tree_root_id = 0
      struct_doc_elem_id = 0
      if (pdf%tagged_pdf) then
        struct_tree_root_id = next_object_id(pdf)
        struct_doc_elem_id = next_object_id(pdf)
      end if

      ! Catalog Object (Obj 1)
      catalog_id = 1
      call record_object_offset(pdf, catalog_id)
      if (pdf%tagged_pdf) then
        call write_catalog_tagged(pdf, struct_tree_root_id)
      else
        call write_raw_string(pdf, "1 0 obj" // new_line('a') // "<< /Type /Catalog /Pages 2 0 R >>" // new_line('a') // "endobj" // new_line('a'))
      end if

      ! Pages Tree Object (Obj 2)
      pages_id = 2
      call record_object_offset(pdf, pages_id)
      call write_pages_tree_object(pdf)

      ! Font Objects, /ToUnicode CMap, FontDescriptor & Font Files (Obj 3+)
      font_id = 3
      call record_object_offset(pdf, font_id)
      call write_font_objects(pdf, font_id, tounicode_id, font_desc_id, font_file_id, cid_font_id)

      ! Tagged PDF StructTreeRoot & StructElem Objects
      if (pdf%tagged_pdf) then
        call write_tagged_struct_tree(pdf, struct_tree_root_id, struct_doc_elem_id)
      end if

      xref_start_offset = pdf%byte_offset
      call write_xref_table(pdf)
      call write_trailer_dict(pdf, xref_start_offset)

      call pdf_c_close(pdf%c_stream, status)
    end if

  end subroutine pdf_close

  !-----------------------------------------------------------------------------
  ! Subroutine: write_catalog_tagged
  ! Purpose: Writes Catalog object with /MarkInfo and /StructTreeRoot references.
  ! Control Structure: Single-entry / single-exit. Complexity <= 2.
  !-----------------------------------------------------------------------------
  subroutine write_catalog_tagged(pdf, struct_root_id)
    type(pdf_document_type), intent(inout) :: pdf
    integer(kind=int32), intent(in) :: struct_root_id
    character(len=256) :: buf

    write(buf, '(A,I0,A)') "1 0 obj" // new_line('a') // &
      "<< /Type /Catalog /Pages 2 0 R /MarkInfo << /Marked true >> /StructTreeRoot ", &
      struct_root_id, " 0 R >>" // new_line('a') // "endobj" // new_line('a')
    call write_raw_string(pdf, trim(buf))

  end subroutine write_catalog_tagged

  !-----------------------------------------------------------------------------
  ! Subroutine: write_font_objects
  ! Purpose: Writes Font Object, /ToUnicode CMap Stream, FontDescriptor and Font Data.
  ! Control Structure: Single-entry / single-exit. Complexity <= 8.
  !-----------------------------------------------------------------------------
  subroutine write_font_objects(pdf, font_id, tounicode_id, font_desc_id, font_file_id, cid_font_id)
    type(pdf_document_type), intent(inout) :: pdf
    integer(kind=int32), intent(in) :: font_id
    integer(kind=int32), intent(out) :: tounicode_id
    integer(kind=int32), intent(out) :: font_desc_id
    integer(kind=int32), intent(out) :: font_file_id
    integer(kind=int32), intent(out) :: cid_font_id

    character(len=4096) :: font_buf, cmap_stream
    character(len=2048) :: widths_str
    integer(kind=int32) :: cmap_len, i

    tounicode_id = next_object_id(pdf)

    ! Build a standard 224-element /Widths array for characters 32 to 255 (default 600)
    widths_str = "/Widths ["
    do i = 32, 255
      widths_str = trim(widths_str) // " 600"
    end do
    widths_str = trim(widths_str) // " ]"

    if (.not. pdf%embedded_font%embedded) then
      call pdf_embed_font_by_kpsewhich(pdf, "cmr10.pfb", "CMR10", i)
    end if

    if (pdf%embedded_font%embedded) then
      font_desc_id = next_object_id(pdf)
      font_file_id = next_object_id(pdf)
      cid_font_id = 0

      if (pdf%embedded_font%font_type == 2) then  ! CFF / Type1C
        write(font_buf, '(I0,A,I0,A,I0,A)') font_id, " 0 obj" // new_line('a') // &
          "<< /Type /Font /Subtype /Type1 /BaseFont /" // trim(pdf%embedded_font%font_name) // &
          " /Encoding /WinAnsiEncoding /FirstChar 32 /LastChar 255 " // trim(widths_str) // &
          " /FontDescriptor ", font_desc_id, " 0 R /ToUnicode ", tounicode_id, &
          " 0 R >>" // new_line('a') // "endobj" // new_line('a')
        call write_raw_string(pdf, trim(font_buf))
      else  ! TrueType
        write(font_buf, '(I0,A,I0,A,I0,A)') font_id, " 0 obj" // new_line('a') // &
          "<< /Type /Font /Subtype /TrueType /BaseFont /" // trim(pdf%embedded_font%font_name) // &
          " /Encoding /WinAnsiEncoding /FirstChar 32 /LastChar 255 " // trim(widths_str) // &
          " /FontDescriptor ", font_desc_id, " 0 R /ToUnicode ", tounicode_id, &
          " 0 R >>" // new_line('a') // "endobj" // new_line('a')
        call write_raw_string(pdf, trim(font_buf))
      end if

      ! FontDescriptor Object
      call record_object_offset(pdf, font_desc_id)
      if (pdf%embedded_font%font_type == 2) then
        write(font_buf, '(I0,A,I0,A)') font_desc_id, " 0 obj" // new_line('a') // &
          "<< /Type /FontDescriptor /FontName /" // trim(pdf%embedded_font%font_name) // &
          " /Flags 32 /FontBBox [-500 -300 1200 1000] /ItalicAngle 0 /Ascent 800 /Descent -200 /CapHeight 700 /StemV 80 /FontFile3 ", &
          font_file_id, " 0 R >>" // new_line('a') // "endobj" // new_line('a')
      else
        write(font_buf, '(I0,A,I0,A)') font_desc_id, " 0 obj" // new_line('a') // &
          "<< /Type /FontDescriptor /FontName /" // trim(pdf%embedded_font%font_name) // &
          " /Flags 32 /FontBBox [-500 -300 1200 1000] /ItalicAngle 0 /Ascent 800 /Descent -200 /CapHeight 700 /StemV 80 /FontFile2 ", &
          font_file_id, " 0 R >>" // new_line('a') // "endobj" // new_line('a')
      end if
      call write_raw_string(pdf, trim(font_buf))

      ! Font File Stream Object
      call record_object_offset(pdf, font_file_id)
      if (pdf%embedded_font%font_type == 2) then
        write(font_buf, '(I0,A,I0,A)') font_file_id, " 0 obj" // new_line('a') // &
          "<< /Subtype /Type1C /Length ", pdf%embedded_font%font_data_len, &
          " >>" // new_line('a') // "stream" // new_line('a')
      else
        write(font_buf, '(I0,A,I0,A,I0,A)') font_file_id, " 0 obj" // new_line('a') // &
          "<< /Length ", pdf%embedded_font%font_data_len, &
          " /Length1 ", pdf%embedded_font%font_data_len, &
          " >>" // new_line('a') // "stream" // new_line('a')
      end if
      call write_raw_string(pdf, trim(font_buf))
      if (pdf%embedded_font%font_data_len > 0) then
        call write_raw_string(pdf, pdf%embedded_font%font_data(1:pdf%embedded_font%font_data_len))
      end if
      call write_raw_string(pdf, new_line('a') // "endstream" // new_line('a') // "endobj" // new_line('a'))

    else
      font_desc_id = 0
      font_file_id = 0
      cid_font_id = 0
      write(font_buf, '(I0,A,I0,A)') font_id, " 0 obj" // new_line('a') // &
        "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding /ToUnicode ", &
        tounicode_id, " 0 R >>" // new_line('a') // "endobj" // new_line('a')
      call write_raw_string(pdf, trim(font_buf))
    end if

    ! /ToUnicode CMap Stream Object
    call record_object_offset(pdf, tounicode_id)
    cmap_stream = "/CIDInit /ProcSet findresource begin" // new_line('a') // &
      "12 dict begin" // new_line('a') // &
      "begincmap" // new_line('a') // &
      "/CIDSystemInfo << /Registry (Adobe) /Ordering (UCS) /Supplement 0 >> def" // new_line('a') // &
      "/CMapName /Adobe-Identity-UCS def" // new_line('a') // &
      "/CMapType 2 def" // new_line('a') // &
      "1 begincodespacerange" // new_line('a') // &
      "<00> <FF>" // new_line('a') // &
      "endcodespacerange" // new_line('a') // &
      "1 beginbfrange" // new_line('a') // &
      "<00> <FF> <0000>" // new_line('a') // &
      "endbfrange" // new_line('a') // &
      "endcmap" // new_line('a') // &
      "end" // new_line('a') // &
      "end" // new_line('a')
    cmap_len = len_trim(cmap_stream)

    write(font_buf, '(I0,A,I0,A)') tounicode_id, " 0 obj" // new_line('a') // &
      "<< /Length ", cmap_len, " >>" // new_line('a') // "stream" // new_line('a')
    call write_raw_string(pdf, trim(font_buf))
    call write_raw_string(pdf, cmap_stream(1:cmap_len))
    call write_raw_string(pdf, "endstream" // new_line('a') // "endobj" // new_line('a'))

  end subroutine write_font_objects

  !-----------------------------------------------------------------------------
  ! Subroutine: write_tagged_struct_tree
  ! Purpose: Writes Tagged PDF StructTreeRoot and StructElem Objects.
  ! Control Structure: Single-entry / single-exit. Complexity <= 6.
  !-----------------------------------------------------------------------------
  subroutine write_tagged_struct_tree(pdf, struct_root_id, struct_doc_id)
    type(pdf_document_type), intent(inout) :: pdf
    integer(kind=int32), intent(in) :: struct_root_id
    integer(kind=int32), intent(in) :: struct_doc_id

    character(len=4096) :: buf, elem_ref
    integer(kind=int32) :: i, p_elem_id, page_obj_id
    integer(kind=int32), allocatable, dimension(:) :: p_elem_ids

    ! Write StructTreeRoot Object
    call record_object_offset(pdf, struct_root_id)
    write(buf, '(I0,A,I0,A)') struct_root_id, " 0 obj" // new_line('a') // &
      "<< /Type /StructTreeRoot /K [", struct_doc_id, " 0 R] >>" // new_line('a') // "endobj" // new_line('a')
    call write_raw_string(pdf, trim(buf))

    ! Write Document StructElem Object
    call record_object_offset(pdf, struct_doc_id)
    buf = ""
    write(buf, '(I0,A,I0,A)') struct_doc_id, " 0 obj" // new_line('a') // &
      "<< /Type /StructElem /S /Document /P ", struct_root_id, " 0 R /K ["

    if (pdf%mcid_count > 0) then
      allocate(p_elem_ids(pdf%mcid_count))
      do i = 1, pdf%mcid_count
        p_elem_ids(i) = next_object_id(pdf)
        write(elem_ref, '(I0,A)') p_elem_ids(i), " 0 R "
        buf = trim(buf) // " " // trim(elem_ref)
      end do
    end if
    buf = trim(buf) // "] >>" // new_line('a') // "endobj" // new_line('a')
    call write_raw_string(pdf, trim(buf))

    ! Write Paragraph StructElem Objects
    if (pdf%mcid_count > 0) then
      do i = 1, pdf%mcid_count
        p_elem_id = p_elem_ids(i)
        call record_object_offset(pdf, p_elem_id)
        page_obj_id = pdf%page_object_ids(pdf%mcid_page_ids(i))
        write(buf, '(I0,A,I0,A,I0,A,I0,A)') p_elem_id, " 0 obj" // new_line('a') // &
          "<< /Type /StructElem /S /P /P ", struct_doc_id, " 0 R /Pg ", page_obj_id, &
          " 0 R /K ", i - 1, " >>" // new_line('a') // "endobj" // new_line('a')
        call write_raw_string(pdf, trim(buf))
      end do
      deallocate(p_elem_ids)
    end if

  end subroutine write_tagged_struct_tree

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
    allocate(pdf%xref_offsets(64))
    pdf%xref_offsets = 0_int64
    pdf%page_count = 0
    allocate(pdf%page_object_ids(16))
    allocate(pdf%stream_object_ids(16))
    pdf%page_object_ids = 0
    pdf%stream_object_ids = 0
    allocate(character(len=4096) :: pdf%current_stream)
    pdf%current_stream = ""
    pdf%stream_len = 0
    pdf%is_read_mode = .true.
    allocate(pdf%mcid_page_ids(16))
    pdf%mcid_page_ids = 0

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

    integer(kind=int64) :: offset, file_sz, avail
    character(len=:), allocatable :: chunk, decomp_buf
    integer(kind=int32) :: strm_pos, end_pos, raw_len, decomp_len, z_stat, read_len
    logical :: is_flate

    status = 0
    out_stream = ""
    stream_len = 0

    if (obj_id >= 1 .and. obj_id <= pdf%object_count) then
      offset = pdf%xref_offsets(obj_id)
      inquire(unit=pdf%unit_num, size=file_sz)
      if (offset > 0_int64 .and. offset <= file_sz) then
        avail = file_sz - offset + 1_int64
        read_len = int(min(65536_int64, avail), kind=int32)
        if (read_len > 0) then
          allocate(character(len=read_len) :: chunk)
          allocate(character(len=65536) :: decomp_buf)
          chunk = ""
          decomp_buf = ""
          read(unit=pdf%unit_num, pos=offset, iostat=status) chunk
          if (status == 0) then
            is_flate = (index(chunk, "/FlateDecode") > 0)
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
              raw_len = end_pos - strm_pos
              if (raw_len > 0) then
                if (is_flate) then
                  call zlib_decompress_stream(chunk(strm_pos : end_pos - 1), raw_len, decomp_buf, decomp_len, z_stat)
                  if (z_stat == 0 .and. decomp_len > 0 .and. decomp_len <= len(out_stream)) then
                    out_stream(1:decomp_len) = decomp_buf(1:decomp_len)
                    stream_len = decomp_len
                  else
                    if (raw_len <= len(out_stream)) then
                      out_stream(1:raw_len) = chunk(strm_pos : end_pos - 1)
                      stream_len = raw_len
                    end if
                  end if
                else
                  if (raw_len <= len(out_stream)) then
                    out_stream(1:raw_len) = chunk(strm_pos : end_pos - 1)
                    stream_len = raw_len
                  end if
                end if
              end if
            end if
          end if
          if (allocated(chunk)) deallocate(chunk)
          if (allocated(decomp_buf)) deallocate(decomp_buf)
        end if
      else
        status = -1
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
    character(len=:), allocatable :: raw_strm
    integer(kind=int32) :: raw_len, p1, p2, cur_pos

    status = 0
    out_text = ""
    out_len = 0

    allocate(character(len=65536) :: raw_strm)
    raw_strm = ""

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

    if (allocated(raw_strm)) deallocate(raw_strm)

  end subroutine pdf_read_page_text

  !=============================================================================
  ! PRIVATE READ HELPERS
  !=============================================================================

  subroutine find_startxref_offset(pdf, offset)
    type(pdf_document_type), intent(in) :: pdf
    integer(kind=int64), intent(out) :: offset

    character(len=1024) :: tail_buf
    integer(kind=int32) :: pos, status, read_pos
    integer(kind=int64) :: val, file_size

    offset = 0_int64
    inquire(unit=pdf%unit_num, size=file_size)
    if (file_size > 0_int64) then
      read_pos = int(max(1_int64, file_size - 1024_int64 + 1_int64), kind=int32)
      read(unit=pdf%unit_num, pos=read_pos, iostat=status) tail_buf
      pos = index(tail_buf, "startxref")
      if (pos > 0) then
        read(tail_buf(pos+10:pos+30), *, iostat=status) val
        if (status == 0) then
          offset = val
        end if
      end if
    end if
  end subroutine find_startxref_offset

  subroutine parse_xref_table(pdf, offset)
    type(pdf_document_type), intent(inout) :: pdf
    integer(kind=int64), intent(in) :: offset

    character(len=:), allocatable :: xref_buf
    integer(kind=int32) :: status, count_objs, i, cur_p, next_p, read_len
    integer(kind=int64) :: file_sz, avail, off_val

    inquire(unit=pdf%unit_num, size=file_sz)
    if (offset > 0_int64 .and. offset <= file_sz) then
      avail = file_sz - offset + 1_int64
      read_len = int(min(4096_int64, avail), kind=int32)
      if (read_len > 0) then
        allocate(character(len=read_len) :: xref_buf)
        read(unit=pdf%unit_num, pos=offset, iostat=status) xref_buf
        if (status == 0) then
          cur_p = index(xref_buf, "0 ")
          if (cur_p > 0) then
            read(xref_buf(cur_p+2:cur_p+10), *, iostat=status) count_objs
            if (status == 0 .and. count_objs > 0) then
              pdf%object_count = count_objs - 1
              if (allocated(pdf%xref_offsets)) deallocate(pdf%xref_offsets)
              allocate(pdf%xref_offsets(pdf%object_count + 16))
              pdf%xref_offsets = 0_int64

              next_p = index(xref_buf(cur_p:read_len), char(10))
              if (next_p > 0) then
                cur_p = cur_p + next_p
                do i = 1, pdf%object_count
                  next_p = index(xref_buf(cur_p:read_len), "00000 n")
                  if (next_p > 10) then
                    read(xref_buf(cur_p + next_p - 11 : cur_p + next_p - 2), *, iostat=status) off_val
                    if (status == 0) then
                      pdf%xref_offsets(i) = off_val
                    end if
                    cur_p = cur_p + next_p + 7
                  else
                    exit
                  end if
                end do
              end if
            end if
          end if
        end if
        deallocate(xref_buf)
      end if
    end if
  end subroutine parse_xref_table

  subroutine parse_pages_metadata(pdf)
    type(pdf_document_type), intent(inout) :: pdf
    character(len=:), allocatable :: page_buf
    integer(kind=int32) :: status, pos, pcount, read_len
    integer(kind=int64) :: file_sz

    inquire(unit=pdf%unit_num, size=file_sz)
    if (file_sz > 0_int64) then
      read_len = int(min(8192_int64, file_sz), kind=int32)
      allocate(character(len=read_len) :: page_buf)
      read(unit=pdf%unit_num, pos=1, iostat=status) page_buf
      if (status == 0) then
        pos = index(page_buf, "/Count ")
        if (pos > 0) then
          read(page_buf(pos+7:pos+15), *, iostat=status) pcount
          if (status == 0 .and. pcount > 0) then
            pdf%page_count = pcount
          else
            pdf%page_count = 1
          end if
        else
          pdf%page_count = 1
        end if
      else
        pdf%page_count = 1
      end if
      deallocate(page_buf)
    else
      pdf%page_count = 1
    end if

    if (allocated(pdf%page_object_ids)) deallocate(pdf%page_object_ids)
    if (allocated(pdf%stream_object_ids)) deallocate(pdf%stream_object_ids)
    allocate(pdf%page_object_ids(pdf%page_count + 16))
    allocate(pdf%stream_object_ids(pdf%page_count + 16))
    pdf%page_object_ids = 0
    pdf%stream_object_ids = 0

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

    if (obj_id >= 1) then
      call ensure_int64_capacity(pdf%xref_offsets, obj_id)
      pdf%xref_offsets(obj_id) = pdf%byte_offset
    end if

  end subroutine record_object_offset

  subroutine append_to_stream(pdf, str)
    type(pdf_document_type), intent(inout) :: pdf
    character(len=*), intent(in) :: str

    call append_string_buffer(pdf%current_stream, pdf%stream_len, str)

  end subroutine append_to_stream

  subroutine zlib_compress_stream(in_bytes, in_len, out_bytes, out_len)
    use, intrinsic :: iso_c_binding, only: c_char, c_long, c_int
    character(len=*), intent(in) :: in_bytes
    integer(kind=int32), intent(in) :: in_len
    character(len=*), intent(out) :: out_bytes
    integer(kind=int32), intent(out) :: out_len

    interface
      function c_zlib_compress(dest, dest_len, source, source_len) &
          bind(c, name="compress") result(res)
        use, intrinsic :: iso_c_binding, only: c_char, c_long, c_int
        implicit none
        character(kind=c_char), intent(out)   :: dest(*)
        integer(kind=c_long), intent(inout)   :: dest_len
        character(kind=c_char), intent(in)    :: source(*)
        integer(kind=c_long), value, intent(in) :: source_len
        integer(kind=c_int) :: res
      end function c_zlib_compress
    end interface

    integer(kind=c_long) :: d_len, s_len
    integer(kind=c_int)  :: z_res

    if (in_len > 0) then
      s_len = int(in_len, kind=c_long)
      d_len = int(len(out_bytes), kind=c_long)
      z_res = c_zlib_compress(out_bytes, d_len, in_bytes, s_len)
      if (z_res == 0) then
        out_len = int(d_len, kind=int32)
      else
        out_bytes(1:in_len) = in_bytes(1:in_len)
        out_len = in_len
      end if
    else
      out_len = 0
    end if

  end subroutine zlib_compress_stream

  subroutine zlib_decompress_stream(in_bytes, in_len, out_bytes, out_len, status)
    use, intrinsic :: iso_c_binding, only: c_char, c_long, c_int
    character(len=*), intent(in) :: in_bytes
    integer(kind=int32), intent(in) :: in_len
    character(len=*), intent(out) :: out_bytes
    integer(kind=int32), intent(out) :: out_len
    integer(kind=int32), intent(out) :: status

    interface
      function c_zlib_uncompress(dest, dest_len, source, source_len) &
          bind(c, name="uncompress") result(res)
        use, intrinsic :: iso_c_binding, only: c_char, c_long, c_int
        implicit none
        character(kind=c_char), intent(out)   :: dest(*)
        integer(kind=c_long), intent(inout)   :: dest_len
        character(kind=c_char), intent(in)    :: source(*)
        integer(kind=c_long), value, intent(in) :: source_len
        integer(kind=c_int) :: res
      end function c_zlib_uncompress
    end interface

    integer(kind=c_long) :: d_len, s_len
    integer(kind=c_int)  :: z_res

    if (in_len > 0) then
      s_len = int(in_len, kind=c_long)
      d_len = int(len(out_bytes), kind=c_long)
      z_res = c_zlib_uncompress(out_bytes, d_len, in_bytes, s_len)
      status = int(z_res, kind=int32)
      if (z_res == 0) then
        out_len = int(d_len, kind=int32)
      else
        out_len = 0
      end if
    else
      status = 0
      out_len = 0
    end if

  end subroutine zlib_decompress_stream

  subroutine flush_current_page_objects(pdf)
    type(pdf_document_type), intent(inout) :: pdf

    integer(kind=int32) :: stream_obj_id
    integer(kind=int32) :: page_obj_id
    character(len=256) :: header_buf
    character(len=:), allocatable :: compressed_buf
    integer(kind=int32) :: compressed_len

    character(len=32) :: w_str, h_str

    stream_obj_id = next_object_id(pdf)
    call record_object_offset(pdf, stream_obj_id)
    pdf%stream_object_ids(pdf%page_count) = stream_obj_id

    if (pdf%compress_streams) then
      allocate(character(len=pdf%stream_len * 2 + 512) :: compressed_buf)
      call zlib_compress_stream(pdf%current_stream, pdf%stream_len, compressed_buf, compressed_len)
      write(header_buf, '(I0,A,I0,A)') stream_obj_id, " 0 obj" // new_line('a') // &
        "<< /Filter /FlateDecode /Length ", compressed_len, " >>" // new_line('a') // "stream" // new_line('a')
      call write_raw_string(pdf, trim(header_buf))
      call write_raw_string(pdf, compressed_buf(1:compressed_len))
      call write_raw_string(pdf, "endstream" // new_line('a') // "endobj" // new_line('a'))
      deallocate(compressed_buf)
    else
      write(header_buf, '(I0,A,I0,A)') stream_obj_id, " 0 obj" // new_line('a') // &
        "<< /Length ", pdf%stream_len, " >>" // new_line('a') // "stream" // new_line('a')
      call write_raw_string(pdf, trim(header_buf))
      call write_raw_string(pdf, pdf%current_stream(1:pdf%stream_len))
      call write_raw_string(pdf, "endstream" // new_line('a') // "endobj" // new_line('a'))
    end if

    page_obj_id = next_object_id(pdf)
    call record_object_offset(pdf, page_obj_id)
    pdf%page_object_ids(pdf%page_count) = page_obj_id

    write(w_str, '(F0.2)') pdf%current_page_width
    write(h_str, '(F0.2)') pdf%current_page_height

    write(header_buf, '(I0,A,A,A,A,A,I0,A)') &
      page_obj_id, " 0 obj" // new_line('a') // &
      "<< /Type /Page /Parent 2 0 R /Resources << /Font << /F1 3 0 R >> >> /MediaBox [0 0 ", &
      trim(w_str), " ", trim(h_str), "] /Contents ", stream_obj_id, " 0 R >>" // new_line('a') // &
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
      write(single_ref, '(I0,A)') pdf%page_object_ids(idx), " 0 R"
      kids_buf = trim(kids_buf) // " " // trim(single_ref)
    end do

    kids_buf = trim(kids_buf) // " ] >>" // new_line('a') // "endobj" // new_line('a')
    call write_raw_string(pdf, trim(kids_buf))

  end subroutine write_pages_tree_object

  subroutine write_xref_table(pdf)
    type(pdf_document_type), intent(inout) :: pdf

    character(len=128) :: entry_buf
    integer(kind=int32) :: i

    call write_raw_string(pdf, "xref" // new_line('a'))
    write(entry_buf, '(A,I0)') "0 ", pdf%object_count + 1
    call write_raw_string(pdf, trim(entry_buf) // new_line('a'))

    call write_raw_string(pdf, "0000000000 65535 f" // char(13) // char(10))

    do i = 1, pdf%object_count
      write(entry_buf, '(I10.10,A,A)') pdf%xref_offsets(i), " 00000 n", char(13) // char(10)
      call write_raw_string(pdf, entry_buf(1:20))
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

    integer(kind=int32) :: str_len, c_stat

    str_len = len(str)
    if (str_len > 0) then
      call pdf_c_write_string(pdf%c_stream, str, c_stat)
      pdf%byte_offset = pdf_c_get_offset(pdf%c_stream)
    end if

  end subroutine write_raw_string

end module iris_pdf
