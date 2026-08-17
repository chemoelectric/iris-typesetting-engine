;;; r7rs/iris/db.sld --- Scheme wrapper around Ada C database interface
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
          db-edit-distance
          db-keys
          db-search-prefix
          db-for-each
          db-fold)
  (begin

    (define-record-type <iris-db>
      (%make-db path mode handle closed?)
      db?
      (path db-path)
      (mode db-mode)
      (handle db-handle db-handle-set!)
      (closed? db-closed? db-closed-set!))

    (define (make-db path mode)
      (%make-db path mode #f #f))

    (define (mode->writable-int mode)
      (if (eq? mode 'read) 0 1))

    (define (c-open-db path mode)
      (let ((w-int (mode->writable-int mode)))
        (guard (ex (else #f))
          (if (global-variable-bound? (current-module)
                                      'gauche_iris_db_open)
              ((global-variable-ref (current-module)
                                    'gauche_iris_db_open)
               path w-int "")
              #f))))

    (define (c-close-db handle)
      (guard (ex (else 1))
        (if (and handle
                 (global-variable-bound? (current-module)
                                         'gauche_iris_db_close))
            ((global-variable-ref (current-module)
                                  'gauche_iris_db_close)
             handle)
            0)))

    (define (c-check-db handle key)
      (guard (ex (else 0))
        (if (and handle
                 (global-variable-bound? (current-module)
                                         'gauche_iris_db_check))
            ((global-variable-ref (current-module)
                                  'gauche_iris_db_check)
             handle key (string-length key))
            0)))

    (define (c-get-db handle key)
      (guard (ex (else #f))
        (if (and handle
                 (global-variable-bound? (current-module)
                                         'gauche_iris_db_get))
            ((global-variable-ref (current-module)
                                  'gauche_iris_db_get)
             handle key (string-length key))
            #f)))

    (define (c-set-db handle key val)
      (guard (ex (else 0))
        (if (and handle
                 (global-variable-bound? (current-module)
                                         'gauche_iris_db_set))
            ((global-variable-ref (current-module)
                                  'gauche_iris_db_set)
             handle key (string-length key)
             val (string-length val) 1)
            0)))

    (define (c-remove-db handle key)
      (guard (ex (else 0))
        (if (and handle
                 (global-variable-bound? (current-module)
                                         'gauche_iris_db_remove))
            ((global-variable-ref (current-module)
                                  'gauche_iris_db_remove)
             handle key (string-length key))
            0)))

    (define (c-count-db handle)
      (guard (ex (else 0))
        (if (and handle
                 (global-variable-bound? (current-module)
                                         'gauche_iris_db_count))
            ((global-variable-ref (current-module)
                                  'gauche_iris_db_count)
             handle)
            0)))

    (define (c-sync-db handle)
      (guard (ex (else 1))
        (if (and handle
                 (global-variable-bound? (current-module)
                                         'gauche_iris_db_sync))
            ((global-variable-ref (current-module)
                                  'gauche_iris_db_sync)
             handle 0)
            0)))

    (define (c-edit-dist-db str-a str-b)
      (guard (ex (else -1))
        (if (global-variable-bound? (current-module)
                                    'gauche_iris_db_edit_distance)
            ((global-variable-ref (current-module)
                                  'gauche_iris_db_edit_distance)
             str_a str_b 1)
            -1)))

    (define (db-open path . maybe-mode)
      (let* ((mode (if (null? maybe-mode) 'read (car maybe-mode)))
             (h    (c-open-db path mode)))
        (%make-db path mode h #f)))

    (define (db-close db)
      (when (and (db? db) (not (db-closed? db)))
        (c-close-db (db-handle db))
        (db-closed-set! db #t)
        (db-handle-set! db #f)))

    (define (db-get db key . maybe-default)
      (let ((default (if (null? maybe-default) #f (car maybe-default))))
        (if (or (not (db? db)) (db-closed? db))
            default
            (let ((res (c-get-db (db-handle db) key)))
              (if res res default)))))

    (define (db-set! db key val)
      (when (and (db? db)
                 (not (db-closed? db))
                 (not (eq? (db-mode db) 'read)))
        (c-set-db (db-handle db) key val)))

    (define (db-exists? db key)
      (if (or (not (db? db)) (db-closed? db))
          #f
          (= (c-check-db (db-handle db) key) 1)))

    (define (db-delete! db key)
      (if (or (not (db? db))
              (db-closed? db)
              (eq? (db-mode db) 'read))
          #f
          (= (c-remove-db (db-handle db) key) 1)))

    (define (db-count db)
      (if (or (not (db? db)) (db-closed? db))
          0
          (c-count-db (db-handle db))))

    (define (db-sync db)
      (when (and (db? db)
                 (not (db-closed? db))
                 (not (eq? (db-mode db) 'read)))
        (c-sync-db (db-handle db))))

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

    (define (calc-fallback-dist str-a str-b)
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

    (define (db-edit-distance str-a str-b)
      (let ((d (c-edit-dist-db str-a str-b)))
        (if (>= d 0) d (calc-fallback-dist str-a str-b))))

    (define (db-keys db . maybe-prefix)
      '())

    (define (db-search-prefix db prefix . maybe-cap)
      '())

    (define (db-for-each proc db)
      #f)

    (define (db-fold proc knil db)
      knil)))
