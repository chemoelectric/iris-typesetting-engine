module iris_dynamic_array
  use, intrinsic :: iso_fortran_env, only: int32, int64
  implicit none
  private

  public :: ensure_int32_capacity
  public :: ensure_int64_capacity

contains

  subroutine ensure_int32_capacity(arr, req_count)
    integer(kind=int32), allocatable, dimension(:), intent(inout) :: arr
    integer(kind=int32), intent(in) :: req_count

    integer(kind=int32) :: curr_cap, new_cap
    integer(kind=int32), allocatable, dimension(:) :: tmp

    if (.not. allocated(arr)) then
      new_cap = max(16_int32, req_count * 2_int32)
      allocate(arr(new_cap))
      arr = 0_int32
    else
      curr_cap = size(arr)
      if (req_count > curr_cap) then
        new_cap = max(curr_cap * 2_int32, req_count * 2_int32)
        allocate(tmp(new_cap))
        tmp = 0_int32
        tmp(1:curr_cap) = arr(1:curr_cap)
        call move_alloc(tmp, arr)
      end if
    end if
  end subroutine ensure_int32_capacity

  subroutine ensure_int64_capacity(arr, req_count)
    integer(kind=int64), allocatable, dimension(:), intent(inout) :: arr
    integer(kind=int32), intent(in) :: req_count

    integer(kind=int32) :: curr_cap, new_cap
    integer(kind=int64), allocatable, dimension(:) :: tmp

    if (.not. allocated(arr)) then
      new_cap = max(16_int32, req_count * 2_int32)
      allocate(arr(new_cap))
      arr = 0_int64
    else
      curr_cap = size(arr)
      if (req_count > curr_cap) then
        new_cap = max(curr_cap * 2_int32, req_count * 2_int32)
        allocate(tmp(new_cap))
        tmp = 0_int64
        tmp(1:curr_cap) = arr(1:curr_cap)
        call move_alloc(tmp, arr)
      end if
    end if
  end subroutine ensure_int64_capacity

end module iris_dynamic_array
