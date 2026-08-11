!===============================================================================
! Program: test_iris_json
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Automated Regression Test for Iris JSON AST Engine
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
program test_iris_json
  use, intrinsic :: iso_fortran_env, only: int32, real64
  use iris_json
  implicit none

  type(json_value_type) :: root_obj, num_val, str_val, bool_val, null_val, arr_val
  type(json_value_type) :: retrieved_val
  character(len=512)    :: json_str
  integer(kind=int32)   :: status, exit_code
  real(kind=real64)     :: r_num
  logical               :: b_val
  character(len=256)    :: s_val

  exit_code = 0

  ! 1. Test Object Creation & Mutators
  call json_create_object(root_obj)
  if (json_get_type(root_obj) /= JSON_OBJ_TYPE) then
    print *, "TEST FAIL: root_obj type mismatch"
    exit_code = 1
  end if

  ! 2. Test Primitive Value Constructors
  call json_create_number(num_val, 123.45_real64)
  call json_create_string(str_val, "Iris Typographic Engine")
  call json_create_bool(bool_val, .true.)
  call json_create_null(null_val)

  ! 3. Test Field Insertion
  call json_set_field(root_obj, "version", num_val)
  call json_set_field(root_obj, "name", str_val)
  call json_set_field(root_obj, "active", bool_val)
  call json_set_field(root_obj, "extra", null_val)

  ! 4. Test Field Retrieval
  call json_get_field(root_obj, "name", retrieved_val, status)
  if (status /= 0) then
    print *, "TEST FAIL: json_get_field name status"
    exit_code = 2
  end if

  call json_get_string(retrieved_val, s_val, status)
  if (status /= 0 .or. trim(s_val) /= "Iris Typographic Engine") then
    print *, "TEST FAIL: json_get_string mismatch"
    exit_code = 3
  end if

  call json_get_field(root_obj, "version", retrieved_val, status)
  call json_get_number(retrieved_val, r_num, status)
  if (status /= 0 .or. abs(r_num - 123.45_real64) > 1.0e-5_real64) then
    print *, "TEST FAIL: json_get_number mismatch"
    exit_code = 4
  end if

  call json_get_field(root_obj, "active", retrieved_val, status)
  call json_get_bool(retrieved_val, b_val, status)
  if (status /= 0 .or. .not. b_val) then
    print *, "TEST FAIL: json_get_bool mismatch"
    exit_code = 5
  end if

  ! 5. Test Array Operations
  call json_create_array(arr_val)
  call json_add_element(arr_val, num_val)
  call json_add_element(arr_val, str_val)

  call json_get_element(arr_val, 1, retrieved_val, status)
  if (status /= 0 .or. json_get_type(retrieved_val) /= JSON_NUM_TYPE) then
    print *, "TEST FAIL: json_get_element array index 1"
    exit_code = 6
  end if

  ! 6. Test Serialization
  call json_serialize(root_obj, json_str)
  if (len_trim(json_str) == 0 .or. index(json_str, "Iris Typographic Engine") == 0) then
    print *, "TEST FAIL: json_serialize output error"
    exit_code = 7
  end if

  ! 7. Free Resources
  call json_free(root_obj)
  call json_free(arr_val)

  if (exit_code == 0) then
    print *, "TEST PASS: Iris JSON module API verified successfully."
  else
    stop 1
  end if
end program test_iris_json
