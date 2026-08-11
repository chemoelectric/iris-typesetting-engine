# `iris_dynamic_array` Module

## Overview
The `iris_dynamic_array` module provides high-performance, single-entry/single-exit dynamic storage container procedures for Fortran `int32` and `int64` integer vectors. It eliminates fixed array limits across the engine while preserving contiguous memory layout for SIMD and CPU vector unit optimizations.

## Data Structures & Procedures

### `ensure_int32_capacity`
Ensures that an allocatable 1D array of `integer(kind=int32)` has sufficient capacity for `req_count` elements without data loss.
```fortran
subroutine ensure_int32_capacity(arr, req_count)
  integer(kind=int32), allocatable, dimension(:), intent(inout) :: arr
  integer(kind=int32), intent(in) :: req_count
end subroutine ensure_int32_capacity
```

### `ensure_int64_capacity`
Ensures that an allocatable 1D array of `integer(kind=int64)` has sufficient capacity for `req_count` elements without data loss.
```fortran
subroutine ensure_int64_capacity(arr, req_count)
  integer(kind=int64), allocatable, dimension(:), intent(inout) :: arr
  integer(kind=int32), intent(in) :: req_count
end subroutine ensure_int64_capacity
```
