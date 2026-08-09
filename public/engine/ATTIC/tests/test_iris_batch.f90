!===============================================================================
! Program: test_iris_batch
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Automated Test Runner for Iris Batch Processing Engine
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10.
!===============================================================================
program test_iris_batch
  use, intrinsic :: iso_fortran_env, only: int32
  use iris_batch_engine, only: batch_config_type, batch_run_report_type, &
                                 batch_init_config, batch_process_document, BATCH_OK
  implicit none

  type(batch_config_type)     :: cfg
  type(batch_run_report_type) :: report
  character(len=512)          :: sample_doc
  integer(kind=int32)          :: exit_code

  exit_code = 0

  call batch_init_config(cfg)
  cfg%font_size = 12.0_8

  sample_doc = "[markup: troff] .TH TEST 1" // char(10) // &
               ".SH NAME" // char(10) // &
               "iris_test - Test batch compiler pass"

  call batch_process_document(sample_doc, "test_output.pdf", cfg, report)

  if (report%status /= BATCH_OK .and. report%status /= 1) then
    print *, "TEST FAIL: Batch processing error code", report%status
    exit_code = 1
  else if (report%pages_generated /= 1) then
    print *, "TEST FAIL: Page count mismatch"
    exit_code = 2
  else
    print *, "TEST PASS: Iris Batch Compilation Engine verified successfully."
  end if

  if (exit_code /= 0) stop 1
end program test_iris_batch
