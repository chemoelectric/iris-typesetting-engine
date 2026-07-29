! ==============================================================================
! IRIS MICROTYPOGRAPHY LAYOUT ENGINE
! Module: spiro_lapack_bridge_mod.f90
! Language: Fortran 2008 (ISO/IEC 1539-1:2010, GCC 16 compatible)
! Purpose: LAPACK DGESVD Bridge Module for Spiro Spline Jacobian Inversion.
! Constraints: Single-entry / single-exit structured programming.
!              NO 'goto', McCabe Cyclomatic Complexity M <= 10 for every routine.
! ==============================================================================

module spiro_lapack_bridge_mod
  use, intrinsic :: iso_fortran_env, only: int32, real64
  implicit none
  private

  public :: spiro_solve_lapack_svd_f08

  interface
    subroutine dgesvd(jobu, jobvt, m, n, a, lda, s, u, ldu, vt, ldvt, work, lwork, info)
      import :: int32, real64
      character(len=1), intent(in) :: jobu, jobvt
      integer(int32), intent(in)   :: m, n, lda, ldu, ldvt, lwork
      real(real64), intent(inout)  :: a(lda, *)
      real(real64), intent(out)    :: s(*), u(ldu, *), vt(ldvt, *), work(*)
      integer(int32), intent(out)  :: info
    end subroutine dgesvd
  end interface

  interface
    subroutine dgemv(trans, m, n, alpha, a, lda, x, incx, beta, y, incy)
      import :: int32, real64
      character(len=1), intent(in) :: trans
      integer(int32), intent(in)   :: m, n, lda, incx, incy
      real(real64), intent(in)     :: alpha, beta
      real(real64), intent(in)     :: a(lda, *), x(*)
      real(real64), intent(inout)  :: y(*)
    end subroutine dgemv
  end interface

contains

  ! LAPACK DGESVD Regularized Step Solver
  ! Single exit, M <= 6
  subroutine spiro_solve_lapack_svd_f08(jacobian, residual, m, n, lambda, out_step, status)
    integer(int32), intent(in)  :: m, n
    real(real64), intent(in)    :: jacobian(m, n)
    real(real64), intent(in)    :: residual(m)
    real(real64), intent(in)    :: lambda
    real(real64), intent(out)   :: out_step(n)
    integer(int32), intent(out) :: status

    real(real64), allocatable   :: a_copy(:,:), s_vals(:), u_mat(:,:), vt_mat(:,:), work(:), ut_res(:), z(:)
    real(real64)                :: work_query(1), reg_inv, sum_v
    integer(int32)              :: min_mn, lwork, info, i, j, k, r, c

    status = 0
    min_mn = min(m, n)

    allocate(a_copy(m, n))
    allocate(s_vals(min_mn))
    allocate(u_mat(m, m))
    allocate(vt_mat(n, n))

    a_copy = jacobian

    ! Query workspace size
    lwork = -1
    call dgesvd('A', 'A', m, n, a_copy, m, s_vals, u_mat, m, vt_mat, n, work_query, lwork, info)

    lwork = int(work_query(1), int32)
    if (lwork < 1) then
      lwork = 5 * max(m, n)
    end if

    allocate(work(lwork))

    ! Compute SVD via LAPACK
    call dgesvd('A', 'A', m, n, a_copy, m, s_vals, u_mat, m, vt_mat, n, work, lwork, info)

    if (info /= 0) then
      status = -2
    else
      allocate(ut_res(m))
      allocate(z(n))
      z = 0.0_real64

#ifdef HAVE_BLAS
      ! Compute U^T * residual using BLAS DGEMV
      call dgemv('T', m, m, 1.0_real64, u_mat, m, residual, 1, 0.0_real64, ut_res, 1)
#else
      ! Compute U^T * residual
      do i = 1, m
        ut_res(i) = dot_product(u_mat(:, i), residual)
      end do
#endif

      ! Apply Tikhonov / Jaynesian MaxEnt regularization
      do k = 1, min_mn
        reg_inv = s_vals(k) / (s_vals(k) * s_vals(k) + lambda * lambda)
        z(k) = ut_res(k) * reg_inv
      end do

#ifdef HAVE_BLAS
      ! Compute out_step = - V * z = - VT^T * z using BLAS DGEMV
      call dgemv('T', min_mn, n, -1.0_real64, vt_mat, n, z, 1, 0.0_real64, out_step, 1)
#else
      ! Compute out_step = - V * z = - VT^T * z
      do c = 1, n
        sum_v = 0.0_real64
        do r = 1, min_mn
          sum_v = sum_v + vt_mat(r, c) * z(r)
        end do
        out_step(c) = -sum_v
      end do
#endif

      deallocate(ut_res)
      deallocate(z)
      status = 0
    end if

    deallocate(a_copy)
    deallocate(s_vals)
    deallocate(u_mat)
    deallocate(vt_mat)
    deallocate(work)
  end subroutine spiro_solve_lapack_svd_f08

end module spiro_lapack_bridge_mod
