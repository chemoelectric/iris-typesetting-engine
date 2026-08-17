;;; r7rs/iris/dbm/builder.sld --- Tkrzw database builder for TeXMF and System Fonts
;;;
;;; SPDX-License-Identifier: MIT

(define-library (iris dbm builder)
  (import (scheme base)
          (scheme char)
          (scheme file)
          (scheme write)
          (scheme process-context)
          (gauche base)
          (gauche process)
          (iris tkrzw)
          (iris texmf ls-R)
          (iris fontconfig))
  (export build-texmf-db
          build-fonts-db
          build-all-databases
          default-texmf-db-path
          default-fonts-db-path)
  (begin

    ;; Default storage locations for Iris DBM files
    (define (default-texmf-db-path)
      (let ((cache-dir (or (get-environment-variable "XDG_CACHE_HOME")
                           (string-append (or (get-environment-variable "HOME") ".")
                                          "/.cache"))))
        (string-append cache-dir "/iris/texmf-files.tkh")))

    (define (default-fonts-db-path)
      (let ((cache-dir (or (get-environment-variable "XDG_CACHE_HOME")
                           (string-append (or (get-environment-variable "HOME") ".")
                                          "/.cache"))))
        (string-append cache-dir "/iris/fonts-system.tkt")))

    ;; Ensure directory path exists
    (define (ensure-parent-dir file-path)
      (let loop ((i (- (string-length file-path) 1)))
        (cond
          ((< i 0) #t)
          ((char=? (string-ref file-path i) #\/)
           (let ((dir (substring file-path 0 i)))
             (unless (string=? dir "")
               (guard (e (else #f))
                 (sys-mkdir dir #o755)))
             #t))
          (else (loop (- i 1))))))

    ;; Case-folding normalization helper
    (define (normalize-name str)
      (string-downcase str))

    ;; Build the TeXMF files database (HashDBM for O(1) filename resolution)
    (define (build-texmf-db . args)
      (let* ((target-path (if (null? args) (default-texmf-db-path) (car args)))
             (_ (ensure-parent-dir target-path))
             (db (tkrzw-open target-path :rw-mode :create :params "align_pow=4"))
             (ls-entries (guard (e (else '())) (ls-R))))
        (when db
          ;; Iterate over directory -> files association list from (iris texmf ls-R)
          (for-each
           (lambda (dir-entry)
             (let ((dir-path (car dir-entry))
                   (files    (cdr dir-entry)))
               (for-each
                (lambda (fname)
                  (let* ((full-path (string-append dir-path "/" fname))
                         (norm-k (normalize-name fname)))
                    ;; Store exact filename -> path
                    (tkrzw-put! db fname full-path :overwrite #t)
                    ;; Store normalized name index if different
                    (unless (string=? norm-k fname)
                      (tkrzw-put! db norm-k full-path :overwrite #f))
                    ;; Add to names: prefix for Levenshtein fuzzy matching
                    (tkrzw-put! db (string-append "name:" norm-k) fname :overwrite #t)))
                files)))
           ls-entries)
          (tkrzw-sync db #t)
          (let ((count (tkrzw-count db)))
            (tkrzw-close db)
            count))))

    ;; Helper: extract lines from fc-list command
    (define (get-fc-list-entries)
      (guard (e (else '()))
        (let* ((process-output
                (process-output->string-list
                 '(fc-list ":" "file" "family" "style" "postscriptname" "fullname" "format")))
               (lines (filter (lambda (s) (not (string=? s ""))) process-output)))
          lines)))

    ;; Split string by delimiter char without regex
    (define (split-by-char str delim)
      (let ((len (string-length str)))
        (let loop ((i 0) (start 0) (acc '()))
          (cond
            ((= i len)
             (reverse (cons (substring str start len) acc)))
            ((char=? (string-ref str i) delim)
             (loop (+ i 1) (+ i 1) (cons (substring str start i) acc)))
            (else
             (loop (+ i 1) start acc))))))

    ;; Build the system & TeX font database (TreeDBM for sorted prefix + edit-distance queries)
    (define (build-fonts-db . args)
      (let* ((target-path (if (null? args) (default-fonts-db-path) (car args)))
             (_ (ensure-parent-dir target-path))
             (db (tkrzw-open target-path :rw-mode :create :params "max_page_size=4096"))
             (fc-entries (get-fc-list-entries))
             (id-seq 0))
        (when db
          ;; Ingest fontconfig entries
          (for-each
           (lambda (line)
             (let* ((parts (split-by-char line #\:))
                    (filepath (if (>= (length parts) 1) (string-trim (list-ref parts 0)) ""))
                    (family   (if (>= (length parts) 2) (string-trim (list-ref parts 1)) ""))
                    (style    (if (>= (length parts) 3) (string-trim (list-ref parts 2)) ""))
                    (psname   (if (>= (length parts) 4) (string-trim (list-ref parts 3)) ""))
                    (fullname (if (>= (length parts) 5) (string-trim (list-ref parts 4)) family)))
               (when (and (not (string=? filepath "")) (file-exists? filepath))
                 (set! id-seq (+ id-seq 1))
                 (let* ((id-str (number->string id-seq))
                        (font-key (string-append "font:" id-str))
                        (meta-sexp `((id . ,id-seq)
                                     (file . ,filepath)
                                     (family . ,family)
                                     (style . ,style)
                                     (postscript . ,psname)
                                     (fullname . ,fullname)))
                        (meta-str (write-to-string meta-sexp)))
                   ;; 1. Store primary font record
                   (tkrzw-put! db font-key meta-str :overwrite #t)
                   (tkrzw-put! db (string-append "file:" filepath) id-str :overwrite #t)

                   ;; 2. Multi-key indexes
                   (unless (string=? psname "")
                     (tkrzw-put! db (string-append "ps:" psname) id-str :overwrite #t)
                     (tkrzw-put! db (string-append "name:" (normalize-name psname)) psname :overwrite #t))

                   (unless (string=? fullname "")
                     (tkrzw-put! db (string-append "full:" fullname) id-str :overwrite #t)
                     (tkrzw-put! db (string-append "name:" (normalize-name fullname)) fullname :overwrite #t))

                   (unless (string=? family "")
                     (let ((fam-key (if (string=? style "")
                                        (string-append "fam:" family)
                                        (string-append "fam:" family ":" style))))
                       (tkrzw-put! db fam-key id-str :overwrite #t)
                       (tkrzw-put! db (string-append "name:" (normalize-name family)) family :overwrite #t)))))))
           fc-entries)

          (tkrzw-sync db #t)
          (let ((count (tkrzw-count db)))
            (tkrzw-close db)
            count))))

    ;; Build all databases
    (define (build-all-databases)
      (let ((t-count (build-texmf-db))
            (f-count (build-fonts-db)))
        `((texmf-records . ,t-count)
          (font-records  . ,f-count))))))
