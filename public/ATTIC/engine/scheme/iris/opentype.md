# Scheme OpenType Font Binary Engine (`(iris opentype)`)

## 1. Executive Summary
The `(iris opentype)` R7RS-large Scheme library provides a functional data-structure interface for reading, writing, and manipulating OpenType (`.otf` / `.ttf`) fonts, including custom `PEGS` tables embedding native Sorts Mill peg coordinates for peg-based microtypography.

This library is designed in **structural isomorphism** with the Fortran 2008 `iris_opentype` module.

---

## 2. Structural Isomorphism Matrix

| API Functionality | R7RS Scheme (`(iris opentype)`) | Fortran 2008 (`iris_opentype`) |
| :--- | :--- | :--- |
| **Font Constructor** | `(make-otf-font family)` | `call otf_init_font(font, family)` |
| **Read Binary File** | `(otf-read-file path)` | `call otf_read_file(path, font, status)` |
| **Write Binary File** | `(otf-write-file font path)` | `call otf_write_file(path, font, status)` |
| **Register Peg Entry** | `(otf-add-peg-entry! font id lx ly rx ry cx)` | `call otf_add_peg_entry(font, id, lx, ly, rx, ry, cx, status)` |
| **Query Peg Entry** | `(otf-get-peg-entry font id)` | `call otf_get_peg_entry(font, id, peg, found)` |
| **Set Name String** | `(otf-set-name-string! font name_id str)` | `call otf_set_name_string(font, name_id, str)` |
| **Get Name String** | `(otf-get-name-string font name_id)` | `call otf_get_name_string(font, name_id, str)` |

---

## 3. Example Usage in R7RS Scheme

```scheme
(import (scheme base)
        (scheme write)
        (iris opentype))

(let ((font (make-otf-font "SortsMillGoudy")))
  ;; Set naming entries
  (otf-set-name-string! font 1 "Sorts Mill Goudy")
  (otf-set-name-string! font 2 "Regular")

  ;; Register custom Sorts Mill visual boundary pegs
  (otf-add-peg-entry! font 36 12 450 380 450 196)

  ;; Query peg entry
  (let ((peg (otf-get-peg-entry font 36)))
    (when peg
      (display (string-append "Optical Center X: "
                             (number->string (peg-optical-cx peg))
                             "\n"))))

  ;; Write font structure to disk
  (otf-write-file font "SortsMillGoudy.otf"))
```

---

## 4. Architectural Standards & Compliance
- **R7RS Conformance**: Standard Scheme library structure using `(define-library (iris opentype) ...)` with explicit exports.
- **Functional Exemption**: In accordance with system design rules, Scheme code is explicitly exempt from imperative single-exit control flow constraints.
- **Module Synchronization**: Maintained in strict synchronization with `/scheme/iris/opentype.sld` and `/fortran/iris_opentype.f90`.
