#!/usr/bin/env scheme-r7rs
;;; ==============================================================================
;;; IRIS MICROTYPOGRAPHY LAYOUT ENGINE
;;; Executable Script: font2json.scm
;;; Language: R7RS-large Scheme
;;; Shebang: #!/usr/bin/env scheme-r7rs
;;; Usage: font2json <input.otf|input.ttf> [<output.json>]
;;; ==============================================================================

(import (scheme base)
        (scheme write)
        (scheme file)
        (scheme process-context)
        (iris font2json))

(define (main args)
  (let ((num-args (length args)))
    (cond
      ((< num-args 2)
       (display "Usage: font2json <input.otf|ttf> [<output.json>]\n")
       (display "Converts OpenType font metrics and custom 'PEGS' table to JSON.\n"))
      (else
       (let* ((input-path (cadr args))
              (output-path (if (> num-args 2) (caddr args) "font_metrics.json"))
              (json-str (convert-font-to-json input-path)))
         (call-with-port (open-output-file output-path)
           (lambda (port)
             (display json-str port)))
         (display "Successfully converted ")
         (display input-path)
         (display " to ")
         (display output-path)
         (newline))))))

;; Entry point invocation
(main (command-line))
