;;; r7rs/iris/fontconfig.sld --- Fontconfig font lookup library for Iris
;;;
;;; SPDX-License-Identifier: MIT

(define-library (iris fontconfig)
  (import (scheme base)
          (scheme char)
          (scheme process-context)
          (gauche process)
          (iris fontconfig fontconfig-process))
  (export fontconfig-find-font
          fontconfig-lookup
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

    ;; Remove duplicate elements from list while preserving order
    (define (remove-duplicates lst)
      (let loop ((rest lst) (acc '()))
        (if (null? rest)
            (reverse acc)
            (if (member (car rest) acc)
                (loop (cdr rest) acc)
                (loop (cdr rest) (cons (car rest) acc))))))

    ;; Run fc-list with arguments and return list of output lines
    (define (fontconfig-lookup . args)
      (guard (ex (else '()))
        (let* ((proc (run-process (apply fontconfig-process args)
                                  :output :pipe))
               (out (process-output proc))
               (lines (let loop ((acc '()))
                        (let ((line (read-line out)))
                          (if (eof-object? line)
                              (reverse acc)
                              (let ((trimmed (string-trim-trailing-newline line)))
                                (if (string=? trimmed "")
                                    (loop acc)
                                    (loop (cons trimmed acc)))))))))
               (status (process-wait proc)))
          (if (equal? status 0) lines '()))))

    ;; Remove known prefixes like file://, file:, name:
    (define (strip-known-prefixes str)
      (cond
        ((string-prefix? "file://" str) (substring str 7 (string-length str)))
        ((string-prefix? "file:" str)   (strip-known-prefixes (substring str 5 (string-length str))))
        ((string-prefix? "name:" str)   (strip-known-prefixes (substring str 5 (string-length str))))
        (else (string-trim-trailing-newline str))))

    ;; Search fontconfig using fc-list
    (define (fontconfig-search query)
      (let* ((clean (strip-known-prefixes query))
             (res1 (fontconfig-lookup clean "-f" "%{file}\n")))
        (if (not (null? res1))
            res1
            (let ((res2 (fontconfig-lookup (string-append ":file=*" clean "*") "-f" "%{file}\n")))
              (if (not (null? res2))
                  res2
                  (let ((res3 (fontconfig-lookup (string-append ":family=" clean) "-f" "%{file}\n")))
                    (if (not (null? res3))
                        res3
                        (let ((res4 (fontconfig-lookup (string-append ":fullname=" clean) "-f" "%{file}\n")))
                          (if (not (null? res4))
                              res4
                              '())))))))))

    ;; Search for companion files in the same directory (e.g. .pfb for .afm)
    (define (find-companion-files path)
      (cond
        ((and (>= (string-length path) 4)
              (string-prefix? ".afm" (substring path (- (string-length path) 4) (string-length path))))
         (let ((pfb (replace-extension path ".pfb")))
           (let ((found (fontconfig-lookup pfb "-f" "%{file}\n")))
             (if (not (null? found)) found '()))))
        (else '())))

    ;; Main fontconfig font finder entry point
    ;; Returns a list of font entries:
    ;; (((query . "query") (uris "file:///path1" ...)) ...)
    (define (fontconfig-find-font query)
      (let* ((found-paths (fontconfig-search query)))
        (if (null? found-paths)
            '()
            (let loop ((paths (remove-duplicates found-paths))
                       (acc '()))
              (if (null? paths)
                  (reverse acc)
                  (let* ((p (car paths))
                         (companions (find-companion-files p))
                         (all-p (remove-duplicates (cons p companions)))
                         (uris (map path->file-uri all-p))
                         (entry `((query . ,query)
                                  (uris ,@uris))))
                    (loop (cdr paths) (cons entry acc))))))))))
