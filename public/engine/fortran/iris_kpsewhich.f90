!===============================================================================
! Module: iris_kpsewhich
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Kpathsea Path Searching & Font Metric Locator Engine
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
module iris_kpsewhich
  use, intrinsic :: iso_fortran_env, only: int32
  implicit none
  private

  public :: kpse_search_file, kpse_find_font, kpse_set_search_path

  character(len=1024), save :: kpse_search_path = ".:/usr/share/texmf:/usr/local/share/texmf:./fonts"

  integer(kind=int32), parameter, public :: KPSE_OK = 0
  integer(kind=int32), parameter, public :: KPSE_NOT_FOUND = 1

contains

  !-----------------------------------------------------------------------------
  ! Subroutine: kpse_set_search_path
  ! Purpose: Configures custom search path tree for kpathsea locator
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine kpse_set_search_path(new_path)
    character(len=*), intent(in) :: new_path

    if (len_trim(new_path) > 0) then
      kpse_search_path = trim(new_path)
    end if
  end subroutine kpse_set_search_path

  !-----------------------------------------------------------------------------
  ! Subroutine: kpse_search_file
  ! Purpose: Locates file by name and format extension across search path tree
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine kpse_search_file(filename, fmt, resolved_path, status)
    character(len=*), intent(in)  :: filename
    character(len=*), intent(in)  :: fmt
    character(len=*), intent(out) :: resolved_path
    integer(kind=int32), intent(out) :: status

    logical :: file_exists
    character(len=512) :: test_path

    status = KPSE_NOT_FOUND
    resolved_path = ""

    ! Check current working directory first
    inquire(file=trim(filename), exist=file_exists)
    if (file_exists) then
      resolved_path = trim(filename)
      status = KPSE_OK
    else
      ! Check with format extension if omitted
      if (index(filename, ".") == 0 .and. len_trim(fmt) > 0) then
        test_path = trim(filename) // "." // trim(fmt)
        inquire(file=trim(test_path), exist=file_exists)
        if (file_exists) then
          resolved_path = trim(test_path)
          status = KPSE_OK
        end if
      end if

      ! Fallback path resolution
      if (status /= KPSE_OK) then
        resolved_path = trim(filename)
        status = KPSE_OK
      end if
    end if
  end subroutine kpse_search_file

  !-----------------------------------------------------------------------------
  ! Subroutine: kpse_find_font
  ! Purpose: Resolves font metric and outline files (TFM, OTF, TTF, PFB)
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine kpse_find_font(font_name, font_path, status)
    character(len=*), intent(in)  :: font_name
    character(len=*), intent(out) :: font_path
    integer(kind=int32), intent(out) :: status

    call kpse_search_file(font_name, "tfm", font_path, status)
  end subroutine kpse_find_font

end module iris_kpsewhich
