-- =====================================================================
-- package capypdf_tests
-- standard: ada 2022
-- description: regression test suite specifications for capypdf.
-- rules:
--   - explicit 'in' parameter modes on subprograms.
--   - no bare 'loop' constructs; use 'while' or 'for'.
--   - lowercase letters throughout (except string literals).
--   - lines kept strictly to 72 characters or less.
--   - modern ada 2022 contract aspects (pre, post).
--   - mccabe cyclomatic complexity <= 10 per subprogram.
-- =====================================================================

package capypdf_tests is

   type test_result is record
      passed : boolean := false;
      failed : boolean := false;
   end record;

   function run_page_config_test return test_result
   with
     post => run_page_config_test'result.passed or else
             run_page_config_test'result.failed;

   function run_drawing_operations_test return test_result
   with
     post => run_drawing_operations_test'result.passed or else
             run_drawing_operations_test'result.failed;

   function run_full_lifecycle_test return test_result
   with
     post => run_full_lifecycle_test'result.passed or else
             run_full_lifecycle_test'result.failed;

end capypdf_tests;
