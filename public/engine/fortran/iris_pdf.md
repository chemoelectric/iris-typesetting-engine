# Fortran 2008 PDF Generator & Reader Engine (`iris_pdf`)

## 1. Overview
The `iris_pdf` module is a standard Fortran 2008 (ISO/IEC 1539-1:2010) imperative module providing a native interface for:
1. **PDF 1.7 File Generation**: Direct stream and object table output with C zlib (`ISO_C_BINDING` `compress`) FlateDecode stream compression (`/Filter /FlateDecode`).
2. **CFF & TrueType Font Embedding**: Native support for embedding Compact Font Format (`/CIDFontType0` / `/FontFile3` with `/Subtype /CIDFontType0C`) and TrueType (`/TrueType` / `/FontFile2`) font binary streams into PDF Font Descriptor dictionaries.
3. **`/ToUnicode` CMap Generation**: Automatic `/ToUnicode` character mapping stream object creation for precise Unicode text extraction and searching.
4. **Tagged PDF Accessibility Structure**: Document Catalog `/MarkInfo << /Marked true >>`, `/StructTreeRoot`, document `/StructElem`, and paragraph `/StructElem` hierarchy with marked content identifier (`/MCID`) tagging operators (`BDC` / `EMC`).
5. **PDF 1.7 File Parsing & Reading**: Reading `startxref` offsets, parsing cross-reference tables (`xref`), extracting raw object streams, automatically decompressing `/FlateDecode` streams with C zlib (`ISO_C_BINDING` `uncompress`), and extracting plain text content operators.

The module enforces strict structured programming paradigms:
- **Control Flow**: Single-entry / single-exit routines across all subprograms.
- **Branching Rules**: Strict exclusion of `goto` statements.
- **Complexity Bound**: Modified McCabe cyclomatic complexity $\le 10$ for all procedures.
- **Type Safety**: ISO Fortran Environment explicit integer (`int32`, `int64`) and real (`real64`) kinds.

---

## 2. API Data Structures

### `font_embed_type`
Metadata and binary stream buffer container for CFF or TrueType embedded font files.

```fortran
type :: font_embed_type
  logical :: embedded = .false.
  integer(kind=int32) :: font_type = 0  ! 1: TrueType (FontFile2), 2: CFF (FontFile3)
  character(len=64) :: font_name = ""
  character(len=:), allocatable :: font_data
  integer(kind=int32) :: font_data_len = 0
end type font_embed_type
```

### `pdf_document_type`
An opaque container managing state, stream buffers, compression flags, cross-reference offsets, Tagged PDF structures, and font embedding context.

```fortran
type :: pdf_document_type
  character(len=256) :: filename
  integer(kind=int32) :: unit_num
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
```

---

## 3. Public API Subroutines

### Writing Interface
- **`pdf_init(pdf, out_filename, status, [compress])`**: Initializes writing mode, opens output stream, writes `%PDF-1.7` header, and initializes Tagged PDF structure context.
- **`pdf_embed_font_truetype(pdf, font_name, tt_data)`**: Embeds TrueType font binary stream into PDF Font Descriptor (`/FontFile2`).
- **`pdf_embed_font_cff(pdf, font_name, cff_data)`**: Embeds CFF (Compact Font Format) font binary stream into PDF Font Descriptor (`/FontFile3` with `/Subtype /CIDFontType0C`).
- **`pdf_add_page(pdf, width, height)`**: Flushes active stream and allocates new page object.
- **`pdf_write_text(pdf, x, y, font_size, text_content)`**: Appends text operator (`BT /F1 ... Tj ET`) wrapped in Tagged PDF Marked Content operators (`BDC ... EMC`).
- **`pdf_draw_rect(pdf, x, y, w, h, fill_flag)`**: Appends vector rectangle operator (`re f` or `re S`).
- **`pdf_close(pdf, status)`**: Writes document catalog with `/MarkInfo` and `/StructTreeRoot`, Tagged PDF structure tree (`StructTreeRoot` and `StructElem`), `/ToUnicode` CMap stream object, font objects, xref table, trailer dictionary, and closes unit.

### Reading Interface
- **`pdf_open_read(pdf, in_filename, status)`**: Opens existing PDF binary file, seeks `startxref`, and parses the `xref` offset table.
- **`pdf_get_page_count(pdf, count)`**: Returns the total number of pages parsed.
- **`pdf_extract_stream(pdf, obj_id, out_stream, stream_len, status)`**: Extracts raw stream content from object `obj_id`.
- **`pdf_read_page_text(pdf, page_num, out_text, out_len, status)`**: Extracts text operators (`Tj` / `TJ`) from page content stream into plain text.

---

## 4. Usage Example (Writing with Font Embedding, /ToUnicode & Tagged PDF)

```fortran
program test_pdf_advanced
  use iris_pdf
  implicit none

  type(pdf_document_type) :: pdf
  integer :: status
  character(len=100) :: tt_font_bytes

  ! Simulated font data bytes
  tt_font_bytes = "TrueType Binary Font Stream Sample Data"

  ! 1. Initialize Tagged PDF File with Stream Compression
  call pdf_init(pdf, "output_tagged.pdf", status, compress=.true.)
  if (status == 0) then
    ! 2. Embed TrueType Font Data
    call pdf_embed_font_truetype(pdf, "SortsMillGoudy", tt_font_bytes)

    ! 3. Add Page and Render Text with Marked Content
    call pdf_add_page(pdf, 612.0_8, 792.0_8)
    call pdf_write_text(pdf, 60.0_8, 715.0_8, 16.0_8, "Iris High-Precision Typography Engine")
    call pdf_close(pdf, status)
  end if
end program test_pdf_advanced
```

---

## 5. Architectural Synchronization
Maintained in strict synchronization with `/fortran/iris_pdf.f90`.
