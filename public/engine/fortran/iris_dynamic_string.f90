module iris_dynamic_string
  use, intrinsic :: iso_fortran_env, only: int32
  implicit none
  private

  public :: append_string_buffer
  public :: ensure_string_capacity

contains

  subroutine ensure_string_capacity(buf, req_len)
    character(len=:), allocatable, intent(inout) :: buf
    integer(kind=int32), intent(in) :: req_len

    integer(kind=int32) :: curr_cap, new_cap
    character(len=:), allocatable :: tmp

    if (.not. allocated(buf)) then
      new_cap = max(4096_int32, req_len * 2_int32)
      allocate(character(len=new_cap) :: buf)
      buf = ""
    else
      curr_cap = len(buf)
      if (req_len > curr_cap) then
        new_cap = max(curr_cap * 2_int32, req_len * 2_int32)
        allocate(character(len=new_cap) :: tmp)
        tmp = ""
        if (curr_cap > 0) then
          tmp(1:curr_cap) = buf(1:curr_cap)
        end if
        call move_alloc(tmp, buf)
      end if
    end if
  end subroutine ensure_string_capacity

  subroutine append_string_buffer(buf, buf_len, text)
    character(len=:), allocatable, intent(inout) :: buf
    integer(kind=int32), intent(inout) :: buf_len
    character(len=*), intent(in) :: text

    integer(kind=int32) :: add_len, target_len

    add_len = len(text)
    if (add_len > 0) then
      target_len = buf_len + add_len
      call ensure_string_capacity(buf, target_len)
      buf(buf_len + 1 : target_len) = text
      buf_len = target_len
    end if
  end subroutine append_string_buffer

end module iris_dynamic_string
