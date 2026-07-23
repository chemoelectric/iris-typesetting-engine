/* ==============================================================================
 * IRIS MICROTYPOGRAPHY LAYOUT ENGINE
 * Library: spiro_lapack_bridge.c
 * Language: ISO C23 (GCC 16 / Clang 18 compatible)
 * Purpose: Optional LAPACK (dgesvd) Bridge for Spiro Spline Solvers.
 * Constraints: Single-entry / single-exit structured programming.
 *              NO 'goto', NO '++' or '--' operators (uses x += 1, x -= 1).
 *              McCabe Cyclomatic Complexity M <= 10 for every function.
 * ============================================================================== */

#include "spiro_svd.h"
#include <stdlib.h>
#include <math.h>

/* Fortran LAPACK DGESVD declaration */
extern void dgesvd_(
    const char *jobu, const char *jobvt,
    const int *m, const int *n,
    double *a, const int *lda,
    double *s,
    double *u, const int *ldu,
    double *vt, const int *ldvt,
    double *work, const int *lwork,
    int *info
);

/* LAPACK-backed SVD Gauss-Newton solver for M-by-N Jacobian systems
 * M <= 8 (single exit, no goto, no ++/--) */
int spiro_solve_lapack_svd(
    const double *jacobian,
    const double *residual,
    int rows_m,
    int cols_n,
    double lambda,
    double *out_step
) {
    int status = 0;

    if (jacobian == NULL || residual == NULL || out_step == NULL || rows_m <= 0 || cols_n <= 0) {
        status = -1;
    } else {
        char jobu = 'A';
        char jobvt = 'A';
        int m = rows_m;
        int n = cols_n;
        int lda = m;
        int ldu = m;
        int ldvt = n;
        int info = 0;

        size_t size_a = (size_t)(m * n);
        size_t size_u = (size_t)(m * m);
        size_t size_vt = (size_t)(n * n);
        size_t min_mn = (size_t)(m < n ? m : n);

        double *a_copy = (double *)malloc(size_a * sizeof(double));
        double *s_vals = (double *)malloc(min_mn * sizeof(double));
        double *u_mat = (double *)malloc(size_u * sizeof(double));
        double *vt_mat = (double *)malloc(size_vt * sizeof(double));

        /* Workspace query */
        int lwork = -1;
        double work_query = 0.0;

        size_t idx = 0;
        while (idx < size_a) {
            a_copy[idx] = jacobian[idx];
            idx += 1;
        }

        dgesvd_(&jobu, &jobvt, &m, &n, a_copy, &lda, s_vals, u_mat, &ldu, vt_mat, &ldvt, &work_query, &lwork, &info);

        lwork = (int)work_query;
        if (lwork < 1) {
            lwork = 5 * (m > n ? m : n);
        }

        double *work = (double *)malloc((size_t)lwork * sizeof(double));

        /* Execute DGESVD */
        dgesvd_(&jobu, &jobvt, &m, &n, a_copy, &lda, s_vals, u_mat, &ldu, vt_mat, &ldvt, work, &lwork, &info);

        if (info != 0) {
            status = -2;
        } else {
            /* Compute Tikhonov regularized step: dx = - V * diag(s_i / (s_i^2 + lambda^2)) * U^T * residual */
            double *ut_res = (double *)calloc((size_t)m, sizeof(double));
            int i = 0;

            while (i < m) {
                double sum = 0.0;
                int j = 0;
                while (j < m) {
                    /* Column-major U matrix */
                    sum += u_mat[(size_t)(j * m + i)] * residual[j];
                    j += 1;
                }
                ut_res[i] = sum;
                i += 1;
            }

            double *z = (double *)calloc((size_t)n, sizeof(double));
            int k = 0;
            while (k < (int)min_mn) {
                double reg_inv = s_vals[k] / (s_vals[k] * s_vals[k] + lambda * lambda);
                z[k] = ut_res[k] * reg_inv;
                k += 1;
            }

            /* Out_step = V * z = VT^T * z */
            int c = 0;
            while (c < n) {
                double sum_v = 0.0;
                int r = 0;
                while (r < (int)min_mn) {
                    sum_v += vt_mat[(size_t)(c * n + r)] * z[r];
                    r += 1;
                }
                out_step[c] = -sum_v;
                c += 1;
            }

            free(ut_res);
            free(z);
            status = 0;
        }

        free(a_copy);
        free(s_vals);
        free(u_mat);
        free(vt_mat);
        free(work);
    }

    return status;
}
