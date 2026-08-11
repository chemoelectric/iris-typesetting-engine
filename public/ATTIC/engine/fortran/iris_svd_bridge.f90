!===============================================================================
! Module: iris_svd_bridge
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010, GCC 16 compatible)
! Architecture: Procedure Pointer & Abstract Interface Bridge for SVD Solvers
!               (Defaults to Pure Fortran Fallback, allows LAPACK/Vendor binding)
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
module iris_svd_bridge
  use, intrinsic :: iso_fortran_env, only: int32, real64
  use iris_svd_fallback, only: iris_svd_fallback_solve
  implicit none
  private

  ! Abstract interface for SVD solvers
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

  ! LAPACK C/Fortran interface for DGESVD
  interface
    subroutine dgesvd(jobu, jobvt, m, n, a, lda, s, u, ldu, vt, ldvt, work, lwork, info)
      import :: int32, real64
      character(len=1), intent(in) :: jobu, jobvt
      integer(kind=int32), intent(in) :: m, n, lda, ldu, ldvt, lwork
      real(kind=real64), intent(inout) :: a(lda, *)
      real(kind=real64), intent(out) :: s(*), u(ldu, *), vt(ldvt, *), work(*)
      integer(kind=int32), intent(out) :: info
    end subroutine dgesvd
  end interface

  ! BLAS C/Fortran interface for DGEMV
  interface
    subroutine dgemv(trans, m, n, alpha, a, lda, x, incx, beta, y, incy)
      import :: int32, real64
      character(len=1), intent(in) :: trans
      integer(kind=int32), intent(in) :: m, n, lda, incx, incy
      real(kind=real64), intent(in) :: alpha, beta
      real(kind=real64), intent(in) :: a(lda, *), x(*)
      real(kind=real64), intent(inout) :: y(*)
    end subroutine dgemv
  end interface

  ! Procedure pointer defaulting to LAPACK solver if available, otherwise pure Fortran fallback
#ifdef HAVE_LAPACK
  procedure(svd_solver_interface), pointer, save :: active_svd_solver => iris_svd_lapack_solve
#else
  procedure(svd_solver_interface), pointer, save :: active_svd_solver => iris_svd_fallback_solve
#endif

  ! Public API
  public :: svd_solver_interface
  public :: iris_svd_set_solver
  public :: iris_svd_reset_to_fallback
  public :: iris_svd_use_lapack
  public :: iris_svd_lapack_solve
  public :: iris_svd_solve

contains

  !-----------------------------------------------------------------------------
  ! Set custom SVD solver procedure pointer
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine iris_svd_set_solver(proc_ptr)
    procedure(svd_solver_interface) :: proc_ptr
    active_svd_solver => proc_ptr
  end subroutine iris_svd_set_solver

  !-----------------------------------------------------------------------------
  ! Reset SVD solver to pure Fortran fallback
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine iris_svd_reset_to_fallback()
    active_svd_solver => iris_svd_fallback_solve
  end subroutine iris_svd_reset_to_fallback

  !-----------------------------------------------------------------------------
  ! LAPACK DGESVD SVD Solver Bridge
  ! Single-entry / single-exit implementation (M <= 5)
  !-----------------------------------------------------------------------------
  subroutine iris_svd_lapack_solve(n, A_in, b, x, singular_tol, status)
    integer(kind=int32), intent(in)   :: n
    real(kind=real64), intent(in)     :: A_in(n, n)
    real(kind=real64), intent(in)     :: b(n)
    real(kind=real64), intent(out)    :: x(n)
    real(kind=real64), intent(in)     :: singular_tol
    integer(kind=int32), intent(out)  :: status

    real(kind=real64), allocatable   :: a_copy(:,:), s_vals(:), u_mat(:,:), vt_mat(:,:), work(:), ut_b(:), z(:)
    real(kind=real64)                :: work_query(1)
    integer(kind=int32)              :: lwork, info, i, j

    status = 0
    allocate(a_copy(n, n))
    allocate(s_vals(n))
    allocate(u_mat(n, n))
    allocate(vt_mat(n, n))
    allocate(ut_b(n))
    allocate(z(n))

    a_copy = A_in

    ! Query LAPACK workspace size
    lwork = -1
    call dgesvd('A', 'A', n, n, a_copy, n, s_vals, u_mat, n, vt_mat, n, work_query, lwork, info)

    lwork = int(work_query(1), int32)
    if (lwork < 1) lwork = 5 * n
    allocate(work(lwork))

    ! Call LAPACK DGESVD
    call dgesvd('A', 'A', n, n, a_copy, n, s_vals, u_mat, n, vt_mat, n, work, lwork, info)

    if (info /= 0) then
      status = -10
    else
#ifdef HAVE_BLAS
      ! Compute U^T * b using BLAS DGEMV
      call dgemv('T', n, n, 1.0_real64, u_mat, n, b, 1, 0.0_real64, ut_b, 1)
#else
      ! Compute U^T * b
      do i = 1, n
        ut_b(i) = dot_product(u_mat(:, i), b)
      end do
#endif

      ! Apply pseudo-inverse
      do i = 1, n
        if (s_vals(i) > singular_tol) then
          z(i) = ut_b(i) / s_vals(i)
        else
          z(i) = 0.0_real64
        end if
      end do

#ifdef HAVE_BLAS
      ! x = V * z = VT^T * z using BLAS DGEMV
      call dgemv('T', n, n, 1.0_real64, vt_mat, n, z, 1, 0.0_real64, x, 1)
#else
      ! x = V * z = VT^T * z
      do i = 1, n
        x(i) = 0.0_real64
        do j = 1, n
          x(i) = x(i) + vt_mat(j, i) * z(j)
        end do
      end do
#endif
    end if

    deallocate(a_copy, s_vals, u_mat, vt_mat, ut_b, z, work)
  end subroutine iris_svd_lapack_solve

  !-----------------------------------------------------------------------------
  ! Switch active solver to LAPACK DGESVD bridge
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine iris_svd_use_lapack()
    active_svd_solver => iris_svd_lapack_solve
  end subroutine iris_svd_use_lapack

  !-----------------------------------------------------------------------------
  ! Dispatch SVD solve through active procedure pointer
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine iris_svd_solve(n, A_in, b, x, singular_tol, status)
    integer(kind=int32), intent(in)   :: n
    real(kind=real64), intent(in)     :: A_in(n, n)
    real(kind=real64), intent(in)     :: b(n)
    real(kind=real64), intent(out)    :: x(n)
    real(kind=real64), intent(in)     :: singular_tol
    integer(kind=int32), intent(out)  :: status

    if (associated(active_svd_solver)) then
      call active_svd_solver(n, A_in, b, x, singular_tol, status)
    else
      call iris_svd_fallback_solve(n, A_in, b, x, singular_tol, status)
    end if
  end subroutine iris_svd_solve

end module iris_svd_bridge
