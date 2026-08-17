;;; r7rs/iris/db.sld --- Scheme interface to Ada shared library libiris
;;;
;;; SPDX-License-Identifier: MIT

(define-library (iris db)
  (import (scheme base)
          (scheme char)
          (scheme file)
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
      (%make-db path mode handle closed?)
      db?
      (path db-path)
      (mode db-mode)
      (handle db-handle db-handle-set!)
      (closed? db-closed? db-closed-set!))

    (define (make-db path mode)
      (%make-db path mode #f #f))

    (define (try-dlopen path)
      (guard (ex (else #f))
        (sys-dlopen path)))

    (define (try-dynamic-load mod-name)
      (guard (ex (else #f))
        (dynamic-load mod-name)))

    (define (ensure-libiris-loaded!)
      (unless (global-variable-bound? (current-module) '%iris-db-open)
        (or (try-dlopen "libiris.so")
            (try-dlopen "./.libs/libiris.so")
            (try-dlopen "../.libs/libiris.so")
            (try-dynamic-load "libiris"))))

    (define (call-db-open path w-int)
      (ensure-libiris-loaded!)
      (guard (ex (else #f))
        (if (global-variable-bound? (current-module) '%iris-db-open)
            ((global-variable-ref (current-module) '%iris-db-open)
             path w-int "")
            #f)))

    (define (call-db-close handle)
      (guard (ex (else 1))
        (if (and handle
                 (global-variable-bound? (current-module)
                                         '%iris-db-close))
            ((global-variable-ref (current-module) '%iris-db-close)
             handle)
            1)))

    (define (call-db-check handle key)
      (guard (ex (else 0))
        (if (and handle
                 (global-variable-bound? (current-module)
                                         '%iris-db-check))
            ((global-variable-ref (current-module) '%iris-db-check)
             handle key)
            0)))

    (define (call-db-get handle key)
      (guard (ex (else #f))
        (if (and handle
                 (global-variable-bound? (current-module)
                                         '%iris-db-get))
            ((global-variable-ref (current-module) '%iris-db-get)
             handle key)
            #f)))

    (define (call-db-set handle key val)
      (guard (ex (else 0))
        (if (and handle
                 (global-variable-bound? (current-module)
                                         '%iris-db-set))
            ((global-variable-ref (current-module) '%iris-db-set)
             handle key val 1)
            0)))

    (define (call-db-remove handle key)
      (guard (ex (else 0))
        (if (and handle
                 (global-variable-bound? (current-module)
                                         '%iris-db-remove))
            ((global-variable-ref (current-module) '%iris-db-remove)
             handle key)
            0)))

    (define (call-db-count handle)
      (guard (ex (else 0))
        (if (and handle
                 (global-variable-bound? (current-module)
                                         '%iris-db-count))
            ((global-variable-ref (current-module) '%iris-db-count)
             handle)
            0)))

    (define (call-db-sync handle)
      (guard (ex (else 1))
        (if (and handle
                 (global-variable-bound? (current-module)
                                         '%iris-db-sync))
            ((global-variable-ref (current-module) '%iris-db-sync)
             handle 0)
            1)))

    (define (call-db-edit-distance str-a str-b)
      (guard (ex (else -1))
        (if (global-variable-bound? (current-module)
                                    '%iris-db-edit-distance)
            ((global-variable-ref (current-module)
                                  '%iris-db-edit-distance)
             str-a str-b)
            -1)))

    (define (db-open path . maybe-mode)
      (let* ((mode  (if (null? maybe-mode) 'read (car maybe-mode)))
             (w-int (if (eq? mode 'read) 0 1))
             (h     (call-db-open path w-int)))
        (if h
            (%make-db path mode h #f)
            #f)))

    (define (db-close db)
      (when (and (db? db) (not (db-closed? db)))
        (call-db-close (db-handle db))
        (db-closed-set! db #t)
        (db-handle-set! db #f)))

    (define (db-get db key . maybe-default)
      (let ((default (if (null? maybe-default) #f (car maybe-default))))
        (if (or (not (db? db)) (db-closed? db))
            default
            (let ((res (call-db-get (db-handle db) key)))
              (if res res default)))))

    (define (db-set! db key val)
      (when (and (db? db)
                 (not (db-closed? db))
                 (not (eq? (db-mode db) 'read)))
        (call-db-set (db-handle db) key val)))

    (define (db-exists? db key)
      (if (or (not (db? db)) (db-closed? db))
          #f
          (= (call-db-check (db-handle db) key) 1)))

    (define (db-delete! db key)
      (if (or (not (db? db))
              (db-closed? db)
              (eq? (db-mode db) 'read))
          #f
          (= (call-db-remove (db-handle db) key) 1)))

    (define (db-count db)
      (if (or (not (db? db)) (db-closed? db))
          0
          (call-db-count (db-handle db))))

    (define (db-sync db)
      (when (and (db? db)
                 (not (db-closed? db))
                 (not (eq? (db-mode db) 'read)))
        (call-db-sync (db-handle db))))

    (define (db-edit-distance str-a str-b)
      (call-db-edit-distance str-a str-b))

    (define (db-keys db . maybe-prefix)
      '())

    (define (db-search-prefix db prefix . maybe-cap)
      '())

    (define (db-for-each proc db)
      #f)

    (define (db-fold proc knil db)
      knil)))
