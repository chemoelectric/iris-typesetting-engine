;;; r7rs/iris/fontconfig.sld --- Fontconfig font resolution library for Iris
;;;
;;; SPDX-License-Identifier: MIT

(define-library (iris fontconfig)
  (import (scheme base)
          (scheme char)
          (scheme file)
          (gauche base))
  (export fontconfig-find-font
          fontconfig-search
          path->file-uri)
  (begin

    ;; Helper: check if prefix is a prefix of str
    (define (string-prefix? prefix str)
      (let ((plen (string-length prefix))
            (slen (string-length str)))
        (and (>= slen plen)
             (string=? prefix (substring str 0 plen)))))

    ;; Helper: check if suffix is a suffix of str
    (define (string-suffix? suffix str)
      (let ((suflen (string-length suffix))
            (slen (string-length str)))
        (and (>= slen suflen)
             (string=? suffix (substring str (- slen suflen) slen)))))

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

    ;; Convert a local filesystem path into a file:/// URI
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

    ;; Remove known prefixes like file://, file:, name:
    (define (strip-known-prefixes str)
      (cond
        ((string-prefix? "file://" str) (substring str 7 (string-length str)))
        ((string-prefix? "file:" str)   (strip-known-prefixes (substring str 5 (string-length str))))
        ((string-prefix? "name:" str)   (strip-known-prefixes (substring str 5 (string-length str))))
        (else (string-trim-trailing-newline str))))

    ;; Standard system font directory candidates
    (define *system-font-directories*
      '("/usr/share/fonts"
        "/usr/local/share/fonts"
        "~/.local/share/fonts"
        "~/.fonts"
        "/Library/Fonts"
        "/System/Library/Fonts"))

    ;; Scan directory tree for font matching query stem
    (define (scan-font-dir-for-query dir stem)
      (guard (ex (else '()))
        (if (not (file-exists? dir))
            '()
            (let ((entries (guard (e (else '())) (sys-readdir dir))))
              (if (not entries)
                  '()
                  (let loop ((rest entries) (acc '()))
                    (if (null? rest)
                        acc
                        (let* ((name (car rest))
                               (full (string-append dir "/" name)))
                          (cond
                            ((or (string=? name ".") (string=? name ".."))
                             (loop (cdr rest) acc))
                            ((guard (e (else #f)) (file-is-directory? full))
                             (let ((sub (scan-font-dir-for-query full stem)))
                               (loop (cdr rest) (append sub acc))))
                            ((or (string-suffix? (string-append "/" stem) full)
                                 (string-suffix? (string-append "/" stem ".ttf") full)
                                 (string-suffix? (string-append "/" stem ".otf") full)
                                 (string-suffix? (string-append "/" stem ".pfb") full)
                                 (string-suffix? (string-append "/" stem ".pfa") full)
                                 (string-suffix? (string-append "/" stem ".afm") full))
                             (loop (cdr rest) (cons full acc)))
                            (else
                             (loop (cdr rest) acc)))))))))))

    ;; Search Fontconfig known paths using query string
    (define (fontconfig-search query)
      (let ((clean (strip-known-prefixes query)))
        (cond
          ((file-exists? clean)
           (list clean))
          (else
           (let loop ((dirs *system-font-directories*)
                      (acc '()))
             (if (null? dirs)
                 (remove-duplicates (reverse acc))
                 (let ((found (scan-font-dir-for-query (car dirs) clean)))
                   (loop (cdr dirs) (append found acc)))))))))

    ;; Search for companion files in the same directory (e.g. .pfb/.pfa for .afm)
    (define (find-companion-files path)
      (cond
        ((and (>= (string-length path) 4)
              (string-prefix? ".afm" (substring path (- (string-length path) 4) (string-length path))))
         (let ((pfb (replace-extension path ".pfb"))
               (pfa (replace-extension path ".pfa")))
           (cond
             ((file-exists? pfb) (list pfb))
             ((file-exists? pfa) (list pfa))
             (else '()))))
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
