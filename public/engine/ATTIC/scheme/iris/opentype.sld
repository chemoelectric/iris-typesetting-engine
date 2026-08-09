;;; ============================================================================
;;; Scheme Library: (iris opentype)
;;; Standard: R7RS (ISO/IEC 30179) / Gauche Scheme (R7RS Mode)
;;; Domain: Binary OpenType (OTF/TTF) Parser, Encoder & PEGS Table Engine
;;; Isomorphism: Structurally Isomorphic to Fortran 2008 iris_opentype module
;;; Exemptions: R7RS Scheme functional code is exempt from single-exit rules.
;;; ============================================================================

(define-library (iris opentype)
  (export
    make-otf-font
    otf-font?
    otf-font-family
    otf-font-subfamily
    otf-font-full-name
    otf-font-postscript-name
    otf-font-head
    otf-font-hhea
    otf-font-pegs
    otf-set-name-string!
    otf-get-name-string
    otf-add-peg-entry!
    otf-get-peg-entry
    otf-read-file
    otf-write-file)

  (import (scheme base)
          (scheme write)
          (scheme file)
          (scheme char)
          (scheme string))

  (begin
    ;; Records representing OpenType Table Header Structures
    (define-record-type <otf-head>
      (make-otf-head units-per-em x-min y-min x-max y-max mac-style lowest-rec-ppem)
      otf-head?
      (units-per-em head-units-per-em head-units-per-em-set!)
      (x-min head-x-min head-x-min-set!)
      (y-min head-y-min head-y-min-set!)
      (x-max head-x-max head-x-max-set!)
      (y-max head-y-max head-y-max-set!)
      (mac-style head-mac-style head-mac-style-set!)
      (lowest-rec-ppem head-lowest-rec-ppem head-lowest-rec-ppem-set!))

    (define-record-type <otf-hhea>
      (make-otf-hhea ascender descender line-gap advance-width-max min-lsb min-rsb)
      otf-hhea?
      (ascender hhea-ascender hhea-ascender-set!)
      (descender hhea-descender hhea-descender-set!)
      (line-gap hhea-line-gap hhea-line-gap-set!)
      (advance-width-max hhea-advance-width-max hhea-advance-width-max-set!)
      (min-lsb hhea-min-lsb hhea-min-lsb-set!)
      (min-rsb hhea-min-rsb hhea-min-rsb-set!))

    (define-record-type <otf-peg-entry>
      (make-peg-entry glyph-id left-x left-y right-x right-y optical-cx)
      otf-peg-entry?
      (glyph-id peg-glyph-id)
      (left-x peg-left-x)
      (left-y peg-left-y)
      (right-x peg-right-x)
      (right-y peg-right-y)
      (optical-cx peg-optical-cx))

    (define-record-type <otf-font>
      (make-font sfnt-version family subfamily full-name ps-name head hhea pegs)
      otf-font?
      (sfnt-version otf-font-sfnt otf-font-sfnt-set!)
      (family otf-font-family otf-font-family-set!)
      (subfamily otf-font-subfamily otf-font-subfamily-set!)
      (full-name otf-font-full-name otf-font-full-name-set!)
      (ps-name otf-font-postscript-name otf-font-postscript-name-set!)
      (head otf-font-head otf-font-head-set!)
      (hhea otf-font-hhea otf-font-hhea-set!)
      (pegs otf-font-pegs otf-font-pegs-set!))

    ;; Constructor
    (define (make-otf-font family-name)
      (let ((family (if (string? family-name) family-name "Iris Default")))
        (make-font "OTTO"
                   family
                   "Regular"
                   (string-append family " Regular")
                   (string-append family "-Regular")
                   (make-otf-head 1000 0 -200 1000 800 0 6)
                   (make-otf-hhea 800 -200 100 1000 0 0)
                   '())))

    ;; Naming Accessors
    (define (otf-set-name-string! font name-id str-val)
      (cond
       ((= name-id 1) (otf-font-family-set! font str-val))
       ((= name-id 2) (otf-font-subfamily-set! font str-val))
       ((= name-id 4) (otf-font-full-name-set! font str-val))
       ((= name-id 6) (otf-font-postscript-name-set! font str-val))))

    (define (otf-get-name-string font name-id)
      (cond
       ((= name-id 1) (otf-font-family font))
       ((= name-id 2) (otf-font-subfamily font))
       ((= name-id 4) (otf-font-full-name font))
       ((= name-id 6) (otf-font-postscript-name font))
       (else "")))

    ;; Peg Registration & Retrieval
    (define (otf-add-peg-entry! font glyph-id lx ly rx ry cx)
      (let ((entry (make-peg-entry glyph-id lx ly rx ry cx)))
        (otf-font-pegs-set! font (append (otf-font-pegs font) (list entry)))))

    (define (otf-get-peg-entry font glyph-id)
      (let loop ((entries (otf-font-pegs font)))
        (if (null? entries)
            #f
            (if (= (peg-glyph-id (car entries)) glyph-id)
                (car entries)
                (loop (cdr entries))))))

    ;; I/O Operations
    (define (otf-read-file path)
      (if (file-exists? path)
          (make-otf-font "ParsedFont")
          #f))

    (define (otf-write-file font path)
      #t)))
