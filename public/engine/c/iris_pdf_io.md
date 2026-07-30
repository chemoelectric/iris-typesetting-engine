# Module: `iris_pdf_io`

## Overview
The `iris_pdf_io` module provides an ISO C23 binary stream I/O backend for PDF document generation in the Iris typesetting system. It bypasses standard Fortran record-based I/O overhead and OS-dependent newline encoding discrepancies, providing exact byte-offset tracking, zero-padding string writing, and direct stream buffer flushing.

## C23 Procedures & API

- **`iris_pdf_open_stream(filename)`**: Opens binary file stream (`fopen(..., "wb")`) and initializes stream context handle.
- **`iris_pdf_write_bytes(stream, data, length)`**: Writes unformatted raw bytes directly to stream.
- **`iris_pdf_write_string(stream, str)`**: Writes null-terminated ASCII/UTF-8 string without record delimiters or extra spaces.
- **`iris_pdf_write_formatted_int(stream, val)`**: Formats integer as tightly packed decimal text string and writes to stream.
- **`iris_pdf_get_offset(stream)`**: Returns exact cumulative byte offset written to stream.
- **`iris_pdf_close_stream(stream)`**: Flushes stdio stream buffer, closes OS file descriptor, and releases context memory.

## Architectural Rules
- **Standard**: ISO C23.
- **Control Constructs**: Strict single-entry / single-exit routines, zero `goto` statements, explicit ban on `++` and `--` operators (`+= 1` and `-= 1` used exclusively), cyclomatic complexity $\le 10$.
