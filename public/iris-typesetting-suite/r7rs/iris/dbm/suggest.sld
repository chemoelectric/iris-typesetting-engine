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

    ;; Search for similar names in database using Levenshtein distance
    ;; Returns a list of (candidate-name . edit-distance) pairs
    (define (suggest-similar-names db query . args)
      (let-keywords* args ((max-distance 3)
                           (capacity 5)
                           (prefix "name:"))
        (if (not db)
            '()
            (let* ((norm-q (normalize-name query))
                   (qlen (string-length norm-q))
                   (pre-len (string-length prefix))
                   (all-keys (tkrzw-search db prefix :mode "begin" :capacity 0))
                   (results '()))
              (for-each
               (lambda (full-k)
                 (let* ((name-part (substring full-k pre-len (string-length full-k)))
                        (nlen (string-length name-part)))
                   ;; Fast length difference pruning: abs(len(a) - len(b)) <= max-distance
                   (when (<= (abs (- nlen qlen)) max-distance)
                     (let ((dist (tkrzw-edit-distance norm-q name-part)))
                       (when (<= dist max-distance)
                         (let ((real-val (or (tkrzw-get db full-k #f) name-part)))
                           (set! results (cons (cons real-val dist) results))))))))
               all-keys)
              ;; Sort candidates: closest distance first, then alphabetically
              (let* ((sorted (sort results (lambda (a b)
                                             (if (= (cdr a) (cdr b))
                                                 (string<? (car a) (car b))
                                                 (< (cdr a) (cdr b))))))
                     ;; Deduplicate while preserving order
                     (unique (let loop ((lst sorted) (seen '()) (acc '()))
                               (cond
                                 ((null? lst) (reverse acc))
                                 ((member (caar lst) seen)
                                  (loop (cdr lst) seen acc))
                                 (else
                                  (loop (cdr lst) (cons (caar lst) seen) (cons (car lst) acc)))))))
                (if (and (> capacity 0) (> (length unique) capacity))
                    (take unique capacity)
                    unique))))))

    ;; Return single best suggestion or #f if none meet threshold
    (define (suggest-did-you-mean db query . args)
      (let* ((max-d (if (null? args) 3 (car args)))
             (candidates (suggest-similar-names db query :max-distance max-d :capacity 1)))
        (if (null? candidates)
            #f
            (caar candidates))))

    ;; Produce a compiler-grade diagnostic message
    (define (format-did-you-mean-diagnostic item-type query suggestion)
      (if suggestion
          (string-append "error: " item-type " '" query "' was not found.\n"
                         "  = note: did you mean '" suggestion "'?")
          (string-append "error: " item-type " '" query "' was not found."))))))
