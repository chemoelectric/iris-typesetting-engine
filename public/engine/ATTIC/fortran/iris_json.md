# Fortran 2008 JSON Engine (`iris_json`)

## 1. Executive Summary
The `iris_json` module is a standard Fortran 2008 (ISO/IEC 1539-1:2010) procedural API for RFC 8259 JSON serialization and AST object manipulation.

This module is designed in **structural isomorphism** with the R7RS Scheme `(iris json)` library.

---

## 2. API Architecture & Symmetrical Procedure Mapping

| API Functionality | Fortran 2008 (`iris_json`) | R7RS Scheme (`(iris json)`) |
| :--- | :--- | :--- |
| **Object Constructor** | `call json_create_object(obj)` | `(make-json-object)` |
| **Array Constructor** | `call json_create_array(arr)` | `(make-json-array)` |
| **String Constructor** | `call json_create_string(val, str)` | `(make-json-string str)` |
| **Number Constructor** | `call json_create_number(val, num)` | `(make-json-number num)` |
| **Boolean Constructor** | `call json_create_bool(val, b)` | `(make-json-bool b)` |
| **Null Constructor** | `call json_create_null(val)` | `(make-json-null)` |
| **Type Inspector** | `type_id = json_get_type(val)` | `(json-type val)` |
| **Object Set Field** | `call json_set_field(obj, key, child)` | `(json-set-field! obj key child)` |
| **Object Get Field** | `call json_get_field(obj, key, child, stat)` | `(json-get-field obj key)` |
| **Array Add Element** | `call json_add_element(arr, child)` | `(json-add-element! arr child)` |
| **Array Get Element** | `call json_get_element(arr, idx, child, stat)` | `(json-get-element arr idx)` |
| **Serialize to String**| `call json_serialize(val, out_str)` | `(json-serialize val)` |
| **Deallocate AST** | `call json_free(val)` | `(json-free val)` |

---

## 3. Fortran Usage Example

```fortran
program test_json_builder
  use iris_json
  implicit none

  type(json_value_type) :: root_obj, author_str, pages_num, active_bool
  character(len=1024) :: json_text

  ! 1. Construct AST Nodes
  call json_create_object(root_obj)
  call json_create_string(author_str, "Sorts Mill Typography")
  call json_create_number(pages_num, 411.0_8)
  call json_create_bool(active_bool, .true.)

  ! 2. Attach Fields to Root Object
  call json_set_field(root_obj, "author", author_str)
  call json_set_field(root_obj, "pageCount", pages_num)
  call json_set_field(root_obj, "unifiedFieldActive", active_bool)

  ! 3. Serialize to JSON Text Stream
  call json_serialize(root_obj, json_text)
  print *, trim(json_text)

  ! 4. Free Memory Allocation
  call json_free(root_obj)
end program test_json_builder
```

---

## 4. Software Design Discipline & Verification
- **ISO Standard**: Fortran 2008 strictly compatible with GCC 16 / ISO C23 interfacing.
- **Single-Entry/Single-Exit**: Enforced without `goto` statements.
- **Complexity Guarantee**: Cyclomatic complexity $\le 10$ across all routines.
