!===============================================================================
! Program: test_iris_tex
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Automated Regression Test for Iris Modular TeX Engine
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
program test_iris_tex
  use, intrinsic :: iso_fortran_env, only: int32
  use iris_json, only: json_value_type, json_free
  use iris_tex
  implicit none

  type(tex_engine_type) :: eng
  type(json_value_type) :: ast
  integer(kind=int32)   :: status, exit_code

  exit_code = 0

  ! 1. Initialize Engine
  call tex_init(eng, "test_job")
  if (trim(eng%jobname) /= "test_job") then
    print *, "TEST FAIL: tex_init jobname mismatch"
    exit_code = 1
  end if

  ! 2. Compile TeX Source String
  call tex_compile_string(eng, "\hello world", ast, status)
  if (status /= TEX_OK) then
    print *, "TEST FAIL: tex_compile_string failed"
    exit_code = 2
  end if

  ! 3. Clean up
  call json_free(ast)
  call tex_free(eng)

  if (exit_code == 0) then
    print *, "TEST PASS: Iris TeX engine module API verified successfully."
  else
    stop 1
  end if
end program test_iris_tex
