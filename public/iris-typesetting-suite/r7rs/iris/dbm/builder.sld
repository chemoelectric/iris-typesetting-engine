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
             (db   (tkrzw-open path :rw-mode :create :params "align_pow=4"))
             (dirs (guard (e (else '())) (ls-R))))
        (if (not db)
            0
            (begin
              (for-each
               (lambda (entry)
                 (ingest-texmf-directory db entry))
               dirs)
              (tkrzw-close db)
              (let* ((ro-db (tkrzw-open path :rw-mode :read))
                     (cnt   (if ro-db (begin (let ((c (tkrzw-count ro-db))) (tkrzw-close ro-db) c)) 0)))
                cnt)))))

    (define (get-fc-list-entries)
      (guard (e (else '()))
        (let* ((cmd '(fc-list ":" "file" "family" "style"
                              "postscriptname" "fullname" "format"))
               (lines (process-output->string-list cmd)))
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

    (define (index-font-metadata db id id-str path fam sty ps full)
      (let ((meta-str (make-font-record id path fam sty ps full)))
        (tkrzw-put! db (string-append "font:" id-str) meta-str)
        (tkrzw-put! db (string-append "file:" path) id-str)
        (unless (string=? ps "")
          (tkrzw-put! db (string-append "ps:" ps) id-str)
          (tkrzw-put! db (string-append "name:" (normalize-name ps)) ps))
        (unless (string=? full "")
          (tkrzw-put! db (string-append "full:" full) id-str)
          (tkrzw-put! db (string-append "name:" (normalize-name full)) full))
        (unless (string=? fam "")
          (let ((fam-k (if (string=? sty "")
                           (string-append "fam:" fam)
                           (string-append "fam:" fam ":" sty))))
            (tkrzw-put! db fam-k id-str)
            (tkrzw-put! db (string-append "name:" (normalize-name fam))
                        fam)))))

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
              (index-font-metadata db next-id id-str path fam sty ps full)
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
                    (tkrzw-close db)
                    (let* ((ro-db (tkrzw-open path :rw-mode :read))
                           (cnt   (if ro-db (begin (let ((c (tkrzw-count ro-db))) (tkrzw-close ro-db) c)) 0)))
                      cnt))
                  (let ((next-id (ingest-font-line db (car rest) id)))
                    (loop (cdr rest) next-id)))))))

    (define (build-all-databases)
      (let ((t-count (build-texmf-db))
            (f-count (build-fonts-db)))
        `((texmf-records . ,t-count)
          (font-records  . ,f-count))))))
