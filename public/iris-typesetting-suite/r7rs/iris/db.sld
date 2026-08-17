;;; r7rs/iris/db.sld --- Pure R7RS associative database interface
;;;
;;; SPDX-License-Identifier: MIT

(define-library (iris db)
  (import (scheme base)
          (scheme char)
          (scheme file)
          (scheme write)
          (scheme process-context)
          (gauche base))
  (export make-db
          db?
          db-open
          db-close
          db-closed?
          db-path
          db-get
          db-set!
          db-exists?
          db-delete!
          db-count
          db-sync
          db-keys
          db-search-prefix
          db-edit-distance
          db-for-each
          db-fold)
  (begin

    (define-record-type <iris-db>
      (%make-db path mode table modified? closed?)
      db?
      (path db-path)
      (mode db-mode)
      (table db-table-ref db-table-set!)
      (modified? db-modified? db-modified-set!)
      (closed? db-closed? db-closed-set!))

    (define (make-db path mode)
      (%make-db path mode (make-hash-table 'string=?) #f #f))

    (define (read-all-entries port table)
      (let loop ()
        (let ((obj (read port)))
          (unless (eof-object? obj)
            (when (and (pair? obj)
                       (not (string=? (car obj) "!format")))
              (hash-table-put! table (car obj) (cdr obj)))
            (loop)))))

    (define (load-db-file path table)
      (when (file-exists? path)
        (guard (ex (else #f))
          (call-with-input-file path
            (lambda (port)
              (read-all-entries port table))))))

    (define (write-one-entry key val port)
      (write (cons key val) port)
      (newline port))

    (define (save-db-file path table)
      (guard (ex (else #f))
        (call-with-output-file path
          (lambda (port)
            (write-one-entry "!format" "iris-db-v1" port)
            (hash-table-for-each table
              (lambda (k v)
                (unless (string=? k "!format")
                  (write-one-entry k v port))))))))

    (define (db-open path . maybe-mode)
      (let* ((mode (if (null? maybe-mode) 'read (car maybe-mode)))
             (tbl  (make-hash-table 'string=?))
             (db   (%make-db path mode tbl #f #f)))
        (unless (eq? mode 'truncate)
          (load-db-file path (db-table-ref db)))
        db))

    (define (db-sync db)
      (when (and (db? db)
                 (not (db-closed? db))
                 (db-modified? db)
                 (not (eq? (db-mode db) 'read)))
        (save-db-file (db-path db) (db-table-ref db))
        (db-modified-set! db #f)))

    (define (db-close db)
      (when (and (db? db) (not (db-closed? db)))
        (db-sync db)
        (db-closed-set! db #t)))

    (define (db-get db key . maybe-default)
      (let ((default (if (null? maybe-default) #f (car maybe-default))))
        (if (or (not (db? db)) (db-closed? db))
            default
            (hash-table-get (db-table-ref db) key default))))

    (define (db-set! db key val)
      (when (and (db? db)
                 (not (db-closed? db))
                 (not (eq? (db-mode db) 'read)))
        (hash-table-put! (db-table-ref db) key val)
        (db-modified-set! db #t)))

    (define (db-exists? db key)
      (if (or (not (db? db)) (db-closed? db))
          #f
          (hash-table-exists? (db-table-ref db) key)))

    (define (db-delete! db key)
      (if (or (not (db? db))
              (db-closed? db)
              (eq? (db-mode db) 'read))
          #f
          (begin
            (hash-table-delete! (db-table-ref db) key)
            (db-modified-set! db #t)
            #t)))

    (define (db-count db)
      (if (or (not (db? db)) (db-closed? db))
          0
          (hash-table-num-entries (db-table-ref db))))

    (define (match-prefix? key prefix)
      (let ((k-len (string-length key))
            (p-len (string-length prefix)))
        (and (>= k-len p-len)
             (string=? (substring key 0 p-len) prefix))))

    (define (db-keys db . maybe-prefix)
      (if (or (not (db? db)) (db-closed? db))
          '()
          (let ((keys (hash-table-keys (db-table-ref db))))
            (if (null? maybe-prefix)
                keys
                (filter (lambda (k)
                          (match-prefix? k (car maybe-prefix)))
                        keys)))))

    (define (take-n lst n)
      (if (or (null? lst) (<= n 0))
          '()
          (cons (car lst) (take-n (cdr lst) (- n 1)))))

    (define (db-search-prefix db prefix . maybe-cap)
      (let* ((cap (if (null? maybe-cap) 10 (car maybe-cap)))
             (matched (db-keys db prefix)))
        (take-n matched cap)))

    (define (step-distance v0 v1 c-a c-b)
      (let ((n (vector-length v0)))
        (vector-set! v1 0 (+ (vector-ref v0 0) 1))
        (let loop ((j 1))
          (when (< j n)
            (let* ((cost (if (char=? c-a (string-ref c-b (- j 1))) 0 1))
                   (d-del (+ (vector-ref v1 (- j 1)) 1))
                   (d-ins (+ (vector-ref v0 j) 1))
                   (d-sub (+ (vector-ref v0 (- j 1)) cost))
                   (min-d (min d-del (min d-ins d-sub))))
              (vector-set! v1 j min-d)
              (loop (+ j 1)))))))

    (define (db-edit-distance str-a str-b)
      (let* ((la (string-length str-a))
             (lb (string-length str-b))
             (v0 (make-vector (+ lb 1) 0))
             (v1 (make-vector (+ lb 1) 0)))
        (let init ((i 0))
          (when (<= i lb)
            (vector-set! v0 i i)
            (init (+ i 1))))
        (let outer ((i 1))
          (if (> i la)
              (vector-ref v0 lb)
              (begin
                (step-distance v0 v1 (string-ref str-a (- i 1)) str-b)
                (let copy ((j 0))
                  (when (<= j lb)
                    (vector-set! v0 j (vector-ref v1 j))
                    (copy (+ j 1))))
                (outer (+ i 1)))))))

    (define (db-for-each proc db)
      (when (and (db? db) (not (db-closed? db)))
        (hash-table-for-each (db-table-ref db) proc)))

    (define (db-fold proc knil db)
      (if (or (not (db? db)) (db-closed? db))
          knil
          (hash-table-fold (db-table-ref db) proc knil)))))
