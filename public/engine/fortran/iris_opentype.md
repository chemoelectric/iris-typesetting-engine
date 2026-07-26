# Fortran 2008 OpenType Font Binary Engine (`iris_opentype`)

## 1. Executive Summary
The `iris_opentype` module provides a standard Fortran 2008 (ISO/IEC 1539-1:2010) binary parser and encoder for OpenType (`.otf` / `.ttf`) font structures, including support for standard headers (`head`, `hhea`, `maxp`, `hmtx`, `name`, `post`) and custom `PEGS` tables embedding native Sorts Mill peg coordinates for microtypographic spacing.

This module is designed in **structural isomorphism** with the R7RS Scheme `(iris opentype)` library.

---

## 2. Structural Isomorphism Matrix

| API Functionality | Fortran 2008 (`iris_opentype`) | R7RS Scheme (`(iris opentype)`) |
| :--- | :--- | :--- |
| **Font Constructor** | `call otf_init_font(font, family)` | `(make-otf-font family)` |
| **Read Binary File** | `call otf_read_file(path, font, status)` | `(otf-read-file path)` |
| **Write Binary File** | `call otf_write_file(path, font, status)` | `(otf-write-file font path)` |
| **Register Peg Entry** | `call otf_add_peg_entry(font, id, lx, ly, rx, ry, cx, status)` | `(otf-add-peg-entry! font id lx ly rx ry cx)` |
| **Query Peg Entry** | `call otf_get_peg_entry(font, id, peg, found)` | `(otf-get-peg-entry font id)` |
| **Query Glyph Metrics** | `call otf_get_glyph_metrics(font, id, metric, found)` | `(otf-get-glyph-metrics font id)` |
| **Set Name String** | `call otf_set_name_string(font, name_id, str)` | `(otf-set-name-string! font name_id str)` |
| **Get Name String** | `call otf_get_name_string(font, name_id, str)` | `(otf-get-name-string font name_id)` |
| **Cleanup** | `call otf_free_font(font)` | N/A (Garbage Collected) |

---

## 3. Example Usage in Fortran 2008

```fortran
program test_opentype
  use iris_opentype
  implicit none

  type(otf_font_type)     :: font
  type(otf_peg_entry_type):: peg
  integer                 :: status
  logical                 :: found

  ! Initialize OpenType font data structure
  call otf_init_font(font, "SortsMillGoudy")

  ! Set naming table entries
  call otf_set_name_string(font, 1, "Sorts Mill Goudy")
  call otf_set_name_string(font, 2, "Regular")

  ! Register custom Sorts Mill visual boundary pegs
  call otf_add_peg_entry(font, 36_2, 12_2, 450_2, 380_2, 450_2, 196_2, status)

  ! Query peg entry
  call otf_get_peg_entry(font, 36_2, peg, found)
  if (found) then
    print *, "Optical Center X:", peg%optical_center_x
  end if

  ! Write font structure to disk
  call otf_write_file("SortsMillGoudy.otf", font, status)

  call otf_free_font(font)
end program test_opentype
```

---

## 4. Architectural Standards & Compliance
- **ISO Standard**: Standard Fortran 2008 (ISO/IEC 1539-1:2010).
- **Structured Control**: Enforces single-entry/single-exit control constructs without `goto` constructs.
- **McCabe Complexity**: Each procedure strictly maintains a modified McCabe cyclomatic complexity $\le 10$.
- **Module Synchronization**: Maintained in strict synchronization with `/fortran/iris_opentype.f90`.
