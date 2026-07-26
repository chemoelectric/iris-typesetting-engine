# Fortran 2008 Batch Typographic Pipeline & CUPS PDF Engine (`iris_batch_engine`)

## 1. Executive Summary
The `iris_batch_engine` module provides a standard Fortran 2008 (ISO/IEC 1539-1:2010) end-to-end batch processing pipeline for compiling mixed markup documents into production-grade PDF/X-1a and PDF/A compliant documents optimized for CUPS printing systems (including Canon UFR II multi-system Linux rasterizer pipelines).

Key capabilities include:
- Integrated pipeline orchestrating markup parsing (`iris_markup_parser`), peg spacing layout (`iris_evaluate_pegs`), and PDF emission (`iris_pdf`).
- Configurable page geometries, margins, font sizing, and strict CUPS PDF/X vector font embedding enforcement.
- Automated generation of batch run reports including page count, detected dialect, and markup ambiguity alerts.

This module is designed in **structural isomorphism** with the R7RS Scheme `(iris batch-engine)` library.

---

## 2. Structural Isomorphism Matrix

| API Functionality | Fortran 2008 (`iris_batch_engine`) | R7RS Scheme (`(iris batch-engine)`) |
| :--- | :--- | :--- |
| **Init Config** | `call batch_init_config(cfg)` | `(make-batch-config [opts])` |
| **Process Document** | `call batch_process_document(text, pdf, cfg, rep)` | `(batch-process-document text pdf [cfg])` |

---

## 3. Example Usage in Fortran 2008

```fortran
program test_batch_engine
  use iris_batch_engine
  implicit none

  type(batch_config_type)     :: cfg
  type(batch_run_report_type) :: report
  character(len=512)          :: input_doc

  call batch_init_config(cfg)
  cfg%font_size = 12.0d0

  input_doc = "[markup: troff] .TH DOC 1\n.SH TITLE\nIris Batch Pipeline on CUPS"

  call batch_process_document(input_doc, "output.pdf", cfg, report)

  print *, "Batch Status:", report%status
  print *, "Pages Generated:", report%pages_generated
  print *, "Status Message:", trim(report%status_msg)
end program test_batch_engine
```

---

## 4. Architectural Standards & Compliance
- **ISO Standard**: Standard Fortran 2008 (ISO/IEC 1539-1:2010).
- **Structured Control**: Enforces single-entry/single-exit control constructs without `goto` constructs.
- **McCabe Complexity**: Each procedure strictly maintains a modified McCabe cyclomatic complexity $\le 10$.
- **Module Synchronization**: Maintained in strict synchronization with `/fortran/iris_batch_engine.f90`.
