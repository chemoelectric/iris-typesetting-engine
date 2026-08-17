;;; SPDX-License-Identifier: MIT

(define-library (iris texmf ls-R)

  (import (scheme base)
          (scheme list)
          (scheme file)
          (scheme write)
          (srfi 152) ;; string library.
          (gauche process))

  (export ls-R)

  (begin

    (define (ls-R)
      ;;
      ;; Return an association list of the TeX installation file
      ;; structure. Each key is the path of a directory and the value
      ;; is a list of the directory’s contents.
      ;;
      (fold (lambda (ls-R-file big-alst)
              (let ((alst (get-ls-R-index ls-R-file)))
                (append
                 (map (lambda (xy)
                        (let-values (((x y) (car+cdr xy)))
                          (cons (delete-dots-from-path
                                 (string-append
                                  (require-slash
                                   (string-drop-right ls-R-file 4))
                                  x))
                                y)))
                      alst)
                 big-alst)))
            '() (get-ls-R-paths)))

    (define (delete-dots-from-path path)
      (let loop ((current-path path))
        (let ((index (string-contains current-path "/./")))
          (if index
            (loop (string-replace current-path "/" index (+ index 3) 0 1))
            current-path))))

    (define (require-slash s)
      (if (string-suffix? "/" s)
        s
        (string-append s "/")))

    (define (standard-texmf-candidates)
      '("/usr/local/texlive/2026/texmf-dist/ls-R"
        "/usr/local/texlive/2025/texmf-dist/ls-R"
        "/usr/local/texlive/2024/texmf-dist/ls-R"
        "/usr/share/texlive/texmf-dist/ls-R"
        "/usr/share/texmf/ls-R"
        "/var/lib/texmf/ls-R"))

    (define (get-ls-R-paths)
      (let* ((dynamic-paths (get-file-paths "ls-R"))
             (candidates    (standard-texmf-candidates))
             (existing      (filter file-exists? candidates)))
        (delete-duplicates (append dynamic-paths existing))))

    (define (get-file-paths filename)
      (guard (ex (else '()))
        (let* ((cmd (list "kpsewhich" "-all" filename))
               (lines (process-output->string-list cmd)))
          (filter file-exists? lines))))

    (define (string-ends-with? str char)
      (let ((len (string-length str)))
        (and (> len 0)
             (char=? (string-ref str (- len 1)) char))))

    (define (parse-ls-R current-dir current-files accumulator)
      (let ((line (read-line)))
        (cond
          ((eof-object? line)
           (if current-dir
               (cons (cons current-dir (reverse current-files)) accumulator)
               accumulator))

          ((or (string=? line "")
               (and (> (string-length line) 0)
                    (char=? (string-ref line 0) #\%)))
           (parse-ls-R current-dir current-files accumulator))

          ((string-ends-with? line #\:)
           (let* ((len (string-length line))
                  (new-dir (substring line 0 (- len 1)))
                  (new-acc (if current-dir
                               (cons (cons current-dir
                                           (reverse current-files))
                                     accumulator)
                               accumulator)))
             (parse-ls-R new-dir '() new-acc)))

          (else
           (parse-ls-R current-dir (cons line current-files) accumulator)))))

    (define (get-ls-R-index filename)
      (guard (ex (else '()))
        (with-input-from-file filename
          (lambda () (parse-ls-R #f '() '())))))

    ))
