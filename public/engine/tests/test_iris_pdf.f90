!===============================================================================
! Program: test_iris_pdf
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Automated Regression Test for Iris PDF Generation Engine
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
program test_iris_pdf
  use, intrinsic :: iso_fortran_env, only: int32, real64
  use iris_pdf
  implicit none

  type(pdf_doc_type)  :: pdf
  integer(kind=int32) :: exit_code
  logical             :: file_exists

  exit_code = 0

  ! 1. Initialize PDF Document
  call pdf_init_document(pdf, "test_pdf_out.pdf", 595.0_real64, 842.0_real64)

  ! 2. Add Page
  call pdf_add_page(pdf, 595.0_real64, 842.0_real64)
  if (pdf%page_count /= 1) then
    print *, "TEST FAIL: Page count mismatch"
    exit_code = 1
  end if

  ! 3. Write Text Content
  call pdf_write_text(pdf, 72.0_real64, 750.0_real64, 12.0_real64, &
                      "Iris Microtypography Engine PDF Regression Test")

  ! 4. Finalize & Flush Output PDF File
  call pdf_finalize_document(pdf)

  ! 5. Verify PDF File Creation
  inquire(file="test_pdf_out.pdf", exist=file_exists)
  if (.not. file_exists) then
    print *, "TEST FAIL: Output PDF file was not created on disk"
    exit_code = 2
  end if

  if (exit_code == 0) then
    print *, "TEST PASS: Iris PDF document module API verified successfully."
  else
    stop 1
  end if
end program test_iris_pdf
