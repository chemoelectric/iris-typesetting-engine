;;; r7rs/iris/dbm/tkrzw.sld --- DBM Tkrzw module alias for Iris
;;;
;;; SPDX-License-Identifier: MIT

(define-library (iris dbm tkrzw)
  (import (scheme base)
          (iris tkrzw))
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
          dbm-db-remove))
