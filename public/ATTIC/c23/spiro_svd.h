/* ==============================================================================
 * IRIS MICROTYPOGRAPHY LAYOUT ENGINE
 * Library: spiro_svd.h
 * Language: ISO C23 (GCC 16 / Clang 18 compatible)
 * Purpose: Numerically Stable Spiro (Euler Spiral / Clothoid) Spline Engine.
 * Algorithm: SVD Gauss-Newton Solver + Scale-Invariant Fresnel Quadrature.
 * Constraints: Single-entry / single-exit structured programming.
 *              NO 'goto', NO '++' or '--' operators (uses x += 1, x -= 1).
 *              McCabe Cyclomatic Complexity M <= 10 for every function.
 * ============================================================================== */

#ifndef SPIRO_SVD_H
#define SPIRO_SVD_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Knot types for Spiro curves */
typedef enum {
    SPIRO_KNOT_SMOOTH = 0,    /* G2 continuous curve knot */
    SPIRO_KNOT_CORNER = 1,    /* Sharp corner (G0 continuous) */
    SPIRO_KNOT_LEFT   = 2,    /* Left-hand tangent constraint */
    SPIRO_KNOT_RIGHT  = 3,    /* Right-hand tangent constraint */
    SPIRO_KNOT_END    = 4     /* Terminating endpoint */
} spiro_knot_type_t;

/* Spiro Knot Structure */
typedef struct {
    double x;
    double y;
    spiro_knot_type_t type;
} spiro_knot_t;

/* Spiro Segment State Structure */
typedef struct {
    double x0;
    double y0;
    double x1;
    double y1;
    double theta0;
    double theta1;
    double kappa0;
    double kappa1;
    double length;
} spiro_segment_t;

/* Spiro Solver Configuration */
typedef struct {
    double max_ent_lambda;    /* Regularization parameter lambda (e.g. 1e-6) */
    double conv_tolerance;    /* Convergence threshold (e.g. 1e-10) */
    int max_iterations;       /* Max Gauss-Newton iterations (e.g. 50) */
    double min_segment_len;   /* Minimum knot spacing before collapse (e.g. 1e-7) */
} spiro_config_t;

/* Function Prototypes */

/* Default configuration initializer */
spiro_config_t spiro_default_config(void);

/* Fresnel Integrator for Clothoid Segment: computes (dx, dy) given L, theta0, K0, K1 */
void spiro_fresnel_integrate(
    double length,
    double theta0,
    double k0,
    double k1,
    double *out_dx,
    double *out_dy
);

/* Standalone 2x2 Singular Value Decomposition (SVD) for localized Jacobian solve */
void spiro_svd_2x2(
    double a, double b, double c, double d,
    double *out_u, double *out_s, double *out_v
);

/* SVD Gauss-Newton Solver for Spiro Knot Sequences */
int spiro_solve_spline_svd(
    const spiro_knot_t *knots,
    size_t knot_count,
    const spiro_config_t *config,
    spiro_segment_t *out_segments,
    size_t *out_segment_count
);

#ifdef __cplusplus
}
#endif

#endif /* SPIRO_SVD_H */
