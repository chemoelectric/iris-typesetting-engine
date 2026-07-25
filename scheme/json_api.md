# Scheme R7RS JSON Engine (`(json-api)`)

## 1. Executive Summary
The `(json-api)` R7RS-large Scheme library provides a functional data-structure interface for RFC 8259 JSON serialization, AST representation, and string conversion.

This library is designed in **structural isomorphism** with the Fortran 2008 `json_module`.

---

## 2. API Architecture & Symmetrical Procedure Mapping

| API Functionality | R7RS Scheme (`(json-api)`) | Fortran 2008 (`json_module`) |
| :--- | :--- | :--- |
| **Object Constructor** | `(make-json-object)` | `call json_create_object(obj)` |
| **Array Constructor** | `(make-json-array)` | `call json_create_array(arr)` |
| **String Constructor** | `(make-json-string str)` | `call json_create_string(val, str)` |
| **Number Constructor** | `(make-json-number num)` | `call json_create_number(val, num)` |
| **Boolean Constructor** | `(make-json-bool b)` | `call json_create_bool(val, b)` |
| **Null Constructor** | `(make-json-null)` | `call json_create_null(val)` |
| **Type Inspector** | `(json-type val)` | `type_id = json_get_type(val)` |
| **Object Set Field** | `(json-set-field! obj key child)` | `call json_set_field(obj, key, child)` |
| **Object Get Field** | `(json-get-field obj key)` | `call json_get_field(obj, key, child, stat)` |
| **Array Add Element** | `(json-add-element! arr child)` | `call json_add_element(arr, child)` |
| **Array Get Element** | `(json-get-element arr idx)` | `call json_get_element(arr, idx, child, stat)` |
| **Serialize to String**| `(json-serialize val)` | `call json_serialize(val, out_str)` |
| **Deallocate AST** | `(json-free val)` | `call json_free(val)` |

---

## 3. Scheme Usage Example

```scheme
#!/usr/bin/env scheme-r7rs

(import (scheme base)
        (scheme write)
        (json-api))

(let ((root (make-json-object)))
  ;; 1. Attach Fields to Object
  (json-set-field! root "author" (make-json-string "Sorts Mill Typography"))
  (json-set-field! root "pageCount" (make-json-number 411))
  (json-set-field! root "unifiedFieldActive" (make-json-bool #t))

  ;; 2. Serialize and Display Output
  (display (json-serialize root))
  (newline)

  ;; 3. Cleanup AST State
  (json-free root))
```

---

## 4. R7RS Conformance & Functional Exemption
- **R7RS Standard**: Standard Scheme library structure using `(define-library (json-api) ...)` with explicit exports.
- **Functional Exemption**: In accordance with system design rules, Scheme functional code is exempt from imperative single-exit structured programming constraints.
