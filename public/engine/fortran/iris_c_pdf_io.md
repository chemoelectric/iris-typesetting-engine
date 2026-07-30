# Module: `iris_c_pdf_io`

## Overview
The `iris_c_pdf_io` Fortran module provides standard `ISO_C_BINDING` Fortran 2008 interfaces to the low-level ISO C23 CapyPDF 0.21.0 primitive and binary stream I/O backend (`iris_pdf_io.c`). This bridge eliminates Fortran runtime record delimiter overhead and guarantees exact stream length calculations, CapyPDF page/drawing context bindings, and byte offsets for PDF objects.

## Fortran Public API

- **`pdf_c_stream_type`**: Derived type holding opaque C handle (`type(c_ptr)`).
- **`pdf_c_open(stream, filename, status)`**: Subroutine initializing C stream context and CapyPDF generator for `filename`.
- **`pdf_c_write_bytes(stream, data, length, status)`**: Writes byte buffer directly to binary stream.
- **`pdf_c_write_string(stream, str, status)`**: Converts Fortran string to null-terminated C string and streams it without extra spaces.
- **`pdf_c_write_int(stream, val, status)`**: Writes tightly formatted integer.
- **`pdf_c_capy_add_page(stream, width, height, status)`**: Adds page using CapyPDF 0.21.0 C API binding.
- **`pdf_c_capy_write_text(stream, x, y, font_size, text_str, status)`**: Appends text rendering primitive via CapyPDF draw context.
- **`pdf_c_capy_draw_rect(stream, x, y, w, h, fill_flag, status)`**: Draws rectangle using CapyPDF 0.21.0 C API binding.
- **`pdf_c_capy_embed_font(stream, font_name, data, len, status)`**: Embeds font binary using CapyPDF 0.21.0 C API binding.
- **`pdf_c_get_offset(stream)`**: Returns precise 64-bit byte offset of the stream.
- **`pdf_c_close(stream, status)`**: Flushes CapyPDF generator, serializes document, and releases C context handle.

## Synchronization & Standard
- **Fortran Standard**: Fortran 2008 (ISO/IEC 1539-1:2010).
- **C Standard**: ISO C23.
- **Rules**: Single-entry / single-exit control constructs, zero `goto` statements, cyclomatic complexity $\le 10$.
