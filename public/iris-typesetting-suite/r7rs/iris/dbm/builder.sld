;;; r7rs/iris/dbm/builder.sld --- Tkrzw database builder
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
          (gauche keyword)
          (srfi 152) ;; string library.
          (iris tkrzw)
          (iris texmf ls-R))
  (export build-texmf-db
          build-fonts-db
          build-all-databases
          default-texmf-db-path
          default-fonts-db-path)
  (begin

    (define (user-cache-dir)
      (or (get-environment-variable "XDG_CACHE_HOME")
          (string-append
           (or (get-environment-variable "HOME") ".")
           "/.cache")))

    (define (default-texmf-db-path)
      (string-append (user-cache-dir) "/iris/texmf-files.tkh"))

    (define (default-fonts-db-path)
      (string-append (user-cache-dir) "/iris/fonts-system.tkt"))

    (define (find-parent-dir path)
      (let loop ((i (- (string-length path) 1)))
        (cond
          ((< i 0) #f)
          ((char=? (string-ref path i) #\/)
           (let ((parent (substring path 0 i)))
             (if (string=? parent "") "/" parent)))
          (else (loop (- i 1))))))

    (define (create-dir-if-missing dir)
      (unless (or (string=? dir "")
                  (string=? dir "/")
                  (file-exists? dir))
        (let ((parent (find-parent-dir dir)))
          (when parent
            (create-dir-if-missing parent))
          (guard (e (else #f))
            (sys-mkdir dir #o755)))))

    (define (ensure-parent-dir file-path)
      (let ((parent (find-parent-dir file-path)))
        (when parent
          (create-dir-if-missing parent))))

    (define (normalize-name str)
      (string-downcase str))

    (define (ingest-texmf-file db dir fname)
      (let* ((full (string-append dir "/" fname))
             (norm (normalize-name fname)))
        (tkrzw-put! db fname full)
        (unless (string=? norm fname)
          (tkrzw-put! db norm full))
        (tkrzw-put! db (string-append "name:" norm) fname)))

    (define (ingest-texmf-directory db dir-entry)
      (let ((dir   (car dir-entry))
            (files (cdr dir-entry)))
        (for-each
         (lambda (fname)
           (ingest-texmf-file db dir fname))
         files)))

    (define (build-texmf-db . args)
      (let* ((path (if (null? args) (default-texmf-db-path) (car args)))
             (_    (ensure-parent-dir path))
             (db   (tkrzw-open path :rw-mode :create
                                :params "align_pow=4"))
             (dirs (guard (e (else '())) (ls-R))))
        (if (not db)
            0
            (begin
              (for-each
               (lambda (entry)
                 (ingest-texmf-directory db entry))
               dirs)
              (tkrzw-sync db)
              (tkrzw-close db)
              (let* ((ro-db (tkrzw-open path :rw-mode :read))
                     (cnt   (if ro-db
                                (let ((c (tkrzw-count ro-db)))
                                  (tkrzw-close ro-db)
                                  c)
                                0)))
                cnt)))))

    (define (get-fc-list-entries)
      (guard (e (else '()))
        (let* ((fmt
                (string-append
                 "%{file}:%{family}:%{style}:"
                 "%{postscriptname}:%{fullname}\n"))
               (cmd (list "fc-list" "-f" fmt))
               (raw (process-output->string-list cmd))
               (lines (map string-trim raw)))
          (filter (lambda (s) (not (string=? s ""))) lines))))

    (define (split-by-char str delim)
      (let ((len (string-length str)))
        (let loop ((i 0) (start 0) (acc '()))
          (cond
            ((= i len)
             (reverse (cons (substring str start len) acc)))
            ((char=? (string-ref str i) delim)
             (loop (+ i 1) (+ i 1)
                   (cons (substring str start i) acc)))
            (else
             (loop (+ i 1) start acc))))))

    (define (get-part parts n dflt)
      (if (>= (length parts) n)
          (string-trim (list-ref parts (- n 1)))
          dflt))

    (define (make-font-record id path fam sty ps full)
      (write-to-string
       `((id         . ,id)
         (file       . ,path)
         (family     . ,fam)
         (style      . ,sty)
         (postscript . ,ps)
         (fullname   . ,full))))

    (define (index-single-alias db prefix alias id-str)
      (unless (string=? alias "")
        (let ((norm (normalize-name alias)))
          (tkrzw-put! db (string-append prefix alias) id-str)
          (tkrzw-put! db (string-append prefix norm) id-str)
          (tkrzw-put! db (string-append "name:" norm) alias))))

    (define (index-alias-list db prefix csv-str id-str)
      (let ((aliases (split-by-char csv-str #\,)))
        (for-each
         (lambda (a)
           (index-single-alias db prefix (string-trim a) id-str))
         aliases)))

    (define (index-font-metadata db id id-str path fam sty ps full)
      (let ((meta-str (make-font-record id path fam sty ps full)))
        (tkrzw-put! db (string-append "font:" id-str) meta-str)
        (tkrzw-put! db (string-append "file:" path) id-str)
        (index-alias-list db "ps:" ps id-str)
        (index-alias-list db "full:" full id-str)
        (index-alias-list db "fam:" fam id-str)))

    (define (ingest-font-line db line id-seq)
      (let* ((parts (split-by-char line #\:))
             (path  (get-part parts 1 ""))
             (fam   (get-part parts 2 ""))
             (sty   (get-part parts 3 ""))
             (ps    (get-part parts 4 ""))
             (full  (get-part parts 5 fam)))
        (if (and (not (string=? path "")) (file-exists? path))
            (let* ((next-id (+ id-seq 1))
                   (id-str  (number->string next-id)))
              (index-font-metadata db next-id id-str
                                   path fam sty ps full)
              next-id)
            id-seq)))

    (define (build-fonts-db . args)
      (let* ((path (if (null? args) (default-fonts-db-path) (car args)))
             (_    (ensure-parent-dir path))
             (db   (tkrzw-open path :rw-mode :create
                                :params "max_page_size=4096"))
             (lines (get-fc-list-entries)))
        (if (not db)
            0
            (let loop ((rest lines) (id 0))
              (if (null? rest)
                  (begin
                    (tkrzw-sync db)
                    (tkrzw-close db)
                    (let* ((ro-db (tkrzw-open path :rw-mode :read))
                           (cnt   (if ro-db
                                      (let ((c (tkrzw-count ro-db)))
                                        (tkrzw-close ro-db)
                                        c)
                                      0)))
                      cnt))
                  (let ((next-id (ingest-font-line db (car rest) id)))
                    (loop (cdr rest) next-id)))))))

    (define (build-all-databases)
      (let ((t-count (build-texmf-db))
            (f-count (build-fonts-db)))
        `((texmf-records . ,t-count)
          (font-records  . ,f-count))))))
