# Scheme Batch Typographic Pipeline & CUPS PDF Engine (`(iris batch-engine)`)

## 1. Executive Summary
The `(iris batch-engine)` R7RS-large Scheme library provides a functional data-structure interface for executing ConTeXt-style batch compilation runs, processing mixed markup documents, and generating CUPS-ready PDF output files.

This library is designed in **structural isomorphism** with the Fortran 2008 `iris_batch_engine` module.

---

## 2. Structural Isomorphism Matrix

| API Functionality | R7RS Scheme (`(iris batch-engine)`) | Fortran 2008 (`iris_batch_engine`) |
| :--- | :--- | :--- |
| **Init Config** | `(make-batch-config [opts])` | `call batch_init_config(cfg)` |
| **Process Document** | `(batch-process-document text pdf [cfg])` | `call batch_process_document(text, pdf, cfg, rep)` |

---

## 3. Example Usage in R7RS Scheme

```scheme
(import (scheme base)
        (scheme write)
        (iris batch-engine))

(let* ((cfg (make-batch-config "A4" 72.0 72.0 12.0))
       (input "[markup: troff] .TH DOC 1\n.SH TITLE\nIris Batch Pipeline on CUPS")
       (report (batch-process-document input "output.pdf" cfg)))

  (display "Status: ")
  (write (cdr (assoc 'status report)))
  (newline)

  (display "Pages Generated: ")
  (write (cdr (assoc 'pages-generated report)))
  (newline))
```

---

## 4. Architectural Standards & Compliance
- **R7RS Conformance**: Standard Scheme library structure using `(define-library (iris batch-engine) ...)` with explicit exports.
- **Functional Exemption**: In accordance with system design rules, Scheme code is explicitly exempt from imperative single-exit control flow constraints.
- **Module Synchronization**: Maintained in strict synchronization with `/scheme/iris/batch-engine.sld` and `/fortran/iris_batch_engine.f90`.
