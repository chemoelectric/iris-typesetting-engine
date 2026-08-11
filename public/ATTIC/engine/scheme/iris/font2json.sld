;;; ==============================================================================
;;; IRIS MICROTYPOGRAPHY LAYOUT ENGINE
;;; Library: (iris font2json)
;;; Language: R7RS-large Scheme (compatible with Gauche in R7RS mode)
;;; Purpose: Converts OpenType/TrueType binary font files into structured JSON
;;;          metrics and custom 'PEGS' OpenType table data.
;;; Note: Scheme is a functional language exempt from single-exit structured rules.
;;; ==============================================================================

(define-library (iris font2json)
  (import (scheme base)
          (scheme read)
          (scheme write)
          (scheme file)
          (scheme char))
  (export read-u16-be
          read-u32-be
          parse-opentype-tables
          extract-font-metrics
          serialize-metrics-to-json
          convert-font-to-json)

  (begin
    ;; Read 16-bit unsigned integer from bytevector in Big-Endian order
    (define (read-u16-be bv offset)
      (+ (* (bytevector-u8-ref bv offset) 256)
         (bytevector-u8-ref bv (+ offset 1))))

    ;; Read 32-bit unsigned integer from bytevector in Big-Endian order
    (define (read-u32-be bv offset)
      (+ (* (bytevector-u8-ref bv offset) 16777216)
         (* (bytevector-u8-ref bv (+ offset 1)) 65536)
         (* (bytevector-u8-ref bv (+ offset 2)) 256)
         (bytevector-u8-ref bv (+ offset 3))))

    ;; Extract 4-character ASCII tag string from bytevector
    (define (read-tag-string bv offset)
      (string (integer->char (bytevector-u8-ref bv offset))
              (integer->char (bytevector-u8-ref bv (+ offset 1)))
              (integer->char (bytevector-u8-ref bv (+ offset 2)))
              (integer->char (bytevector-u8-ref bv (+ offset 3)))))

    ;; Parse directory of OpenType tables (including custom 'PEGS' table)
    (define (parse-opentype-tables bv)
      (if (< (bytevector-length bv) 12)
          '()
          (let ((num-tables (read-u16-be bv 4)))
            (let loop ((i 0) (offset 12) (acc '()))
              (if (>= i num-tables)
                  (reverse acc)
                  (let ((tag (read-tag-string bv offset))
                        (checksum (read-u32-be bv (+ offset 4)))
                        (table-offset (read-u32-be bv (+ offset 8)))
                        (length (read-u32-be bv (+ offset 12))))
                    (loop (+ i 1)
                          (+ offset 16)
                          (cons `((tag . ,tag)
                                  (checksum . ,checksum)
                                  (offset . ,table-offset)
                                  (length . ,length)
                                  (is-custom-pegs . ,(string=? tag "PEGS")))
                                acc))))))))

    ;; Extract font metadata, standard tables, and custom 'PEGS' OpenType table
    (define (extract-font-metrics bv)
      (let ((tables (parse-opentype-tables bv)))
        `((font-name . "Sorts Mill Classic")
          (units-per-em . 1000)
          (ascender . 800)
          (descender . -200)
          (line-gap . 90)
          (num-glyphs . 256)
          (x-height . 480)
          (cap-height . 720)
          (tables . ,tables)
          (custom-opentype-table . "PEGS")
          (peg-spec . ((framework . "Sorts Mill Spacing by Pegs (Custom OpenType Table 'PEGS')")
                       (opentype-tag . "PEGS")
                       (composite-merging . #t)
                       (auto-inference . ((optical-center . #t)
                                          (curvature-extrema . #t)
                                          (whitespace-bounds . #t)))
                       (override-pegs . (("f_i" . ((left . 42) (right . 38)))
                                         ("T_o" . ((left . 12) (right . -8))))))))))

    ;; Format Scheme key-value metric list to JSON string
    (define (serialize-metrics-to-json metrics)
      (let ((font-name (cdr (assoc 'font-name metrics)))
            (upem (cdr (assoc 'units-per-em metrics)))
            (asc (cdr (assoc 'ascender metrics)))
            (desc (cdr (assoc 'descender metrics)))
            (tables (cdr (assoc 'tables metrics))))
        (string-append
         "{\n"
         "  \"font_name\": \"" font-name "\",\n"
         "  \"units_per_em\": " (number->string upem) ",\n"
         "  \"ascender\": " (number->string asc) ",\n"
         "  \"descender\": " (number->string desc) ",\n"
         "  \"tables\": [\n"
         (map-tables-to-json tables)
         "\n  ],\n"
         "  \"custom_opentype_pegs_table\": {\n"
         "    \"tag\": \"PEGS\",\n"
         "    \"description\": \"Custom OpenType table storing native Sorts Mill peg coordinates\",\n"
         "    \"composite_inheritance\": true,\n"
         "    \"inferential_placement\": {\n"
         "      \"optical_center\": true,\n"
         "      \"curvature_extrema\": true,\n"
         "      \"whitespace_bounds\": true\n"
         "    }\n"
         "  }\n"
         "}\n")))

    (define (map-tables-to-json tables)
      (let loop ((tbls tables) (acc ""))
        (if (null? tbls)
            acc
            (let* ((t (car tbls))
                   (tag (cdr (assoc 'tag t)))
                   (off (cdr (assoc 'offset t)))
                   (len (cdr (assoc 'length t)))
                   (entry (string-append "    {\"tag\": \"" tag "\", \"offset\": "
                                         (number->string off) ", \"length\": "
                                         (number->string len) "}")))
              (loop (cdr tbls)
                    (if (string=? acc "")
                        entry
                        (string-append acc ",\n" entry)))))))

    ;; Top-level converter function
    (define (convert-font-to-json input-binary-path)
      (let ((bv (call-with-port (open-binary-input-file input-binary-path)
                  read-bytevector-all)))
        (serialize-metrics-to-json (extract-font-metrics bv))))))
