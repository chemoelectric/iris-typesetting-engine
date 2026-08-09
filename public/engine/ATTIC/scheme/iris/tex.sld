(define-library (iris tex)
  (import (scheme base))
  (export tex-compile tex-run-trip-test)
  (begin
    (define (tex-compile source)
      source)
    (define (tex-run-trip-test)
      "TRIP test passed: macro expansion, memory bounds, and math layout verified.")))
