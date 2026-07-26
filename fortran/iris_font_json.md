# Fortran 2008 OpenType JSON Serialization Bridge (`iris_font_json`)

## 1. Executive Summary
The `iris_font_json` module provides a decoupled JSON AST serialization bridge connecting `iris_opentype` font data structures with the `iris_json` RFC 8259 parser/serializer engine.

This module is designed in **structural isomorphism** with the R7RS Scheme `(iris font-json)` library.

---

## 2. Structural Isomorphism Matrix

| API Functionality | Fortran 2008 (`iris_font_json`) | R7RS Scheme (`(iris font-json)`) |
| :--- | :--- | :--- |
| **Convert OTF to JSON AST** | `call otf_to_json(font, json_obj)` | `(otf->json font)` |
| **Convert JSON AST to OTF** | `call json_to_otf(json_obj, font)` | `(json->otf json_obj)` |
| **Serialize OTF to JSON Text**| `call otf_serialize_json(font, str)` | `(otf->json-string font)` |

---

## 3. Example Usage in Fortran 2008

```fortran
program test_font_json
  use iris_opentype
  use iris_font_json
  implicit none

  type(otf_font_type) :: font
  character(len=2048) :: json_text

  ! Initialize font and register Sorts Mill pegs
  call otf_init_font(font, "SortsMillGoudy")
  call otf_set_name_string(font, 1, "Sorts Mill Goudy")

  ! Serialize font object directly to JSON string representation
  call otf_serialize_json(font, json_text)
  print *, trim(json_text)

  call otf_free_font(font)
end program test_font_json
```

---

## 4. Architectural Standards & Compliance
- **ISO Standard**: Standard Fortran 2008 (ISO/IEC 1539-1:2010).
- **Structured Control**: Enforces single-entry/single-exit control constructs without `goto` constructs.
- **McCabe Complexity**: Each procedure strictly maintains a modified McCabe cyclomatic complexity $\le 10$.
- **Module Synchronization**: Maintained in strict synchronization with `/fortran/iris_font_json.f90`.
