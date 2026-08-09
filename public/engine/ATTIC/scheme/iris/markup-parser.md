# Scheme Mixed Markup & Natural Language Intent Disambiguation Engine (`(iris markup-parser)`)

## 1. Executive Summary
The `(iris markup-parser)` R7RS-large Scheme library provides a functional data-structure interface for parsing mixed markup inputs (TeX/LaTeX, ConTeXt, Troff/Groff, HTML, Natural Prose), parsing inline natural language disambiguation directives, and generating Intermediate Intent Representation (IIR) AST structures.

This library is designed in **structural isomorphism** with the Fortran 2008 `iris_markup_parser` module.

---

## 2. Structural Isomorphism Matrix

| API Functionality | R7RS Scheme (`(iris markup-parser)`) | Fortran 2008 (`iris_markup_parser`) |
| :--- | :--- | :--- |
| **Detect Dialect** | `(detect-markup-dialect text)` | `dialect = detect_markup_dialect(text)` |
| **Parse Hint** | `(parse-disambiguation-hint text)` | `call parse_disambiguation_hint(text, dialect, hint_found)` |
| **Parse Mixed Text** | `(parse-mixed-markup-text text)` | `call parse_mixed_markup_text(text, ast_res)` |

---

## 3. Example Usage in R7RS Scheme

```scheme
(import (scheme base)
        (scheme write)
        (iris markup-parser))

(let* ((sample "[markup: troff] .TH MAN 1\n.SH NAME\niris - MaxEnt Layout")
       (ast (parse-mixed-markup-text sample)))

  (display "Detected Dialect: ")
  (write (cdr (assoc 'dialect ast))) ;; Expect 4 (DIALECT-TROFF-GROFF)
  (newline)

  (display "Ambiguity Detected: ")
  (write (cdr (assoc 'ambiguity-detected ast)))
  (newline))
```

---

## 4. Architectural Standards & Compliance
- **R7RS Conformance**: Standard Scheme library structure using `(define-library (iris markup-parser) ...)` with explicit exports.
- **Functional Exemption**: In accordance with system design rules, Scheme code is explicitly exempt from imperative single-exit control flow constraints.
- **Module Synchronization**: Maintained in strict synchronization with `/scheme/iris/markup-parser.sld` and `/fortran/iris_markup_parser.f90`.
