# Scheme R7RS PDF Generator & Reader Engine (`(iris pdf)`)

## 1. Executive Summary
The `(iris pdf)` R7RS-large Scheme library provides a low-level imperative procedural interface for direct emission and parsing of PDF 1.7 specification binary documents without external C or third-party library dependencies.

The library incorporates a **pure R7RS Scheme zlib/DEFLATE stream encoder** (RFC 1950 / RFC 1951) for optional stream compression (`/Filter /FlateDecode`).

This library is designed in **structural isomorphism** with the Fortran 2008 `iris_pdf` module.

---

## 2. API Architecture & Symmetrical Procedure Mapping

| API Functionality | R7RS Scheme (`(iris pdf)`) | Fortran 2008 (`iris_pdf`) |
| :--- | :--- | :--- |
| **Initialize Writer** | `(pdf-init filename [compress?])` | `call pdf_init(pdf, filename, status, [compress])` |
| **Add Page Context** | `(pdf-add-page! pdf width height)` | `call pdf_add_page(pdf, width, height)` |
| **Write Text Block** | `(pdf-write-text! pdf x y size str)` | `call pdf_write_text(pdf, x, y, size, str)` |
| **Draw Rectangle** | `(pdf-draw-rect! pdf x y w h fill)` | `call pdf_draw_rect(pdf, x, y, w, h, fill)` |
| **Finalize & Close** | `(pdf-close! pdf)` | `call pdf_close(pdf, status)` |
| **Initialize Reader** | `(pdf-open-read filename)` | `call pdf_open_read(pdf, filename, status)` |
| **Get Page Count** | `(pdf-get-page-count pdf)` | `call pdf_get_page_count(pdf, count)` |
| **Extract Stream** | `(pdf-extract-stream pdf obj-id)` | `call pdf_extract_stream(pdf, obj-id, strm, len, status)` |
| **Read Page Text** | `(pdf-read-page-text pdf page-num)` | `call pdf_read_page_text(pdf, page-num, text, len, status)` |

---

## 3. Scheme Usage Example (Writing & Reading Back)

```scheme
#!/usr/bin/env scheme-r7rs

(import (scheme base)
        (scheme write)
        (iris pdf))

;; 1. Write Compressed PDF File
(let ((pdf (pdf-init "output.pdf" #t)))
  (pdf-add-page! pdf 612.0 792.0)
  (pdf-draw-rect! pdf 50.0 700.0 512.0 40.0 #t)
  (pdf-write-text! pdf 60.0 715.0 16.0 "Scheme R7RS PDF Engine")
  (pdf-close! pdf))

;; 2. Read Back Generated PDF File
(let* ((reader-pdf (pdf-open-read "output.pdf"))
       (page-count (pdf-get-page-count reader-pdf))
       (extracted-text (pdf-read-page-text reader-pdf 1)))
  (display "Total Pages: ") (display page-count) (newline)
  (display "Page 1 Text: ") (display extracted-text) (newline)
  (pdf-close! reader-pdf))
```

---

## 4. Software Design Discipline & Verification
- **R7RS Conformance**: Standard Scheme library structure using `(define-library (iris pdf) ...)` with explicit exports.
- **Pure zlib Algorithm**: Implements RFC 1950 Adler-32 checksums and RFC 1951 DEFLATE stored block wrappers natively in portable R7RS math and string primitives.
- **Functional Exemption**: In accordance with system design rules, Scheme code is explicitly exempt from imperative single-exit control flow constraints.
- **Module Synchronization**: Maintained in strict synchronization with `/scheme/iris/pdf.sld` and `/fortran/iris_pdf.f90`.
