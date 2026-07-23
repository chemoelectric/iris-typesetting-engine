;;; ==============================================================================
;;; IRIS MICROTYPOGRAPHY LAYOUT ENGINE
;;; Library: (iris cli)
;;; Language: R7RS-large Scheme (compatible with Gauche Scheme in R7RS mode)
;;; Purpose: GNU long_getopt CLI argument parsing, standard I/O streaming,
;;;          and automatic font format detection (OTF/TTF/JSON).
;;; ==============================================================================

(define-library (iris cli)
  (import (scheme base)
          (scheme read)
          (scheme write)
          (scheme file)
          (scheme char))
  (export parse-cli-args
          read-input-bytes
          detect-font-flavor
          detect-output-format
          write-output)

  (begin
    ;; Helper: Parse string value for boolean flags ("yes", "no", "true", "false", "1", "0")
    (define (string->boolean-value str)
      (let ((s (string-downcase str)))
        (cond
          ((or (string=? s "yes") (string=? s "true") (string=? s "1") (string=? s "y")) #t)
          ((or (string=? s "no") (string=? s "false") (string=? s "0") (string=? s "n")) #f)
          (else #t))))

    ;; Check if string starts with a given prefix
    (define (string-prefix? prefix str)
      (let ((plen (string-length prefix))
            (slen (string-length str)))
        (and (>= slen plen)
             (string=? prefix (substring str 0 plen)))))

    ;; Case-insensitive suffix check for file extensions (.otf, .ttf, .json)
    (define (string-suffix-ci? suffix str)
      (let ((slen (string-length suffix))
            (len (string-length str)))
        (and (>= len slen)
             (string-ci=? suffix (substring str (- len slen) len)))))

    ;; Search character in string
    (define (char-in-string? c str)
      (let ((len (string-length str)))
        (let loop ((i 0))
          (if (>= i len)
              #f
              (if (char=? c (string-ref str i))
                  #t
                  (loop (+ i 1)))))))

    ;; GNU long_getopt option parser
    ;; Supports:
    ;;   -a                          (boolean short flag for apply, takes NO argument)
    ;;   --apply / --apply=VAL       (long flag for apply)
    ;;   -o FILE / -oFILE / --output=FILE / --output FILE  (output specifier)
    ;;   -f FMT / -fFMT / --format=FMT / --format FMT      (format override: otf, ttf, json)
    ;;   --                          (stop option parsing; remaining args are positional)
    ;;   Flags can appear before, between, or after positional arguments.
    (define (parse-cli-args args)
      (let loop ((rest args)
                 (in-options? #t)
                 (apply-pegs? #f)
                 (output-path #f)
                 (format-override #f)
                 (show-help? #f)
                 (show-version? #f)
                 (positional '()))
        (if (null? rest)
            `((apply-pegs . ,apply-pegs?)
              (output-path . ,output-path)
              (format . ,format-override)
              (help . ,show-help?)
              (version . ,show-version?)
              (positional . ,(reverse positional)))
            (let ((arg (car rest)))
              (cond
                ;; Stop option parsing on "--"
                ((and in-options? (string=? arg "--"))
                 (loop (cdr rest) #f apply-pegs? output-path format-override show-help? show-version? positional))

                ;; Help flags
                ((and in-options? (or (string=? arg "-h") (string=? arg "--help")))
                 (loop (cdr rest) in-options? apply-pegs? output-path format-override #t show-version? positional))

                ;; Version flags
                ((and in-options? (or (string=? arg "-v") (string=? arg "-V") (string=? arg "--version")))
                 (loop (cdr rest) in-options? apply-pegs? output-path format-override show-help? #t positional))

                ;; Short option -a (takes NO argument)
                ((and in-options? (string=? arg "-a"))
                 (loop (cdr rest) in-options? #t output-path format-override show-help? show-version? positional))

                ;; Long option --apply / --apply=val
                ((and in-options? (string=? arg "--apply"))
                 (loop (cdr rest) in-options? #t output-path format-override show-help? show-version? positional))
                ((and in-options? (string-prefix? "--apply=" arg))
                 (let ((val (string->boolean-value (substring arg 8 (string-length arg)))))
                   (loop (cdr rest) in-options? val output-path format-override show-help? show-version? positional)))

                ;; Output option: -o FILE, -oFILE, --output FILE, --output=FILE
                ((and in-options? (string=? arg "-o"))
                 (if (null? (cdr rest))
                     (loop (cdr rest) in-options? apply-pegs? output-path format-override show-help? show-version? positional)
                     (loop (cddr rest) in-options? apply-pegs? (cadr rest) format-override show-help? show-version? positional)))
                ((and in-options? (> (string-length arg) 2) (string-prefix? "-o" arg))
                 (loop (cdr rest) in-options? apply-pegs? (substring arg 2 (string-length arg)) format-override show-help? show-version? positional))
                ((and in-options? (string=? arg "--output"))
                 (if (null? (cdr rest))
                     (loop (cdr rest) in-options? apply-pegs? output-path format-override show-help? show-version? positional)
                     (loop (cddr rest) in-options? apply-pegs? (cadr rest) format-override show-help? show-version? positional)))
                ((and in-options? (string-prefix? "--output=" arg))
                 (loop (cdr rest) in-options? apply-pegs? output-path (substring arg 9 (string-length arg)) format-override show-help? show-version? positional))

                ;; Format option: -f FORMAT, -fFORMAT, --format FORMAT, --format=FORMAT
                ((and in-options? (string=? arg "-f"))
                 (if (null? (cdr rest))
                     (loop (cdr rest) in-options? apply-pegs? output-path format-override show-help? show-version? positional)
                     (loop (cddr rest) in-options? apply-pegs? output-path (cadr rest) show-help? show-version? positional)))
                ((and in-options? (> (string-length arg) 2) (string-prefix? "-f" arg))
                 (loop (cdr rest) in-options? apply-pegs? output-path (substring arg 2 (string-length arg)) show-help? show-version? positional))
                ((and in-options? (string=? arg "--format"))
                 (if (null? (cdr rest))
                     (loop (cdr rest) in-options? apply-pegs? output-path format-override show-help? show-version? positional)
                     (loop (cddr rest) in-options? apply-pegs? output-path (cadr rest) show-help? show-version? positional)))
                ((and in-options? (string-prefix? "--format=" arg))
                 (loop (cdr rest) in-options? apply-pegs? output-path (substring arg 9 (string-length arg)) show-help? show-version? positional))

                ;; Combined or standalone flags starting with "-" (excluding "-" itself)
                ((and in-options? (> (string-length arg) 1) (char=? (string-ref arg 0) #\-))
                 (let* ((substr (substring arg 1 (string-length arg)))
                        (has-a? (char-in-string? #\a substr))
                        (has-h? (char-in-string? #\h substr))
                        (has-v? (or (char-in-string? #\v substr) (char-in-string? #\V substr))))
                   (loop (cdr rest) in-options? (or apply-pegs? has-a?) output-path format-override (or show-help? has-h?) (or show-version? has-v?) positional)))

                ;; Positional argument
                (else
                 (loop (cdr rest) in-options? apply-pegs? output-path format-override show-help? show-version? (cons arg positional))))))))

    ;; Read all bytes from a input file path OR standard input (if path is #f or "-")
    (define (read-input-bytes input-path)
      (if (or (not input-path) (string=? input-path "-"))
          (read-all-port-bytes (current-input-port))
          (call-with-port (open-binary-input-file input-path)
            read-all-port-bytes)))

    ;; Read bytevector chunks from port until EOF
    (define (read-all-port-bytes port)
      (let loop ((chunks '()) (total 0))
        (let ((bv (read-bytevector 8192 port)))
          (if (or (eof-object? bv) (= (bytevector-length bv) 0))
              (let ((res (make-bytevector total 0)))
                (let copy-loop ((lst (reverse chunks)) (pos 0))
                  (if (null? lst)
                      res
                      (let* ((c (car lst))
                             (len (bytevector-length c)))
                        (bytevector-copy! res pos c 0 len)
                        (copy-loop (cdr lst) (+ pos len))))))
              (loop (cons bv chunks) (+ total (bytevector-length bv)))))))

    ;; Detect font flavor from header magic bytes:
    ;;   - 0x4F 0x54 0x54 0x4F ("OTTO") -> 'otf
    ;;   - 0x00 0x01 0x00 0x00 or "true" or "typ1" -> 'ttf
    ;;   - Otherwise -> 'json
    (define (detect-font-flavor bv)
      (if (< (bytevector-length bv) 4)
          'json
          (let ((b0 (bytevector-u8-ref bv 0))
                (b1 (bytevector-u8-ref bv 1))
                (b2 (bytevector-u8-ref bv 2))
                (b3 (bytevector-u8-ref bv 3)))
            (cond
              ((and (= b0 #x4F) (= b1 #x54) (= b2 #x54) (= b3 #x4F)) 'otf)
              ((or (and (= b0 0) (= b1 1) (= b2 0) (= b3 0))
                   (and (= b0 #x74) (= b1 #x72) (= b2 #x75) (= b3 #x65))
                   (and (= b0 #x74) (= b1 #x79) (= b2 #x70) (= b3 #x31))) 'ttf)
              (else 'json)))))

    ;; Determine output format priority:
    ;;  1. --format / -f override
    ;;  2. Case-insensitive output file extension (.otf, .ttf, .json)
    ;;  3. Default format
    (define (detect-output-format format-override output-path default-fmt)
      (cond
        (format-override
         (let ((fmt (string-downcase format-override)))
           (cond
             ((or (string=? fmt "otf") (string=? fmt "open-type") (string=? fmt "opentype")) 'otf)
             ((or (string=? fmt "ttf") (string=? fmt "true-type") (string=? fmt "truetype")) 'ttf)
             ((string=? fmt "json") 'json)
             (else default-fmt))))
        ((and output-path (not (string=? output-path "-")) (not (string=? output-path "stdout")))
         (cond
           ((string-suffix-ci? ".otf" output-path) 'otf)
           ((string-suffix-ci? ".ttf" output-path) 'ttf)
           ((string-suffix-ci? ".json" output-path) 'json)
           (else default-fmt)))
        (else default-fmt)))

    ;; Write bytevector OR text string output to standard output or specified file
    (define (write-output output-path data format-symbol log-msg)
      (let ((is-stdout? (or (not output-path) (string=? output-path "-") (string=? output-path "stdout"))))
        (if is-stdout?
            (begin
              (if (symbol=? format-symbol 'json)
                  (display (if (bytevector? data) (utf8->string data) data) (current-output-port))
                  (write-bytevector (if (string? data) (string->utf8 data) data) (current-output-port)))
              (when log-msg
                (display log-msg (current-error-port))
                (newline (current-error-port))))
            (begin
              (if (symbol=? format-symbol 'json)
                  (call-with-port (open-output-file output-path)
                    (lambda (port)
                      (display (if (bytevector? data) (utf8->string data) data) port)))
                  (call-with-port (open-binary-output-file output-path)
                    (lambda (port)
                      (write-bytevector (if (string? data) (string->utf8 data) data) port))))
              (when log-msg
                (display log-msg)
                (newline))))))))
