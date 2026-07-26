;;; ============================================================================
;;; Scheme Library: (iris markup-parser)
;;; Standard: R7RS (ISO/IEC 30179) / Gauche Scheme (R7RS Mode)
;;; Domain: Mixed Markup & Natural Language Intent Disambiguation Engine
;;;         Supports TeX, LaTeX, ConTeXt, Troff/Groff, HTML, and Natural Prose
;;; Isomorphism: Structurally Isomorphic to Fortran 2008 iris_markup_parser module
;;; Exemptions: R7RS Scheme functional code is exempt from single-exit rules.
;;; ============================================================================

(define-library (iris markup-parser)
  (export
    detect-markup-dialect
    parse-disambiguation-hint
    parse-mixed-markup-text
    DIALECT-UNKNOWN
    DIALECT-NATURAL-PROSE
    DIALECT-TEX-LATEX
    DIALECT-CONTEXT
    DIALECT-TROFF-GROFF
    DIALECT-HTML-XML)

  (import (scheme base)
          (scheme write)
          (scheme char))

  (begin
    ;; -------------------------------------------------------------------------
    ;; Dialect Constants
    ;; -------------------------------------------------------------------------
    (define DIALECT-UNKNOWN 0)
    (define DIALECT-NATURAL-PROSE 1)
    (define DIALECT-TEX-LATEX 2)
    (define DIALECT-CONTEXT 3)
    (define DIALECT-TROFF-GROFF 4)
    (define DIALECT-HTML-XML 5)

    ;; -------------------------------------------------------------------------
    ;; Detect Dialect
    ;; -------------------------------------------------------------------------
    (define (detect-markup-dialect text)
      (cond ((or (string-contains? text "\\starttext")
                 (string-contains? text "\\startchapter")
                 (string-contains? text "\\setupbodyfont"))
             DIALECT-CONTEXT)
            ((or (string-contains? text "\\documentclass")
                 (string-contains? text "\\begin{document}")
                 (string-contains? text "\\section{")
                 (string-contains? text "\\textbf{"))
             DIALECT-TEX-LATEX)
            ((or (string-contains? text ".TH ")
                 (string-contains? text ".PP")
                 (string-contains? text ".SH")
                 (string-contains? text "\\fB")
                 (string-contains? text ".ms")
                 (string-contains? text ".mm"))
             DIALECT-TROFF-GROFF)
            ((or (string-contains? text "<html>")
                 (string-contains? text "<p>")
                 (string-contains? text "<h1>")
                 (string-contains? text "<div>"))
             DIALECT-HTML-XML)
            (else DIALECT-NATURAL-PROSE)))

    ;; -------------------------------------------------------------------------
    ;; Helper: string-contains?
    ;; -------------------------------------------------------------------------
    (define (string-contains? hay needle)
      (let ((lh (string-length hay))
            (ln (string-length needle)))
        (if (< lh ln)
            #f
            (let loop ((i 0))
              (if (> (+ i ln) lh)
                  #f
                  (if (string=? (substring hay i (+ i ln)) needle)
                      #t
                      (loop (+ i 1))))))))

    ;; -------------------------------------------------------------------------
    ;; Parse Disambiguation Hint
    ;; -------------------------------------------------------------------------
    (define (parse-disambiguation-hint text)
      (let ((start (or (string-search text "[markup:")
                       (string-search text "[format:"))))
        (if (not start)
            (values DIALECT-UNKNOWN #f)
            (let ((end (string-search-from text "]" start)))
              (if (not end)
                  (values DIALECT-UNKNOWN #f)
                  (let ((hint (substring text (+ start 8) end)))
                    (cond ((string-contains? hint "context") (values DIALECT-CONTEXT #t))
                          ((or (string-contains? hint "tex") (string-contains? hint "latex")) (values DIALECT-TEX-LATEX #t))
                          ((or (string-contains? hint "troff") (string-contains? hint "groff") (string-contains? hint "ms")) (values DIALECT-TROFF-GROFF #t))
                          ((or (string-contains? hint "html") (string-contains? hint "xml")) (values DIALECT-HTML-XML #t))
                          ((or (string-contains? hint "prose") (string-contains? hint "natural")) (values DIALECT-NATURAL-PROSE #t))
                          (else (values DIALECT-UNKNOWN #t)))))))))

    (define (string-search hay needle)
      (let ((lh (string-length hay))
            (ln (string-length needle)))
        (if (< lh ln)
            #f
            (let loop ((i 0))
              (if (> (+ i ln) lh)
                  #f
                  (if (string=? (substring hay i (+ i ln)) needle)
                      i
                      (loop (+ i 1))))))))

    (define (string-search-from hay needle start-pos)
      (let ((lh (string-length hay))
            (ln (string-length needle)))
        (if (< lh (+ start-pos ln))
            #f
            (let loop ((i start-pos))
              (if (> (+ i ln) lh)
                  #f
                  (if (string=? (substring hay i (+ i ln)) needle)
                      i
                      (loop (+ i 1))))))))

    ;; -------------------------------------------------------------------------
    ;; Parse Mixed Markup Text
    ;; -------------------------------------------------------------------------
    (define (parse-mixed-markup-text input-text)
      (let-values (((hint-dialect has-hint) (parse-disambiguation-hint input-text)))
        (let* ((dialect (if (and has-hint (not (= hint-dialect DIALECT-UNKNOWN)))
                            hint-dialect
                            (detect-markup-dialect input-text)))
               (ambiguous? (and (not has-hint)
                                (string-contains? input-text "\\")
                                (string-contains? input-text ".")
                                (= dialect DIALECT-NATURAL-PROSE)))
               (msg (if ambiguous?
                        "Ambiguous markup detected. Please insert '[markup: troff]' or '[markup: latex]' in prose."
                        "")))
          `((dialect . ,dialect)
            (ambiguity-detected . ,ambiguous?)
            (disambiguation-msg . ,msg)
            (tokens . (((type . paragraph)
                        (content . ,input-text))))))))))
