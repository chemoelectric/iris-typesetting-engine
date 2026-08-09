;;; ============================================================================
;;; Scheme Library: (iris cli-args)
;;; Standard: R7RS (ISO/IEC 30179) / Gauche Scheme (R7RS Mode)
;;; Domain: Declarative Specification-Driven Command Line Argument Parser
;;; Isomorphism: Structurally Isomorphic to Fortran 2008 iris_cli_args module
;;; Exemptions: R7RS Scheme functional code is exempt from single-exit rules.
;;; ============================================================================

(define-library (iris cli-args)
  (export
    make-cli-parser
    cli-add-option!
    cli-add-mode!
    cli-parse
    cli-has-option?
    cli-get-option
    cli-option-count
    cli-positional-count
    cli-get-positional
    cli-positionals
    cli-format-help
    cli-print-help
    cli-format-mode-help
    cli-print-mode-help)

  (import (scheme base)
          (scheme write)
          (scheme char)
          (scheme string)
          (scheme process-context))

  (begin
    ;; -------------------------------------------------------------------------
    ;; Record Definitions
    ;; -------------------------------------------------------------------------
    (define-record-type <cli-option-spec>
      (make-option-spec short-flag long-flag arg-mode value-name help-text)
      option-spec?
      (short-flag spec-short)
      (long-flag spec-long)
      (arg-mode spec-mode)
      (value-name spec-val-name)
      (help-text spec-help))

    (define-record-type <cli-mode-spec>
      (make-mode-spec name args help detailed)
      mode-spec?
      (name mode-name)
      (args mode-args)
      (help mode-help)
      (detailed mode-detailed))

    (define-record-type <cli-parser>
      (make-parser prog-name desc specs modes)
      cli-parser?
      (prog-name parser-prog-name)
      (desc parser-desc)
      (specs parser-specs parser-specs-set!)
      (modes parser-modes parser-modes-set!))

    (define-record-type <cli-result>
      (make-result parsed-opts positionals status error-msg)
      cli-result?
      (parsed-opts result-opts)
      (positionals result-positionals)
      (status result-status)
      (error-msg result-error-msg))

    ;; -------------------------------------------------------------------------
    ;; Constructor
    ;; -------------------------------------------------------------------------
    (define (make-cli-parser prog-name desc)
      (make-parser (if (string? prog-name) prog-name "")
                   (if (string? desc) desc "")
                   '()
                   '()))

    ;; -------------------------------------------------------------------------
    ;; Registration
    ;; -------------------------------------------------------------------------
    (define (cli-add-option! parser short-flag long-flag arg-mode value-name help-text)
      (let ((spec (make-option-spec
                    (cond ((char? short-flag) (string short-flag))
                          ((string? short-flag) short-flag)
                          (else #f))
                    (if (string? long-flag) long-flag #f)
                    (case arg-mode
                      ((required 1 'required) 'required)
                      ((optional 2 'optional) 'optional)
                      (else 'none))
                    (if (string? value-name) value-name "")
                    (if (string? help-text) help-text ""))))
        (parser-specs-set! parser (append (parser-specs parser) (list spec)))))

    (define (cli-add-mode! parser mode-name mode-args help-text . rest)
      (let ((detailed (if (and (pair? rest) (string? (car rest))) (car rest) ""))
            (spec (make-mode-spec
                    (if (string? mode-name) mode-name "")
                    (if (string? mode-args) mode-args "")
                    (if (string? help-text) help-text "")
                    (if (and (pair? rest) (string? (car rest))) (car rest) ""))))
        (parser-modes-set! parser (append (parser-modes parser) (list spec)))))

    ;; -------------------------------------------------------------------------
    ;; Internal Helpers
    ;; -------------------------------------------------------------------------
    (define (find-spec-by-flag parser flag-str)
      (let loop ((specs (parser-specs parser)))
        (if (null? specs)
            #f
            (let ((sp (car specs)))
              (if (or (and (spec-short sp) (string=? (spec-short sp) flag-str))
                      (and (spec-long sp) (string=? (spec-long sp) flag-str)))
                  sp
                  (loop (cdr specs)))))))

    ;; -------------------------------------------------------------------------
    ;; Parse Execution
    ;; -------------------------------------------------------------------------
    (define (cli-parse parser . opt-args)
      (let ((raw-args (if (null? opt-args)
                          (cdr (command-line))
                          (car opt-args))))
        (let loop ((args raw-args)
                   (parsed-opts '())
                   (positionals '())
                   (double-dash? #f))
          (if (null? args)
              (make-result (reverse parsed-opts) (reverse positionals) 0 "")
              (let ((arg (car args))
                    (rest (cdr args)))
                (cond
                 ;; After --, treat everything as positional
                 (double-dash?
                  (loop rest parsed-opts (cons arg positionals) #t))

                 ;; -- terminator
                 ((string=? arg "--")
                  (loop rest parsed-opts positionals #t))

                 ;; Long option --flag or --flag=value
                 ((and (> (string-length arg) 2)
                       (string=? (substring arg 0 2) "--"))
                  (let* ((eq-idx (string-index arg #\=))
                         (flag-name (if eq-idx
                                        (substring arg 2 eq-idx)
                                        (substring arg 2 (string-length arg))))
                         (inline-val (if eq-idx
                                         (substring arg (+ eq-idx 1) (string-length arg))
                                         #f))
                         (spec (find-spec-by-flag parser flag-name)))
                    (if (not spec)
                        (make-result '() '() -1 (string-append "Unknown option --" flag-name))
                        (cond
                         (inline-val
                          (loop rest (cons (cons spec inline-val) parsed-opts) positionals #f))
                         ((eq? (spec-mode spec) 'required)
                          (if (null? rest)
                              (make-result '() '() -1 (string-append "Missing required argument for --" flag-name))
                              (loop (cdr rest) (cons (cons spec (car rest)) parsed-opts) positionals #f)))
                         (else
                          (loop rest (cons (cons spec "") parsed-opts) positionals #f))))))

                 ;; Short option -f or -fVAL
                 ((and (> (string-length arg) 1)
                       (char=? (string-ref arg 0) #\-))
                  (let* ((flag-name (substring arg 1 2))
                         (inline-val (if (> (string-length arg) 2)
                                         (substring arg 2 (string-length arg))
                                         #f))
                         (spec (find-spec-by-flag parser flag-name)))
                    (if (not spec)
                        (make-result '() '() -1 (string-append "Unknown option -" flag-name))
                        (cond
                         (inline-val
                          (loop rest (cons (cons spec inline-val) parsed-opts) positionals #f))
                         ((eq? (spec-mode spec) 'required)
                          (if (null? rest)
                              (make-result '() '() -1 (string-append "Missing required argument for -" flag-name))
                              (loop (cdr rest) (cons (cons spec (car rest)) parsed-opts) positionals #f)))
                         (else
                          (loop rest (cons (cons spec "") parsed-opts) positionals #f))))))

                 ;; Positional argument
                 (else
                  (loop rest parsed-opts (cons arg positionals) #f))))))))

    ;; Helper string-index
    (define (string-index str char)
      (let loop ((i 0))
        (cond ((>= i (string-length str)) #f)
              ((char=? (string-ref str i) char) i)
              (else (loop (+ i 1))))))

    ;; -------------------------------------------------------------------------
    ;; Query Procedures
    ;; -------------------------------------------------------------------------
    (define (cli-has-option? result flag-query)
      (let loop ((opts (result-opts result)))
        (if (null? opts)
            #f
            (let* ((pair (car opts))
                   (spec (car pair)))
              (if (or (and (spec-short spec) (string=? (spec-short spec) flag-query))
                      (and (spec-long spec) (string=? (spec-long spec) flag-query)))
                  #t
                  (loop (cdr opts)))))))

    (define (cli-get-option result flag-query)
      (let loop ((opts (result-opts result)))
        (if (null? opts)
            #f
            (let* ((pair (car opts))
                   (spec (car pair)))
              (if (or (and (spec-short spec) (string=? (spec-short spec) flag-query))
                      (and (spec-long spec) (string=? (spec-long spec) flag-query)))
                  (cdr pair)
                  (loop (cdr opts)))))))

    (define (cli-option-count result flag-query)
      (let loop ((opts (result-opts result))
                 (count 0))
        (if (null? opts)
            count
            (let* ((pair (car opts))
                   (spec (car pair)))
              (if (or (and (spec-short spec) (string=? (spec-short spec) flag-query))
                      (and (spec-long spec) (string=? (spec-long spec) flag-query)))
                  (loop (cdr opts) (+ count 1))
                  (loop (cdr opts) count))))))

    (define (cli-positional-count result)
      (length (result-positionals result)))

    (define (cli-get-positional result index)
      (let ((pos (result-positionals result)))
        (if (and (>= index 1) (<= index (length pos)))
            (list-ref pos (- index 1))
            #f)))

    (define (cli-positionals result)
      (result-positionals result))

    ;; -------------------------------------------------------------------------
    ;; Help Generation
    ;; -------------------------------------------------------------------------
    (define (cli-format-help parser)
      (let ((out (open-output-string)))
        (display "Usage: " out)
        (display (parser-prog-name parser) out)
        (if (null? (parser-modes parser))
            (display " [OPTIONS] [ARGUMENTS]\n" out)
            (display " [OPTIONS] [MODE] [ARGUMENTS]\n" out))
        (if (not (string=? (parser-desc parser) ""))
            (begin
              (display (parser-desc parser) out)
              (display "\n" out)))
        (if (not (null? (parser-modes parser)))
            (begin
              (display "\nModes / Subcommands:\n" out)
              (for-each
               (lambda (m)
                 (let ((m-str (string-append "  " (mode-name m)
                                             (if (not (string=? (mode-args m) ""))
                                                 (string-append " " (mode-args m))
                                                 ""))))
                   (display m-str out)
                   (display "    " out)
                   (display (mode-help m) out)
                   (newline out)))
               (parser-modes parser))))
        (display "\nOptions:\n" out)
        (for-each
         (lambda (sp)
           (let ((flag-str
                  (string-append
                   "  "
                   (if (spec-short sp) (string-append "-" (spec-short sp)) "    ")
                   (if (and (spec-short sp) (spec-long sp)) ", " "  ")
                   (if (spec-long sp) (string-append "--" (spec-long sp)) "")
                   (if (not (string=? (spec-val-name sp) ""))
                       (string-append " <" (spec-val-name sp) ">")
                       ""))))
             (display flag-str out)
             (display "    " out)
             (display (spec-help sp) out)
             (newline out)))
         (parser-specs parser))
        (get-output-string out)))

    (define (cli-print-help parser)
      (display (cli-format-help parser)))

    (define (cli-format-mode-help parser mode-name-str)
      (let ((found #f)
            (modes (parser-modes parser)))
        (for-each
         (lambda (m)
           (if (string=? (mode-name m) mode-name-str)
               (set! found m)))
         modes)
        (if found
            (let ((out (open-output-string)))
              (display "Usage: " out)
              (display (parser-prog-name parser) out)
              (display " " out)
              (display (mode-name found) out)
              (if (not (string=? (mode-args found) ""))
                  (begin (display " " out) (display (mode-args found) out)))
              (display "\n\n" out)
              (display (mode-help found) out)
              (display "\n" out)
              (if (not (string=? (mode-detailed found) ""))
                  (begin
                    (display "\n" out)
                    (display (mode-detailed found) out)
                    (display "\n" out)))
              (display "\nOptions:\n" out)
              (for-each
               (lambda (sp)
                 (let ((flag-str
                        (string-append
                         "  "
                         (if (spec-short sp) (string-append "-" (spec-short sp)) "    ")
                         (if (and (spec-short sp) (spec-long sp)) ", " "  ")
                         (if (spec-long sp) (string-append "--" (spec-long sp)) "")
                         (if (not (string=? (spec-val-name sp) ""))
                             (string-append " <" (spec-val-name sp) ">")
                             ""))))
                   (display flag-str out)
                   (display "    " out)
                   (display (spec-help sp) out)
                   (newline out)))
               (parser-specs parser))
              (get-output-string out))
            (cli-format-help parser))))

    (define (cli-print-mode-help parser mode-name-str)
      (display (cli-format-mode-help parser mode-name-str)))))
