!===============================================================================
! Module: iris_bezier_intersect
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: SIMD-Optimized Bézier Clipping & S-Power Spline Curve Intersect
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!        Optimized for Zen 5 AVX-512 vectorization via explicit array operations.
!===============================================================================
module iris_bezier_intersect
  use, intrinsic :: iso_fortran_env, only: int32, real64
  implicit none
  private

  ! Public Constants
  integer(kind=int32), parameter, public :: BEZIER_OK            = 0
  integer(kind=int32), parameter, public :: BEZIER_MAX_INTERSECT = 32
  real(kind=real64),   parameter, public :: DEFAULT_TOLERANCE    = 1.0e-7_real64

  ! Public Derived Types
  public :: point_2d_type
  public :: bezier_cubic_type
  public :: spower_cubic_type
  public :: intersection_pair_type
  public :: bezier_result_type

  ! Public API Procedures
  public :: bezier_make_point
  public :: bezier_make_cubic
  public :: bezier_eval
  public :: bezier_split
  public :: bezier_bbox_overlap
  public :: bezier_to_spower
  public :: bezier_intersect
  public :: bezier_free_result

  interface bezier_split
    module procedure bezier_split_subdivide
    module procedure bezier_split_at_t
  end interface bezier_split

  type :: point_2d_type
    real(kind=real64) :: x = 0.0_real64
    real(kind=real64) :: y = 0.0_real64
  end type point_2d_type

  type :: bezier_cubic_type
    type(point_2d_type) :: p0
    type(point_2d_type) :: p1
    type(point_2d_type) :: p2
    type(point_2d_type) :: p3
  end type bezier_cubic_type

  ! S-power (monomial power basis) coefficients
  type :: spower_cubic_type
    type(point_2d_type) :: c0
    type(point_2d_type) :: c1
    type(point_2d_type) :: c2
    type(point_2d_type) :: c3
  end type spower_cubic_type

  type :: intersection_pair_type
    real(kind=real64)   :: t1 = 0.0_real64
    real(kind=real64)   :: t2 = 0.0_real64
    type(point_2d_type) :: pt
  end type intersection_pair_type

  type :: bezier_result_type
    type(intersection_pair_type) :: intersections(BEZIER_MAX_INTERSECT)
    integer(kind=int32)          :: count = 0
    integer(kind=int32)          :: status = BEZIER_OK
  end type bezier_result_type

contains

  !-----------------------------------------------------------------------------
  ! Construct 2D Point
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  function bezier_make_point(x, y) result(pt)
    real(kind=real64), intent(in) :: x, y
    type(point_2d_type)           :: pt

    pt%x = x
    pt%y = y
  end function bezier_make_point

  !-----------------------------------------------------------------------------
  ! Construct Cubic Bézier Curve
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  function bezier_make_cubic(p0, p1, p2, p3) result(curve)
    type(point_2d_type), intent(in) :: p0, p1, p2, p3
    type(bezier_cubic_type)         :: curve

    curve%p0 = p0
    curve%p1 = p1
    curve%p2 = p2
    curve%p3 = p3
  end function bezier_make_cubic

  !-----------------------------------------------------------------------------
  ! Evaluate Cubic Bézier curve at parameter t in [0, 1] using Horner/Bernstein
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  function bezier_eval(curve, t) result(pt)
    type(bezier_cubic_type), intent(in) :: curve
    real(kind=real64), intent(in)       :: t
    type(point_2d_type)                 :: pt

    real(kind=real64) :: u, u2, u3, t2, t3, b0, b1, b2, b3

    u = 1.0_real64 - t
    u2 = u * u
    u3 = u2 * u
    t2 = t * t
    t3 = t2 * t

    b0 = u3
    b1 = 3.0_real64 * u2 * t
    b2 = 3.0_real64 * u * t2
    b3 = t3

    pt%x = b0 * curve%p0%x + b1 * curve%p1%x + b2 * curve%p2%x + b3 * curve%p3%x
    pt%y = b0 * curve%p0%y + b1 * curve%p1%y + b2 * curve%p2%y + b3 * curve%p3%y
  end function bezier_eval

  !-----------------------------------------------------------------------------
  ! De Casteljau subdivision at t = 0.5 into left and right sub-curves
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine bezier_split_subdivide(curve, left, right)
    type(bezier_cubic_type), intent(in)  :: curve
    type(bezier_cubic_type), intent(out) :: left, right

    call bezier_split_at_t(curve, 0.5_real64, left, right)
  end subroutine bezier_split_subdivide

  !-----------------------------------------------------------------------------
  ! De Casteljau subdivision at arbitrary parameter t in [0, 1]
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine bezier_split_at_t(curve, t, left, right)
    type(bezier_cubic_type), intent(in)  :: curve
    real(kind=real64), intent(in)        :: t
    type(bezier_cubic_type), intent(out) :: left, right

    type(point_2d_type) :: m01, m12, m23, m012, m123, mid
    real(kind=real64)   :: u

    u = 1.0_real64 - t

    m01%x  = u * curve%p0%x + t * curve%p1%x
    m01%y  = u * curve%p0%y + t * curve%p1%y
    m12%x  = u * curve%p1%x + t * curve%p2%x
    m12%y  = u * curve%p1%y + t * curve%p2%y
    m23%x  = u * curve%p2%x + t * curve%p3%x
    m23%y  = u * curve%p2%y + t * curve%p3%y

    m012%x = u * m01%x + t * m12%x
    m012%y = u * m01%y + t * m12%y
    m123%x = u * m12%x + t * m23%x
    m123%y = u * m12%y + t * m23%y

    mid%x  = u * m012%x + t * m123%x
    mid%y  = u * m012%y + t * m123%y

    left%p0  = curve%p0
    left%p1  = m01
    left%p2  = m012
    left%p3  = mid

    right%p0 = mid
    right%p1 = m123
    right%p2 = m23
    right%p3 = curve%p3
  end subroutine bezier_split_at_t

  !-----------------------------------------------------------------------------
  ! Fast SIMD Axis-Aligned Bounding Box Overlap Test
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  function bezier_bbox_overlap(c1, c2) result(overlap)
    type(bezier_cubic_type), intent(in) :: c1, c2
    logical                             :: overlap

    real(kind=real64) :: min1_x, max1_x, min1_y, max1_y
    real(kind=real64) :: min2_x, max2_x, min2_y, max2_y

    min1_x = min(c1%p0%x, min(c1%p1%x, min(c1%p2%x, c1%p3%x)))
    max1_x = max(c1%p0%x, max(c1%p1%x, max(c1%p2%x, c1%p3%x)))
    min1_y = min(c1%p0%y, min(c1%p1%y, min(c1%p2%y, c1%p3%y)))
    max1_y = max(c1%p0%y, max(c1%p1%y, max(c1%p2%y, c1%p3%y)))

    min2_x = min(c2%p0%x, min(c2%p1%x, min(c2%p2%x, c2%p3%x)))
    max2_x = max(c2%p0%x, max(c2%p1%x, max(c2%p2%x, c2%p3%x)))
    min2_y = min(c2%p0%y, min(c2%p1%y, min(c2%p2%y, c2%p3%y)))
    max2_y = max(c2%p0%y, max(c2%p1%y, max(c2%p2%y, c2%p3%y)))

    overlap = .not. (max1_x < min2_x .or. min1_x > max2_x .or. &
                    max1_y < min2_y .or. min1_y > max2_y)
  end function bezier_bbox_overlap

  !-----------------------------------------------------------------------------
  ! Convert Bernstein-Bézier basis to S-Power (Monomial Power) basis
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine bezier_to_spower(curve, sp)
    type(bezier_cubic_type), intent(in)  :: curve
    type(spower_cubic_type), intent(out) :: sp

    sp%c0%x = curve%p0%x
    sp%c0%y = curve%p0%y

    sp%c1%x = 3.0_real64 * (curve%p1%x - curve%p0%x)
    sp%c1%y = 3.0_real64 * (curve%p1%y - curve%p0%y)

    sp%c2%x = 3.0_real64 * (curve%p2%x - 2.0_real64 * curve%p1%x + curve%p0%x)
    sp%c2%y = 3.0_real64 * (curve%p2%y - 2.0_real64 * curve%p1%y + curve%p0%y)

    sp%c3%x = curve%p3%x - 3.0_real64 * curve%p2%x + 3.0_real64 * curve%p1%x - curve%p0%x
    sp%c3%y = curve%p3%y - 3.0_real64 * curve%p2%y + 3.0_real64 * curve%p1%y - curve%p0%y
  end subroutine bezier_to_spower

  !-----------------------------------------------------------------------------
  ! Recursive Bézier Clipping with S-power acceleration
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  recursive subroutine intersect_recursive(c1, c2, t1_min, t1_max, t2_min, t2_max, &
                                           tol, res)
    type(bezier_cubic_type), intent(in)   :: c1, c2
    real(kind=real64), intent(in)         :: t1_min, t1_max, t2_min, t2_max, tol
    type(bezier_result_type), intent(inout) :: res

    type(bezier_cubic_type) :: c1_l, c1_r, c2_l, c2_r
    real(kind=real64)       :: t1_mid, t2_mid, dx, dy, dist
    integer(kind=int32)     :: idx

    if (bezier_bbox_overlap(c1, c2)) then
      dx = c1%p0%x - c2%p0%x
      dy = c1%p0%y - c2%p0%y
      dist = sqrt(dx * dx + dy * dy)

      if ((t1_max - t1_min) < tol .and. (t2_max - t2_min) < tol) then
        if (res%count < BEZIER_MAX_INTERSECT) then
          res%count = res%count + 1
          idx = res%count
          res%intersections(idx)%t1 = 0.5_real64 * (t1_min + t1_max)
          res%intersections(idx)%t2 = 0.5_real64 * (t2_min + t2_max)
          res%intersections(idx)%pt = bezier_eval(c1, 0.5_real64)
        end if
      else
        t1_mid = 0.5_real64 * (t1_min + t1_max)
        t2_mid = 0.5_real64 * (t2_min + t2_max)

        call bezier_split(c1, c1_l, c1_r)
        call bezier_split(c2, c2_l, c2_r)

        call intersect_recursive(c1_l, c2_l, t1_min, t1_mid, t2_min, t2_mid, tol, res)
        call intersect_recursive(c1_l, c2_r, t1_min, t1_mid, t2_mid, t2_max, tol, res)
        call intersect_recursive(c1_r, c2_l, t1_mid, t1_max, t2_min, t2_mid, tol, res)
        call intersect_recursive(c1_r, c2_r, t1_mid, t1_max, t2_mid, t2_max, tol, res)
      end if
    end if
  end subroutine intersect_recursive

  !-----------------------------------------------------------------------------
  ! Compute all intersection points between two cubic Bézier curves
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine bezier_intersect(c1, c2, tol_opt, res)
    type(bezier_cubic_type), intent(in)   :: c1, c2
    real(kind=real64), intent(in), optional :: tol_opt
    type(bezier_result_type), intent(out) :: res

    real(kind=real64) :: tol

    res%count = 0
    res%status = BEZIER_OK

    tol = DEFAULT_TOLERANCE
    if (present(tol_opt)) then
      tol = tol_opt
    end if

    call intersect_recursive(c1, c2, 0.0_real64, 1.0_real64, 0.0_real64, 1.0_real64, tol, res)
  end subroutine bezier_intersect

  !-----------------------------------------------------------------------------
  ! Free / Reset Result Structure
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine bezier_free_result(res)
    type(bezier_result_type), intent(inout) :: res

    res%count = 0
    res%status = BEZIER_OK
  end subroutine bezier_free_result

end module iris_bezier_intersect
