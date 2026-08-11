# Scheme OpenType JSON Serialization Bridge (`(iris font-json)`)

## 1. Executive Summary
The `(iris font-json)` R7RS-large Scheme library provides a decoupled JSON AST serialization bridge connecting `(iris opentype)` font data structures with the `(iris json)` RFC 8259 parser/serializer engine.

This library is designed in **structural isomorphism** with the Fortran 2008 `iris_font_json` module.

---

## 2. Structural Isomorphism Matrix

| API Functionality | R7RS Scheme (`(iris font-json)`) | Fortran 2008 (`iris_font_json`) |
| :--- | :--- | :--- |
| **Convert OTF to JSON AST** | `(otf->json font)` | `call otf_to_json(font, json_obj)` |
| **Convert JSON AST to OTF** | `(json->otf json_obj)` | `call json_to_otf(json_obj, font)` |
| **Serialize OTF to JSON Text**| `(otf->json-string font)` | `call otf_serialize_json(font, str)` |

---

## 3. Example Usage in R7RS Scheme

```scheme
(import (scheme base)
        (scheme write)
        (iris opentype)
        (iris font-json))

(let ((font (make-otf-font "SortsMillGoudy")))
  (otf-set-name-string! font 1 "Sorts Mill Goudy")
  (otf-add-peg-entry! font 36 12 450 380 450 196)

  ;; Serialize OpenType font structure directly to JSON string
  (let ((json-text (otf->json-string font)))
    (display json-text)
    (newline)))
```

---

## 4. Architectural Standards & Compliance
- **R7RS Conformance**: Standard Scheme library structure using `(define-library (iris font-json) ...)` with explicit exports.
- **Functional Exemption**: In accordance with system design rules, Scheme code is explicitly exempt from imperative single-exit control flow constraints.
- **Module Synchronization**: Maintained in strict synchronization with `/scheme/iris/font-json.sld` and `/fortran/iris_font_json.f90`.
