# Fortran 2008 PDF Generator Engine (`pdf_generator_module`)

## 1. Overview
The `pdf_generator_module` is a standard Fortran 2008 (ISO/IEC 1539-1:2010) imperative module providing a native interface for emitting PDF 1.7 binary files directly without external library dependencies.

The module enforces strict structured programming paradigms:
- **Control Flow**: Single-entry / single-exit routines across all subprograms.
- **Branching Rules**: Strict exclusion of `goto` statements.
- **Complexity Bound**: Modified McCabe cyclomatic complexity $\le 10$ for all procedures.
- **Type Safety**: ISO Fortran Environment explicit integer (`int32`, `int64`) and real (`real64`) kinds.

---

## 2. API Data Structures

### `pdf_document_type`
An opaque container managing state, stream buffers, and object offsets during PDF generation.

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
end type pdf_document_type
```

---

## 3. Public API Subroutines

### `pdf_init(pdf, out_filename, status)`
Initializes the `pdf_document_type` instance, opens an unformatted stream unit, and writes the `%PDF-1.7` binary header.

- **`pdf`** (*out*, `type(pdf_document_type)`): Document handle.
- **`out_filename`** (*in*, `character(len=*)`): Destination file path.
- **`status`** (*out*, `integer(kind=int32)`): I/O status code (0 on success).

### `pdf_add_page(pdf, width, height)`
Flushes any active page content stream and allocates a new page object context.

- **`pdf`** (*inout*, `type(pdf_document_type)`): Document handle.
- **`width`** (*in*, `real(kind=real64)`): Page width in PostScript points ($1/72$ inch).
- **`height`** (*in*, `real(kind=real64)`): Page height in PostScript points.

### `pdf_write_text(pdf, x, y, font_size, text_content)`
Appends a text block operator (`BT ... ET`) to the active page stream.

- **`pdf`** (*inout*, `type(pdf_document_type)`): Document handle.
- **`x`**, **`y`** (*in*, `real(kind=real64)`): Origin coordinates from bottom-left corner.
- **`font_size`** (*in*, `real(kind=real64)`): Text point size.
- **`text_content`** (*in*, `character(len=*)`): Text string.

### `pdf_draw_rect(pdf, x, y, w, h, fill_flag)`
Appends a rectangle vector drawing operator (`re f` or `re S`) to the active stream.

- **`pdf`** (*inout*, `type(pdf_document_type)`): Document handle.
- **`x`**, **`y`** (*in*, `real(kind=real64)`): Lower-left corner coordinates.
- **`w`**, **`h`** (*in*, `real(kind=real64)`): Width and height.
- **`fill_flag`** (*in*, `logical`): `.true.` for filled rectangle, `.false.` for stroked border.

### `pdf_close(pdf, status)`
Flushes remaining page objects, synthesizes the Document Catalog (`/Catalog`), Pages Tree (`/Pages`), Type 1 Font (`/Font`), Cross-Reference Table (`xref`), and Trailer Dictionary, then safely closes the file unit.

- **`pdf`** (*inout*, `type(pdf_document_type)`): Document handle.
- **`status`** (*out*, `integer(kind=int32)`): I/O result code.

---

## 4. Usage Example

```fortran
program test_pdf_builder
  use pdf_generator_module
  implicit none

  type(pdf_document_type) :: pdf
  integer :: status

  ! Initialize PDF File
  call pdf_init(pdf, "output.pdf", status)

  if (status == 0) then
    ! Page 1: Standard Letter Size (612 x 792 pt)
    call pdf_add_page(pdf, 612.0_8, 792.0_8)
    call pdf_draw_rect(pdf, 50.0_8, 700.0_8, 512.0_8, 40.0_8, .true.)
    call pdf_write_text(pdf, 60.0_8, 715.0_8, 16.0_8, "Type Engine Output")

    ! Finalize Document Structure
    call pdf_close(pdf, status)
  end if
end program test_pdf_builder
```

---

## 5. Architectural Verification & Synchronization
This documentation is maintained in synchronization with `/fortran/pdf_generator_module.f90`. Any modifications to buffer sizes, procedure interfaces, or object emission logic must be reflected here immediately.
