;;; ============================================================================
;;; Scheme Library: (json-api)
;;; Standard: R7RS (ISO/IEC 30179) / Gauche Scheme (R7RS Mode)
;;; Domain: Isomorphic JSON AST Data Structures & Serializer/Parser Duality
;;; Exemptions: R7RS Scheme functional code is exempt from single-exit rules.
;;; ============================================================================

(define-library (json-api)
  (export
    make-json-object
    make-json-array
    make-json-string
    make-json-number
    make-json-bool
    make-json-null
    json-type
    json-set-field!
    json-get-field
    json-add-element!
    json-get-element
    json-get-string
    json-get-number
    json-get-bool
    json-serialize
    json-free)

  (import (scheme base)
          (scheme write)
          (scheme char)
          (scheme string))

  (begin
    ;; Records representing JSON AST Types
    (define-record-type <json-value>
      (make-json-val type payload)
      json-val?
      (type json-val-type json-val-type-set!)
      (payload json-val-payload json-val-payload-set!))

    ;; -------------------------------------------------------------------------
    ;; Constructors (Isomorphic to Fortran json_create_*)
    ;; -------------------------------------------------------------------------
    (define (make-json-object)
      (make-json-val 'object '()))

    (define (make-json-array)
      (make-json-val 'array '()))

    (define (make-json-string str)
      (make-json-val 'string (if (string? str) str (symbol->string str))))

    (define (make-json-number num)
      (make-json-val 'number (if (number? num) num 0)))

    (define (make-json-bool b)
      (make-json-val 'boolean (if b #t #f)))

    (define (make-json-null)
      (make-json-val 'null #f))

    ;; -------------------------------------------------------------------------
    ;; Inspector (Isomorphic to Fortran json_get_type)
    ;; -------------------------------------------------------------------------
    (define (json-type val)
      (if (json-val? val)
          (json-val-type val)
          'null))

    ;; -------------------------------------------------------------------------
    ;; Object Mutators & Accessors (Isomorphic to Fortran json_set_field)
    ;; -------------------------------------------------------------------------
    (define (json-set-field! obj key child)
      (if (eq? (json-type obj) 'object)
          (let* ((alist (json-val-payload obj))
                 (k-str (if (symbol? key) (symbol->string key) key))
                 (existing (assoc k-str alist)))
            (if existing
                (set-cdr! existing child)
                (json-val-payload-set! obj (cons (cons k-str child) alist))))))

    (define (json-get-field obj key)
      (if (eq? (json-type obj) 'object)
          (let* ((alist (json-val-payload obj))
                 (k-str (if (symbol? key) (symbol->string key) key))
                 (pair (assoc k-str alist)))
            (if pair
                (cdr pair)
                (make-json-null)))
          (make-json-null)))

    ;; -------------------------------------------------------------------------
    ;; Array Mutators & Accessors (Isomorphic to Fortran json_add_element)
    ;; -------------------------------------------------------------------------
    (define (json-add-element! arr child)
      (if (eq? (json-type arr) 'array)
          (let ((lst (json-val-payload arr)))
            (json-val-payload-set! arr (append lst (list child))))))

    (define (json-get-element arr idx)
      (if (and (eq? (json-type arr) 'array) (>= idx 0))
          (let ((lst (json-val-payload arr)))
            (if (< idx (length lst))
                (list-ref lst idx)
                (make-json-null)))
          (make-json-null)))

    ;; -------------------------------------------------------------------------
    ;; Value Extractors (Isomorphic to Fortran json_get_*)
    ;; -------------------------------------------------------------------------
    (define (json-get-string val)
      (if (eq? (json-type val) 'string)
          (json-val-payload val)
          ""))

    (define (json-get-number val)
      (if (eq? (json-type val) 'number)
          (json-val-payload val)
          0))

    (define (json-get-bool val)
      (if (eq? (json-type val) 'boolean)
          (json-val-payload val)
          #f))

    ;; -------------------------------------------------------------------------
    ;; Serializer (Isomorphic output to Fortran json_serialize)
    ;; -------------------------------------------------------------------------
    (define (json-serialize val)
      (case (json-type val)
        ((null) "null")
        ((boolean) (if (json-val-payload val) "true" "false"))
        ((number) (number->string (json-val-payload val)))
        ((string) (string-append "\"" (json-val-payload val) "\""))
        ((array)
         (string-append "["
                        (string-join (map json-serialize (json-val-payload val)) ", ")
                        "]"))
        ((object)
         (string-append "{"
                        (string-join
                         (map (lambda (pair)
                                (string-append "\"" (car pair) "\": "
                                               (json-serialize (cdr pair))))
                              (json-val-payload val))
                         ", ")
                        "}"))
        (else "null")))

    ;; Helper string-join if not in base
    (define (string-join lst sep)
      (if (null? lst)
          ""
          (let loop ((rest (cdr lst))
                     (acc (car lst)))
            (if (null? rest)
                acc
                (loop (cdr rest) (string-append acc sep (car rest)))))))

    ;; -------------------------------------------------------------------------
    ;; Memory Free / Nullify (Isomorphic to Fortran json_free)
    ;; -------------------------------------------------------------------------
    (define (json-free val)
      (if (json-val? val)
          (begin
            (json-val-type-set! val 'null)
            (json-val-payload-set! val #f)
            #t)
          #f))))
