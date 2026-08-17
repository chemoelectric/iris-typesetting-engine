;;; r7rs/iris/tkrzw.sld --- Tkrzw DBM database interface for Iris
;;;
;;; SPDX-License-Identifier: MIT

(define-library (iris tkrzw)
  (import (scheme base)
          (scheme char)
          (scheme file)
          (scheme write)
          (scheme process-context)
          (gauche base)
          (gauche keyword)
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

    (define-class <tkrzw-meta> (<dbm-meta>) ())

    (define-class <tkrzw> (<dbm>)
      ((handle       :init-value #f :init-keyword :handle)
       (iter         :init-value #f :init-keyword :iter)
       (params       :init-value "" :init-keyword :params)
       (table        :init-value #f)
       (keys-cache   :init-value '())
       (iter-index   :init-value 0)
       (closed       :init-value #f)
       (sync-mode    :init-value #f))
      :metaclass <tkrzw-meta>)

    (define (to-string obj)
      (cond
        ((string? obj) obj)
        ((symbol? obj) (symbol->string obj))
        ((number? obj) (number->string obj))
        ((char? obj)   (string obj))
        ((bytevector? obj) (utf8->string obj))
        (else (call-with-port (open-output-string)
                (lambda (p) (write obj p) (get-output-string p))))))

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

    (define (read-single-record port ht)
      (let ((k (guard (e (else #f)) (read port))))
        (cond
          ((eof-object? k) #f)
          ((not k) #f)
          (else
           (let ((v (guard (e (else #f)) (read port))))
             (cond
               ((eof-object? v) #f)
               ((not v) #f)
               (else
                (let ((k-str (to-string k))
                      (v-str (to-string v)))
                  (hash-table-put! ht k-str v-str)
                  #t))))))))

    (define (read-all-db-records port ht)
      (let loop ()
        (when (read-single-record port ht)
          (loop))))

    (define (safe-file-read-records path)
      (guard (ex (else (make-hash-table 'string=?)))
        (if (not (file-exists? path))
            (make-hash-table 'string=?)
            (let ((ht (make-hash-table 'string=?)))
              (guard (e (else ht))
                (call-with-input-file path
                  (lambda (p)
                    (read-all-db-records p ht))))
              ht))))

    (define (write-all-db-records port ht)
      (hash-table-for-each
       ht
       (lambda (k v)
         (write k port)
         (newline port)
         (write v port)
         (newline port))))

    (define (remove-file-if-exists file-path)
      (when (file-exists? file-path)
        (guard (e (else #f))
          (sys-remove file-path))))

    (define (write-records-to-file path ht)
      (call-with-output-file path
        (lambda (p)
          (write-all-db-records p ht))))

    (define (try-atomic-write-records path ht)
      (let ((tmp (string-append path ".tmp."
                                (number->string (sys-getpid)))))
        (remove-file-if-exists tmp)
        (let ((ok (guard (e (else #f))
                    (write-records-to-file tmp ht)
                    (sys-rename tmp path)
                    #t)))
          (unless ok
            (remove-file-if-exists tmp))
          ok)))

    (define (safe-file-write-records path ht)
      (guard (ex (else #f))
        (ensure-parent-dir path)
        (let ((saved (try-atomic-write-records path ht)))
          (if saved
              #t
              (guard (e2 (else #f))
                (write-records-to-file path ht)
                #t)))))

    (define (tkrzw-open path . args)
      (let-keywords* args ((rw-mode :read)
                           (sync-mode :async)
                           (params "")
                           (key-convert #f)
                           (value-convert #f))
        (let ((inst (make <tkrzw>
                      :path path
                      :rw-mode rw-mode
                      :sync-mode sync-mode
                      :key-convert key-convert
                      :value-convert value-convert
                      :params params)))
          (dbm-open inst))))

    (define (tkrzw-close self)
      (dbm-close self))

    (define (tkrzw-closed? self)
      (dbm-closed? self))

    (define (tkrzw-get self key . default)
      (if (pair? default)
          (dbm-get self (to-string key) (car default))
          (dbm-get self (to-string key))))

    (define (tkrzw-put! self key val)
      (dbm-put! self (to-string key) (to-string val)))

    (define (tkrzw-exists? self key)
      (dbm-exists? self (to-string key)))

    (define (tkrzw-delete! self key)
      (dbm-delete! self (to-string key)))

    (define (tkrzw-count self)
      (let ((ht (slot-ref self 'table)))
        (if ht (hash-table-num-entries ht) 0)))

    (define (tkrzw-file-size self)
      (let ((p (slot-ref self 'path)))
        (if (and p (file-exists? p))
            (file-size-in-bytes p)
            0)))

    (define (file-size-in-bytes path)
      (guard (e (else 0))
        (sys-stat-size (sys-stat path))))

    (define (tkrzw-file-path self)
      (slot-ref self 'path))

    (define (tkrzw-clear! self)
      (if (slot-ref self 'closed)
          (error "Attempt to clear a closed DBM:" self)
          (let ((rw (slot-ref self 'rw-mode)))
            (if (eq? rw :read)
                (error "DBM opened as read-only:" self)
                (let ((ht (slot-ref self 'table)))
                  (hash-table-clear! ht)
                  (slot-set! self 'keys-cache '())
                  (slot-set! self 'iter-index 0)
                  #t)))))

    (define (tkrzw-sync self . hard)
      (if (slot-ref self 'closed)
          #f
          (let ((p (slot-ref self 'path))
                (ht (slot-ref self 'table))
                (rw (slot-ref self 'rw-mode)))
            (if (and (not (eq? rw :read)) p ht)
                (safe-file-write-records p ht)
                #t))))

    (define (tkrzw-edit-distance str1 str2)
      (string-levenshtein (to-string str1) (to-string str2)))

    (define (filter-keys-by-mode mode pat keys)
      (cond
        ((string=? mode "exact")
         (filter (lambda (k) (string=? (to-string k) pat)) keys))
        ((string=? mode "begin")
         (filter (lambda (k)
                   (let* ((ks (to-string k))
                          (plen (string-length pat))
                          (klen (string-length ks)))
                     (and (>= klen plen)
                          (string=? (substring ks 0 plen) pat))))
                 keys))
        ((string=? mode "end")
         (filter (lambda (k)
                   (let* ((ks (to-string k))
                          (plen (string-length pat))
                          (klen (string-length ks)))
                     (and (>= klen plen)
                          (string=? (substring ks (- klen plen) klen)
                                    pat))))
                 keys))
        (else
         (filter (lambda (k)
                   (let* ((ks (to-string k))
                          (plen (string-length pat))
                          (klen (string-length ks)))
                     (if (> plen klen)
                         #f
                         (let loop ((i 0))
                           (cond
                             ((> (+ i plen) klen) #f)
                             ((string=? (substring ks i (+ i plen)) pat)
                              #t)
                             (else (loop (+ i 1))))))))
                 keys))))

    (define (tkrzw-search self pattern . args)
      (let-keywords* args ((mode "contain")
                           (capacity 0))
        (let* ((tbl (slot-ref self 'table))
               (keys (if tbl (hash-table-keys tbl) '()))
               (pat (to-string pattern))
               (matched (filter-keys-by-mode mode pat keys)))
          (if (and (> capacity 0) (> (length matched) capacity))
              (take matched capacity)
              matched))))

    (define (eval-approx-key qstr qlen max-d k)
      (let* ((kstr (to-string k))
             (klen (string-length kstr)))
        (if (<= (abs (- klen qlen)) max-d)
            (let ((dist (tkrzw-edit-distance qstr kstr)))
              (if (<= dist max-d)
                  (cons kstr dist)
                  #f))
            #f)))

    (define (tkrzw-search-approximate self query max-distance . args)
      (let-keywords* args ((capacity 0))
        (let* ((tbl (slot-ref self 'table))
               (keys (if tbl (hash-table-keys tbl) '()))
               (qstr (to-string query))
               (qlen (string-length qstr))
               (matches '()))
          (for-each
           (lambda (k)
             (let ((cand (eval-approx-key qstr qlen max-distance k)))
               (when cand
                 (set! matches (cons cand matches)))))
           keys)
          (let ((sorted (sort matches
                              (lambda (a b) (< (cdr a) (cdr b))))))
            (if (and (> capacity 0) (> (length sorted) capacity))
                (take sorted capacity)
                sorted)))))

    (define (tkrzw-increment! self key . args)
      (let-keywords* args ((increment 1)
                           (initial 0))
        (let* ((k (to-string key))
               (cur (tkrzw-get self k #f))
               (num (if cur
                        (or (string->number cur) initial)
                        initial))
               (next (+ num increment)))
          (tkrzw-put! self k (number->string next))
          next)))

    (define (tkrzw-append! self key value . delim)
      (let* ((k (to-string key))
             (v (to-string value))
             (d (if (pair? delim) (to-string (car delim)) ""))
             (cur (tkrzw-get self k #f))
             (new-val (if cur
                          (string-append cur d v)
                          v)))
        (tkrzw-put! self k new-val)
        new-val))

    (define (tkrzw-rekey! self old-key new-key)
      (let* ((ok (to-string old-key))
             (nk (to-string new-key))
             (val (tkrzw-get self ok #f)))
        (if val
            (begin
              (tkrzw-put! self nk val)
              (tkrzw-delete! self ok)
              #t)
            #f)))

    (define (tkrzw-inspect self)
      `((path       . ,(tkrzw-file-path self))
        (count      . ,(tkrzw-count self))
        (size-bytes . ,(tkrzw-file-size self))
        (closed?    . ,(tkrzw-closed? self))))

    (define (ensure-keys-cache self)
      (when (null? (slot-ref self 'keys-cache))
        (let ((ht (slot-ref self 'table)))
          (when ht
            (slot-set! self 'keys-cache (hash-table-keys ht))))))

    (define (tkrzw-iter-first self)
      (ensure-keys-cache self)
      (slot-set! self 'iter-index 0)
      (let ((keys (slot-ref self 'keys-cache)))
        (if (null? keys)
            #f
            (let ((k (car keys)))
              (cons k (tkrzw-get self k #f))))))

    (define (tkrzw-iter-next self)
      (ensure-keys-cache self)
      (let* ((idx (+ (slot-ref self 'iter-index) 1))
             (keys (slot-ref self 'keys-cache)))
        (slot-set! self 'iter-index idx)
        (if (>= idx (length keys))
            #f
            (let ((k (list-ref keys idx)))
              (cons k (tkrzw-get self k #f))))))

    (define (tkrzw-iter-get self)
      (ensure-keys-cache self)
      (let ((idx (slot-ref self 'iter-index))
            (keys (slot-ref self 'keys-cache)))
        (if (or (< idx 0) (>= idx (length keys)))
            #f
            (let ((k (list-ref keys idx)))
              (cons k (tkrzw-get self k #f))))))

    (define (tkrzw-iter-step self)
      (let ((cur (tkrzw-iter-get self)))
        (tkrzw-iter-next self)
        cur))

    (define (tkrzw-iter-jump self key)
      (ensure-keys-cache self)
      (let* ((k (to-string key))
             (keys (slot-ref self 'keys-cache)))
        (let loop ((rest keys) (idx 0))
          (cond
            ((null? rest)
             (slot-set! self 'iter-index (length keys))
             #f)
            ((string=? (car rest) k)
             (slot-set! self 'iter-index idx)
             (cons k (tkrzw-get self k #f)))
            (else
             (loop (cdr rest) (+ idx 1)))))))

    (define (tkrzw-iter-remove! self)
      (let ((cur (tkrzw-iter-get self)))
        (when cur
          (tkrzw-delete! self (car cur))
          (slot-set! self 'keys-cache '())
          #t)))

    (define (tkrzw-iter-set! self val)
      (let ((cur (tkrzw-iter-get self)))
        (when cur
          (dbm-put! self (car cur) val))))

    ;; -----------------------------------------------------------------
    ;; Generic DBM Method Implementations
    ;; -----------------------------------------------------------------

    (define-method initialize ((self <tkrzw>) initargs)
      (next-method)
      (unless (slot-bound? self 'k2s)
        (slot-set! self 'k2s identity))
      (unless (slot-bound? self 's2k)
        (slot-set! self 's2k identity))
      (unless (slot-bound? self 'v2s)
        (slot-set! self 'v2s identity))
      (unless (slot-bound? self 's2v)
        (slot-set! self 's2v identity)))

    (define-method dbm-open ((self <tkrzw>))
      (let* ((path (slot-ref self 'path))
             (rw (slot-ref self 'rw-mode)))
        (if (not path)
            (error "<tkrzw> requires a valid path slot to open")
            (let ((ht (if (eq? rw :truncate)
                          (make-hash-table 'string=?)
                          (safe-file-read-records path))))
              (slot-set! self 'table ht)
              (slot-set! self 'handle path)
              (slot-set! self 'closed #f)
              (slot-set! self 'keys-cache '())
              (slot-set! self 'iter-index 0)
              (unless (slot-bound? self 'k2s)
                (slot-set! self 'k2s identity))
              (unless (slot-bound? self 's2k)
                (slot-set! self 's2k identity))
              (unless (slot-bound? self 'v2s)
                (slot-set! self 'v2s identity))
              (unless (slot-bound? self 's2v)
                (slot-set! self 's2v identity))
              self))))

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
                  (slot-set! self 'keys-cache '())
                  (let ((sync (slot-ref self 'sync-mode)))
                    (when (or (eq? sync :sync)
                              (eq? sync :on-demand))
                      (safe-file-write-records
                       (slot-ref self 'path) ht)))
                  v)))))

    (define-method dbm-get ((self <tkrzw>) key . default)
      (if (slot-ref self 'closed)
          (error "Attempt to read from a closed DBM:" self)
          (let* ((k (to-string key))
                 (ht (slot-ref self 'table)))
            (if (and ht (hash-table-exists? ht k))
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
                  (if (and ht (hash-table-exists? ht k))
                      (begin
                        (hash-table-delete! ht k)
                        (slot-set! self 'keys-cache '())
                        #t)
                      #f))))))

    (define-method dbm-fold ((self <tkrzw>) proc knil)
      (if (slot-ref self 'closed)
          knil
          (let ((ht (slot-ref self 'table)))
            (if ht
                (hash-table-fold ht proc knil)
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
      (tkrzw-iter-first self))

    (define-method dbm-next ((self <tkrzw>))
      (tkrzw-iter-next self))

    (define-method dbm-sync ((self <tkrzw>))
      (tkrzw-sync self))

    (define-method dbm-db-exists? ((class <tkrzw-meta>) name)
      (file-exists? name))

    (define-method dbm-db-remove ((class <tkrzw-meta>) name)
      (guard (ex (else #f))
        (sys-unlink name)))

    ))
