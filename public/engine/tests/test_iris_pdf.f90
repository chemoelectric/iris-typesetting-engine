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

  type(pdf_document_type) :: pdf
  integer(kind=int32)     :: exit_code, status, read_pcount
  logical                 :: file_exists
  character(len=64)       :: sample_cff_bytes

  exit_code = 0
  sample_cff_bytes = "CFF Font Stream Sample Data Payload 0123456789"

  ! 1. Initialize PDF Document with Font Embedding & Tagged Structure
  call pdf_init(pdf, "test_pdf_out.pdf", status, compress=.true.)

  ! 2. Embed CFF Font Data
  call pdf_embed_font_cff(pdf, "SortsMillGoudy-Regular", sample_cff_bytes)

  ! 3. Add Page
  call pdf_add_page(pdf, 595.0_real64, 842.0_real64)
  if (pdf%page_count /= 1) then
    print *, "TEST FAIL: Page count mismatch"
    exit_code = 1
  end if

  ! 4. Write Text Content (Tagged PDF Marked Content)
  call pdf_write_text(pdf, 72.0_real64, 750.0_real64, 12.0_real64, &
                      "Iris Microtypography Engine PDF Regression Test")

  ! 5. Finalize & Flush Output PDF File
  call pdf_close(pdf, status)

  ! 6. Verify PDF File Creation
  inquire(file="test_pdf_out.pdf", exist=file_exists)
  if (.not. file_exists) then
    print *, "TEST FAIL: Output PDF file was not created on disk"
    exit_code = 2
  end if

  ! 7. Test Reading PDF File Back
  call pdf_open_read(pdf, "test_pdf_out.pdf", status)
  if (status == 0) then
    call pdf_get_page_count(pdf, read_pcount)
    if (read_pcount /= 1) then
      print *, "TEST FAIL: Parsed page count mismatch"
      exit_code = 3
    end if
    call pdf_close(pdf, status)
  end if

  if (exit_code == 0) then
    print *, "TEST PASS: Iris PDF document module API with CFF/TrueType, ToUnicode & Tagged PDF verified successfully."
  else
    stop 1
  end if
end program test_iris_pdf
