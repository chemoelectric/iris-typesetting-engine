# Fortran 2008 PDF Generator & Reader Engine (`iris_pdf`)

## 1. Overview
The `iris_pdf` module is a standard Fortran 2008 (ISO/IEC 1539-1:2010) imperative module providing a native interface for:
1. **PDF 1.7 File Generation**: Direct stream and object table output with optional pure Fortran zlib/DEFLATE compression (`/Filter /FlateDecode`).
2. **PDF 1.7 File Parsing & Reading**: Reading `startxref` offsets, parsing cross-reference tables (`xref`), extracting raw object streams, and extracting plain text content operators.

The module enforces strict structured programming paradigms:
- **Control Flow**: Single-entry / single-exit routines across all subprograms.
- **Branching Rules**: Strict exclusion of `goto` statements.
- **Complexity Bound**: Modified McCabe cyclomatic complexity $\le 10$ for all procedures.
- **Type Safety**: ISO Fortran Environment explicit integer (`int32`, `int64`) and real (`real64`) kinds.

---

## 2. API Data Structures

### `pdf_document_type`
An opaque container managing state, stream buffers, compression flags, cross-reference offsets, and read/write mode flags.

```fortran
type :: pdf_document_type
  character(len=256) :: filename
  integer(kind=int32) :: unit_num
  integer(kind=int32) :: object_count
  integer(kind=int64) :: byte_offset
  integer(kind=int64), dimension(1000) :: xref_offsets
  integer(kind=int32) :: page_count
  integer(kind=int32), dimension(100) :: page_object_ids
  integer(kind=int32), dimension(100) :: stream_object_ids
  character(len=65536) :: current_stream
  integer(kind=int32) :: stream_len
  real(kind=real64) :: current_page_width
  real(kind=real64) :: current_page_height
  logical :: compress_streams = .false.
  logical :: is_read_mode = .false.
end type pdf_document_type
```

---

## 3. Public API Subroutines

### Writing Interface
- **`pdf_init(pdf, out_filename, status, [compress])`**: Initializes writing mode, opens output stream, writes `%PDF-1.7` header.
- **`pdf_add_page(pdf, width, height)`**: Flushes active stream and allocates new page object.
- **`pdf_write_text(pdf, x, y, font_size, text_content)`**: Appends text operator (`BT /F1 ... Tj ET`).
- **`pdf_draw_rect(pdf, x, y, w, h, fill_flag)`**: Appends vector rectangle operator (`re f` or `re S`).
- **`pdf_close(pdf, status)`**: Writes document catalog, page tree, font, xref table, trailer dictionary, and closes unit.

### Reading Interface
- **`pdf_open_read(pdf, in_filename, status)`**: Opens existing PDF binary file, seeks `startxref`, and parses the `xref` offset table.
- **`pdf_get_page_count(pdf, count)`**: Returns the total number of pages parsed.
- **`pdf_extract_stream(pdf, obj_id, out_stream, stream_len, status)`**: Extracts raw stream content from object `obj_id`.
- **`pdf_read_page_text(pdf, page_num, out_text, out_len, status)`**: Extracts text operators (`Tj` / `TJ`) from page content stream into plain text.

---

## 4. Usage Example (Writing & Reading Back)

```fortran
program test_pdf_rw
  use iris_pdf
  implicit none

  type(pdf_document_type) :: pdf
  integer :: status, pcount, text_len
  character(len=1024) :: extracted_text

  ! 1. Write Compressed PDF File
  call pdf_init(pdf, "output.pdf", status, compress=.true.)
  if (status == 0) then
    call pdf_add_page(pdf, 612.0_8, 792.0_8)
    call pdf_write_text(pdf, 60.0_8, 715.0_8, 16.0_8, "Fortran PDF Engine")
    call pdf_close(pdf, status)
  end if

  ! 2. Read Back Generated PDF File
  call pdf_open_read(pdf, "output.pdf", status)
  if (status == 0) then
    call pdf_get_page_count(pdf, pcount)
    call pdf_read_page_text(pdf, 1, extracted_text, text_len, status)
    call pdf_close(pdf, status)
  end if
end program test_pdf_rw
```

---

## 5. Architectural Synchronization
Maintained in strict synchronization with `/fortran/iris_pdf.f90`.
