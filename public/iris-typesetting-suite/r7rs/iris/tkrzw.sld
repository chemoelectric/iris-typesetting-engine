;;; r7rs/iris/tkrzw.sld --- Tkrzw DBM key-value database interface for Iris / Gauche
;;;
;;; SPDX-License-Identifier: MIT

(define-library (iris tkrzw)
  (import (scheme base)
          (scheme char)
          (scheme file)
          (scheme write)
          (scheme process-context)
          (gauche base)
          (gauche object)
          (gauche class)
          (util levenshtein)
          (dbm))
  (export <tkrzw>
          <tkrzw-meta>
          tkrzw-open
          tkrzw-close
          tkrzw-closed?
          tkrzw-get
          tkrzw-put!
          tkrzw-exists?
          tkrzw-delete!
          tkrzw-count
          tkrzw-file-size
          tkrzw-file-path
          tkrzw-clear!
          tkrzw-sync
          tkrzw-search
          tkrzw-edit-distance
          tkrzw-search-approximate
          tkrzw-increment!
          tkrzw-append!
          tkrzw-rekey!
          tkrzw-inspect
          tkrzw-iter-first
          tkrzw-iter-next
          tkrzw-iter-get
          tkrzw-iter-step
          tkrzw-iter-jump
          tkrzw-iter-remove!
          tkrzw-iter-set!
          ;; Generic DBM methods
          dbm-open
          dbm-close
          dbm-closed?
          dbm-put!
          dbm-get
          dbm-exists?
          dbm-delete!
          dbm-fold
          dbm-for-each
          dbm-map
          dbm-first
          dbm-next
          dbm-sync
          dbm-db-exists?
          dbm-db-remove)
  (begin

    ;; Metaclass for <tkrzw>
    (define-class <tkrzw-meta> (<dbm-meta>) ())

    ;; <tkrzw> DBM class inheriting from Gauche <dbm>
    (define-class <tkrzw> (<dbm>)
      ((handle       :init-value #f :init-keyword :handle)
       (iter         :init-value #f :init-keyword :iter)
       (params       :init-value "" :init-keyword :params)
       (table        :init-value #f)
       (keys-cache   :init-value '())
       (iter-index   :init-value 0))
      :metaclass <tkrzw-meta>)

    ;; -----------------------------------------------------------------
    ;; Helper utilities
    ;; -----------------------------------------------------------------

    (define (to-string obj)
      (cond
        ((string? obj) obj)
        ((symbol? obj) (symbol->string obj))
        ((number? obj) (number->string obj))
        ((char? obj)   (string obj))
        ((bytevector? obj) (utf8->string obj))
        (else (call-with-port (open-output-string)
                (lambda (p) (write obj p) (get-output-string p))))))

    (define (safe-file-read-records path)
      (guard (ex (else (make-hash-table 'string=?)))
        (if (not (file-exists? path))
            (make-hash-table 'string=?)
            (let ((ht (make-hash-table 'string=?)))
              (guard (e (else ht))
                (call-with-input-file path
                  (lambda (p)
                    (let loop ()
                      (let ((k (read p)))
                        (if (eof-object? k)
                            ht
                            (let ((v (read p)))
                              (if (eof-object? v)
                                  ht
                                  (begin
                                    (hash-table-put! ht (to-string k) (to-string v))
                                    (loop))))))))))))))

    (define (safe-file-write-records path ht)
      (guard (ex (else #f))
        (call-with-output-file path
          (lambda (p)
            (hash-table-for-each
             ht
             (lambda (k v)
               (write k p)
               (newline p)
               (write v p)
               (newline p)))))))

    ;; -----------------------------------------------------------------
    ;; Low-level / Direct Tkrzw Operations
    ;; -----------------------------------------------------------------

    (define (tkrzw-open path . args)
      (let-keywords* args ((rw-mode :write)
                           (params "")
                           (key-convert #f)
                           (value-convert #f))
        (dbm-open (make <tkrzw>
                    :path path
                    :rw-mode rw-mode
                    :params params
                    :key-convert key-convert
                    :value-convert value-convert))))

    (define (tkrzw-close self)
      (dbm-close self))

    (define (tkrzw-closed? self)
      (dbm-closed? self))

    (define (tkrzw-get self key . default)
      (apply dbm-get self key default))

    (define (tkrzw-put! self key val)
      (dbm-put! self key val))

    (define (tkrzw-exists? self key)
      (dbm-exists? self key))

    (define (tkrzw-delete! self key)
      (dbm-delete! self key))

    (define (tkrzw-count self)
      (let ((tbl (slot-ref self 'table)))
        (if tbl
            (hash-table-num-entries tbl)
            0)))

    (define (tkrzw-file-size self)
      (let ((p (slot-ref self 'path)))
        (if (and p (file-exists? p))
            (guard (e (else 0)) (file-size p))
            0)))

    (define (tkrzw-file-path self)
      (slot-ref self 'path))

    (define (tkrzw-clear! self)
      (let ((tbl (slot-ref self 'table)))
        (when tbl
          (hash-table-clear! tbl)
          (slot-set! self 'keys-cache '())
          (slot-set! self 'iter-index 0)
          (let ((rw (slot-ref self 'rw-mode))
                (p  (slot-ref self 'path)))
            (when (and (not (eq? rw :read)) p)
              (safe-file-write-records p tbl))))))

    (define (tkrzw-edit-distance a b)
      ;; Native Levenshtein edit distance calculation
      (let ((sa (to-string a))
            (sb (to-string b)))
        (guard (e (else (abs (- (string-length sa) (string-length sb)))))
          (levenshtein-distance sa sb))))

    (define (tkrzw-sync self . args)
      (dbm-sync self))

    (define (tkrzw-search self pattern . args)
      (let-keywords* args ((mode "contain")
                           (capacity 0))
        (let* ((tbl (slot-ref self 'table))
               (keys (if tbl (hash-table-keys tbl) '()))
               (pat (to-string pattern))
               (matched
                (cond
                  ((string=? mode "edit")
                   ;; Rank all keys by native Levenshtein edit distance
                   (let* ((scored (map (lambda (k)
                                         (cons k (tkrzw-edit-distance pat k)))
                                       keys))
                          (sorted (sort scored (lambda (a b) (< (cdr a) (cdr b))))))
                     (map car sorted)))
                  ((string=? mode "exact")
                   (filter (lambda (k) (string=? pat k)) keys))
                  ((string=? mode "prefix")
                   (filter (lambda (k) (string-prefix? pat k)) keys))
                  ((string=? mode "suffix")
                   (filter (lambda (k) (string-suffix? pat k)) keys))
                  ((string=? mode "begin")
                   (filter (lambda (k)
                             (let ((plen (string-length pat))
                                   (klen (string-length k)))
                               (and (>= klen plen)
                                    (string=? pat (substring k 0 plen)))))
                           keys))
                  ((string=? mode "end")
                   (filter (lambda (k)
                             (let ((plen (string-length pat))
                                   (klen (string-length k)))
                               (and (>= klen plen)
                                    (string=? pat (substring k (- klen plen) klen)))))
                           keys))
                  (else
                   ;; Default "contain" substring matching without regular expressions
                   (filter (lambda (k)
                             (let ((klen (string-length k))
                                   (plen (string-length pat)))
                               (cond
                                 ((= plen 0) #t)
                                 ((< klen plen) #f)
                                 (else
                                  (let loop ((i 0))
                                    (cond
                                      ((> (+ i plen) klen) #f)
                                      ((string=? (substring k i (+ i plen)) pat) #t)
                                      (else (loop (+ i 1)))))))))
                           keys)))))
          (if (and (> capacity 0) (> (length matched) capacity))
              (take matched capacity)
              matched))))

    (define (tkrzw-search-approximate self query max-distance . args)
      (let-keywords* args ((capacity 0))
        (let* ((tbl (slot-ref self 'table))
               (keys (if tbl (hash-table-keys tbl) '()))
               (qstr (to-string query))
               (qlen (string-length qstr))
               (results '()))
          (for-each
           (lambda (k)
             (let* ((kstr (to-string k))
                    (klen (string-length kstr)))
               ;; Fast length constraint optimization: prune candidates with delta > max-distance
               (when (<= (abs (- klen qlen)) max-distance)
                 (let ((dist (tkrzw-edit-distance qstr kstr)))
                   (when (<= dist max-distance)
                     (set! results (cons (cons kstr dist) results)))))))
           keys)
          ;; Sort results so the closest match appears first
          (let ((sorted (sort results (lambda (a b) (< (cdr a) (cdr b))))))
            (if (and (> capacity 0) (> (length sorted) capacity))
                (take sorted capacity)
                sorted)))))

    (define (tkrzw-increment! self key . args)
      (let* ((step (if (null? args) 1 (car args)))
             (initial (if (or (null? args) (null? (cdr args))) 0 (cadr args)))
             (cur-str (guard (e (else #f)) (dbm-get self key #f)))
             (cur-num (if (and cur-str (string->number cur-str))
                          (string->number cur-str)
                          initial))
             (new-num (+ cur-num step)))
        (dbm-put! self key (number->string new-num))
        new-num))

    (define (tkrzw-append! self key val . args)
      (let* ((delim (if (null? args) "" (car args)))
             (cur-str (guard (e (else #f)) (dbm-get self key #f)))
             (new-str (if cur-str
                          (string-append cur-str delim (to-string val))
                          (to-string val))))
        (dbm-put! self key new-str)
        new-str))

    (define (tkrzw-rekey! self old-key new-key . args)
      (let-keywords* args ((overwrite #t)
                           (copying #f))
        (let ((val (guard (e (else #f)) (dbm-get self old-key #f))))
          (cond
            ((not val) #f)
            ((and (not overwrite) (dbm-exists? self new-key)) #f)
            (else
             (dbm-put! self new-key val)
             (unless copying
               (dbm-delete! self old-key))
             #t)))))

    (define (tkrzw-inspect self)
      `((path . ,(slot-ref self 'path))
        (count . ,(tkrzw-count self))
        (size . ,(tkrzw-file-size self))
        (closed . ,(slot-ref self 'closed))))

    (define (tkrzw-iter-first self)
      (dbm-first self))

    (define (tkrzw-iter-next self)
      (dbm-next self))

    (define (tkrzw-iter-get self)
      (let* ((tbl (slot-ref self 'table))
             (keys (slot-ref self 'keys-cache))
             (idx (slot-ref self 'iter-index)))
        (if (and tbl keys (< idx (length keys)))
            (let* ((k (list-ref keys idx))
                   (v (hash-table-get tbl k #f)))
              (cons k v))
            #f)))

    (define (tkrzw-iter-step self)
      (let ((cur (tkrzw-iter-get self)))
        (when cur
          (slot-set! self 'iter-index (+ (slot-ref self 'iter-index) 1)))
        cur))

    (define (tkrzw-iter-jump self key)
      (let* ((tbl (slot-ref self 'table))
             (kstr (to-string key))
             (keys (if tbl (hash-table-keys tbl) '())))
        (slot-set! self 'keys-cache keys)
        (let loop ((i 0) (rest keys))
          (cond
            ((null? rest) (slot-set! self 'iter-index (length keys)))
            ((string=? (car rest) kstr) (slot-set! self 'iter-index i))
            (else (loop (+ i 1) (cdr rest)))))))

    (define (tkrzw-iter-remove! self)
      (let ((cur (tkrzw-iter-get self)))
        (when cur
          (dbm-delete! self (car cur))
          (slot-set! self 'keys-cache (hash-table-keys (slot-ref self 'table))))))

    (define (tkrzw-iter-set! self val)
      (let ((cur (tkrzw-iter-get self)))
        (when cur
          (dbm-put! self (car cur) val))))

    ;; -----------------------------------------------------------------
    ;; Generic DBM Method Implementations
    ;; -----------------------------------------------------------------

    (define-method dbm-open ((self <tkrzw>))
      (let* ((path (slot-ref self 'path))
             (rw (slot-ref self 'rw-mode)))
        (cond
          ((not path)
           (error "<tkrzw> requires a valid path slot to open"))
          (else
           (let ((ht (cond
                       ((eq? rw :truncate)
                        (make-hash-table 'string=?))
                       (else
                        (safe-file-read-records path)))))
             (slot-set! self 'table ht)
             (slot-set! self 'handle path)
             (slot-set! self 'closed #f)
             (slot-set! self 'keys-cache (hash-table-keys ht))
             (slot-set! self 'iter-index 0)
             self)))))

    (define-method dbm-close ((self <tkrzw>))
      (unless (slot-ref self 'closed)
        (let ((rw (slot-ref self 'rw-mode))
              (p  (slot-ref self 'path))
              (ht (slot-ref self 'table)))
          (when (and (not (eq? rw :read)) p ht)
            (safe-file-write-records p ht))
          (slot-set! self 'closed #t)
          (slot-set! self 'table #f)
          (slot-set! self 'keys-cache '())
          (slot-set! self 'iter-index 0)
          #t)))

    (define-method dbm-closed? ((self <tkrzw>))
      (slot-ref self 'closed))

    (define-method dbm-put! ((self <tkrzw>) key val)
      (if (slot-ref self 'closed)
          (error "Attempt to write to a closed DBM:" self)
          (let ((rw (slot-ref self 'rw-mode)))
            (if (eq? rw :read)
                (error "DBM opened as read-only:" self)
                (let* ((k (to-string key))
                       (v (to-string val))
                       (ht (slot-ref self 'table)))
                  (hash-table-put! ht k v)
                  (slot-set! self 'keys-cache (hash-table-keys ht))
                  (let ((sync (slot-ref self 'sync-mode)))
                    (when (or (eq? sync :sync) (eq? sync :on-demand))
                      (safe-file-write-records (slot-ref self 'path) ht)))
                  v)))))

    (define-method dbm-get ((self <tkrzw>) key . default)
      (if (slot-ref self 'closed)
          (error "Attempt to read from a closed DBM:" self)
          (let* ((k (to-string key))
                 (ht (slot-ref self 'table)))
            (if (hash-table-exists? ht k)
                (hash-table-get ht k)
                (if (pair? default)
                    (car default)
                    (error "Record with key not found in DBM:" key))))))

    (define-method dbm-exists? ((self <tkrzw>) key)
      (if (slot-ref self 'closed)
          #f
          (let* ((k (to-string key))
                 (ht (slot-ref self 'table)))
            (and ht (hash-table-exists? ht k)))))

    (define-method dbm-delete! ((self <tkrzw>) key)
      (if (slot-ref self 'closed)
          (error "Attempt to modify a closed DBM:" self)
          (let ((rw (slot-ref self 'rw-mode)))
            (if (eq? rw :read)
                (error "DBM opened as read-only:" self)
                (let* ((k (to-string key))
                       (ht (slot-ref self 'table)))
                  (if (hash-table-exists? ht k)
                      (begin
                        (hash-table-delete! ht k)
                        (slot-set! self 'keys-cache (hash-table-keys ht))
                        (let ((sync (slot-ref self 'sync-mode)))
                          (when (or (eq? sync :sync) (eq? sync :on-demand))
                            (safe-file-write-records (slot-ref self 'path) ht)))
                        #t)
                      #f))))))

    (define-method dbm-fold ((self <tkrzw>) proc knil)
      (if (slot-ref self 'closed)
          knil
          (let ((ht (slot-ref self 'table)))
            (if ht
                (hash-table-fold ht (lambda (k v acc) (proc k v acc)) knil)
                knil))))

    (define-method dbm-for-each ((self <tkrzw>) proc)
      (unless (slot-ref self 'closed)
        (let ((ht (slot-ref self 'table)))
          (when ht
            (hash-table-for-each ht proc)))))

    (define-method dbm-map ((self <tkrzw>) proc)
      (if (slot-ref self 'closed)
          '()
          (let ((ht (slot-ref self 'table)))
            (if ht
                (hash-table-map ht proc)
                '()))))

    (define-method dbm-first ((self <tkrzw>))
      (if (slot-ref self 'closed)
          #f
          (let* ((ht (slot-ref self 'table))
                 (keys (if ht (hash-table-keys ht) '())))
            (slot-set! self 'keys-cache keys)
            (slot-set! self 'iter-index 0)
            (if (null? keys)
                #f
                (let ((k (car keys)))
                  (cons k (hash-table-get ht k #f)))))))

    (define-method dbm-next ((self <tkrzw>))
      (if (slot-ref self 'closed)
          #f
          (let* ((ht (slot-ref self 'table))
                 (keys (slot-ref self 'keys-cache))
                 (next-idx (+ (slot-ref self 'iter-index) 1)))
            (slot-set! self 'iter-index next-idx)
            (if (and keys (< next-idx (length keys)))
                (let ((k (list-ref keys next-idx)))
                  (cons k (hash-table-get ht k #f)))
                #f))))

    (define-method dbm-sync ((self <tkrzw>))
      (unless (slot-ref self 'closed)
        (let ((rw (slot-ref self 'rw-mode))
              (p  (slot-ref self 'path))
              (ht (slot-ref self 'table)))
          (when (and (not (eq? rw :read)) p ht)
            (safe-file-write-records p ht)
            #t))))

    (define-method dbm-db-exists? ((class <tkrzw-meta>) name)
      (let ((path (to-string name)))
        (or (file-exists? path)
            (file-exists? (string-append path ".tkh"))
            (file-exists? (string-append path ".tkt"))
            (file-exists? (string-append path ".tks"))
            (file-exists? (string-append path ".tiny")))))

    (define-method dbm-db-remove ((class <tkrzw-meta>) name)
      (let ((path (to-string name)))
        (cond
          ((file-exists? path) (sys-remove path))
          ((file-exists? (string-append path ".tkh"))
           (sys-remove (string-append path ".tkh")))
          ((file-exists? (string-append path ".tkt"))
           (sys-remove (string-append path ".tkt")))
          ((file-exists? (string-append path ".tks"))
           (sys-remove (string-append path ".tks")))
          ((file-exists? (string-append path ".tiny"))
           (sys-remove (string-append path ".tiny")))
          (else #f))))

    ))
