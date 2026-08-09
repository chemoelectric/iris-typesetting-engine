# `iris_hobby_svd` — Extended Hobby Spline Engine with SVD Solver

## Architectural Overview
`iris_hobby_svd` is a specialized Fortran 2008 module implementing an extension to John Hobby's smooth planar curve generation algorithm (used in METAFONT and MetaPost). Instead of relying on rigid tridiagonal Gaussian elimination, `iris_hobby_svd` employs a Jacobi Singular Value Decomposition (SVD) pseudo-inverse solver.

This SVD extension handles over-constrained (e.g., explicit tangent angles, multi-point curvature bounds) and under-constrained systems (e.g., open curves with degenerate boundary conditions) without numerical ill-conditioning or rank deficiency errors.

## Data Structures

### `hobby_knot_type`
Represents a knot point along the spline path:
- `x`, `y`: Real precision coordinates in absolute spatial continuum.
- `tension_in`, `tension_out`: Segment tension controls (default: `1.0`).
- `explicit_angle`: Fixed tangent angle specification.
- `has_explicit_angle`: Boolean indicator for angle constraint.

### `hobby_control_point_type`
Defines the resulting cubic Bézier control points for each segment:
- `z0_x`, `z0_y`: Start knot point ($z_0$).
- `z1_x`, `z1_y`: First handle control point ($z_1$).
- `z2_x`, `z2_y`: Second handle control point ($z_2$).
- `z3_x`, `z3_y`: End knot point ($z_3$).
- `theta`, `phi`: Ingress and egress tangent deviation angles.
- `alpha`, `beta`: Velocity handle lengths.

### `hobby_config_type`
Engine parameters:
- `default_tension`: Default tension factor ($1.0$).
- `svd_threshold`: Singular value truncation threshold ($\epsilon = 10^{-12}$).
- `curl`: Boundary curl factor for open curves ($1.0$).

## Procedures & API

### `hobby_init_config(cfg)`
Initializes the configuration parameters to default settings.

### `hobby_velocity_func(theta, phi, tension)`
Calculates Hobby's velocity scaling factor $f(\theta, \phi)$ for handle length determination.

### `hobby_curvature_func(theta, phi)`
Computes the joint curvature response metric $\kappa(\theta, \phi)$.

### `hobby_svd_solve(n, A, b, x, singular_tol, status)`
Solves $A x = b$ using Jacobi SVD decomposition $A = U \Sigma V^T$, returning the minimum-norm least-squares solution $x = V \Sigma^+ U^T b$.

### `hobby_compute_spline_svd(knots, n, is_closed, cfg, controls, status)`
Main entry point. Constructs the curvature system, solves tangent angles via SVD pseudo-inverse, and constructs cubic Bézier control points $z_0, z_1, z_2, z_3$.

## Synchronization
- **Fortran Source**: `/public/engine/fortran/iris_hobby_svd.f90`
- **Markdown Documentation**: `/public/engine/fortran/iris_hobby_svd.md`
- **Standards Compliance**: Fortran 2008 (ISO/IEC 1539-1:2010), GCC 16 compatible, single-entry/single-exit control flow, McCabe cyclomatic complexity $M \le 10$.
