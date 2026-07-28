# `iris_svd_bridge` — SVD Abstract Interface & Procedure Pointer Bridge

## Architectural Overview
`iris_svd_bridge` provides a Fortran 2008 procedure pointer abstraction layer for Singular Value Decomposition (SVD) solvers. It decouples higher-level geometric spline modules (such as `iris_hobby_svd`) from specific linear algebra backend implementations.

By default, `iris_svd_bridge` points to the pure Fortran Jacobi SVD fallback (`iris_svd_fallback_solve`). At runtime, applications or host environments can dynamically point `active_svd_solver` to LAPACK (`iris_svd_lapack_solve`) or vendor-optimized libraries (e.g., AMD AOCL-LAPACK, Intel MKL) without build-time CPP `#ifdef` macros or preprocessor directives.

## Abstract Interface

```fortran
abstract interface
  subroutine svd_solver_interface(n, A_in, b, x, singular_tol, status)
    import :: int32, real64
    integer(kind=int32), intent(in)   :: n
    real(kind=real64), intent(in)     :: A_in(n, n)
    real(kind=real64), intent(in)     :: b(n)
    real(kind=real64), intent(out)    :: x(n)
    real(kind=real64), intent(in)     :: singular_tol
    integer(kind=int32), intent(out)  :: status
  end subroutine svd_solver_interface
end interface
```

## Procedures & API

### `iris_svd_solve(n, A_in, b, x, singular_tol, status)`
Main entry point. Dispatches execution through the active procedure pointer `active_svd_solver`.

### `iris_svd_set_solver(proc_ptr)`
Binds a custom solver conforming to `svd_solver_interface` to `active_svd_solver`.

### `iris_svd_reset_to_fallback()`
Resets `active_svd_solver` back to `iris_svd_fallback_solve`.

### `iris_svd_use_lapack()`
Points `active_svd_solver` to `iris_svd_lapack_solve` (LAPACK `DGESVD` wrapper).

### `iris_svd_lapack_solve(n, A_in, b, x, singular_tol, status)`
LAPACK `DGESVD` implementation wrapper.

## Synchronization
- **Fortran Source**: `/public/engine/fortran/iris_svd_bridge.f90`
- **Markdown Documentation**: `/public/engine/fortran/iris_svd_bridge.md`
- **Standards Compliance**: Fortran 2008 (ISO/IEC 1539-1:2010), GCC 16 compatible, single-entry/single-exit control flow, McCabe cyclomatic complexity $M \le 10$.
