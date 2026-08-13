;;; r7rs/iris/kpsewhich.sld --- Kpathsea font lookup library for Iris
;;;
;;; SPDX-License-Identifier: MIT

(define-library (iris kpsewhich)

  (import (scheme base)
          (scheme char)
          (scheme process-context)
          (gauche process)
          (gauche keyword)
          (iris kpsewhich kpsewhich-process))

  (export kpsewhich-find-font
          kpsewhich-lookup
          path->file-uri)

  (begin

    ;; Helper: check if prefix is a prefix of str
    (define (string-prefix? prefix str)
      (let ((plen (string-length prefix))
            (slen (string-length str)))
        (and (>= slen plen)
             (string=? prefix (substring str 0 plen)))))

    ;; Helper: trim trailing newline and carriage return characters
    (define (string-trim-trailing-newline str)
      (let loop ((s str))
        (let ((len (string-length s)))
          (cond
            ((= len 0) s)
            ((or (char=? (string-ref s (- len 1)) #\newline)
                 (char=? (string-ref s (- len 1)) #\return))
             (loop (substring s 0 (- len 1))))
            (else s)))))

    ;; Convert a local file system path into a file:/// URI
    (define (path->file-uri path)
      (cond
        ((or (string-prefix? "file://" path)
             (string-prefix? "http://" path)
             (string-prefix? "https://" path))
         path)
        ((and (> (string-length path) 0)
              (char=? (string-ref path 0) #\/))
         (string-append "file://" path))
        (else
         (string-append "file://" path))))

    ;; Helper: replace or add extension to a filename/path
    (define (replace-extension path new-ext)
      (let loop ((i (- (string-length path) 1)))
        (cond
          ((< i 0) (string-append path new-ext))
          ((char=? (string-ref path i) #\.)
           (string-append (substring path 0 i) new-ext))
          ((char=? (string-ref path i) #\/)
           (string-append path new-ext))
          (else (loop (- i 1))))))

    ;; Run kpsewhich with arguments and return list of output lines
    (define (kpsewhich-lookup . args)
      (let ((process (apply kpsewhich-process args)))
        (guard (ex (else '()))
          (let* ((proc (run-process process :output :pipe))
                 (out (process-output proc))
                 (lines (let loop ((acc '()))
                          (let ((line (read-line out)))
                            (if (eof-object? line)
                              (reverse acc)
                              (let ((trimmed (string-trim-trailing-newline line)))
                                (if (string=? trimmed "")
                                  (loop acc)
                                  (loop (cons trimmed acc))))))))
                 (status (process-wait proc)))
            (if status lines '())))))

    ;; Search for font files by font name across common TeX font formats
    (define (kpsewhich-search-name font-name)
      (let* ((try-formats
              (lambda (name)
                (let loop ((formats '("opentype fonts"
                                      "truetype fonts"
                                      "type1 fonts"
                                      "afm"
                                      "tfm"
                                      "pk"
                                      "ofm")))
                  (if (null? formats)
                    '()
                    (let ((res (kpsewhich-lookup (string-append "-format=" (car formats)) name)))
                      (if (not (null? res))
                        res
                        (loop (cdr formats))))))))
             (direct (kpsewhich-lookup font-name)))
        (if (not (null? direct))
          direct
          (let ((fmt-res (try-formats font-name)))
            (if (not (null? fmt-res))
              fmt-res
              ;; Strip extension if present and try base name
              (let loop-ext ((i (- (string-length font-name) 1)))
                (cond
                  ((< i 0) '())
                  ((char=? (string-ref font-name i) #\.)
                   (try-formats (substring font-name 0 i)))
                  ((char=? (string-ref font-name i) #\/) '())
                  (else (loop-ext (- i 1))))))))))

  ;; Extract filename from path (strip leading directory components)
  (define (basename path)
    (let loop ((i (- (string-length path) 1)))
      (cond
        ((< i 0) path)
        ((char=? (string-ref path i) #\/)
         (substring path (+ i 1) (string-length path)))
        (else (loop (- i 1))))))

  ;; Extract stem (strip directory path AND extension)
  (define (extract-stem path)
    (let* ((name (basename path))
           (len (string-length name)))
      (let loop ((i (- len 1)))
        (cond
          ((< i 0) name)
          ((char=? (string-ref name i) #\.)
           (substring name 0 i))
          (else (loop (- i 1)))))))

  ;; Remove duplicate elements from list while preserving order
  (define (remove-duplicates lst)
    (let loop ((rest lst) (acc '()))
      (if (null? rest)
        (reverse acc)
        (if (member (car rest) acc)
          (loop (cdr rest) acc)
          (loop (cdr rest) (cons (car rest) acc))))))

  ;; Find all associated files for a given font stem across extensions and formats
  (define (find-all-associated-files stem)
    (let* ((extensions '(".tfm" ".afm" ".pfb" ".pfa" ".otf" ".ttf" ".vf" ".ofm"))
           (formats '("tfm" "afm" "type1 fonts" "opentype fonts" "truetype fonts" "vf" "ofm"))
           (ext-results
            (apply append
                   (map (lambda (ext)
                          (kpsewhich-lookup (string-append stem ext)))
                        extensions)))
           (fmt-results
            (apply append
                   (map (lambda (fmt)
                          (kpsewhich-lookup (string-append "-format=" fmt) stem))
                        formats))))
      (remove-duplicates (append ext-results fmt-results))))

  ;; Main font finder entry point
  ;; Returns S-expression list:
  ;; ((query . "query") (uris . ("file:///path1" ...)))
  (define (kpsewhich-find-font query)
    (let* ((raw-paths
            (cond
              ((string-prefix? "file:" query)
               (let ((fname (substring query 5 (string-length query))))
                 (kpsewhich-lookup fname)))
              ((string-prefix? "name:" query)
               (let ((mname (substring query 5 (string-length query))))
                 (kpsewhich-search-name mname)))
              (else
               (let ((direct (kpsewhich-lookup query)))
                 (if (not (null? direct))
                   direct
                   (kpsewhich-search-name query))))))
           (stems
            (remove-duplicates
             (cons (extract-stem query)
                   (map extract-stem raw-paths))))
           (all-paths
            (remove-duplicates
             (append raw-paths
                     (apply append (map find-all-associated-files stems)))))
           (uris (map path->file-uri all-paths)))
      `((query . ,query)
        (uris . ,uris))))))
