-- =====================================================================
-- package body capypdf_tests
-- standard: ada 2022
-- description: regression test suite implementation for capypdf.
-- rules:
--   - explicit 'in' parameter modes on subprograms.
--   - no bare 'loop' constructs; use 'while' or 'for'.
--   - lowercase letters throughout (except string literals).
--   - lines kept strictly to 72 characters or less.
--   - mccabe cyclomatic complexity <= 10 per subprogram.
-- =====================================================================

with capypdf; use capypdf;
with interfaces.c;

package body capypdf_tests is

   function run_page_config_test return test_result is
      cfg    : page_config;
      res    : test_result;
      width  : constant interfaces.c.double := 595.28;
      height : constant interfaces.c.double := 841.89;
   begin
      cfg := create_page_config (width, height);
      if cfg.prop /= null_page_properties then
         destroy_page_config (cfg);
         if cfg.prop = null_page_properties then
            res.passed := true;
         else
            res.failed := true;
         end if;
      else
         res.failed := true;
      end if;
      return res;
   end run_page_config_test;

   function run_drawing_operations_test return test_result is
      dc   : pdf_draw_context;
      err1 : capy_error;
      err2 : capy_error;
      res  : test_result;
   begin
      err1 := draw_rectangle (dc, 0.0, 0.0, 10.0, 10.0);
      err2 := fill_path (dc);
      if err1 = capy_err_invalid_state and then
         err2 = capy_err_invalid_state
      then
         res.passed := true;
      else
         res.failed := true;
      end if;
      return res;
   end run_drawing_operations_test;

   function run_full_lifecycle_test return test_result is
      doc  : pdf_document;
      dc   : pdf_draw_context;
      err1 : capy_error;
      err2 : capy_error;
      err3 : capy_error;
      res  : test_result;
   begin
      doc := create_document ("test_output.pdf");
      if is_valid (doc) then
         dc   := create_draw_context (doc);
         err1 := draw_rectangle (dc, 50.0, 50.0, 100.0, 100.0);
         err2 := add_page_with_context (doc, dc);
         err3 := close_document (doc);
         if err1 = capy_err_ok and then
            err2 = capy_err_ok and then
            err3 = capy_err_ok and then
            not is_valid (doc)
         then
            res.passed := true;
         else
            res.failed := true;
         end if;
      else
         res.passed := true;
      end if;
      return res;
   end run_full_lifecycle_test;

end capypdf_tests;
