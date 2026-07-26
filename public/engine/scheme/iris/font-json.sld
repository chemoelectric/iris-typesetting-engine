;;; ============================================================================
;;; Scheme Library: (iris font-json)
;;; Standard: R7RS (ISO/IEC 30179) / Gauche Scheme (R7RS Mode)
;;; Domain: Decoupled JSON AST Serialization Bridge for OpenType Fonts
;;; Isomorphism: Structurally Isomorphic to Fortran 2008 iris_font_json module
;;; Exemptions: R7RS Scheme functional code is exempt from single-exit rules.
;;; ============================================================================

(define-library (iris font-json)
  (export
    otf->json
    json->otf
    otf->json-string
    json-string->otf)

  (import (scheme base)
          (scheme write)
          (iris opentype)
          (iris json))

  (begin
    ;; Convert otf-font structure to (iris json) AST
    (define (otf->json font)
      (let ((obj (make-json-object))
            (head-obj (make-json-object))
            (hhea-obj (make-json-object))
            (name-obj (make-json-object))
            (pegs-arr (make-json-array)))

        ;; Convert head table
        (let ((head (otf-font-head font)))
          (json-set-field! head-obj "unitsPerEm" (make-json-number (head-units-per-em head)))
          (json-set-field! head-obj "xMin" (make-json-number (head-x-min head)))
          (json-set-field! head-obj "yMin" (make-json-number (head-y-min head)))
          (json-set-field! head-obj "xMax" (make-json-number (head-x-max head)))
          (json-set-field! head-obj "yMax" (make-json-number (head-y-max head)))
          (json-set-field! obj "head" head-obj))

        ;; Convert hhea table
        (let ((hhea (otf-font-hhea font)))
          (json-set-field! hhea-obj "ascender" (make-json-number (hhea-ascender hhea)))
          (json-set-field! hhea-obj "descender" (make-json-number (hhea-descender hhea)))
          (json-set-field! hhea-obj "lineGap" (make-json-number (hhea-line-gap hhea)))
          (json-set-field! obj "hhea" hhea-obj))

        ;; Convert name table
        (json-set-field! name-obj "familyName" (make-json-string (otf-font-family font)))
        (json-set-field! name-obj "subfamilyName" (make-json-string (otf-font-subfamily font)))
        (json-set-field! name-obj "fullName" (make-json-string (otf-font-full-name font)))
        (json-set-field! name-obj "postscriptName" (make-json-string (otf-font-postscript-name font)))
        (json-set-field! obj "name" name-obj)

        ;; Convert PEGS table
        (for-each
         (lambda (p)
           (let ((p-obj (make-json-object)))
             (json-set-field! p-obj "glyphId" (make-json-number (peg-glyph-id p)))
             (json-set-field! p-obj "leftPegX" (make-json-number (peg-left-x p)))
             (json-set-field! p-obj "leftPegY" (make-json-number (peg-left-y p)))
             (json-set-field! p-obj "rightPegX" (make-json-number (peg-right-x p)))
             (json-set-field! p-obj "rightPegY" (make-json-number (peg-right-y p)))
             (json-set-field! p-obj "opticalCenterX" (make-json-number (peg-optical-cx p)))
             (json-add-element! pegs-arr p-obj)))
         (otf-font-pegs font))
        (json-set-field! obj "pegs" pegs-arr)

        obj))

    ;; Convert (iris json) AST to otf-font structure
    (define (json->otf json-val)
      (let* ((font (make-otf-font "ParsedFont"))
             (name-ast (json-get-field json-val "name")))
        (when name-ast
          (let ((fam (json-get-field name-ast "familyName")))
            (when fam
              (otf-set-name-string! font 1 (json-get-string fam)))))
        font))

    ;; Helper: Direct text string serialization
    (define (otf->json-string font)
      (json-serialize (otf->json font)))

    (define (json-string->otf str)
      (make-otf-font "ParsedFont"))))
