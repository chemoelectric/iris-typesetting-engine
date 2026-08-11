!===============================================================================
! Module: iris_spline_collection
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Piecewise Spline Collection Engine, Pairwise Contour Intersections,
!               Ray-Casting Containment Hierarchy & OpenType Winding Auto-Orientation
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
module iris_spline_collection
  use, intrinsic :: iso_fortran_env, only: int32, real64
  use iris_bezier_intersect, only: point_2d_type, bezier_cubic_type, &
                                   bezier_result_type, bezier_make_point, &
                                   bezier_make_cubic, bezier_intersect
  use iris_spline, only: piecewise_spline_type, spline_self_intersects, &
                         spline_get_rotation, spline_set_rotation, &
                         SPLINE_ROTATION_CCW, SPLINE_ROTATION_CW, &
                         SPLINE_ROTATION_SELF_INTERSECTING, SPLINE_OK
  implicit none
  private

  ! Public Constants
  integer(kind=int32), parameter, public :: COLLECTION_MAX_SPLINES       = 32
  integer(kind=int32), parameter, public :: COLLECTION_MAX_INTERSECTS    = 128
  integer(kind=int32), parameter, public :: COLLECTION_OK                = 0
  integer(kind=int32), parameter, public :: COLLECTION_ERR_EMPTY         = -1
  integer(kind=int32), parameter, public :: COLLECTION_ERR_FULL          = -2
  integer(kind=int32), parameter, public :: COLLECTION_ERR_SELF_INTERSECT = -3
  real(kind=real64),   parameter, public :: DEFAULT_COLL_TOL          = 1.0e-5_real64

  ! Public Derived Types
  public :: collection_intersection_type
  public :: collection_intersect_result_type
  public :: spline_collection_type

  ! Public API Procedures
  public :: collection_init
  public :: collection_add_spline
  public :: collection_get_bbox
  public :: collection_point_in_spline
  public :: collection_find_intersections_internal
  public :: collection_find_intersections_between
  public :: collection_compute_hierarchy
  public :: collection_auto_orient_opentype

  interface collection_get_bbox
    module procedure collection_get_bbox_spline
    module procedure collection_get_bbox_coll
  end interface collection_get_bbox

  type :: collection_intersection_type
    integer(kind=int32) :: spline_idx1 = 0
    integer(kind=int32) :: seg_idx1    = 0
    real(kind=real64)   :: t1          = 0.0_real64
    integer(kind=int32) :: spline_idx2 = 0
    integer(kind=int32) :: seg_idx2    = 0
    real(kind=real64)   :: t2          = 0.0_real64
    type(point_2d_type) :: pt
  end type collection_intersection_type

  type :: collection_intersect_result_type
    type(collection_intersection_type) :: intersections(COLLECTION_MAX_INTERSECTS)
    integer(kind=int32)                :: count = 0
    integer(kind=int32)                :: status = COLLECTION_OK
  end type collection_intersect_result_type

  type :: spline_collection_type
    type(piecewise_spline_type) :: splines(COLLECTION_MAX_SPLINES)
    integer(kind=int32)         :: nesting_levels(COLLECTION_MAX_SPLINES) = 0
    integer(kind=int32)         :: spline_count = 0
  end type spline_collection_type

contains

  !-----------------------------------------------------------------------------
  ! Initialize empty spline collection
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine collection_init(coll)
    type(spline_collection_type), intent(out) :: coll

    coll%spline_count = 0
    coll%nesting_levels = 0
  end subroutine collection_init

  !-----------------------------------------------------------------------------
  ! Add a piecewise spline contour to collection
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine collection_add_spline(coll, spline, status)
    type(spline_collection_type), intent(inout) :: coll
    type(piecewise_spline_type), intent(in)     :: spline
    integer(kind=int32), intent(out)            :: status

    if (coll%spline_count < COLLECTION_MAX_SPLINES) then
      coll%spline_count = coll%spline_count + 1
      coll%splines(coll%spline_count) = spline
      coll%nesting_levels(coll%spline_count) = 0
      status = COLLECTION_OK
    else
      status = COLLECTION_ERR_FULL
    end if
  end subroutine collection_add_spline

  !-----------------------------------------------------------------------------
  ! Calculate tight axis-aligned bounding box for a spline
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine collection_get_bbox_spline(spline, min_x, min_y, max_x, max_y)
    type(piecewise_spline_type), intent(in) :: spline
    real(kind=real64), intent(out)          :: min_x, min_y, max_x, max_y

    integer(kind=int32) :: i
    type(point_2d_type) :: p0, p1, p2, p3

    if (spline%segment_count == 0) then
      min_x = 0.0_real64
      max_x = 0.0_real64
      min_y = 0.0_real64
      max_y = 0.0_real64
    else
      p0 = spline%segments(1)%p0
      min_x = p0%x
      max_x = p0%x
      min_y = p0%y
      max_y = p0%y

      do i = 1, spline%segment_count
        p0 = spline%segments(i)%p0
        p1 = spline%segments(i)%p1
        p2 = spline%segments(i)%p2
        p3 = spline%segments(i)%p3

        min_x = min(min_x, min(p0%x, min(p1%x, min(p2%x, p3%x))))
        max_x = max(max_x, max(p0%x, max(p1%x, max(p2%x, p3%x))))
        min_y = min(min_y, min(p0%y, min(p1%y, min(p2%y, p3%y))))
        max_y = max(max_y, max(p0%y, max(p1%y, max(p2%y, p3%y))))
      end do
    end if
  end subroutine collection_get_bbox_spline

  !-----------------------------------------------------------------------------
  ! Calculate tight axis-aligned bounding box for an entire spline collection
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine collection_get_bbox_coll(coll, min_x, min_y, max_x, max_y)
    type(spline_collection_type), intent(in) :: coll
    real(kind=real64), intent(out)          :: min_x, min_y, max_x, max_y

    integer(kind=int32) :: i
    real(kind=real64)   :: s_min_x, s_min_y, s_max_x, s_max_y

    if (coll%spline_count == 0) then
      min_x = 0.0_real64
      min_y = 0.0_real64
      max_x = 0.0_real64
      max_y = 0.0_real64
    else
      call collection_get_bbox_spline(coll%splines(1), min_x, min_y, max_x, max_y)
      do i = 2, coll%spline_count
        call collection_get_bbox_spline(coll%splines(i), s_min_x, s_min_y, s_max_x, s_max_y)
        min_x = min(min_x, s_min_x)
        min_y = min(min_y, s_min_y)
        max_x = max(max_x, s_max_x)
        max_y = max(max_y, s_max_y)
      end do
    end if
  end subroutine collection_get_bbox_coll

  !-----------------------------------------------------------------------------
  ! Point-in-polygon containment test via ray casting against cubic segments
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  function collection_point_in_spline(spline, pt) result(inside)
    type(piecewise_spline_type), intent(in) :: spline
    type(point_2d_type), intent(in)         :: pt
    logical                                 :: inside

    integer(kind=int32) :: i, crossings
    real(kind=real64)   :: x0, y0, x3, y3

    crossings = 0

    do i = 1, spline%segment_count
      x0 = spline%segments(i)%p0%x
      y0 = spline%segments(i)%p0%y
      x3 = spline%segments(i)%p3%x
      y3 = spline%segments(i)%p3%y

      if (((y0 > pt%y) .neqv. (y3 > pt%y))) then
        if (pt%x < (x3 - x0) * (pt%y - y0) / (y3 - y0 + 1.0e-12_real64) + x0) then
          crossings = crossings + 1
        end if
      end if
    end do

    inside = (mod(crossings, 2) /= 0)
  end function collection_point_in_spline

  !-----------------------------------------------------------------------------
  ! Helper: Intersect two specific segments and append to results
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine intersect_two_segments(s1, idx1, seg_idx1, s2, idx2, seg_idx2, tol, res)
    type(piecewise_spline_type), intent(in)         :: s1, s2
    integer(kind=int32), intent(in)                 :: idx1, seg_idx1, idx2, seg_idx2
    real(kind=real64), intent(in)                   :: tol
    type(collection_intersect_result_type), intent(inout) :: res

    type(bezier_result_type) :: b_res
    integer(kind=int32)      :: k, count_curr
    logical                  :: is_adj

    is_adj = (idx1 == idx2) .and. ((seg_idx2 == seg_idx1 + 1) .or. &
             (seg_idx1 == 1 .and. seg_idx2 == s1%segment_count .and. s1%is_closed))

    call bezier_intersect(s1%segments(seg_idx1), s2%segments(seg_idx2), tol, b_res)

    do k = 1, b_res%count
      if (res%count < COLLECTION_MAX_INTERSECTS) then
        if (.not. (is_adj .and. (b_res%intersections(k)%t1 > 0.95_real64 .and. &
                                 b_res%intersections(k)%t2 < 0.05_real64))) then
          res%count = res%count + 1
          count_curr = res%count
          res%intersections(count_curr)%spline_idx1 = idx1
          res%intersections(count_curr)%seg_idx1    = seg_idx1
          res%intersections(count_curr)%t1          = b_res%intersections(k)%t1
          res%intersections(count_curr)%spline_idx2 = idx2
          res%intersections(count_curr)%seg_idx2    = seg_idx2
          res%intersections(count_curr)%t2          = b_res%intersections(k)%t2
          res%intersections(count_curr)%pt          = b_res%intersections(k)%pt
        end if
      end if
    end do
  end subroutine intersect_two_segments

  !-----------------------------------------------------------------------------
  ! Helper: Intersect two specific splines across all their cubic segments
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine intersect_two_splines(s1, idx1, s2, idx2, tol, res)
    type(piecewise_spline_type), intent(in)         :: s1, s2
    integer(kind=int32), intent(in)                 :: idx1, idx2
    real(kind=real64), intent(in)                   :: tol
    type(collection_intersect_result_type), intent(inout) :: res

    integer(kind=int32) :: k1, k2
    real(kind=real64)   :: min1_x, max1_x, min1_y, max1_y
    real(kind=real64)   :: min2_x, max2_x, min2_y, max2_y
    logical             :: bbox_overlap

    call collection_get_bbox(s1, min1_x, min1_y, max1_x, max1_y)
    call collection_get_bbox(s2, min2_x, min2_y, max2_x, max2_y)

    bbox_overlap = .not. (max1_x < min2_x .or. min1_x > max2_x .or. &
                         max1_y < min2_y .or. min1_y > max2_y)

    if (bbox_overlap) then
      do k1 = 1, s1%segment_count
        do k2 = 1, s2%segment_count
          if (idx1 /= idx2 .or. k2 >= k1) then
            call intersect_two_segments(s1, idx1, k1, s2, idx2, k2, tol, res)
          end if
        end do
      end do
    end if
  end subroutine intersect_two_splines

  !-----------------------------------------------------------------------------
  ! Find all internal intersections between splines in a single collection
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine collection_find_intersections_internal(coll, res, tol_opt)
    type(spline_collection_type), intent(in) :: coll
    type(collection_intersect_result_type), intent(out) :: res
    real(kind=real64), intent(in), optional   :: tol_opt

    integer(kind=int32) :: i, j
    real(kind=real64)   :: tol

    res%count  = 0
    res%status = COLLECTION_OK
    tol        = DEFAULT_COLL_TOL

    if (present(tol_opt)) then
      tol = tol_opt
    end if

    do i = 1, coll%spline_count
      do j = i, coll%spline_count
        call intersect_two_splines(coll%splines(i), i, coll%splines(j), j, tol, res)
      end do
    end do
  end subroutine collection_find_intersections_internal

  !-----------------------------------------------------------------------------
  ! Find all intersections between two distinct collections (A and B)
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine collection_find_intersections_between(coll_a, coll_b, res, tol_opt)
    type(spline_collection_type), intent(in) :: coll_a, coll_b
    type(collection_intersect_result_type), intent(out) :: res
    real(kind=real64), intent(in), optional   :: tol_opt

    integer(kind=int32) :: i, j
    real(kind=real64)   :: tol

    res%count  = 0
    res%status = COLLECTION_OK
    tol        = DEFAULT_COLL_TOL

    if (present(tol_opt)) then
      tol = tol_opt
    end if

    do i = 1, coll_a%spline_count
      do j = 1, coll_b%spline_count
        call intersect_two_splines(coll_a%splines(i), i, coll_b%splines(j), j, tol, res)
      end do
    end do
  end subroutine collection_find_intersections_between

  !-----------------------------------------------------------------------------
  ! Compute nesting hierarchy depth for all splines in the collection
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine collection_compute_hierarchy(coll, status)
    type(spline_collection_type), intent(inout) :: coll
    integer(kind=int32), intent(out), optional  :: status

    integer(kind=int32) :: i, j, depth, local_stat
    type(point_2d_type) :: test_pt

    local_stat = COLLECTION_OK

    if (coll%spline_count == 0) then
      local_stat = COLLECTION_ERR_EMPTY
    else
      do i = 1, coll%spline_count
        depth = 0
        if (coll%splines(i)%segment_count > 0) then
          test_pt = coll%splines(i)%segments(1)%p0
          do j = 1, coll%spline_count
            if (i /= j) then
              if (collection_point_in_spline(coll%splines(j), test_pt)) then
                depth = depth + 1
              end if
            end if
          end do
        end if
        coll%nesting_levels(i) = depth
      end do
    end if

    if (present(status)) then
      status = local_stat
    end if
  end subroutine collection_compute_hierarchy

  !-----------------------------------------------------------------------------
  ! Auto-orient collection contours according to OpenType/TrueType winding rules:
  ! Even nesting levels (0, 2...) -> CCW (Outer boundary)
  ! Odd nesting levels (1, 3...)  -> CW (Inner holes)
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine collection_auto_orient_opentype(coll, status)
    type(spline_collection_type), intent(inout) :: coll
    integer(kind=int32), intent(out), optional  :: status

    integer(kind=int32) :: i, target_rot, set_stat, local_stat

    call collection_compute_hierarchy(coll, local_stat)

    if (local_stat == COLLECTION_OK) then
      do i = 1, coll%spline_count
        if (mod(coll%nesting_levels(i), 2) == 0) then
          target_rot = SPLINE_ROTATION_CCW
        else
          target_rot = SPLINE_ROTATION_CW
        end if

        call spline_set_rotation(coll%splines(i), target_rot, set_stat)
      end do
    end if

    if (present(status)) then
      status = local_stat
    end if
  end subroutine collection_auto_orient_opentype

end module iris_spline_collection
