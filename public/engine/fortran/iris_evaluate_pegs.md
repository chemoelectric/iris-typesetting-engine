# Fortran 2008 Peg Evaluation Engine (`iris_evaluate_pegs`)

## 1. Executive Summary
The `iris_evaluate_pegs` module provides a standard Fortran 2008 (ISO/IEC 1539-1:2010) engine for applying pre-existing Sorts Mill visual boundary pegs to compute precise glyph-pair kerning and line-run spacing adjustments. In accordance with strict separation of concerns, this module contains zero automatic peg calculation or inference logic.

This module is designed in **structural isomorphism** with the R7RS Scheme `(iris evaluate-pegs)` library.

---

## 2. Structural Isomorphism Matrix

| API Functionality | Fortran 2008 (`iris_evaluate_pegs`) | R7RS Scheme (`(iris evaluate-pegs)`) |
| :--- | :--- | :--- |
| **Compute Pair Kerning** | `call compute_peg_kerning(l_peg, r_peg, gap, delta)` | `(compute-peg-kerning l-peg r-peg gap)` |
| **Apply Pair to Font** | `call apply_pegs_glyph_pair(font, lgid, rgid, gap, delta, [status])` | `(apply-pegs-glyph-pair font lgid rgid gap)` |
| **Apply Run to Font** | `call apply_pegs_glyph_run(font, gids, count, gap\|gaps, deltas\|sum, [status])` | `(apply-pegs-glyph-run font gids gap)` |

---

## 3. Example Usage in Fortran 2008

```fortran
program test_evaluate_pegs
  use iris_opentype
  use iris_evaluate_pegs
  implicit none

  type(otf_font_type)  :: font
  integer(kind=2)      :: glyphs(3)
  integer(kind=2)      :: deltas(2)
  integer              :: status

  ! Initialize font and add peg specifications
  call otf_init_font(font, "SortsMillGoudy")
  call otf_add_peg_entry(font, 1_2, 0_2, 0_2, 400_2, 0_2, 200_2, status)
  call otf_add_peg_entry(font, 2_2, 20_2, 0_2, 420_2, 0_2, 210_2, status)

  glyphs = [1_2, 2_2, 1_2]

  ! Compute kerning adjustments across run
  call apply_pegs_glyph_run(font, glyphs, 3, 50_2, deltas, status)
  if (status == PEG_APPLY_OK) then
    print *, "First pair kerning delta:", deltas(1)
  end if

  call otf_free_font(font)
end program test_evaluate_pegs
```

---

## 4. Architectural Standards & Compliance
- **ISO Standard**: Standard Fortran 2008 (ISO/IEC 1539-1:2010).
- **Structured Control**: Enforces single-entry/single-exit control constructs without `goto` constructs.
- **McCabe Complexity**: Each procedure strictly maintains a modified McCabe cyclomatic complexity $\le 10$.
- **Module Synchronization**: Maintained in strict synchronization with `/fortran/iris_evaluate_pegs.f90`.
