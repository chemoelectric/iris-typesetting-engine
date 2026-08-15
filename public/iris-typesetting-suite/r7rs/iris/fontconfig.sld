;;; r7rs/iris/fontconfig.sld --- Fontconfig C library interface for Iris
;;;
;;; SPDX-License-Identifier: MIT

(define-library (iris fontconfig)
  (import (scheme base)
          (scheme char)
          (scheme file)
          (gauche base)
          (c-wrapper))
  (export fontconfig-find-font
          fontconfig-search
          path->file-uri)
  (begin
    ;; Load Fontconfig C headers and library
    (c-load '("fontconfig/fontconfig.h")
            :libs "-lfontconfig")

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

    ;; Query fontconfig library for font files matching a pattern string
    (define (fc-query-pattern-string pat-str)
      (guard (ex (else '()))
        (FcInit)
        (let ((pat (FcNameParse (cast <FcChar8*> pat-str))))
          (if (or (not pat) (c-null? pat))
              '()
              (let* ((_ (begin
                          (FcConfigSubstitute (c-null) pat FcMatchPattern)
                          (FcDefaultSubstitute pat)))
                     (os (FcObjectSetBuild FC_FILE (c-null)))
                     (fs (if (or (not os) (c-null? os))
                             (c-null)
                             (FcFontList (c-null) pat os)))
                     (paths
                      (if (or (not fs) (c-null? fs))
                          '()
                          (let ((count (ref fs 'nfont)))
                            (let loop ((i 0) (acc '()))
                              (if (>= i count)
                                  (reverse acc)
                                  (let* ((font-pat (ref (ref fs 'fonts) i))
                                         (file-ptr (make (c-ptr <FcChar8>)))
                                         (res (FcPatternGetString font-pat FC_FILE 0 (ptr file-ptr))))
                                    (if (= res FcResultMatch)
                                        (let ((fstr (x->string (cast <const-char*> file-ptr))))
                                          (loop (+ i 1) (cons fstr acc)))
                                        (loop (+ i 1) acc)))))))))
                (when (and fs (not (c-null? fs)))
                  (FcFontSetDestroy fs))
                (when (and os (not (c-null? os)))
                  (FcObjectSetDestroy os))
                (when (and pat (not (c-null? pat)))
                  (FcPatternDestroy pat))
                paths)))))

    ;; Match single best font using FcFontMatch
    (define (fc-match-pattern-string pat-str)
      (guard (ex (else '()))
        (FcInit)
        (let ((pat (FcNameParse (cast <FcChar8*> pat-str))))
          (if (or (not pat) (c-null? pat))
              '()
              (let* ((_ (begin
                          (FcConfigSubstitute (c-null) pat FcMatchPattern)
                          (FcDefaultSubstitute pat)))
                     (result (make <FcResult>))
                     (matched (FcFontMatch (c-null) pat (ptr result)))
                     (paths
                      (if (or (not matched) (c-null? matched))
                          '()
                          (let* ((file-ptr (make (c-ptr <FcChar8>)))
                                 (res (FcPatternGetString matched FC_FILE 0 (ptr file-ptr))))
                            (if (= res FcResultMatch)
                                (list (x->string (cast <const-char*> file-ptr)))
                                '())))))
                (when (and matched (not (c-null? matched)))
                  (FcPatternDestroy matched))
                (when (and pat (not (c-null? pat)))
                  (FcPatternDestroy pat))
                paths)))))

    ;; Search Fontconfig using library API
    (define (fontconfig-search query)
      (let* ((clean (strip-known-prefixes query))
             (res1 (fc-query-pattern-string clean)))
        (if (not (null? res1))
            res1
            (let ((res2 (fc-query-pattern-string (string-append ":file=*" clean "*"))))
              (if (not (null? res2))
                  res2
                  (let ((res3 (fc-query-pattern-string (string-append ":family=" clean))))
                    (if (not (null? res3))
                        res3
                        (let ((res4 (fc-query-pattern-string (string-append ":fullname=" clean))))
                          (if (not (null? res4))
                              res4
                              (let ((res5 (fc-match-pattern-string clean)))
                                (if (not (null? res5))
                                    res5
                                    '())))))))))))

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
             (else
              (let ((found-pfb (fc-query-pattern-string (string-append ":file=" pfb))))
                (if (not (null? found-pfb))
                    found-pfb
                    (let ((found-pfa (fc-query-pattern-string (string-append ":file=" pfa))))
                      (if (not (null? found-pfa)) found-pfa '()))))))))
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
