!===============================================================================
! Module: iris_evaluate_pegs
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Sorts Mill Peg Evaluation Engine (Pure Peg Spacing & Kerning)
! Description: Applies pre-existing visual boundary pegs to compute exact
!              microtypographic glyph kerning and positioning offsets.
!              Strictly decoupled from automatic peg calculation/inference.
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
module iris_evaluate_pegs
  use, intrinsic :: iso_fortran_env, only: int16, int32, real64
  use iris_opentype
  implicit none
  private

  ! Public Constants
  integer(kind=int32), parameter, public :: PEG_APPLY_OK        = 0
  integer(kind=int32), parameter, public :: PEG_APPLY_NO_PEGS   = 1
  integer(kind=int32), parameter, public :: PEG_APPLY_ERR_BOUND = -1

  ! Public API Procedures
  public :: compute_peg_kerning
  public :: apply_pegs_glyph_pair
  public :: apply_pegs_glyph_run

contains

  !-----------------------------------------------------------------------------
  ! Compute kerning adjustment between two peg entries
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine compute_peg_kerning(left_peg, right_peg, nominal_gap, kerning_delta)
    type(otf_peg_entry_type), intent(in) :: left_peg
    type(otf_peg_entry_type), intent(in) :: right_peg
    integer(kind=int16), intent(in)      :: nominal_gap
    integer(kind=int16), intent(out)     :: kerning_delta

    integer(kind=int32) :: eff_gap, delta_val

    ! Gap between preceding right peg and following left peg
    eff_gap = int(right_peg%left_peg_x, int32) - int(left_peg%right_peg_x, int32)
    delta_val = int(nominal_gap, int32) - eff_gap

    ! Clamp delta within int16 bounds
    if (delta_val > 32767) then
      delta_val = 32767
    else if (delta_val < -32768) then
      delta_val = -32768
    end if

    kerning_delta = int(delta_val, int16)
  end subroutine compute_peg_kerning

  !-----------------------------------------------------------------------------
  ! Apply existing pegs to a pair of glyph IDs in a font
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine apply_pegs_glyph_pair(font, left_gid, right_gid, nominal_gap, &
                                   kerning_delta, status)
    type(otf_font_type), intent(in)  :: font
    integer(kind=int16), intent(in)  :: left_gid
    integer(kind=int16), intent(in)  :: right_gid
    integer(kind=int16), intent(in)  :: nominal_gap
    integer(kind=int16), intent(out) :: kerning_delta
    integer(kind=int32), intent(out) :: status

    type(otf_peg_entry_type) :: l_peg, r_peg
    logical                  :: l_found, r_found

    kerning_delta = 0
    status = PEG_APPLY_OK

    call otf_get_peg_entry(font, left_gid, l_peg, l_found)
    call otf_get_peg_entry(font, right_gid, r_peg, r_found)

    if (l_found .and. r_found) then
      call compute_peg_kerning(l_peg, r_peg, nominal_gap, kerning_delta)
    else
      status = PEG_APPLY_NO_PEGS
    end if
  end subroutine apply_pegs_glyph_pair

  !-----------------------------------------------------------------------------
  ! Apply existing pegs to a sequence run of glyph IDs
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine apply_pegs_glyph_run(font, glyph_ids, num_glyphs, nominal_gap, &
                                  kerning_deltas, status)
    type(otf_font_type), intent(in)  :: font
    integer(kind=int16), intent(in)  :: glyph_ids(:)
    integer(kind=int32), intent(in)  :: num_glyphs
    integer(kind=int16), intent(in)  :: nominal_gap
    integer(kind=int16), intent(out) :: kerning_deltas(:)
    integer(kind=int32), intent(out) :: status

    integer(kind=int32) :: i, pair_stat
    integer(kind=int16) :: delta

    status = PEG_APPLY_OK

    if (num_glyphs > 1 .and. size(glyph_ids) >= num_glyphs .and. &
        size(kerning_deltas) >= (num_glyphs - 1)) then
      do i = 1, num_glyphs - 1
        call apply_pegs_glyph_pair(font, glyph_ids(i), glyph_ids(i + 1), &
                                   nominal_gap, delta, pair_stat)
        kerning_deltas(i) = delta
        if (pair_stat /= PEG_APPLY_OK) then
          status = PEG_APPLY_NO_PEGS
        end if
      end do
    else
      status = PEG_APPLY_ERR_BOUND
    end if
  end subroutine apply_pegs_glyph_run

end module iris_evaluate_pegs
