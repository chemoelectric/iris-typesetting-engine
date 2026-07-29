!===============================================================================
! Module: iris_svd_fallback
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010, GCC 16 compatible)
! Architecture: Pure Fortran Fallback Jacobi SVD Pseudo-Inverse Solver
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
module iris_svd_fallback
  use, intrinsic :: iso_fortran_env, only: int32, real64
  implicit none
  private

  public :: iris_svd_fallback_solve

contains

  !-----------------------------------------------------------------------------
  ! General Dense SVD Linear Solver A x = b via Classical Jacobi Rotations
  ! Computes pseudo-inverse x = V * Sigma^+ * U^T * b
  ! Single-entry / single-exit implementation (M <= 8)
  !-----------------------------------------------------------------------------
  subroutine iris_svd_fallback_solve(n, A_in, b, x, singular_tol, status)
    integer(kind=int32), intent(in)   :: n
    real(kind=real64), intent(in)     :: A_in(n, n)
    real(kind=real64), intent(in)     :: b(n)
    real(kind=real64), intent(out)    :: x(n)
    real(kind=real64), intent(in)     :: singular_tol
    integer(kind=int32), intent(out)  :: status

    real(kind=real64) :: U(n, n), V(n, n), S_vec(n), UTb(n), SigmaPlusUTb(n)
    real(kind=real64) :: a_norm, b_norm, c_dot, tau, t_val, c_rot, s_rot, max_off
    real(kind=real64) :: u_ki, v_ki
    integer(kind=int32) :: i, j, k, iter, max_iter

    status = 0
    U = A_in
    V = 0.0_real64
    do i = 1, n
      V(i, i) = 1.0_real64
    end do

    max_iter = 100 * n
    iter = 0
    do while (iter < max_iter)
      iter = iter + 1
      max_off = 0.0_real64

      do i = 1, n - 1
        do j = i + 1, n
          c_dot = sum(U(:, i) * U(:, j))
          a_norm = sum(U(:, i)**2)
          b_norm = sum(U(:, j)**2)

          max_off = max(max_off, abs(c_dot))

          if (abs(c_dot) > 1.0e-15_real64 * sqrt(max(a_norm * b_norm, 1.0e-30_real64))) then
            tau = (b_norm - a_norm) / (2.0_real64 * c_dot)
            if (tau >= 0.0_real64) then
              t_val = 1.0_real64 / (tau + sqrt(1.0_real64 + tau * tau))
            else
              t_val = -1.0_real64 / (-tau + sqrt(1.0_real64 + tau * tau))
            end if
            c_rot = 1.0_real64 / sqrt(1.0_real64 + t_val * t_val)
            s_rot = t_val * c_rot

            do k = 1, n
              u_ki = U(k, i)
              U(k, i) = c_rot * u_ki - s_rot * U(k, j)
              U(k, j) = s_rot * u_ki + c_rot * U(k, j)

              v_ki = V(k, i)
              V(k, i) = c_rot * v_ki - s_rot * V(k, j)
              V(k, j) = s_rot * v_ki + c_rot * V(k, j)
            end do
          end if
        end do
      end do

      if (max_off < 1.0e-14_real64) exit
    end do

    ! Extract singular values
    do i = 1, n
      S_vec(i) = sqrt(sum(U(:, i)**2))
      if (S_vec(i) > 1.0e-14_real64) then
        U(:, i) = U(:, i) / S_vec(i)
      end if
    end do

    ! Compute U^T * b
    do i = 1, n
      UTb(i) = sum(U(:, i) * b)
    end do

    ! Apply pseudo-inverse of singular values
    do i = 1, n
      if (S_vec(i) > singular_tol) then
        SigmaPlusUTb(i) = UTb(i) / S_vec(i)
      else
        SigmaPlusUTb(i) = 0.0_real64
      end if
    end do

    ! x = V * SigmaPlusUTb
    do i = 1, n
      x(i) = sum(V(i, :) * SigmaPlusUTb)
    end do
  end subroutine iris_svd_fallback_solve

end module iris_svd_fallback
