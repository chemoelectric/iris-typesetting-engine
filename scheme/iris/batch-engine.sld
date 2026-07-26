;;; ============================================================================
;;; Scheme Library: (iris batch-engine)
;;; Standard: R7RS (ISO/IEC 30179) / Gauche Scheme (R7RS Mode)
;;; Domain: Modular ConTeXt-Style Batch Typographic Pipeline &
;;;         CUPS-Compliant PDF/X-1a / PDF/A Document Emission Engine
;;; Isomorphism: Structurally Isomorphic to Fortran 2008 iris_batch_engine module
;;; Exemptions: R7RS Scheme functional code is exempt from single-exit rules.
;;; ============================================================================

(define-library (iris batch-engine)
  (export
    make-batch-config
    batch-config?
    batch-process-document)

  (import (scheme base)
          (scheme write)
          (iris markup-parser)
          (iris pdf))

  (begin
    ;; -------------------------------------------------------------------------
    ;; Batch Config Record Type
    ;; -------------------------------------------------------------------------
    (define-record-type <batch-config>
      (make-batch-config-record page-size margin-left margin-top font-size cups-pdf-x?)
      batch-config?
      (page-size config-page-size)
      (margin-left config-margin-left)
      (margin-top config-margin-top)
      (font-size config-font-size)
      (cups-pdf-x? config-cups-pdf-x?))

    (define (make-batch-config . opts)
      (let ((ps (if (null? opts) "A4" (car opts)))
            (ml (if (or (null? opts) (null? (cdr opts))) 72.0 (cadr opts)))
            (mt (if (or (null? opts) (null? (cdr opts)) (null? (cddr opts))) 72.0 (caddr opts)))
            (fs (if (or (null? opts) (null? (cdr opts)) (null? (cddr opts)) (null? (cdddr opts))) 11.0 (cadddr opts)))
            (cups? #t))
        (make-batch-config-record ps ml mt fs cups?)))

    ;; -------------------------------------------------------------------------
    ;; Process Document
    ;; -------------------------------------------------------------------------
    (define (batch-process-document input-content output-pdf-filename . opts)
      (let* ((cfg (if (null? opts) (make-batch-config) (car opts)))
             (parse-ast (parse-mixed-markup-text input-content))
             (dialect (cdr (assoc 'dialect parse-ast)))
             (ambiguity? (cdr (assoc 'ambiguity-detected parse-ast)))
             (msg (cdr (assoc 'disambiguation-msg parse-ast)))
             (pdf-doc (pdf-init))
             (p-stat (pdf-add-page pdf-doc)))

        (pdf-add-text pdf-doc
                      (config-margin-left cfg)
                      (config-margin-top cfg)
                      input-content
                      (config-font-size cfg))

        (let ((pdf-stat (pdf-write-file pdf-doc output-pdf-filename)))
          `((status . ,(if (= pdf-stat 0) 'ok 'error))
            (pages-generated . 1)
            (detected-dialect . ,dialect)
            (ambiguity-warning . ,ambiguity?)
            (status-msg . ,(if ambiguity? msg "Processing completed successfully.")))))))))
