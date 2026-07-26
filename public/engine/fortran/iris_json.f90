!===============================================================================
! Module: iris_json
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Imperative Procedural Memory-Tree AST API for JSON RFC 8259
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
module iris_json
  use, intrinsic :: iso_fortran_env, only: int32, real64
  implicit none
  private

  ! Public AST Type Constants
  integer(kind=int32), parameter, public :: JSON_NULL_TYPE   = 0
  integer(kind=int32), parameter, public :: JSON_BOOL_TYPE   = 1
  integer(kind=int32), parameter, public :: JSON_NUM_TYPE    = 2
  integer(kind=int32), parameter, public :: JSON_STR_TYPE    = 3
  integer(kind=int32), parameter, public :: JSON_ARR_TYPE    = 4
  integer(kind=int32), parameter, public :: JSON_OBJ_TYPE    = 5

  ! Public Derived Type
  public :: json_value_type

  ! Public API Procedures (Isomorphic to Scheme (json-api))
  public :: json_create_object
  public :: json_create_array
  public :: json_create_string
  public :: json_create_number
  public :: json_create_bool
  public :: json_create_null
  public :: json_get_type
  public :: json_set_field
  public :: json_get_field
  public :: json_add_element
  public :: json_get_element
  public :: json_get_string
  public :: json_get_number
  public :: json_get_bool
  public :: json_serialize
  public :: json_free

  ! Linked list node for JSON object member fields
  type :: json_field_node
    character(len=128) :: key
    type(json_value_type), pointer :: val => null()
    type(json_field_node), pointer :: next => null()
  end type json_field_node

  ! Linked list node for JSON array elements
  type :: json_element_node
    type(json_value_type), pointer :: val => null()
    type(json_element_node), pointer :: next => null()
  end type json_element_node

  ! Recursive JSON Value AST Node
  type :: json_value_type
    integer(kind=int32) :: value_type = JSON_NULL_TYPE
    logical :: bool_val = .false.
    real(kind=real64) :: num_val = 0.0_real64
    character(len=256) :: str_val = ""
    type(json_field_node), pointer :: first_field => null()
    type(json_element_node), pointer :: first_element => null()
  end type json_value_type

contains

  !-----------------------------------------------------------------------------
  ! Constructors
  !-----------------------------------------------------------------------------
  subroutine json_create_object(val)
    type(json_value_type), intent(out) :: val
    val%value_type = JSON_OBJ_TYPE
    val%first_field => null()
  end subroutine json_create_object

  subroutine json_create_array(val)
    type(json_value_type), intent(out) :: val
    val%value_type = JSON_ARR_TYPE
    val%first_element => null()
  end subroutine json_create_array

  subroutine json_create_string(val, str)
    type(json_value_type), intent(out) :: val
    character(len=*), intent(in) :: str
    val%value_type = JSON_STR_TYPE
    val%str_val = str
  end subroutine json_create_string

  subroutine json_create_number(val, num)
    type(json_value_type), intent(out) :: val
    real(kind=real64), intent(in) :: num
    val%value_type = JSON_NUM_TYPE
    val%num_val = num
  end subroutine json_create_number

  subroutine json_create_bool(val, b)
    type(json_value_type), intent(out) :: val
    logical, intent(in) :: b
    val%value_type = JSON_BOOL_TYPE
    val%bool_val = b
  end subroutine json_create_bool

  subroutine json_create_null(val)
    type(json_value_type), intent(out) :: val
    val%value_type = JSON_NULL_TYPE
  end subroutine json_create_null

  !-----------------------------------------------------------------------------
  ! Inspectors
  !-----------------------------------------------------------------------------
  function json_get_type(val) result(res_type)
    type(json_value_type), intent(in) :: val
    integer(kind=int32) :: res_type
    res_type = val%value_type
  end function json_get_type

  !-----------------------------------------------------------------------------
  ! Object Mutators & Accessors
  !-----------------------------------------------------------------------------
  subroutine json_set_field(obj, key, child)
    type(json_value_type), intent(inout) :: obj
    character(len=*), intent(in) :: key
    type(json_value_type), intent(in) :: child

    type(json_field_node), pointer :: new_node

    if (obj%value_type == JSON_OBJ_TYPE) then
      allocate(new_node)
      new_node%key = trim(key)
      allocate(new_node%val)
      new_node%val = child
      new_node%next => obj%first_field
      obj%first_field => new_node
    end if
  end subroutine json_set_field

  subroutine json_get_field(obj, key, child, status)
    type(json_value_type), intent(in) :: obj
    character(len=*), intent(in) :: key
    type(json_value_type), intent(out) :: child
    integer(kind=int32), intent(out) :: status

    type(json_field_node), pointer :: curr

    status = -1
    call json_create_null(child)

    if (obj%value_type == JSON_OBJ_TYPE) then
      curr => obj%first_field
      do while (associated(curr))
        if (trim(curr%key) == trim(key)) then
          child = curr%val
          status = 0
          exit
        end if
        curr => curr%next
      end do
    end if
  end subroutine json_get_field

  !-----------------------------------------------------------------------------
  ! Array Mutators & Accessors
  !-----------------------------------------------------------------------------
  subroutine json_add_element(arr, child)
    type(json_value_type), intent(inout) :: arr
    type(json_value_type), intent(in) :: child

    type(json_element_node), pointer :: new_node, curr

    if (arr%value_type == JSON_ARR_TYPE) then
      allocate(new_node)
      allocate(new_node%val)
      new_node%val = child
      new_node%next => null()

      if (.not. associated(arr%first_element)) then
        arr%first_element => new_node
      else
        curr => arr%first_element
        do while (associated(curr%next))
          curr => curr%next
        end do
        curr%next => new_node
      end if
    end if
  end subroutine json_add_element

  subroutine json_get_element(arr, idx, child, status)
    type(json_value_type), intent(in) :: arr
    integer(kind=int32), intent(in) :: idx
    type(json_value_type), intent(out) :: child
    integer(kind=int32), intent(out) :: status

    type(json_element_node), pointer :: curr
    integer(kind=int32) :: count

    status = -1
    call json_create_null(child)

    if (arr%value_type == JSON_ARR_TYPE .and. idx >= 1) then
      curr => arr%first_element
      count = 1
      do while (associated(curr))
        if (count == idx) then
          child = curr%val
          status = 0
          exit
        end if
        count = count + 1
        curr => curr%next
      end do
    end if
  end subroutine json_get_element

  !-----------------------------------------------------------------------------
  ! Value Extractors
  !-----------------------------------------------------------------------------
  subroutine json_get_string(val, str, status)
    type(json_value_type), intent(in) :: val
    character(len=*), intent(out) :: str
    integer(kind=int32), intent(out) :: status

    if (val%value_type == JSON_STR_TYPE) then
      str = trim(val%str_val)
      status = 0
    else
      str = ""
      status = -1
    end if
  end subroutine json_get_string

  subroutine json_get_number(val, num, status)
    type(json_value_type), intent(in) :: val
    real(kind=real64), intent(out) :: num
    integer(kind=int32), intent(out) :: status

    if (val%value_type == JSON_NUM_TYPE) then
      num = val%num_val
      status = 0
    else
      num = 0.0_real64
      status = -1
    end if
  end subroutine json_get_number

  subroutine json_get_bool(val, b, status)
    type(json_value_type), intent(in) :: val
    logical, intent(out) :: b
    integer(kind=int32), intent(out) :: status

    if (val%value_type == JSON_BOOL_TYPE) then
      b = val%bool_val
      status = 0
    else
      b = .false.
      status = -1
    end if
  end subroutine json_get_bool

  !-----------------------------------------------------------------------------
  ! Serializer
  ! Single-entry / single-exit loop traversal without goto
  !-----------------------------------------------------------------------------
  subroutine json_serialize(val, out_str)
    type(json_value_type), intent(in) :: val
    character(len=*), intent(out) :: out_str

    character(len=2048) :: buffer
    character(len=512) :: sub_buf
    type(json_field_node), pointer :: f_curr
    type(json_element_node), pointer :: e_curr
    logical :: first

    buffer = ""

    select case (val%value_type)
    case (JSON_NULL_TYPE)
      buffer = "null"
    case (JSON_BOOL_TYPE)
      if (val%bool_val) then
        buffer = "true"
      else
        buffer = "false"
      end if
    case (JSON_NUM_TYPE)
      write(buffer, '(F12.4)') val%num_val
      buffer = adjustl(buffer)
    case (JSON_STR_TYPE)
      buffer = '"' // trim(val%str_val) // '"'
    case (JSON_OBJ_TYPE)
      buffer = "{"
      f_curr => val%first_field
      first = .true.
      do while (associated(f_curr))
        if (.not. first) buffer = trim(buffer) // ", "
        call json_serialize(f_curr%val, sub_buf)
        buffer = trim(buffer) // '"' // trim(f_curr%key) // '": ' // trim(sub_buf)
        first = .false.
        f_curr => f_curr%next
      end do
      buffer = trim(buffer) // "}"
    case (JSON_ARR_TYPE)
      buffer = "["
      e_curr => val%first_element
      first = .true.
      do while (associated(e_curr))
        if (.not. first) buffer = trim(buffer) // ", "
        call json_serialize(e_curr%val, sub_buf)
        buffer = trim(buffer) // trim(sub_buf)
        first = .false.
        e_curr => e_curr%next
      end do
      buffer = trim(buffer) // "]"
    end select

    out_str = trim(buffer)
  end subroutine json_serialize

  !-----------------------------------------------------------------------------
  ! Memory Cleanup
  !-----------------------------------------------------------------------------
  subroutine json_free(val)
    type(json_value_type), intent(inout) :: val

    type(json_field_node), pointer :: f_curr, f_next
    type(json_element_node), pointer :: e_curr, e_next

    if (val%value_type == JSON_OBJ_TYPE) then
      f_curr => val%first_field
      do while (associated(f_curr))
        f_next => f_curr%next
        if (associated(f_curr%val)) then
          call json_free(f_curr%val)
          deallocate(f_curr%val)
        end if
        deallocate(f_curr)
        f_curr => f_next
      end do
      val%first_field => null()
    else if (val%value_type == JSON_ARR_TYPE) then
      e_curr => val%first_element
      do while (associated(e_curr))
        e_next => e_curr%next
        if (associated(e_curr%val)) then
          call json_free(e_curr%val)
          deallocate(e_curr%val)
        end if
        deallocate(e_curr)
        e_curr => e_next
      end do
      val%first_element => null()
    end if

    val%value_type = JSON_NULL_TYPE
  end subroutine json_free

end module iris_json
