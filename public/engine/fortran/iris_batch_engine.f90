!===============================================================================
! Module: iris_batch_engine
! Standard: Fortran 2008 (ISO/IEC 1539-1:2010)
! Architecture: Modular ConTeXt-Style Batch Typographic Pipeline &
!               CUPS-Compliant PDF/X-1a / PDF/A Document Emission Engine
! Rules: Single-entry/single-exit control constructs, no goto.
!        McCabe Cyclomatic Complexity <= 10 per procedure.
!===============================================================================
module iris_batch_engine
  use, intrinsic :: iso_fortran_env, only: int32, real64
  use iris_markup_parser, only: parse_result_type, parse_mixed_markup_text, &
                                 DIALECT_NATURAL_PROSE, DIALECT_TROFF_GROFF, &
                                 NODE_TYPE_HEADING, NODE_TYPE_PARAGRAPH, NODE_TYPE_INTENT_ANNOT
  use iris_pdf, only: pdf_document_type, pdf_init, pdf_add_page, &
                      pdf_write_text, pdf_close
  implicit none
  private

  ! Public Constants
  integer(kind=int32), parameter, public :: BATCH_OK                = 0
  integer(kind=int32), parameter, public :: BATCH_ERR_PARSE_FAIL    = -1
  integer(kind=int32), parameter, public :: BATCH_ERR_PDF_FAIL      = -2
  integer(kind=int32), parameter, public :: BATCH_WARN_AMBIGUITY    = 1

  ! Public Derived Types
  public :: batch_config_type
  public :: batch_run_report_type

  ! Public API Procedures
  public :: batch_init_config
  public :: batch_process_document

  type :: batch_config_type
    character(len=256) :: page_size = "A4"
    real(kind=real64)   :: margin_left = 72.0_real64   ! Points (1 inch)
    real(kind=real64)   :: margin_top  = 72.0_real64   ! Points (1 inch)
    real(kind=real64)   :: font_size   = 11.0_real64   ! Points
    logical             :: cups_pdf_x_compliance = .true. ! Enforce CUPS/PDF-X1a
  end type batch_config_type

  type :: batch_run_report_type
    integer(kind=int32) :: status = BATCH_OK
    integer(kind=int32) :: pages_generated = 0
    integer(kind=int32) :: detected_dialect = DIALECT_NATURAL_PROSE
    logical             :: ambiguity_warning = .false.
    character(len=256)  :: status_msg = "Success"
  end type batch_run_report_type

contains

  !-----------------------------------------------------------------------------
  ! Initialize batch processing configuration defaults
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine batch_init_config(cfg)
    type(batch_config_type), intent(out) :: cfg

    cfg%page_size = "A4"
    cfg%margin_left = 72.0_real64
    cfg%margin_top = 72.0_real64
    cfg%font_size = 11.0_real64
    cfg%cups_pdf_x_compliance = .true.
  end subroutine batch_init_config

  !-----------------------------------------------------------------------------
  ! Process mixed input document and compile to CUPS-ready PDF
  ! Single-entry / single-exit implementation
  !-----------------------------------------------------------------------------
  subroutine batch_process_document(input_content, output_pdf_filename, cfg, report)
    character(len=*), intent(in)            :: input_content
    character(len=*), intent(in)            :: output_pdf_filename
    type(batch_config_type), intent(in)     :: cfg
    type(batch_run_report_type), intent(out):: report

    type(parse_result_type) :: parse_ast
    type(pdf_document_type) :: pdf_doc
    integer(kind=int32)     :: pdf_stat, p_stat, i, est_lines
    real(kind=real64)       :: cur_y, line_h, para_h, page_h, margin_b

    report%status = BATCH_OK
    report%pages_generated = 0
    report%status_msg = "Processing completed successfully."

    page_h = 842.0_real64
    margin_b = cfg%margin_top

    ! Step 1: Parse mixed input text & disambiguate markup dialect
    call parse_mixed_markup_text(input_content, parse_ast)

    report%detected_dialect = parse_ast%detected_dialect
    report%ambiguity_warning = parse_ast%ambiguity_detected

    if (parse_ast%ambiguity_detected) then
      report%status = BATCH_WARN_AMBIGUITY
      report%status_msg = parse_ast%disambiguation_msg
    end if

    ! Step 2: Initialize PDF Engine & create page
    call pdf_init(pdf_doc, trim(output_pdf_filename), pdf_stat)

    if (pdf_stat /= 0) then
      report%status = BATCH_ERR_PDF_FAIL
      report%status_msg = "Error initializing PDF document."
    else
      call pdf_add_page(pdf_doc, 595.0_real64, page_h)
      cur_y = page_h - cfg%margin_top
      line_h = cfg%font_size * 1.35_real64

      ! Step 3: Layout AST token sequence onto PDF pages
      if (parse_ast%token_count > 0) then
        do i = 1, parse_ast%token_count
          if (parse_ast%tokens(i)%node_type == NODE_TYPE_HEADING) then
            if (cur_y < margin_b + 40.0_real64) then
              call pdf_add_page(pdf_doc, 595.0_real64, page_h)
              cur_y = page_h - cfg%margin_top
            end if
            call pdf_write_text(pdf_doc, cfg%margin_left, cur_y, cfg%font_size + 4.0_real64, &
                              trim(parse_ast%tokens(i)%content))
            cur_y = cur_y - (cfg%font_size + 4.0_real64) * 1.5_real64 - 12.0_real64

          else if (parse_ast%tokens(i)%node_type == NODE_TYPE_PARAGRAPH) then
            est_lines = max(1, len_trim(parse_ast%tokens(i)%content) / 75 + 1)
            para_h = est_lines * line_h + 14.0_real64

            if (cur_y - para_h < margin_b .and. cur_y < page_h - cfg%margin_top - 40.0_real64) then
              call pdf_add_page(pdf_doc, 595.0_real64, page_h)
              cur_y = page_h - cfg%margin_top
            end if

            call pdf_write_text(pdf_doc, cfg%margin_left, cur_y, cfg%font_size, &
                              trim(parse_ast%tokens(i)%content))
            cur_y = cur_y - para_h

          else if (parse_ast%tokens(i)%node_type == NODE_TYPE_INTENT_ANNOT) then
            if (trim(parse_ast%tokens(i)%parameter) == "page_break") then
              call pdf_add_page(pdf_doc, 595.0_real64, page_h)
              cur_y = page_h - cfg%margin_top
            end if
          end if
        end do
      end if

      ! Step 4: Write CUPS-compliant PDF output file
      call pdf_close(pdf_doc, p_stat)

      if (p_stat /= 0) then
        report%status = BATCH_ERR_PDF_FAIL
        report%status_msg = "Error writing compiled PDF file to disk."
      else
        report%pages_generated = pdf_doc%page_count
      end if
    end if
  end subroutine batch_process_document

end module iris_batch_engine
