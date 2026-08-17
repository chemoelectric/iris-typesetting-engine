;;; r7rs/iris/dbm/suggest.sld --- Levenshtein compiler diagnostic suggest engine
;;;
;;; SPDX-License-Identifier: MIT

(define-library (iris dbm suggest)
  (import (scheme base)
          (scheme char)
          (scheme write)
          (gauche base)
          (iris tkrzw))
  (export suggest-similar-names
          suggest-did-you-mean
          format-did-you-mean-diagnostic)
  (begin

    (define (normalize-name str)
      (string-downcase str))

    (define (eval-candidate-key db full-k pre-len norm-q qlen max-d)
      (let* ((name-part (substring full-k pre-len (string-length full-k)))
             (nlen      (string-length name-part)))
        (if (> (abs (- nlen qlen)) max-d)
            #f
            (let ((dist (tkrzw-edit-distance norm-q name-part)))
              (if (<= dist max-d)
                  (let ((real-val (or (tkrzw-get db full-k #f) name-part)))
                    (cons real-val dist))
                  #f)))))

    (define (candidate<? a b)
      (if (= (cdr a) (cdr b))
          (string<? (car a) (car b))
          (< (cdr a) (cdr b))))

    (define (dedup-candidates lst)
      (let loop ((rest lst) (seen '()) (acc '()))
        (cond
          ((null? rest)
           (reverse acc))
          ((member (caar rest) seen)
           (loop (cdr rest) seen acc))
          (else
           (loop (cdr rest)
                 (cons (caar rest) seen)
                 (cons (car rest) acc))))))

    (define (collect-candidates db keys pre-len norm-q qlen max-d)
      (let loop ((rest keys) (acc '()))
        (if (null? rest)
            acc
            (let ((cand (eval-candidate-key db (car rest) pre-len
                                            norm-q qlen max-d)))
              (loop (cdr rest)
                    (if cand (cons cand acc) acc))))))

    (define (suggest-similar-names db query . args)
      (let-keywords* args ((max-distance 3)
                           (capacity 5)
                           (prefix "name:"))
        (if (not db)
            '()
            (let* ((norm-q   (normalize-name query))
                   (qlen     (string-length norm-q))
                   (pre-len  (string-length prefix))
                   (all-keys (tkrzw-search db prefix :mode "begin"
                                           :capacity 0))
                   (matches  (collect-candidates db all-keys pre-len
                                                 norm-q qlen max-distance))
                   (sorted   (sort matches candidate<?))
                   (unique   (dedup-candidates sorted)))
              (if (and (> capacity 0) (> (length unique) capacity))
                  (take unique capacity)
                  unique)))))

    (define (suggest-did-you-mean db query . args)
      (let* ((max-d (if (null? args) 3 (car args)))
             (candidates (suggest-similar-names db query
                                                :max-distance max-d
                                                :capacity 1)))
        (if (null? candidates)
            #f
            (caar candidates))))

    (define (format-did-you-mean-diagnostic item-type query suggestion)
      (if suggestion
          (string-append "error: " item-type " '" query "' was not found.\n"
                         "  = note: did you mean '" suggestion "'?")
          (string-append "error: " item-type " '" query
                         "' was not found.")))))
