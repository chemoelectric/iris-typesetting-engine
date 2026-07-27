(define-library (iris kpsewhich)
  (import (scheme base))
  (export kpse-search-file kpse-find-font)
  (begin
    (define (kpse-search-file filename format)
      filename)
    (define (kpse-find-font font-name)
      (string-append font-name ".tfm"))))
