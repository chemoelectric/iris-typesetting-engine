! ==============================================================================
! Program: test_iris_dvi
! Standard: ISO Fortran 2008
! Architecture: Automated Regression Test for Iris TeX DVI Output Engine
! ==============================================================================

program test_iris_dvi
  use, intrinsic :: iso_fortran_env, only: int32, real64
  use iris_dvi
  implicit none

  type(dvi_document_type) :: doc
  integer :: status
  logical :: file_exists
  integer(int32) :: sp_72pt, sp_10pt, sp_halfpt

  ! TeX scaled point conversion constants
  sp_72pt = 4718592_int32    ! 72 pt in sp
  sp_10pt = 655360_int32     ! 10 pt in sp
  sp_halfpt = 32768_int32    ! 0.5 pt in sp

  ! 1. Initialize DVI document
  call dvi_init(doc, "test_dvi_out.dvi", status)
  if (status /= 0) then
    print *, "TEST FAIL: Unable to initialize DVI document"
    stop 1
  end if

  ! 2. Define font cmr10 (Font #1)
  call dvi_define_font(doc, 1_int32, 1234567_int32, sp_10pt, sp_10pt, "cmr10", status)
  if (status /= 0) then
    print *, "TEST FAIL: Unable to define font in DVI document"
    stop 1
  end if

  ! 3. Begin Page 1
  call dvi_begin_page(doc, 1_int32, status)
  if (status /= 0) then
    print *, "TEST FAIL: Unable to begin page in DVI document"
    stop 1
  end if

  ! 4. Select font and write character string 'Hello'
  call dvi_select_font(doc, 1_int32, status)
  call dvi_write_char(doc, iachar('H'), status)
  call dvi_write_char(doc, iachar('e'), status)
  call dvi_write_char(doc, iachar('l'), status)
  call dvi_write_char(doc, iachar('l'), status)
  call dvi_write_char(doc, iachar('o'), status)

  ! 5. Move right and draw horizontal rule
  call dvi_move_right(doc, sp_10pt, status)
  call dvi_write_rule(doc, sp_halfpt, sp_72pt, status)

  ! 6. End Page 1
  call dvi_end_page(doc, status)
  if (status /= 0) then
    print *, "TEST FAIL: Unable to end page in DVI document"
    stop 1
  end if

  ! 7. Close and finalize DVI file
  call dvi_close(doc, status)
  if (status /= 0) then
    print *, "TEST FAIL: Unable to finalize DVI document"
    stop 1
  end if

  ! 8. Verify DVI File Creation
  inquire(file="test_dvi_out.dvi", exist=file_exists)
  if (.not. file_exists) then
    print *, "TEST FAIL: Output DVI file was not created on disk"
    stop 1
  else
    print *, "TEST PASS: Iris TeX DVI document module API verified successfully."
  end if

end program test_iris_dvi
