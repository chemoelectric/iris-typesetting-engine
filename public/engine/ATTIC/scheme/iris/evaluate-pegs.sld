;;; ============================================================================
;;; Scheme Library: (iris evaluate-pegs)
;;; Standard: R7RS (ISO/IEC 30179) / Gauche Scheme (R7RS Mode)
;;; Domain: Sorts Mill Peg Evaluation Engine (Pure Peg Spacing & Kerning)
;;; Description: Applies pre-existing visual boundary pegs to compute exact
;;;              microtypographic glyph kerning and positioning offsets.
;;;              Strictly decoupled from automatic peg calculation/inference.
;;; Isomorphism: Structurally Isomorphic to Fortran 2008 iris_evaluate_pegs module
;;; Exemptions: R7RS Scheme functional code is exempt from single-exit rules.
;;; ============================================================================

(define-library (iris evaluate-pegs)
  (export
    compute-peg-kerning
    apply-pegs-glyph-pair
    apply-pegs-glyph-run)

  (import (scheme base)
          (scheme write)
          (iris opentype))

  (begin
    ;; -------------------------------------------------------------------------
    ;; Compute kerning adjustment between two peg records
    ;; -------------------------------------------------------------------------
    (define (compute-peg-kerning left-peg right-peg nominal-gap)
      (let* ((eff-gap (- (peg-left-x right-peg) (peg-right-x left-peg)))
             (delta (- nominal-gap eff-gap)))
        delta))

    ;; -------------------------------------------------------------------------
    ;; Apply existing pegs to a pair of glyph IDs in an OpenType font
    ;; -------------------------------------------------------------------------
    (define (apply-pegs-glyph-pair font left-gid right-gid nominal-gap)
      (let ((l-peg (otf-get-peg-entry font left-gid))
            (r-peg (otf-get-peg-entry font right-gid)))
        (if (and l-peg r-peg)
            (compute-peg-kerning l-peg r-peg nominal-gap)
            0)))

    ;; -------------------------------------------------------------------------
    ;; Apply existing pegs to a sequence list of glyph IDs
    ;; -------------------------------------------------------------------------
    (define (apply-pegs-glyph-run font glyph-ids nominal-gap)
      (if (or (null? glyph-ids) (null? (cdr glyph-ids)))
          '()
          (let loop ((rest glyph-ids)
                     (deltas '()))
            (if (null? (cdr rest))
                (reverse deltas)
                (let ((delta (apply-pegs-glyph-pair font (car rest) (cadr rest) nominal-gap)))
                  (loop (cdr rest) (cons delta deltas)))))))))
