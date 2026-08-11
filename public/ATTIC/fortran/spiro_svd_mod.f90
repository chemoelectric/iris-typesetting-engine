! ==============================================================================
! IRIS MICROTYPOGRAPHY LAYOUT ENGINE
! Module: spiro_svd_mod.f90
! Language: Fortran 2008 (ISO/IEC 1539-1:2010, GCC 16 compatible)
! Purpose: Numerically Stable Spiro (Euler Spiral / Clothoid) Spline Engine.
! Algorithm: SVD Gauss-Newton Solver + Scale-Invariant Fresnel Quadrature.
! Constraints: Enforces strict structured programming (single-entry / single-exit).
!              NO 'goto', McCabe Cyclomatic Complexity M <= 10 for every routine.
! ==============================================================================

module spiro_svd_mod
  use, intrinsic :: iso_fortran_env, only: int32, real64
  implicit none
  private

  public :: spiro_knot_t, spiro_segment_t, spiro_config_t
  public :: spiro_fresnel_integrate, spiro_svd_2x2, spiro_solve_spline_svd

  ! Knot type definitions
  integer(int32), parameter, public :: SPIRO_KNOT_SMOOTH = 0
  integer(int32), parameter, public :: SPIRO_KNOT_CORNER = 1
  integer(int32), parameter, public :: SPIRO_KNOT_LEFT   = 2
  integer(int32), parameter, public :: SPIRO_KNOT_RIGHT  = 3
  integer(int32), parameter, public :: SPIRO_KNOT_END    = 4

  ! Knot structure
  type :: spiro_knot_t
    real(real64)   :: x = 0.0_real64
    real(real64)   :: y = 0.0_real64
    integer(int32) :: knot_type = SPIRO_KNOT_SMOOTH
  end type spiro_knot_t

  ! Segment structure
  type :: spiro_segment_t
    real(real64) :: x0 = 0.0_real64
    real(real64) :: y0 = 0.0_real64
    real(real64) :: x1 = 0.0_real64
    real(real64) :: y1 = 0.0_real64
    real(real64) :: theta0 = 0.0_real64
    real(real64) :: theta1 = 0.0_real64
    real(real64) :: kappa0 = 0.0_real64
    real(real64) :: kappa1 = 0.0_real64
    real(real64) :: length = 0.0_real64
  end type spiro_segment_t

  ! Configuration parameters
  type :: spiro_config_t
    real(real64)   :: max_ent_lambda   = 1.0e-6_real64
    real(real64)   :: conv_tolerance   = 1.0e-10_real64
    integer(int32) :: max_iterations   = 50
    real(real64)   :: min_segment_len  = 1.0e-7_real64
  end type spiro_config_t

  ! 16-point Gauss-Legendre Quadrature Nodes & Weights
  real(real64), parameter :: GL16_NODES(16) = [ &
    0.0094439678381622_real64, 0.0493064360527315_real64, 0.1171801260714771_real64, 0.2091176219468969_real64, &
    0.3204900898517227_real64, 0.4461879007185012_real64, 0.5804565451996160_real64, 0.7169317006899757_real64, &
    0.8491295240974057_real64, 0.9602052671230489_real64, 0.9905560321618378_real64, 0.9506935639472685_real64, &
    0.8828198739285229_real64, 0.7908823780531031_real64, 0.6795099101482773_real64, 0.5538120992814988_real64  &
  ]

  real(real64), parameter :: GL16_WEIGHTS(16) = [ &
    0.0241483028694344_real64, 0.0555458058886483_real64, 0.0833215984180801_real64, 0.1055740968117032_real64, &
    0.1209549991207606_real64, 0.1284674183811802_real64, 0.1284674183811802_real64, 0.1209549991207606_real64, &
    0.1055740968117032_real64, 0.0833215984180801_real64, 0.0555458058886483_real64, 0.0241483028694344_real64, &
    0.0241483028694344_real64, 0.0555458058886483_real64, 0.0833215984180801_real64, 0.1055740968117032_real64  &
  ]

contains

  ! Fresnel Integrator for Clothoid Segment: computes (dx, dy) given length, theta0, k0, k1
  ! Single exit, M <= 2
  subroutine spiro_fresnel_integrate(length, theta0, k0, k1, out_dx, out_dy)
    real(real64), intent(in)  :: length, theta0, k0, k1
    real(real64), intent(out) :: out_dx, out_dy
    real(real64) :: sum_x, sum_y, t, w, theta
    integer(int32) :: idx

    sum_x = 0.0_real64
    sum_y = 0.0_real64

    do idx = 1, 16
      t = GL16_NODES(idx)
      w = GL16_WEIGHTS(idx)
      theta = theta0 + k0 * t + 0.5_real64 * k1 * t * t
      sum_x = sum_x + w * cos(theta)
      sum_y = sum_y + w * sin(theta)
    end do

    out_dx = length * sum_x
    out_dy = length * sum_y
  end subroutine spiro_fresnel_integrate

  ! Standalone 2x2 Singular Value Decomposition (SVD) for matrix [[a, b], [c, d]]
  ! Single exit, M <= 4
  subroutine spiro_svd_2x2(a, b, c, d, out_u, out_s, out_v)
    real(real64), intent(in)  :: a, b, c, d
    real(real64), intent(out) :: out_u(4), out_s(2), out_v(4)
    real(real64) :: e, f, g, h, q, r, s1, s2, a1, a2, theta, phi

    e = (a + d) * 0.5_real64
    f = (a - d) * 0.5_real64
    g = (b + c) * 0.5_real64
    h = (b - c) * 0.5_real64
    q = sqrt(e * e + h * h)
    r = sqrt(f * f + g * g)
    s1 = q + r
    s2 = abs(q - r)
    a1 = atan2(g, f)
    a2 = atan2(h, e)
    theta = (a2 - a1) * 0.5_real64
    phi = (a2 + a1) * 0.5_real64

    out_u(1) = cos(phi)
    out_u(2) = -sin(phi)
    out_u(3) = sin(phi)
    out_u(4) = cos(phi)

    out_s(1) = s1
    out_s(2) = s2

    out_v(1) = cos(theta)
    out_v(2) = -sin(theta)
    out_v(3) = sin(theta)
    out_v(4) = cos(theta)
  end subroutine spiro_svd_2x2

  ! Helper: Solve Tikhonov-regularized 2x2 system via SVD
  ! Single exit, M <= 3
  subroutine spiro_solve_2x2_regularized(a, b, c, d, rhs_x, rhs_y, lambda, out_dx, out_dy)
    real(real64), intent(in)  :: a, b, c, d, rhs_x, rhs_y, lambda
    real(real64), intent(out) :: out_dx, out_dy
    real(real64) :: u(4), s(2), v(4)
    real(real64) :: ut_rhs0, ut_rhs1, d0, d1, z0, z1

    call spiro_svd_2x2(a, b, c, d, u, s, v)

    ut_rhs0 = u(1) * rhs_x + u(3) * rhs_y
    ut_rhs1 = u(2) * rhs_x + u(4) * rhs_y

    d0 = s(1) / (s(1) * s(1) + lambda * lambda)
    d1 = s(2) / (s(2) * s(2) + lambda * lambda)

    z0 = ut_rhs0 * d0
    z1 = ut_rhs1 * d1

    out_dx = v(1) * z0 + v(2) * z1
    out_dy = v(3) * z0 + v(4) * z1
  end subroutine spiro_solve_2x2_regularized

  ! SVD Gauss-Newton Solver for Spiro Knot Sequences
  ! Single exit, M <= 8
  subroutine spiro_solve_spline_svd(knots, config, out_segments, status)
    type(spiro_knot_t), intent(in)      :: knots(:)
    type(spiro_config_t), intent(in)    :: config
    type(spiro_segment_t), intent(out)  :: out_segments(:)
    integer(int32), intent(out)         :: status

    integer(int32) :: knot_count, num_segs, i, iter, seg_idx
    real(real64)   :: dx, dy, len, chord_angle, max_err, target_dx, target_dy
    real(real64)   :: curr_dx, curr_dy, k0, k1, res_x, res_y, err
    real(real64)   :: eps, dx_dt, dy_dt, dx_dk, dy_dk, j11, j12, j21, j22, d_theta0, d_k0
    logical        :: converged

    knot_count = size(knots)
    status = 0

    if (knot_count < 2 .or. size(out_segments) < knot_count - 1) then
      status = -1
    else
      num_segs = knot_count - 1

      ! Initialize segment geometry
      do i = 1, num_segs
        dx = knots(i + 1)%x - knots(i)%x
        dy = knots(i + 1)%y - knots(i)%y
        len = sqrt(dx * dx + dy * dy)

        if (len < config%min_segment_len) then
          len = config%min_segment_len
        end if

        out_segments(i)%x0 = knots(i)%x
        out_segments(i)%y0 = knots(i)%y
        out_segments(i)%x1 = knots(i + 1)%x
        out_segments(i)%y1 = knots(i + 1)%y
        out_segments(i)%length = len

        chord_angle = atan2(dy, dx)
        out_segments(i)%theta0 = chord_angle
        out_segments(i)%theta1 = chord_angle
        out_segments(i)%kappa0 = 0.0_real64
        out_segments(i)%kappa1 = 0.0_real64
      end do

      ! Gauss-Newton SVD iteration
      iter = 0
      converged = .false.

      do while (iter < config%max_iterations .and. .not. converged)
        max_err = 0.0_real64

        do seg_idx = 1, num_segs
          target_dx = out_segments(seg_idx)%x1 - out_segments(seg_idx)%x0
          target_dy = out_segments(seg_idx)%y1 - out_segments(seg_idx)%y0

          k0 = out_segments(seg_idx)%kappa0 * out_segments(seg_idx)%length
          k1 = (out_segments(seg_idx)%kappa1 - out_segments(seg_idx)%kappa0) * out_segments(seg_idx)%length

          call spiro_fresnel_integrate(out_segments(seg_idx)%length, out_segments(seg_idx)%theta0, k0, k1, curr_dx, curr_dy)

          res_x = target_dx - curr_dx
          res_y = target_dy - curr_dy
          err = sqrt(res_x * res_x + res_y * res_y)

          if (err > max_err) then
            max_err = err
          end if

          ! Jacobian finite difference perturbations
          eps = 1.0e-6_real64
          call spiro_fresnel_integrate(out_segments(seg_idx)%length, out_segments(seg_idx)%theta0 + eps, k0, k1, dx_dt, dy_dt)
          j11 = (dx_dt - curr_dx) / eps
          j21 = (dy_dt - curr_dy) / eps

          call spiro_fresnel_integrate(out_segments(seg_idx)%length, out_segments(seg_idx)%theta0, k0 + eps, k1, dx_dk, dy_dk)
          j12 = (dx_dk - curr_dx) / eps
          j22 = (dy_dk - curr_dy) / eps

          call spiro_solve_2x2_regularized(j11, j12, j21, j22, res_x, res_y, config%max_ent_lambda, d_theta0, d_k0)

          out_segments(seg_idx)%theta0 = out_segments(seg_idx)%theta0 + d_theta0
          out_segments(seg_idx)%theta1 = out_segments(seg_idx)%theta1 + d_theta0
          out_segments(seg_idx)%kappa0 = out_segments(seg_idx)%kappa0 + d_k0 / out_segments(seg_idx)%length
        end do

        if (max_err < config%conv_tolerance) then
          converged = .true.
        end if

        iter = iter + 1
      end do

      status = 0
    end if
  end subroutine spiro_solve_spline_svd

end module spiro_svd_mod
