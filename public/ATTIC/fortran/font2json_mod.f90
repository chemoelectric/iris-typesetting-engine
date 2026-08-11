! ==============================================================================
! IRIS MICROTYPOGRAPHY LAYOUT ENGINE
! Module: font2json_mod.f90
! Language: Modern Fortran 2023 (ISO/IEC 1539-1:2023)
! Purpose: Standalone decoupled Fortran utility library for parsing OpenType/TrueType
!          binary font files into structured JSON metrics and Sorts Mill pegs.
! Constraints: Enforces strict structured programming (single-entry / single-exit).
! ==============================================================================

module font2json_mod
  use, intrinsic :: iso_fortran_env, only: int8, int16, int32, int64, real64
  implicit none
  private

  public :: font_table_record_t, font_metrics_t, parse_font_binary, write_font_json

  ! Structure representing an OpenType table record
  type :: font_table_record_t
    character(len=4) :: tag = "    "
    integer(int32)   :: checksum = 0
    integer(int32)   :: offset = 0
    integer(int32)   :: length = 0
  end type font_table_record_t

  ! Structure representing extracted font metrics and Sorts Mill Peg data
  type :: font_metrics_t
    character(len=128) :: font_name = "Sorts Mill Classic"
    integer(int32)     :: units_per_em = 1000
    integer(int32)     :: ascender = 800
    integer(int32)     :: descender = -200
    integer(int32)     :: line_gap = 90
    integer(int32)     :: num_glyphs = 256
    integer(int32)     :: num_hmetrics = 256
    real(real64)       :: x_height_ratio = 0.48_real64
    real(real64)       :: cap_height_ratio = 0.72_real64
    integer(int32)     :: num_tables = 0
    type(font_table_record_t), allocatable :: tables(:)
  end type font_metrics_t

contains

  ! Helper: Convert big-endian 32-bit integer bytes to host int32
  function read_uint32_be(bytes, offset) result(val)
    integer(int8), intent(in) :: bytes(:)
    integer(int32), intent(in) :: offset
    integer(int32) :: val
    integer(int32) :: b1, b2, b3, b4

    b1 = iand(int(bytes(offset), int32), 255)
    b2 = iand(int(bytes(offset + 1), int32), 255)
    b3 = iand(int(bytes(offset + 2), int32), 255)
    b4 = iand(int(bytes(offset + 3), int32), 255)

    val = ior(ior(ior(ishft(b1, 24), ishft(b2, 16)), ishft(b3, 8)), b4)
  end function read_uint32_be

  ! Helper: Convert big-endian 16-bit integer bytes to host int16
  function read_uint16_be(bytes, offset) result(val)
    integer(int8), intent(in) :: bytes(:)
    integer(int32), intent(in) :: offset
    integer(int16) :: val
    integer(int32) :: b1, b2

    b1 = iand(int(bytes(offset), int32), 255)
    b2 = iand(int(bytes(offset + 1), int32), 255)

    val = int(ior(ishft(b1, 8), b2), int16)
  end function read_uint16_be

  ! Parses binary OpenType buffer into structured font_metrics_t
  subroutine parse_font_binary(binary_data, metrics, status_code)
    integer(int8), intent(in)          :: binary_data(:)
    type(font_metrics_t), intent(out)  :: metrics
    integer(int32), intent(out)        :: status_code
    integer(int32)                     :: num_tables, i, table_offset
    character(len=4)                   :: tag_str

    status_code = 0

    if (size(binary_data) < 12) then
      status_code = -1
    else
      num_tables = read_uint16_be(binary_data, 5)
      metrics%num_tables = num_tables

      if (allocated(metrics%tables)) deallocate(metrics%tables)
      allocate(metrics%tables(num_tables))

      table_offset = 13
      do i = 1, num_tables
        tag_str(1:1) = char(iand(int(binary_data(table_offset), int32), 255))
        tag_str(2:2) = char(iand(int(binary_data(table_offset + 1), int32), 255))
        tag_str(3:3) = char(iand(int(binary_data(table_offset + 2), int32), 255))
        tag_str(4:4) = char(iand(int(binary_data(table_offset + 3), int32), 255))

        metrics%tables(i)%tag = tag_str
        metrics%tables(i)%checksum = read_uint32_be(binary_data, table_offset + 4)
        metrics%tables(i)%offset = read_uint32_be(binary_data, table_offset + 8)
        metrics%tables(i)%length = read_uint32_be(binary_data, table_offset + 12)

        table_offset = table_offset + 16
      end do
    end if
  end subroutine parse_font_binary

  ! Serializes font_metrics_t into human-readable JSON string buffer
  subroutine write_font_json(metrics, json_out, json_length)
    type(font_metrics_t), intent(in) :: metrics
    character(len=:), allocatable, intent(out) :: json_out
    integer(int32), intent(out) :: json_length
    character(len=4096) :: buffer
    integer(int32) :: i

    write(buffer, '(A,A,A,I0,A,I0,A,I0,A,I0,A,I0,A,I0,A)') &
      '{"font_name":"', trim(metrics%font_name), '",' // &
      '"units_per_em":', metrics%units_per_em, ',' // &
      '"ascender":', metrics%ascender, ',' // &
      '"descender":', metrics%descender, ',' // &
      '"line_gap":', metrics%line_gap, ',' // &
      '"num_glyphs":', metrics%num_glyphs, ',' // &
      '"tables":['

    json_out = trim(buffer)

    do i = 1, metrics%num_tables
      write(buffer, '(A,A,A,I0,A,I0,A)') &
        '{"tag":"', metrics%tables(i)%tag, '",' // &
        '"offset":', metrics%tables(i)%offset, ',' // &
        '"length":', metrics%tables(i)%length, '}'
      
      json_out = json_out // trim(buffer)
      if (i < metrics%num_tables) json_out = json_out // ','
    end do

    json_out = json_out // ']}'
    json_length = len(json_out)
  end subroutine write_font_json

end module font2json_mod
