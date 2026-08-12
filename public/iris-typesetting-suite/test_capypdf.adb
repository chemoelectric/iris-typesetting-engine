-- =====================================================================
-- procedure test_capypdf
-- standard: ada 2022
-- SPDX-License-Identifier: MIT
-- description: main regression test runner for capypdf ada binding.
-- rules:
--   - explicit 'in' parameter modes on subprograms.
--   - no bare 'loop' constructs; use 'while' or 'for'.
--   - lowercase letters throughout (except string literals).
--   - lines kept strictly to 72 characters or less.
--   - mccabe cyclomatic complexity <= 10 for main program.
-- =====================================================================

with ada.text_io; use ada.text_io;
with capypdf_tests; use capypdf_tests;

procedure test_capypdf is
   type test_case is record
      name : string (1 .. 24);
      res  : test_result;
   end record;

   r1 : constant test_result := run_page_config_test;
   r2 : constant test_result := run_drawing_operations_test;
   r3 : constant test_result := run_full_lifecycle_test;

   cases : constant array (1 .. 3) of test_case :=
     [1 => (name => "page_config_test        ", res => r1),
      2 => (name => "drawing_operations_test ", res => r2),
      3 => (name => "full_lifecycle_test     ", res => r3)];

   pass_count : natural := 0;
   fail_count : natural := 0;
begin
   put_line ("=== capypdf ada regression test suite ===");

   for i in cases'range loop
      if cases (i).res.passed then
         pass_count := pass_count + 1;
         put_line ("[pass] " & cases (i).name);
      else
         fail_count := fail_count + 1;
         put_line ("[fail] " & cases (i).name);
      end if;
   end loop;

   put_line ("summary: " & natural'image (pass_count) &
             " passed, " & natural'image (fail_count) &
             " failed.");
end test_capypdf;
