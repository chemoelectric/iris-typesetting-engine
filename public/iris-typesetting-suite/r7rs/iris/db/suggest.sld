;;; r7rs/iris/db/suggest.sld --- Font name suggestions via edit distance
;;;
;;; SPDX-License-Identifier: MIT

(define-library (iris db suggest)
  (import (scheme base)
          (scheme char)
          (scheme write)
          (gauche base)
          (srfi 13)
          (iris db))
  (export suggest-similar-names
          format-did-you-mean-diagnostic)
  (begin

    (define (score-candidate query candidate max-dist)
      (let ((dist (db-edit-distance query candidate)))
        (if (<= dist max-dist)
            (cons dist candidate)
            #f)))

    (define (sort-scored pairs)
      (sort pairs (lambda (a b) (< (car a) (car b)))))

    (define (collect-candidates db query max-dist)
      (let ((names (db-keys db "name:"))
            (q-norm (string-downcase query)))
        (db-fold
         (lambda (k v acc)
           (if (and (>= (string-length k) 5)
                    (string=? (substring k 0 5) "name:"))
               (let* ((cand (substring k 5 (string-length k)))
                      (scored (score-candidate q-norm cand max-dist)))
                 (if scored (cons scored acc) acc))
               acc))
         '()
         db)))

    (define (take-n lst n)
      (if (or (null? lst) (<= n 0))
          '()
          (cons (car lst) (take-n (cdr lst) (- n 1)))))

    (define (suggest-similar-names db query . args)
      (let* ((cap      (if (null? args) 3 (car args)))
             (max-dist 4)
             (scored   (collect-candidates db query max-dist))
             (sorted   (sort-scored scored)))
        (map cdr (take-n sorted cap))))

    (define (format-did-you-mean-diagnostic suggestions)
      (if (null? suggestions)
          ""
          (string-append
           "Did you mean: "
           (string-join suggestions ", ")
           "?")))))
