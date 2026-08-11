# Ada CapyPDF Binding & Module Documentation

## Overview
`capypdf` is a high-level Ada 2022 binding package for the CapyPDF document generation engine. It wraps CapyPDF C library primitives (`capy_generator_new`, `capy_document_properties_new`, `capy_page_draw_context_new`, `capy_dc_cmd_re`, etc.) into type-safe Ada records with pre- and post-condition contracts.

## Architecture & Location
- **Package Spec**: `/public/ada/capypdf.ads`
- **Package Body**: `/public/ada/capypdf.adb`
- **Test Spec**: `/public/ada/capypdf_tests.ads`
- **Test Body**: `/public/ada/capypdf_tests.adb`
- **Test Runner**: `/public/ada/test_capypdf.adb`

## Regression Test Suite
The regression test suite verifies:
1. **Page Configuration Lifecycle**: Tests `create_page_config` and `destroy_page_config` handle transitions and null handle resets.
2. **Drawing Context Validation**: Ensures uninitialized contexts safely reject drawing primitives (`draw_rectangle`, `fill_path`) returning `capy_err_invalid_state`.
3. **Full Lifecycle Execution**: Tests document creation, drawing context binding, page addition (`add_page_with_context`), and clean post-condition verification upon document closure (`close_document`).

## Coding Standards Compliance
1. **Ada 2022 Standard**: Modern contract aspects (`Pre => ...`, `Post => ...`).
2. **Explicit Parameter Modes**: Subprogram parameters explicitly declare `in` or `in out`.
3. **Casing & Style**: Lowercase identifiers throughout, line lengths strictly <= 72 characters.
4. **Control Structures**: No bare `loop` constructs; guarded state transitions and `in out` handles.
5. **McCabe Complexity**: All functions and procedures have cyclomatic complexity <= 10.

## API Usage Example
```ada
with capypdf; use capypdf;

procedure create_pdf_example is
   doc    : pdf_document;
   dc     : pdf_draw_context;
   status : capy_error;
begin
   doc := create_document ("output.pdf");
   if is_valid (doc) then
      dc := create_draw_context (doc);
      status := draw_rectangle (dc, 100.0, 100.0, 200.0, 150.0);
      status := fill_path (dc);
      status := add_page_with_context (doc, dc);
      status := close_document (doc);
   end if;
end create_pdf_example;
```
