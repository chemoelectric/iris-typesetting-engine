# Scheme Peg Evaluation Engine (`(iris evaluate-pegs)`)

## 1. Executive Summary
The `(iris evaluate-pegs)` R7RS-large Scheme library provides a functional engine for applying pre-existing Sorts Mill visual boundary pegs to compute precise glyph-pair kerning and line-run spacing adjustments. In accordance with strict separation of concerns, this library contains zero automatic peg calculation or inference logic.

This library is designed in **structural isomorphism** with the Fortran 2008 `iris_evaluate_pegs` module.

---

## 2. Structural Isomorphism Matrix

| API Functionality | R7RS Scheme (`(iris evaluate-pegs)`) | Fortran 2008 (`iris_evaluate_pegs`) |
| :--- | :--- | :--- |
| **Compute Pair Kerning** | `(compute-peg-kerning l-peg r-peg gap)` | `call compute_peg_kerning(l_peg, r_peg, gap, delta)` |
| **Apply Pair to Font** | `(apply-pegs-glyph-pair font lgid rgid gap)` | `call apply_pegs_glyph_pair(font, lgid, rgid, gap, delta, status)` |
| **Apply Run to Font** | `(apply-pegs-glyph-run font gids gap)` | `call apply_pegs_glyph_run(font, gids, count, gap, deltas, status)` |

---

## 3. Example Usage in R7RS Scheme

```scheme
(import (scheme base)
        (scheme write)
        (iris opentype)
        (iris evaluate-pegs))

(let ((font (make-otf-font "SortsMillGoudy")))
  ;; Register peg specifications
  (otf-add-peg-entry! font 1 0 0 400 0 200)
  (otf-add-peg-entry! font 2 20 0 420 0 210)

  ;; Compute kerning adjustments across run
  (let ((deltas (apply-pegs-glyph-run font '(1 2 1) 50)))
    (display "Run kerning deltas: ")
    (write deltas)
    (newline)))
```

---

## 4. Architectural Standards & Compliance
- **R7RS Conformance**: Standard Scheme library structure using `(define-library (iris evaluate-pegs) ...)` with explicit exports.
- **Functional Exemption**: In accordance with system design rules, Scheme code is explicitly exempt from imperative single-exit control flow constraints.
- **Module Synchronization**: Maintained in strict synchronization with `/scheme/iris/evaluate-pegs.sld` and `/fortran/iris_evaluate_pegs.f90`.
