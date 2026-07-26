# Fortran 2008 Mixed Markup & Natural Language Intent Disambiguation Engine (`iris_markup_parser`)

## 1. Executive Summary
The `iris_markup_parser` module provides a standard Fortran 2008 (ISO/IEC 1539-1:2010) parsing and intent disambiguation engine capable of analyzing mixed input documents containing TeX/LaTeX, ConTeXt, Troff/Groff (e.g. `.ms`, `.mm`), HTML/XML, and plain natural language prose.

Key capabilities include:
- Structural syntax detection for TeX, ConTeXt, Troff/Groff, HTML, and Natural Prose dialects.
- Inline natural language disambiguation hint parsing (e.g., `[markup: troff]` or `[format: context]`).
- Automatic detection of ambiguous syntax patterns with self-disambiguation user guidance prompts.
- Conversion of mixed input into Intermediate Intent Representation (IIR) AST tokens.

This module is designed in **structural isomorphism** with the R7RS Scheme `(iris markup-parser)` library.

---

## 2. Structural Isomorphism Matrix

| API Functionality | Fortran 2008 (`iris_markup_parser`) | R7RS Scheme (`(iris markup-parser)`) |
| :--- | :--- | :--- |
| **Detect Dialect** | `dialect = detect_markup_dialect(text)` | `(detect-markup-dialect text)` |
| **Parse Hint** | `call parse_disambiguation_hint(text, dialect, hint_found)` | `(parse-disambiguation-hint text)` |
| **Parse Mixed Text** | `call parse_mixed_markup_text(text, ast_res)` | `(parse-mixed-markup-text text)` |

---

## 3. Example Usage in Fortran 2008

```fortran
program test_markup_parser
  use iris_markup_parser
  implicit none

  type(parse_result_type) :: ast
  character(len=256)      :: sample_text

  ! Sample text with inline natural language disambiguation hint
  sample_text = "[markup: troff] .TH MAN 1\n.SH NAME\niris - MaxEnt Layout"

  call parse_mixed_markup_text(sample_text, ast)

  print *, "Detected Dialect:", ast%detected_dialect ! Expect 4 (DIALECT_TROFF_GROFF)
  print *, "Token Count:", ast%token_count
  print *, "Ambiguity Detected:", ast%ambiguity_detected
end program test_markup_parser
```

---

## 4. Architectural Standards & Compliance
- **ISO Standard**: Standard Fortran 2008 (ISO/IEC 1539-1:2010).
- **Structured Control**: Enforces single-entry/single-exit control constructs without `goto` constructs.
- **McCabe Complexity**: Each procedure strictly maintains a modified McCabe cyclomatic complexity $\le 10$.
- **Module Synchronization**: Maintained in strict synchronization with `/fortran/iris_markup_parser.f90`.
