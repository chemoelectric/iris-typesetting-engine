!===============================================================================
! Module: iris_spline
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Piecewise Spline Engine with Explicit Closing Segment,
!               Joint Continuity Checking (C0, C1, C2), Self-Intersection
!               Detection, and Sense of Rotation Management
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
module iris_spline
  use, intrinsic :: iso_fortran_env, only: int32, real64
  use iris_bezier_intersect, only: point_2d_type, bezier_cubic_type, &
                                   bezier_result_type, bezier_make_point, &
                                   bezier_make_cubic, bezier_intersect
  implicit none
  private

  ! Public Constants
  integer(kind=int32), parameter, public :: SPLINE_MAX_SEGMENTS           = 64
  integer(kind=int32), parameter, public :: SPLINE_OK                     = 0
  integer(kind=int32), parameter, public :: SPLINE_ERR_EMPTY              = -1
  integer(kind=int32), parameter, public :: SPLINE_ERR_FULL               = -2
  real(kind=real64),   parameter, public :: DEFAULT_CONT_TOL              = 1.0e-5_real64

  ! Sense of Rotation Constants
  integer(kind=int32), parameter, public :: SPLINE_ROTATION_CCW           = 1
  integer(kind=int32), parameter, public :: SPLINE_ROTATION_CW            = -1
  integer(kind=int32), parameter, public :: SPLINE_ROTATION_NOT_CLOSED   = 0
  integer(kind=int32), parameter, public :: SPLINE_ROTATION_SELF_INTERSECTING = -2

  ! Public Derived Types
  public :: piecewise_spline_type
  public :: continuity_report_type

  ! Public API Procedures
  public :: spline_init
  public :: spline_add_segment
  public :: spline_close
  public :: spline_check_continuity
  public :: spline_eval
  public :: spline_self_intersects
  public :: spline_calc_signed_area
  public :: spline_get_rotation
  public :: spline_set_rotation

  type :: piecewise_spline_type
    type(bezier_cubic_type) :: segments(SPLINE_MAX_SEGMENTS)
    integer(kind=int32)     :: segment_count = 0
    logical                 :: is_closed = .false.
    logical                 :: has_explicit_closing = .false.
  end type piecewise_spline_type

  type :: continuity_report_type
    logical             :: c0_continuous = .true.
    logical             :: c1_continuous = .true.
    logical             :: c2_continuous = .true.
    integer(kind=int32) :: max_continuity = 2
    real(kind=real64)   :: max_c0_error = 0.0_real64
    real(kind=real64)   :: max_c1_error = 0.0_real64
    real(kind=real64)   :: max_c2_error = 0.0_real64
    integer(kind=int32) :: status = SPLINE_OK
  end type continuity_report_type

contains

  !-----------------------------------------------------------------------------
  ! Initialize empty piecewise spline
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine spline_init(spline)
    type(piecewise_spline_type), intent(out) :: spline

    spline%segment_count = 0
    spline%is_closed = .false.
    spline%has_explicit_closing = .false.
  end subroutine spline_init

  !-----------------------------------------------------------------------------
  ! Add a cubic segment to the piecewise spline
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine spline_add_segment(spline, curve, status)
    type(piecewise_spline_type), intent(inout) :: spline
    type(bezier_cubic_type), intent(in)       :: curve
    integer(kind=int32), intent(out)          :: status

    if (spline%segment_count < SPLINE_MAX_SEGMENTS) then
      spline%segment_count = spline%segment_count + 1
      spline%segments(spline%segment_count) = curve
      status = SPLINE_OK
    else
      status = SPLINE_ERR_FULL
    end if
  end subroutine spline_add_segment

  !-----------------------------------------------------------------------------
  ! Close the piecewise spline by maintaining an explicit closing segment
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine spline_close(spline, status)
    type(piecewise_spline_type), intent(inout) :: spline
    integer(kind=int32), intent(out)          :: status

    type(point_2d_type)     :: p_last, p_first, ctrl1, ctrl2
    type(bezier_cubic_type) :: closing_seg
    real(kind=real64)       :: dx, dy

    status = SPLINE_OK

    if (spline%segment_count == 0) then
      status = SPLINE_ERR_EMPTY
    else if (.not. spline%is_closed) then
      spline%is_closed = .true.
      p_last  = spline%segments(spline%segment_count)%p3
      p_first = spline%segments(1)%p0

      dx = p_first%x - p_last%x
      dy = p_first%y - p_last%y

      ! Check if end and start points differ; construct explicit closing segment
      if (abs(dx) > 1.0e-7_real64 .or. abs(dy) > 1.0e-7_real64) then
        if (spline%segment_count < SPLINE_MAX_SEGMENTS) then
          ctrl1 = bezier_make_point(p_last%x + 0.3333333333333333d0 * dx, &
                                    p_last%y + 0.3333333333333333d0 * dy)
          ctrl2 = bezier_make_point(p_last%x + 0.6666666666666666d0 * dx, &
                                    p_last%y + 0.6666666666666666d0 * dy)
          closing_seg = bezier_make_cubic(p_last, ctrl1, ctrl2, p_first)

          spline%segment_count = spline%segment_count + 1
          spline%segments(spline%segment_count) = closing_seg
          spline%has_explicit_closing = .true.
        else
          status = SPLINE_ERR_FULL
        end if
      end if
    end if
  end subroutine spline_close

  !-----------------------------------------------------------------------------
  ! Evaluate C0, C1, C2 continuity across all interior and closing joints
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine spline_check_continuity(spline, tol_opt, report)
    type(piecewise_spline_type), intent(in)   :: spline
    real(kind=real64), intent(in), optional   :: tol_opt
    type(continuity_report_type), intent(out) :: report

    integer(kind=int32)     :: i, num_joints, next_idx
    real(kind=real64)       :: tol, err_c0, err_c1, err_c2
    type(bezier_cubic_type) :: curr_s, next_s
    type(point_2d_type)     :: d1_curr, d1_next, d2_curr, d2_next

    tol = DEFAULT_CONT_TOL
    if (present(tol_opt)) then
      tol = tol_opt
    end if

    report%c0_continuous = .true.
    report%c1_continuous = .true.
    report%c2_continuous = .true.
    report%max_c0_error  = 0.0_real64
    report%max_c1_error  = 0.0_real64
    report%max_c2_error  = 0.0_real64
    report%status        = SPLINE_OK

    if (spline%segment_count == 0) then
      report%status = SPLINE_ERR_EMPTY
    else
      num_joints = spline%segment_count - 1
      if (spline%is_closed) then
        num_joints = spline%segment_count
      end if

      do i = 1, num_joints
        curr_s = spline%segments(i)
        next_idx = i + 1
        if (next_idx > spline%segment_count) then
          next_idx = 1
        end if
        next_s = spline%segments(next_idx)

        ! C0 Positional Continuity: S_i(1) vs S_{i+1}(0)
        err_c0 = sqrt((curr_s%p3%x - next_s%p0%x)**2 + (curr_s%p3%y - next_s%p0%y)**2)
        if (err_c0 > report%max_c0_error) report%max_c0_error = err_c0

        ! C1 Tangent Continuity: 3*(P3 - P2)_i vs 3*(P1 - P0)_{i+1}
        d1_curr%x = 3.0_real64 * (curr_s%p3%x - curr_s%p2%x)
        d1_curr%y = 3.0_real64 * (curr_s%p3%y - curr_s%p2%y)
        d1_next%x = 3.0_real64 * (next_s%p1%x - next_s%p0%x)
        d1_next%y = 3.0_real64 * (next_s%p1%y - next_s%p0%y)

        err_c1 = sqrt((d1_curr%x - d1_next%x)**2 + (d1_curr%y - d1_next%y)**2)
        if (err_c1 > report%max_c1_error) report%max_c1_error = err_c1

        ! C2 Curvature Continuity: 6*(P3 - 2*P2 + P1)_i vs 6*(P2 - 2*P1 + P0)_{i+1}
        d2_curr%x = 6.0_real64 * (curr_s%p3%x - 2.0_real64 * curr_s%p2%x + curr_s%p1%x)
        d2_curr%y = 6.0_real64 * (curr_s%p3%y - 2.0_real64 * curr_s%p2%y + curr_s%p1%y)
        d2_next%x = 6.0_real64 * (next_s%p2%x - 2.0_real64 * next_s%p1%x + next_s%p0%x)
        d2_next%y = 6.0_real64 * (next_s%p2%y - 2.0_real64 * next_s%p1%y + next_s%p0%y)

        err_c2 = sqrt((d2_curr%x - d2_next%x)**2 + (d2_curr%y - d2_next%y)**2)
        if (err_c2 > report%max_c2_error) report%max_c2_error = err_c2
      end do

      if (report%max_c0_error > tol) report%c0_continuous = .false.
      if (report%max_c1_error > tol) report%c1_continuous = .false.
      if (report%max_c2_error > tol) report%c2_continuous = .false.

      if (.not. report%c0_continuous) then
        report%max_continuity = -1
      else if (.not. report%c1_continuous) then
        report%max_continuity = 0
      else if (.not. report%c2_continuous) then
        report%max_continuity = 1
      else
        report%max_continuity = 2
      end if
    end if
  end subroutine spline_check_continuity

  !-----------------------------------------------------------------------------
  ! Evaluate point on piecewise spline given global parameter u in [0, count]
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  function spline_eval(spline, u) result(pt)
    type(piecewise_spline_type), intent(in) :: spline
    real(kind=real64), intent(in)           :: u
    type(point_2d_type)                     :: pt

    integer(kind=int32) :: seg_idx
    real(kind=real64)   :: local_t
    real(kind=real64)   :: u_clamped

    if (spline%segment_count == 0) then
      pt = bezier_make_point(0.0_real64, 0.0_real64)
    else
      u_clamped = max(0.0_real64, min(real(spline%segment_count, real64), u))
      seg_idx = min(spline%segment_count, int(u_clamped, int32) + 1)
      local_t = u_clamped - real(seg_idx - 1, real64)

      if (seg_idx > spline%segment_count) then
        seg_idx = spline%segment_count
        local_t = 1.0_real64
      end if

      pt = eval_segment(spline%segments(seg_idx), local_t)
    end if
  end function spline_eval

  !-----------------------------------------------------------------------------
  ! Helper: Self-intersection of a single cubic Bézier curve
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  function check_segment_self_intersect(curve, tol) result(found)
    type(bezier_cubic_type), intent(in) :: curve
    real(kind=real64), intent(in)       :: tol
    logical                             :: found

    type(bezier_result_type) :: res
    integer(kind=int32)      :: k
    real(kind=real64)        :: dt

    found = .false.
    call bezier_intersect(curve, curve, tol, res)
    do k = 1, res%count
      dt = abs(res%intersections(k)%t1 - res%intersections(k)%t2)
      if (dt >= 0.05_real64) then
        found = .true.
      end if
    end do
  end function check_segment_self_intersect

  !-----------------------------------------------------------------------------
  ! Helper: Intersection between a pair of distinct cubic Bézier curves
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  function check_pair_intersect(c1, c2, is_adjacent, is_wrap, tol) result(found)
    type(bezier_cubic_type), intent(in) :: c1, c2
    logical, intent(in)                 :: is_adjacent, is_wrap
    real(kind=real64), intent(in)       :: tol
    logical                             :: found

    type(bezier_result_type) :: res
    integer(kind=int32)      :: k
    real(kind=real64)        :: t1, t2
    logical                  :: is_joint

    found = .false.
    call bezier_intersect(c1, c2, tol, res)
    do k = 1, res%count
      t1 = res%intersections(k)%t1
      t2 = res%intersections(k)%t2
      is_joint = .false.
      if (is_adjacent .and. (t1 > 0.95_real64 .and. t2 < 0.05_real64)) then
        is_joint = .true.
      end if
      if (is_wrap .and. (t1 < 0.05_real64 .and. t2 > 0.95_real64)) then
        is_joint = .true.
      end if
      if (.not. is_joint) then
        found = .true.
      end if
    end do
  end function check_pair_intersect

  !-----------------------------------------------------------------------------
  ! Query if a piecewise spline self-intersects
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  function spline_self_intersects(spline, tol_opt) result(intersects)
    type(piecewise_spline_type), intent(in) :: spline
    real(kind=real64), intent(in), optional :: tol_opt
    logical                                 :: intersects

    integer(kind=int32) :: i, j, n
    real(kind=real64)   :: tol
    logical             :: is_adj, is_wrap

    intersects = .false.
    tol = DEFAULT_CONT_TOL
    if (present(tol_opt)) then
      tol = tol_opt
    end if

    n = spline%segment_count
    if (n > 0) then
      do i = 1, n
        if (check_segment_self_intersect(spline%segments(i), tol)) then
          intersects = .true.
        end if
      end do

      if (.not. intersects) then
        do i = 1, n
          do j = i + 1, n
            is_adj = (j == i + 1)
            is_wrap = (i == 1 .and. j == n .and. spline%is_closed)
            if (check_pair_intersect(spline%segments(i), spline%segments(j), is_adj, is_wrap, tol)) then
              intersects = .true.
            end if
          end do
        end do
      end if
    end if
  end function spline_self_intersects

  !-----------------------------------------------------------------------------
  ! Compute exact total signed area via Green's theorem on cubic segments
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  function spline_calc_signed_area(spline) result(area)
    type(piecewise_spline_type), intent(in) :: spline
    real(kind=real64)                       :: area

    integer(kind=int32) :: i
    type(point_2d_type) :: p0, p1, p2, p3
    real(kind=real64)   :: a_seg, cp_01, cp_02, cp_03, cp_12, cp_13, cp_23

    area = 0.0_real64
    do i = 1, spline%segment_count
      p0 = spline%segments(i)%p0
      p1 = spline%segments(i)%p1
      p2 = spline%segments(i)%p2
      p3 = spline%segments(i)%p3

      cp_01 = p0%x * p1%y - p0%y * p1%x
      cp_02 = p0%x * p2%y - p0%y * p2%x
      cp_03 = p0%x * p3%y - p0%y * p3%x
      cp_12 = p1%x * p2%y - p1%y * p2%x
      cp_13 = p1%x * p3%y - p1%y * p3%x
      cp_23 = p2%x * p3%y - p2%y * p3%x

      a_seg = 0.5_real64 * (0.3_real64 * cp_01 + 0.15_real64 * cp_02 + 0.05_real64 * cp_03 + &
                            0.15_real64 * cp_12 + 0.15_real64 * cp_13 + 0.3_real64 * cp_23)
      area = area + a_seg
    end do
  end function spline_calc_signed_area

  !-----------------------------------------------------------------------------
  ! Query sense of rotation of a closed piecewise spline
  ! Returns SPLINE_ROTATION_SELF_INTERSECTING if self-intersecting
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  function spline_get_rotation(spline, tol_opt) result(rot)
    type(piecewise_spline_type), intent(in) :: spline
    real(kind=real64), intent(in), optional :: tol_opt
    integer(kind=int32)                     :: rot

    real(kind=real64) :: tol, area

    tol = DEFAULT_CONT_TOL
    if (present(tol_opt)) then
      tol = tol_opt
    end if

    if (spline%segment_count == 0 .or. .not. spline%is_closed) then
      rot = SPLINE_ROTATION_NOT_CLOSED
    else if (spline_self_intersects(spline, tol)) then
      rot = SPLINE_ROTATION_SELF_INTERSECTING
    else
      area = spline_calc_signed_area(spline)
      if (area >= 0.0_real64) then
        rot = SPLINE_ROTATION_CCW
      else
        rot = SPLINE_ROTATION_CW
      end if
    end if
  end function spline_get_rotation

  !-----------------------------------------------------------------------------
  ! Helper: Reverse parameter direction of piecewise spline
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine spline_reverse(spline)
    type(piecewise_spline_type), intent(inout) :: spline

    type(bezier_cubic_type) :: tmp_segs(SPLINE_MAX_SEGMENTS)
    integer(kind=int32)     :: i, n, k

    n = spline%segment_count
    do i = 1, n
      tmp_segs(i) = spline%segments(i)
    end do

    do i = 1, n
      k = n - i + 1
      spline%segments(i)%p0 = tmp_segs(k)%p3
      spline%segments(i)%p1 = tmp_segs(k)%p2
      spline%segments(i)%p2 = tmp_segs(k)%p1
      spline%segments(i)%p3 = tmp_segs(k)%p0
    end do
  end subroutine spline_reverse

  !-----------------------------------------------------------------------------
  ! Set sense of rotation of a closed piecewise spline
  ! Succeds safely without crash/corruption even if self-intersecting
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine spline_set_rotation(spline, target_rotation, status)
    type(piecewise_spline_type), intent(inout) :: spline
    integer(kind=int32), intent(in)            :: target_rotation
    integer(kind=int32), intent(out), optional :: status

    real(kind=real64) :: area
    logical           :: current_ccw, target_ccw

    if (present(status)) then
      status = SPLINE_OK
    end if

    if (spline%segment_count == 0) then
      if (present(status)) then
        status = SPLINE_ERR_EMPTY
      end if
    else if (spline%is_closed) then
      area = spline_calc_signed_area(spline)
      current_ccw = (area >= 0.0_real64)
      target_ccw  = (target_rotation == SPLINE_ROTATION_CCW)

      if (current_ccw .neqv. target_ccw) then
        call spline_reverse(spline)
      end if
    end if
  end subroutine spline_set_rotation

  !-----------------------------------------------------------------------------
  ! Helper: Evaluate single cubic segment at local parameter t
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  function eval_segment(curve, t) result(pt)
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
  end function eval_segment

end module iris_spline
