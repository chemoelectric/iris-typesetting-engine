# `iris_dynamic_string` Module

## Overview
The `iris_dynamic_string` module provides dynamic deferred-length string buffer container procedures for appending character sequences without arbitrary buffer limits.

## Procedures

### `ensure_string_capacity`
Ensures an allocatable `character(len=:)` buffer has sufficient allocation capacity for `req_len` characters while preserving existing buffer contents.
```fortran
subroutine ensure_string_capacity(buf, req_len)
  character(len=:), allocatable, intent(inout) :: buf
  integer(kind=int32), intent(in) :: req_len
end subroutine ensure_string_capacity
```

### `append_string_buffer`
Appends a string segment `text` to `buf` at offset `buf_len`, automatically growing `buf` capacity as needed and updating `buf_len`.
```fortran
subroutine append_string_buffer(buf, buf_len, text)
  character(len=:), allocatable, intent(inout) :: buf
  integer(kind=int32), intent(inout) :: buf_len
  character(len=*), intent(in) :: text
end subroutine append_string_buffer
```
