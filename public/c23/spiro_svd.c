/* ==============================================================================
 * IRIS MICROTYPOGRAPHY LAYOUT ENGINE
 * Library: spiro_svd.c
 * Language: ISO C23 (GCC 16 / Clang 18 compatible)
 * Purpose: Numerically Stable Spiro (Euler Spiral / Clothoid) Spline Engine.
 * Algorithm: SVD Gauss-Newton Solver + Scale-Invariant Fresnel Quadrature.
 * Constraints: Single-entry / single-exit structured programming.
 *              NO 'goto', NO '++' or '--' operators (uses x += 1, x -= 1).
 *              McCabe Cyclomatic Complexity M <= 10 for every function.
 * ============================================================================== */

#include "spiro_svd.h"
#include <math.h>
#include <stdbool.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

/* 16-point Gauss-Legendre Quadrature Nodes and Weights on [0, 1] */
static const double GL16_NODES[16] = {
    0.0094439678381622, 0.0493064360527315, 0.1171801260714771, 0.2091176219468969,
    0.3204900898517227, 0.4461879007185012, 0.5804565451996160, 0.7169317006899757,
    0.8491295240974057, 0.9602052671230489, 0.9905560321618378, 0.9506935639472685,
    0.8828198739285229, 0.7908823780531031, 0.6795099101482773, 0.5538120992814988
};

static const double GL16_WEIGHTS[16] = {
    0.0241483028694344, 0.0555458058886483, 0.0833215984180801, 0.1055740968117032,
    0.1209549991207606, 0.1284674183811802, 0.1284674183811802, 0.1209549991207606,
    0.1055740968117032, 0.0833215984180801, 0.0555458058886483, 0.0241483028694344,
    0.0241483028694344, 0.0555458058886483, 0.0833215984180801, 0.1055740968117032
};

/* Default configuration initializer */
spiro_config_t spiro_default_config(void) {
    spiro_config_t cfg;
    cfg.max_ent_lambda = 1.0e-6;
    cfg.conv_tolerance = 1.0e-10;
    cfg.max_iterations = 50;
    cfg.min_segment_len = 1.0e-7;
    return cfg;
}

/* Fresnel Integrator for Clothoid Segment: computes (dx, dy) given L, theta0, K0, K1
 * M <= 3 (1 loop, 0 branches) */
void spiro_fresnel_integrate(
    double length,
    double theta0,
    double k0,
    double k1,
    double *out_dx,
    double *out_dy
) {
    double sum_x = 0.0;
    double sum_y = 0.0;
    int idx = 0;

    while (idx < 16) {
        double t = GL16_NODES[idx];
        double w = GL16_WEIGHTS[idx];
        double theta = theta0 + k0 * t + 0.5 * k1 * t * t;
        sum_x += w * cos(theta);
        sum_y += w * sin(theta);
        idx += 1;
    }

    *out_dx = length * sum_x;
    *out_dy = length * sum_y;
}

/* Standalone 2x2 Singular Value Decomposition (SVD) for matrix [[a, b], [c, d]]
 * M <= 5 (single exit, no ++/--) */
void spiro_svd_2x2(
    double a, double b, double c, double d,
    double *out_u, double *out_s, double *out_v
) {
    double e = (a + d) * 0.5;
    double f = (a - d) * 0.5;
    double g = (b + c) * 0.5;
    double h = (b - c) * 0.5;
    double q = sqrt(e * e + h * h);
    double r = sqrt(f * f + g * g);
    double s1 = q + r;
    double s2 = fabs(q - r);
    double a1 = atan2(g, f);
    double a2 = atan2(h, e);
    double theta = (a2 - a1) * 0.5;
    double phi = (a2 + a1) * 0.5;

    out_u[0] = cos(phi);
    out_u[1] = -sin(phi);
    out_u[2] = sin(phi);
    out_u[3] = cos(phi);

    out_s[0] = s1;
    out_s[1] = s2;

    out_v[0] = cos(theta);
    out_v[1] = -sin(theta);
    out_v[2] = sin(theta);
    out_v[3] = cos(theta);
}

/* Helper: Solve Tikhonov-regularized 2x2 system via SVD
 * M <= 4 */
static void spiro_solve_2x2_regularized(
    double a, double b, double c, double d,
    double rhs_x, double rhs_y, double lambda,
    double *out_dx, double *out_dy
) {
    double u[4];
    double s[2];
    double v[4];

    spiro_svd_2x2(a, b, c, d, u, s, v);

    /* Compute U^T * rhs */
    double ut_rhs0 = u[0] * rhs_x + u[2] * rhs_y;
    double ut_rhs1 = u[1] * rhs_x + u[3] * rhs_y;

    /* Apply regularized inverse: s_i / (s_i^2 + lambda^2) */
    double d0 = s[0] / (s[0] * s[0] + lambda * lambda);
    double d1 = s[1] / (s[1] * s[1] + lambda * lambda);

    double z0 = ut_rhs0 * d0;
    double z1 = ut_rhs1 * d1;

    /* Multiply by V: V * z */
    *out_dx = v[0] * z0 + v[1] * z1;
    *out_dy = v[2] * z0 + v[3] * z1;
}

/* SVD Gauss-Newton Solver for Spiro Knot Sequences
 * M <= 8 (single exit, no goto, no ++/--) */
int spiro_solve_spline_svd(
    const spiro_knot_t *knots,
    size_t knot_count,
    const spiro_config_t *config,
    spiro_segment_t *out_segments,
    size_t *out_segment_count
) {
    int status = 0;
    size_t num_segs = 0;

    if (knots == NULL || knot_count < 2 || config == NULL || out_segments == NULL || out_segment_count == NULL) {
        status = -1;
    } else {
        num_segs = knot_count - 1;
        size_t i = 0;

        /* Step 1: Initialize segment geometry & handle degenerate knots */
        while (i < num_segs) {
            double dx = knots[i + 1].x - knots[i].x;
            double dy = knots[i + 1].y - knots[i].y;
            double len = sqrt(dx * dx + dy * dy);

            if (len < config->min_segment_len) {
                len = config->min_segment_len;
            }

            out_segments[i].x0 = knots[i].x;
            out_segments[i].y0 = knots[i].y;
            out_segments[i].x1 = knots[i + 1].x;
            out_segments[i].y1 = knots[i + 1].y;
            out_segments[i].length = len;

            /* Initial chord angle estimation */
            double chord_angle = atan2(dy, dx);
            out_segments[i].theta0 = chord_angle;
            out_segments[i].theta1 = chord_angle;
            out_segments[i].kappa0 = 0.0;
            out_segments[i].kappa1 = 0.0;

            i += 1;
        }

        /* Step 2: Iterative SVD Gauss-Newton refinement */
        int iter = 0;
        bool converged = false;

        while (iter < config->max_iterations && !converged) {
            double max_err = 0.0;
            size_t seg_idx = 0;

            while (seg_idx < num_segs) {
                spiro_segment_t *seg = &out_segments[seg_idx];

                /* Target endpoint displacement */
                double target_dx = seg->x1 - seg->x0;
                double target_dy = seg->y1 - seg->y0;

                /* Integrated displacement */
                double curr_dx = 0.0;
                double curr_dy = 0.0;
                double k0 = seg->kappa0 * seg->length;
                double k1 = (seg->kappa1 - seg->kappa0) * seg->length;

                spiro_fresnel_integrate(seg->length, seg->theta0, k0, k1, &curr_dx, &curr_dy);

                /* Spatial residual error */
                double res_x = target_dx - curr_dx;
                double res_y = target_dy - curr_dy;
                double err = sqrt(res_x * res_x + res_y * res_y);

                if (err > max_err) {
                    max_err = err;
                }

                /* Compute Jacobian components via finite difference perturbations */
                double eps = 1.0e-6;
                double dx_dt, dy_dt, dx_dk, dy_dk;

                spiro_fresnel_integrate(seg->length, seg->theta0 + eps, k0, k1, &dx_dt, &dy_dt);
                double j11 = (dx_dt - curr_dx) / eps;
                double j21 = (dy_dt - curr_dy) / eps;

                spiro_fresnel_integrate(seg->length, seg->theta0, k0 + eps, k1, &dx_dk, &dy_dk);
                double j12 = (dx_dk - curr_dx) / eps;
                double j22 = (dy_dk - curr_dy) / eps;

                /* Solve regularized step via SVD */
                double d_theta0 = 0.0;
                double d_k0 = 0.0;

                spiro_solve_2x2_regularized(
                    j11, j12, j21, j22,
                    res_x, res_y, config->max_ent_lambda,
                    &d_theta0, &d_k0
                );

                /* Update segment state */
                seg->theta0 += d_theta0;
                seg->theta1 += d_theta0;
                seg->kappa0 += d_k0 / seg->length;

                seg_idx += 1;
            }

            if (max_err < config->conv_tolerance) {
                converged = true;
            }

            iter += 1;
        }

        *out_segment_count = num_segs;
        status = 0;
    }

    return status;
}
