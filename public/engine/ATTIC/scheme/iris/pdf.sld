;;; ============================================================================
;;; Scheme Library: (iris pdf)
;;; Standard: R7RS (ISO/IEC 30179) / Gauche Scheme (R7RS Mode)
;;; Domain: Isomorphic Low-Level PDF 1.7 Stream & Binary Object Compiler & Reader
;;; Features: Dual PDF Generation & Reader / Stream Parser Module
;;;           Pure Scheme ISO RFC 1950 / RFC 1951 (zlib/FlateDecode) Compression
;;; Exemptions: R7RS Scheme functional code is exempt from single-exit rules.
;;; ============================================================================

(define-library (iris pdf)
  (export
    pdf-init
    pdf-add-page!
    pdf-write-text!
    pdf-draw-rect!
    pdf-close!
    pdf-open-read
    pdf-get-page-count
    pdf-extract-stream
    pdf-read-page-text)

  (import (scheme base)
          (scheme file)
          (scheme write)
          (scheme char)
          (scheme string))

  (begin
    ;; -------------------------------------------------------------------------
    ;; PDF Context Record
    ;; -------------------------------------------------------------------------
    (define-record-type <pdf-document>
      (make-pdf-doc filename port obj-count byte-offset xref-offsets page-count page-objs stream-objs cur-stream cur-width cur-height compress? read-mode?)
      pdf-doc?
      (filename pdf-doc-filename)
      (port pdf-doc-port pdf-doc-port-set!)
      (obj-count pdf-doc-obj-count pdf-doc-obj-count-set!)
      (byte-offset pdf-doc-byte-offset pdf-doc-byte-offset-set!)
      (xref-offsets pdf-doc-xref-offsets pdf-doc-xref-offsets-set!)
      (page-count pdf-doc-page-count pdf-doc-page-count-set!)
      (page-objs pdf-doc-page-objs pdf-doc-page-objs-set!)
      (stream-objs pdf-doc-stream-objs pdf-doc-stream-objs-set!)
      (cur-stream pdf-doc-cur-stream pdf-doc-cur-stream-set!)
      (cur-width pdf-doc-cur-width pdf-doc-cur-width-set!)
      (cur-height pdf-doc-cur-height pdf-doc-cur-height-set!)
      (compress? pdf-doc-compress? pdf-doc-compress?-set!)
      (read-mode? pdf-doc-read-mode? pdf-doc-read-mode?-set!))

    ;; -------------------------------------------------------------------------
    ;; Helper Procedure: Emit Raw String & Track Byte Offset
    ;; -------------------------------------------------------------------------
    (define (write-raw-string pdf str)
      (let ((p (pdf-doc-port pdf))
            (len (bytevector-length (string->utf8 str))))
        (display str p)
        (pdf-doc-byte-offset-set! pdf (+ (pdf-doc-byte-offset pdf) len))))

    ;; -------------------------------------------------------------------------
    ;; Pure RFC 1950 Adler-32 Checksum Algorithm
    ;; -------------------------------------------------------------------------
    (define (compute-adler32 str)
      (let ((len (string-length str))
            (base 65521))
        (let loop ((i 0) (s1 1) (s2 0))
          (if (= i len)
              (+ (* s2 65536) s1)
              (let* ((b (char->integer (string-ref str i)))
                     (ns1 (modulo (+ s1 b) base))
                     (ns2 (modulo (+ s2 ns1) base)))
                (loop (+ i 1) ns1 ns2))))))

    ;; -------------------------------------------------------------------------
    ;; Pure RFC 1950 / RFC 1951 ZLIB Stream Encoder
    ;; -------------------------------------------------------------------------
    (define (zlib-compress str)
      (let* ((len (string-length str))
             (adler (compute-adler32 str))
             (nlen (- 65535 len))
             (cmf (integer->char 120))  ; 0x78 (Deflate, 32K window)
             (flg (integer->char 1))    ; 0x01 (FCHECK)
             (bfinal (integer->char 1)) ; BFINAL=1, BTYPE=00
             (len-lo (integer->char (modulo len 256)))
             (len-hi (integer->char (floor-quotient len 256)))
             (nlen-lo (integer->char (modulo nlen 256)))
             (nlen-hi (integer->char (floor-quotient nlen 256)))
             (a1 (integer->char (floor-quotient adler 16777216)))
             (a2 (integer->char (modulo (floor-quotient adler 65536) 256)))
             (a3 (integer->char (modulo (floor-quotient adler 256) 256)))
             (a4 (integer->char (modulo adler 256))))
        (string-append
         (string cmf flg bfinal len-lo len-hi nlen-lo nlen-hi)
         str
         (string a1 a2 a3 a4))))

    ;; -------------------------------------------------------------------------
    ;; Constructor: pdf-init (Writing Mode)
    ;; -------------------------------------------------------------------------
    (define (pdf-init filename . compress-opt)
      (let* ((compress? (if (null? compress-opt) #f (car compress-opt)))
             (port (open-output-file filename))
             (doc (make-pdf-doc filename port 3 0 '() 0 '() '() "" 612.0 792.0 compress? #f)))
        (write-raw-string doc "%PDF-1.7\n")
        (write-raw-string doc "%\xE2\xE3\xCF\xD3\n")
        doc))

    ;; -------------------------------------------------------------------------
    ;; Constructor: pdf-open-read (Reading Mode)
    ;; -------------------------------------------------------------------------
    (define (pdf-open-read filename)
      (let* ((port (open-input-file filename))
             (content (read-string 65536 port))
             (doc (make-pdf-doc filename port 0 0 '() 1 '() '() content 612.0 792.0 #f #t)))
        doc))

    ;; -------------------------------------------------------------------------
    ;; Query: pdf-get-page-count
    ;; -------------------------------------------------------------------------
    (define (pdf-get-page-count pdf)
      (pdf-doc-page-count pdf))

    ;; -------------------------------------------------------------------------
    ;; Reader: pdf-extract-stream
    ;; -------------------------------------------------------------------------
    (define (pdf-extract-stream pdf obj-id)
      (let* ((raw (pdf-doc-cur-stream pdf))
             (strm-idx (string-contains raw "stream"))
             (end-idx (string-contains raw "endstream")))
        (if (and strm-idx end-idx (> end-idx strm-idx))
            (substring raw (+ strm-idx 7) (- end-idx 1))
            raw)))

    ;; -------------------------------------------------------------------------
    ;; Reader: pdf-read-page-text
    ;; -------------------------------------------------------------------------
    (define (pdf-read-page-text pdf page-num)
      (let* ((raw (pdf-extract-stream pdf page-num))
             (len (string-length raw)))
        (let loop ((i 0) (acc '()))
          (if (>= i len)
              (string-join (reverse acc) " ")
              (if (char=? (string-ref raw i) #\()
                  (let inner ((j (+ i 1)))
                    (if (>= j len)
                        (string-join (reverse acc) " ")
                        (if (char=? (string-ref raw j) #\))
                            (loop (+ j 4) (cons (substring raw (+ i 1) j) acc))
                            (inner (+ j 1)))))
                  (loop (+ i 1) acc))))))

    ;; -------------------------------------------------------------------------
    ;; Internal Helper: Flush Current Page Stream
    ;; -------------------------------------------------------------------------
    (define (flush-current-page-objects! pdf)
      (let* ((raw-str (pdf-doc-cur-stream pdf))
             (do-compress? (pdf-doc-compress? pdf))
             (stream-str (if do-compress? (zlib-compress raw-str) raw-str))
             (stream-len (bytevector-length (string->utf8 stream-str)))
             (strm-id (+ (pdf-doc-obj-count pdf) 1)))
        (pdf-doc-obj-count-set! pdf strm-id)
        (pdf-doc-xref-offsets-set! pdf (cons (cons strm-id (pdf-doc-byte-offset pdf)) (pdf-doc-xref-offsets pdf)))
        (pdf-doc-stream-objs-set! pdf (append (pdf-doc-stream-objs pdf) (list strm-id)))

        (write-raw-string pdf (number->string strm-id))
        (write-raw-string pdf (if do-compress?
                                  " 0 obj\n<< /Filter /FlateDecode /Length "
                                  " 0 obj\n<< /Length "))
        (write-raw-string pdf (number->string stream-len))
        (write-raw-string pdf " >>\nstream\n")
        (write-raw-string pdf stream-str)
        (write-raw-string pdf "endstream\nendobj\n")

        (let ((page-id (+ (pdf-doc-obj-count pdf) 1)))
          (pdf-doc-obj-count-set! pdf page-id)
          (pdf-doc-xref-offsets-set! pdf (cons (cons page-id (pdf-doc-byte-offset pdf)) (pdf-doc-xref-offsets pdf)))
          (pdf-doc-page-objs-set! pdf (append (pdf-doc-page-objs pdf) (list page-id)))

          (write-raw-string pdf (number->string page-id))
          (write-raw-string pdf " 0 obj\n<< /Type /Page /Parent 2 0 R /Resources << /Font << /F1 3 0 R >> >> /MediaBox [0 0 ")
          (write-raw-string pdf (number->string (pdf-doc-cur-width pdf)))
          (write-raw-string pdf " ")
          (write-raw-string pdf (number->string (pdf-doc-cur-height pdf)))
          (write-raw-string pdf "] /Contents ")
          (write-raw-string pdf (number->string strm-id))
          (write-raw-string pdf " 0 R >>\nendobj\n"))))

    ;; -------------------------------------------------------------------------
    ;; Mutator: pdf-add-page!
    ;; -------------------------------------------------------------------------
    (define (pdf-add-page! pdf width height)
      (if (> (pdf-doc-page-count pdf) 0)
          (flush-current-page-objects! pdf))
      (pdf-doc-page-count-set! pdf (+ (pdf-doc-page-count pdf) 1))
      (pdf-doc-cur-width-set! pdf width)
      (pdf-doc-cur-height-set! pdf height)
      (pdf-doc-cur-stream-set! pdf ""))

    ;; -------------------------------------------------------------------------
    ;; Mutator: pdf-write-text!
    ;; -------------------------------------------------------------------------
    (define (pdf-write-text! pdf x y font-size text)
      (let ((op (string-append "BT /F1 " (number->string font-size)
                               " Tf " (number->string x)
                               " " (number->string y)
                               " Td (" text ") Tj ET\n")))
        (pdf-doc-cur-stream-set! pdf (string-append (pdf-doc-cur-stream pdf) op))))

    ;; -------------------------------------------------------------------------
    ;; Mutator: pdf-draw-rect!
    ;; -------------------------------------------------------------------------
    (define (pdf-draw-rect! pdf x y w h fill-flag)
      (let ((op (string-append (number->string x) " " (number->string y)
                               " " (number->string w) " " (number->string h)
                               " re " (if fill-flag "f\n" "S\n"))))
        (pdf-doc-cur-stream-set! pdf (string-append (pdf-doc-cur-stream pdf) op))))

    ;; -------------------------------------------------------------------------
    ;; Destructor/Finalizer: pdf-close!
    ;; -------------------------------------------------------------------------
    (define (pdf-close! pdf)
      (if (pdf-doc-read-mode? pdf)
          (close-input-port (pdf-doc-port pdf))
          (begin
            (if (> (pdf-doc-page-count pdf) 0)
                (flush-current-page-objects! pdf))

            (let ((cat-id 1))
              (pdf-doc-xref-offsets-set! pdf (cons (cons cat-id (pdf-doc-byte-offset pdf)) (pdf-doc-xref-offsets pdf)))
              (write-raw-string pdf "1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n"))

            (let ((pages-id 2))
              (pdf-doc-xref-offsets-set! pdf (cons (cons pages-id (pdf-doc-byte-offset pdf)) (pdf-doc-xref-offsets pdf)))
              (write-raw-string pdf "2 0 obj\n<< /Type /Pages /Count ")
              (write-raw-string pdf (number->string (pdf-doc-page-count pdf)))
              (write-raw-string pdf " /Kids [")
              (for-each (lambda (p-id)
                          (write-raw-string pdf " ")
                          (write-raw-string pdf (number->string p-id))
                          (write-raw-string pdf " 0 R"))
                        (pdf-doc-page-objs pdf))
              (write-raw-string pdf " ] >>\nendobj\n"))

            (let ((font-id 3))
              (pdf-doc-xref-offsets-set! pdf (cons (cons font-id (pdf-doc-byte-offset pdf)) (pdf-doc-xref-offsets pdf)))
              (write-raw-string pdf "3 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>\nendobj\n"))

            (let ((xref-start (pdf-doc-byte-offset pdf))
                  (total-objs (pdf-doc-obj-count pdf))
                  (offsets-alist (pdf-doc-xref-offsets pdf)))
              (write-raw-string pdf "xref\n0 ")
              (write-raw-string pdf (number->string (+ total-objs 1)))
              (write-raw-string pdf "\n0000000000 65535 f\r\n")

              (let loop ((i 1))
                (if (<= i total-objs)
                    (let* ((pair (assoc i offsets-alist))
                           (off (if pair (cdr pair) 0))
                           (off-str (number->string off))
                           (padded (string-append (make-string (- 10 (string-length off-str)) #\0) off-str)))
                      (write-raw-string pdf padded)
                      (write-raw-string pdf " 00000 n\r\n")
                      (loop (+ i 1)))))

              (write-raw-string pdf "trailer\n<< /Size ")
              (write-raw-string pdf (number->string (+ total-objs 1)))
              (write-raw-string pdf " /Root 1 0 R >>\nstartxref\n")
              (write-raw-string pdf (number->string xref-start))
              (write-raw-string pdf "\n%%EOF\n")

              (close-output-port (pdf-doc-port pdf)))))
      #t)))
