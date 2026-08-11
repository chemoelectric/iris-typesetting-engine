# `iris_svd_fallback` — Pure Fortran Fallback Jacobi SVD Solver

## Architectural Overview
`iris_svd_fallback` provides a self-contained, pure Fortran 2008 implementation of a dense Jacobi Singular Value Decomposition (SVD) pseudo-inverse solver. It serves as the guaranteed fallback algorithm when external LAPACK / vendor BLAS libraries are not linked or available at runtime.

## Mathematical Formulation
For a real matrix $A \in \mathbb{R}^{n \times n}$, classical one-sided Jacobi orthogonal rotations iteratively diagonalize $A$:
$$A = U \Sigma V^T$$
The pseudo-inverse solution $x$ for linear system $A x = b$ is calculated as:
$$x = V \Sigma^+ U^T b$$
where $\Sigma^+$ truncates singular values smaller than the user-specified tolerance parameter $\epsilon_{\text{tol}}$.

## Procedures & API

### `iris_svd_fallback_solve(n, A_in, b, x, singular_tol, status)`
- `n`: System dimension.
- `A_in`: Real input matrix $n \times n$.
- `b`: Right-hand side vector of length $n$.
- `x`: Output solution vector of length $n$.
- `singular_tol`: Singular value truncation threshold.
- `status`: Integer return status code (`0` on success).

## Synchronization
- **Fortran Source**: `/public/engine/fortran/iris_svd_fallback.f90`
- **Markdown Documentation**: `/public/engine/fortran/iris_svd_fallback.md`
- **Standards Compliance**: Fortran 2008 (ISO/IEC 1539-1:2010), GCC 16 compatible, single-entry/single-exit control flow, McCabe cyclomatic complexity $M \le 8$.
