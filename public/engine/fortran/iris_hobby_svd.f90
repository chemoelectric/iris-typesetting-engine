!===============================================================================
! Module: iris_hobby_svd
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010, GCC 16 compatible)
! Architecture: Extended Hobby Spline Engine with Singular Value Decomposition
!               (SVD) Pseudo-Inverse Solver for Over/Under-Constrained Systems
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
module iris_hobby_svd
  use, intrinsic :: iso_fortran_env, only: int32, real64
  use iris_svd_bridge, only: iris_svd_solve
  implicit none
  private

  ! Public Constants
  integer(kind=int32), parameter, public :: HOBBY_MAX_KNOTS     = 128
  integer(kind=int32), parameter, public :: HOBBY_OK            = 0
  integer(kind=int32), parameter, public :: HOBBY_ERR_TOO_FEW   = -1
  integer(kind=int32), parameter, public :: HOBBY_ERR_TOO_MANY  = -2
  integer(kind=int32), parameter, public :: HOBBY_ERR_SVD_FAIL  = -3

  real(kind=real64), parameter, public   :: HOBBY_DEFAULT_TENSION = 1.0_real64
  real(kind=real64), parameter, public   :: HOBBY_SVD_TOL         = 1.0e-12_real64

  ! Public Derived Types
  public :: hobby_knot_type
  public :: hobby_control_point_type
  public :: hobby_config_type

  ! Public Procedures
  public :: hobby_init_config
  public :: hobby_curvature_func
  public :: hobby_velocity_func
  public :: hobby_svd_solve
  public :: hobby_compute_spline_svd

  type :: hobby_knot_type
    real(kind=real64) :: x = 0.0_real64
    real(kind=real64) :: y = 0.0_real64
    real(kind=real64) :: tension_in = HOBBY_DEFAULT_TENSION
    real(kind=real64) :: tension_out = HOBBY_DEFAULT_TENSION
    real(kind=real64) :: explicit_angle = 0.0_real64
    logical           :: has_explicit_angle = .false.
  end type hobby_knot_type

  type :: hobby_control_point_type
    real(kind=real64) :: z0_x = 0.0_real64, z0_y = 0.0_real64
    real(kind=real64) :: z1_x = 0.0_real64, z1_y = 0.0_real64
    real(kind=real64) :: z2_x = 0.0_real64, z2_y = 0.0_real64
    real(kind=real64) :: z3_x = 0.0_real64, z3_y = 0.0_real64
    real(kind=real64) :: theta = 0.0_real64
    real(kind=real64) :: phi = 0.0_real64
    real(kind=real64) :: alpha = 0.0_real64
    real(kind=real64) :: beta = 0.0_real64
  end type hobby_control_point_type

  type :: hobby_config_type
    real(kind=real64) :: default_tension = HOBBY_DEFAULT_TENSION
    real(kind=real64) :: svd_threshold   = HOBBY_SVD_TOL
    real(kind=real64) :: curl            = 1.0_real64
  end type hobby_config_type

contains

  !-----------------------------------------------------------------------------
  ! Initialize default configuration parameters
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine hobby_init_config(cfg)
    type(hobby_config_type), intent(out) :: cfg

    cfg%default_tension = HOBBY_DEFAULT_TENSION
    cfg%svd_threshold   = HOBBY_SVD_TOL
    cfg%curl            = 1.0_real64
  end subroutine hobby_init_config

  !-----------------------------------------------------------------------------
  ! Hobby velocity scale function f(theta, phi)
  ! Single-entry / single-exit implementation (M <= 2)
  !-----------------------------------------------------------------------------
  function hobby_velocity_func(theta, phi, tension) result(v)
    real(kind=real64), intent(in) :: theta, phi, tension
    real(kind=real64)             :: v
    real(kind=real64)             :: st, ct, sp, cp, num, den, t_val

    st = sin(theta)
    ct = cos(theta)
    sp = sin(phi)
    cp = cos(phi)

    t_val = tension
    if (t_val <= 0.0_real64) t_val = 1.0_real64

    num = 2.0_real64 + sqrt(2.0_real64) * (st - sp / 16.0_real64) * (sp - st / 16.0_real64) * (ct - cp)
    den = (1.0_real64 + 0.5_real64 * (sqrt(5.0_real64) - 1.0_real64) * ct + &
           0.5_real64 * (3.0_real64 - sqrt(5.0_real64)) * cp) * 3.0_real64 * t_val

    if (abs(den) > 1.0e-14_real64) then
      v = num / den
    else
      v = 1.0_real64 / (3.0_real64 * t_val)
    end if
  end function hobby_velocity_func

  !-----------------------------------------------------------------------------
  ! Hobby curvature response metric
  ! Single-entry / single-exit implementation (M <= 1)
  !-----------------------------------------------------------------------------
  function hobby_curvature_func(theta, phi) result(kappa)
    real(kind=real64), intent(in) :: theta, phi
    real(kind=real64)             :: kappa
    real(kind=real64)             :: v_th, v_ph

    v_th = hobby_velocity_func(theta, phi, 1.0_real64)
    v_ph = hobby_velocity_func(phi, theta, 1.0_real64)

    kappa = 2.0_real64 * sin(theta + phi) / (3.0_real64 * v_th * v_ph)
  end function hobby_curvature_func

  !-----------------------------------------------------------------------------
  ! SVD Linear System Solver Bridge Dispatch
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine hobby_svd_solve(n, A_in, b, x, singular_tol, status)
    integer(kind=int32), intent(in)   :: n
    real(kind=real64), intent(in)     :: A_in(n, n)
    real(kind=real64), intent(in)     :: b(n)
    real(kind=real64), intent(out)    :: x(n)
    real(kind=real64), intent(in)     :: singular_tol
    integer(kind=int32), intent(out)  :: status

    call iris_svd_solve(n, A_in, b, x, singular_tol, status)
  end subroutine hobby_svd_solve

  !-----------------------------------------------------------------------------
  ! Compute Extended Hobby Spline using SVD Angle Solver
  ! Single-entry / single-exit implementation (M <= 7)
  !-----------------------------------------------------------------------------
  subroutine hobby_compute_spline_svd(knots, n, is_closed, cfg, controls, status)
    type(hobby_knot_type), intent(in)           :: knots(n)
    integer(kind=int32), intent(in)             :: n
    logical, intent(in)                         :: is_closed
    type(hobby_config_type), intent(in)         :: cfg
    type(hobby_control_point_type), intent(out) :: controls(n)
    integer(kind=int32), intent(out)            :: status

    integer(kind=int32) :: i, num_eq, num_seg
    real(kind=real64)   :: d(n), psi(n)
    real(kind=real64)   :: A(n, n), b(n), theta_vec(n), phi_vec(n)
    real(kind=real64)   :: dx, dy, dist, th, ph, v_alpha, v_beta

    status = HOBBY_OK

    if (n < 2) then
      status = HOBBY_ERR_TOO_FEW
    else if (n > HOBBY_MAX_KNOTS) then
      status = HOBBY_ERR_TOO_MANY
    else
      num_seg = n - 1
      if (is_closed) num_seg = n

      ! Compute chord vectors, distances, and chord angles (psi)
      do i = 1, num_seg
        if (i < n) then
          dx = knots(i + 1)%x - knots(i)%x
          dy = knots(i + 1)%y - knots(i)%y
        else
          dx = knots(1)%x - knots(n)%x
          dy = knots(1)%y - knots(n)%y
        end if
        dist = sqrt(dx * dx + dy * dy)
        if (dist < 1.0e-12_real64) dist = 1.0e-12_real64
        d(i) = dist
        psi(i) = atan2(dy, dx)
      end do

      ! Build linear system A * theta = b for continuity of curvature
      num_eq = num_seg
      A = 0.0_real64
      b = 0.0_real64

      do i = 1, num_eq
        if (is_closed) then
          A(i, i) = 4.0_real64
          if (i < num_eq) then
            A(i, i + 1) = 1.0_real64
            b(i) = 3.0_real64 * (psi(i + 1) - psi(i))
          else
            A(i, 1) = 1.0_real64
            b(i) = 3.0_real64 * (psi(1) - psi(num_eq))
          end if
        else
          ! Open curve boundary conditions
          if (i == 1) then
            A(1, 1) = 2.0_real64 + cfg%curl
            A(1, 2) = 1.0_real64
            b(1) = 0.0_real64
          else if (i == num_eq) then
            A(num_eq, num_eq - 1) = 1.0_real64
            A(num_eq, num_eq) = 2.0_real64 + cfg%curl
            b(num_eq) = 0.0_real64
          else
            A(i, i - 1) = 1.0_real64
            A(i, i) = 4.0_real64
            A(i, i + 1) = 1.0_real64
            b(i) = 3.0_real64 * (psi(i + 1) - psi(i - 1))
          end if
        end if

        ! Apply explicit knot angle constraints if specified
        if (knots(i)%has_explicit_angle) then
          A(i, :) = 0.0_real64
          A(i, i) = 1.0_real64
          b(i) = knots(i)%explicit_angle - psi(i)
        end if
      end do

      ! Solve system using Jacobi SVD pseudo-inverse
      call hobby_svd_solve(num_eq, A, b, theta_vec, cfg%svd_threshold, status)

      if (status == HOBBY_OK) then
        ! Compute phi_vec from theta_vec and chord differences
        do i = 1, num_seg
          if (i < num_seg) then
            phi_vec(i) = -theta_vec(i + 1) + 2.0_real64 * (psi(i + 1) - psi(i))
          else if (is_closed) then
            phi_vec(i) = -theta_vec(1) + 2.0_real64 * (psi(1) - psi(i))
          else
            phi_vec(i) = -theta_vec(i)
          end if
        end do

        ! Construct control points z0, z1, z2, z3 for each segment
        do i = 1, num_seg
          th = theta_vec(i)
          ph = phi_vec(i)

          v_alpha = hobby_velocity_func(th, ph, knots(i)%tension_out)
          v_beta  = hobby_velocity_func(ph, th, knots(i)%tension_in)

          controls(i)%theta = th
          controls(i)%phi   = ph
          controls(i)%alpha = v_alpha * d(i)
          controls(i)%beta  = v_beta * d(i)

          ! z0 = knot i
          controls(i)%z0_x = knots(i)%x
          controls(i)%z0_y = knots(i)%y

          ! z1 = z0 + alpha * (cos(psi + th), sin(psi + th))
          controls(i)%z1_x = knots(i)%x + controls(i)%alpha * cos(psi(i) + th)
          controls(i)%z1_y = knots(i)%y + controls(i)%alpha * sin(psi(i) + th)

          ! z3 = knot i+1
          if (i < n) then
            controls(i)%z3_x = knots(i + 1)%x
            controls(i)%z3_y = knots(i + 1)%y
          else
            controls(i)%z3_x = knots(1)%x
            controls(i)%z3_y = knots(1)%y
          end if

          ! z2 = z3 - beta * (cos(psi - ph), sin(psi - ph))
          controls(i)%z2_x = controls(i)%z3_x - controls(i)%beta * cos(psi(i) - ph)
          controls(i)%z2_y = controls(i)%z3_y - controls(i)%beta * sin(psi(i) - ph)
        end do
      end if
    end if
  end subroutine hobby_compute_spline_svd

end module iris_hobby_svd
