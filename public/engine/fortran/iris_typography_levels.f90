!===============================================================================
! Module: iris_typography_levels
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Multi-Level Iris Typography Abstraction Engine
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
module iris_typography_levels
  use, intrinsic :: iso_fortran_env, only: int32, real64
  use iris_json, only: json_value_type, json_create_object, json_create_string, &
                       json_create_integer, json_create_real, json_set_field
  implicit none
  private

  public :: TYPO_LEVEL_0_CLASSIC_TEX
  public :: TYPO_LEVEL_1_MICROTYPO_PEGS
  public :: TYPO_LEVEL_2_FOURIER_SPECTRAL

  public :: typography_config_type
  public :: typography_config_init
  public :: typography_evaluate_level
  public :: typography_export_json

  ! Typography Levels
  integer(kind=int32), parameter :: TYPO_LEVEL_0_CLASSIC_TEX     = 0 ! Knuth Box & Glue
  integer(kind=int32), parameter :: TYPO_LEVEL_1_MICROTYPO_PEGS  = 1 ! MaxEnt + Pegs
  integer(kind=int32), parameter :: TYPO_LEVEL_2_FOURIER_SPECTRAL = 2 ! Continuous Spectrum

  type :: typography_config_type
    integer(kind=int32) :: active_level = TYPO_LEVEL_0_CLASSIC_TEX
    logical             :: enable_sorts_mill_pegs = .false.
    logical             :: enable_maxent_layout = .false.
    logical             :: enable_fourier_spectral = .false.
    real(kind=real64)   :: maxent_lambda = 1.0_real64
    character(len=64)   :: font_attachment_mode = "native_ot_gpos"
  end type typography_config_type

contains

  !-----------------------------------------------------------------------------
  ! Subroutine: typography_config_init
  ! Purpose: Initializes the typography engine configuration for a given level
  ! Control Structure: Single-entry / single-exit. Complexity <= 4.
  !-----------------------------------------------------------------------------
  subroutine typography_config_init(config, level)
    type(typography_config_type), intent(out) :: config
    integer(kind=int32), intent(in)           :: level

    if (level < TYPO_LEVEL_0_CLASSIC_TEX .or. level > TYPO_LEVEL_2_FOURIER_SPECTRAL) then
      config%active_level = TYPO_LEVEL_0_CLASSIC_TEX
    else
      config%active_level = level
    end if

    select case (config%active_level)
    case (TYPO_LEVEL_0_CLASSIC_TEX)
      config%enable_sorts_mill_pegs = .false.
      config%enable_maxent_layout   = .false.
      config%enable_fourier_spectral = .false.
      config%font_attachment_mode  = "classic_tfm"
    case (TYPO_LEVEL_1_MICROTYPO_PEGS)
      config%enable_sorts_mill_pegs = .true.
      config%enable_maxent_layout   = .true.
      config%enable_fourier_spectral = .false.
      config%font_attachment_mode  = "sorts_mill_pegs"
    case (TYPO_LEVEL_2_FOURIER_SPECTRAL)
      config%enable_sorts_mill_pegs = .true.
      config%enable_maxent_layout   = .true.
      config%enable_fourier_spectral = .true.
      config%font_attachment_mode  = "continuous_multivector_cl411"
    end select

    config%maxent_lambda = 1.0_real64

  end subroutine typography_config_init

  !-----------------------------------------------------------------------------
  ! Function: typography_evaluate_level
  ! Purpose: Returns descriptive text strategy name for active typography level
  ! Control Structure: Single-entry / single-exit. Complexity <= 4.
  !-----------------------------------------------------------------------------
  function typography_evaluate_level(config) result(level_desc)
    type(typography_config_type), intent(in) :: config
    character(len=128) :: level_desc

    select case (config%active_level)
    case (TYPO_LEVEL_0_CLASSIC_TEX)
      level_desc = "Level 0: Classic TeX Box-and-Glue Interception Model"
    case (TYPO_LEVEL_1_MICROTYPO_PEGS)
      level_desc = "Level 1: MaxEnt Jaynesian Microtypography with Sorts Mill Pegs"
    case (TYPO_LEVEL_2_FOURIER_SPECTRAL)
      level_desc = "Level 2: Continuous 2D/3D Fourier Spatial Frequency & Cl(4,1,1) Rotors"
    case default
      level_desc = "Level 0: Classic TeX Default Fallback"
    end select

  end function typography_evaluate_level

  !-----------------------------------------------------------------------------
  ! Subroutine: typography_export_json
  ! Purpose: Serializes active typography configuration into JSON AST representation
  ! Control Structure: Single-entry / single-exit. Complexity <= 2.
  !-----------------------------------------------------------------------------
  subroutine typography_export_json(config, json_obj)
    type(typography_config_type), intent(in) :: config
    type(json_value_type), intent(out)        :: json_obj

    call json_create_object(json_obj)
    call json_set_field(json_obj, "level", json_create_integer(config%active_level))
    call json_set_field(json_obj, "description", json_create_string(trim(typography_evaluate_level(config))))
    call json_set_field(json_obj, "attachment_mode", json_create_string(trim(config%font_attachment_mode)))

  end subroutine typography_export_json

end module iris_typography_levels
