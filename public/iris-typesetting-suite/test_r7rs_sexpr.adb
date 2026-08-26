--  test_r7rs_sexpr.adb --- Unit Tests for R7RS S-Expressions
--
--  SPDX-License-Identifier: MIT

with Ada.Text_IO;
with Interfaces;
with r7rs_sexpr;

procedure test_r7rs_sexpr is

   use Ada.Text_IO;
   use Interfaces;
   use r7rs_sexpr;

   total_tests  : natural := 0;
   failed_tests : natural := 0;

   procedure assert_true
     (cond : in boolean;
      msg  : in string)
   is
   begin
      total_tests := total_tests + 1;
      if not cond then
         failed_tests := failed_tests + 1;
         put_line ("FAIL: " & msg);
      end if;
   end assert_true;

   procedure test_null_and_booleans is
      n  : sexpr := make_null;
      bt : sexpr := make_boolean (true);
      bf : sexpr := make_boolean (false);
   begin
      assert_true (is_null (n), "n should be null");
      assert_true (write_to_string (n) = "()", "null string ()");
      assert_true (is_boolean (bt), "bt is boolean");
      assert_true (get_boolean (bt) = true, "bt is true");
      assert_true (write_to_string (bt) = "#t", "bt write #t");
      assert_true (is_boolean (bf), "bf is boolean");
      assert_true (get_boolean (bf) = false, "bf is false");
      assert_true (write_to_string (bf) = "#f", "bf write #f");
   end test_null_and_booleans;

   procedure test_numbers is
      i : sexpr := make_integer (42);
      r : sexpr := make_real (3.14);
      q : sexpr := make_rational (22, 7);
   begin
      assert_true (is_integer (i), "i is integer");
      assert_true (get_integer (i) = 42, "i = 42");
      assert_true (write_to_string (i) = "42", "i write 42");

      assert_true (is_real (r), "r is real");
      assert_true (get_real (r) > 3.13 and get_real (r) < 3.15,
                   "r ~ 3.14");

      assert_true (is_rational (q), "q is rational");
      assert_true (get_numerator (q) = 22, "num = 22");
      assert_true (get_denominator (q) = 7, "den = 7");
      assert_true (write_to_string (q) = "22/7", "q write 22/7");
   end test_numbers;

   procedure test_characters_and_strings is
      c : sexpr := make_character ('a');
      s : sexpr := make_string ("hello world");
   begin
      assert_true (is_character (c), "c is character");
      assert_true (write_to_string (c) = "#\a", "c write #\a");

      assert_true (is_string (s), "s is string");
      assert_true (get_string_str (s) = "hello world",
                   "s = hello world");
      assert_true (write_to_string (s) = """hello world""",
                   "s write quoted");
      assert_true (display_to_string (s) = "hello world",
                   "s display unquoted");
   end test_characters_and_strings;

   procedure test_symbols is
      sym : sexpr := make_symbol ("foobar");
   begin
      assert_true (is_symbol (sym), "sym is symbol");
      assert_true (get_symbol_str (sym) = "foobar", "sym = foobar");
      assert_true (write_to_string (sym) = "foobar", "sym write");
   end test_symbols;

   procedure test_pairs_and_lists is
      p  : sexpr := cons (make_integer (1), make_integer (2));
      l1 : sexpr := cons (make_integer (1),
                          cons (make_integer (2),
                                cons (make_integer (3), make_null)));
   begin
      assert_true (is_pair (p), "p is pair");
      assert_true (get_integer (car (p)) = 1, "car(p) = 1");
      assert_true (get_integer (cdr (p)) = 2, "cdr(p) = 2");
      assert_true (write_to_string (p) = "(1 . 2)", "p write (1 . 2)");

      assert_true (is_list (l1), "l1 is list");
      assert_true (length (l1) = 3, "l1 length 3");
      assert_true (get_integer (list_ref (l1, 1)) = 1, "l1(1) = 1");
      assert_true (get_integer (list_ref (l1, 2)) = 2, "l1(2) = 2");
      assert_true (get_integer (list_ref (l1, 3)) = 3, "l1(3) = 3");
      assert_true (write_to_string (l1) = "(1 2 3)",
                   "l1 write (1 2 3)");
   end test_pairs_and_lists;

   procedure test_vectors_and_bytevectors is
      items : sexpr_array (1 .. 3);
      v     : sexpr;
      bytes : byte_array (1 .. 3);
      bv    : sexpr;
   begin
      items (1) := make_symbol ("a");
      items (2) := make_symbol ("b");
      items (3) := make_symbol ("c");
      v := make_vector (items);

      assert_true (is_vector (v), "v is vector");
      assert_true (vector_length (v) = 3, "v length = 3");
      assert_true (get_symbol_str (vector_ref (v, 2)) = "b",
                   "v(2) = b");
      assert_true (write_to_string (v) = "#(a b c)",
                   "v write #(a b c)");

      bytes (1) := 10;
      bytes (2) := 20;
      bytes (3) := 30;
      bv := make_bytevector (bytes);

      assert_true (is_bytevector (bv), "bv is bytevector");
      assert_true (bytevector_length (bv) = 3, "bv length = 3");
      assert_true (bytevector_ref (bv, 2) = 20, "bv(2) = 20");
      assert_true (write_to_string (bv) = "#u8(10 20 30)",
                   "bv write #u8(10 20 30)");
   end test_vectors_and_bytevectors;

   procedure test_reader_basics is
      e1 : sexpr := read_from_string ("(+ 10 20 #x1f)");
      e2 : sexpr := read_from_string ("#t");
      e3 : sexpr := read_from_string ("#false");
      e4 : sexpr := read_from_string ("#\space");
      e5 : sexpr := read_from_string ("#\newline");
      e6 : sexpr := read_from_string ("""hello\nworld""");
      e7 : sexpr := read_from_string ("#(1 2 3)");
      e8 : sexpr := read_from_string ("#u8(1 2 3)");
      e9 : sexpr := read_from_string ("'foo");
   begin
      assert_true (is_list (e1), "read list");
      assert_true (length (e1) = 4, "read list length 4");
      assert_true (get_symbol_str (car (e1)) = "+", "car = +");
      assert_true (get_integer (cadr (e1)) = 10, "cadr = 10");
      assert_true (get_integer (list_ref (e1, 4)) = 31, "#x1f = 31");

      assert_true (is_boolean (e2) and then get_boolean (e2) = true,
                   "read #t");
      assert_true (is_boolean (e3) and then get_boolean (e3) = false,
                   "read #false");
      assert_true (is_character (e4) and then get_character (e4) = ' ',
                   "read #\space");
      assert_true (is_character (e5) and then
                   get_character (e5) = wide_wide_character'val (10),
                   "read #\newline");

      assert_true (is_string (e6), "read string with escapes");
      assert_true (is_vector (e7), "read vector");
      assert_true (is_bytevector (e8), "read bytevector");
      assert_true (is_pair (e9) and then
                   get_symbol_str (car (e9)) = "quote",
                   "read quote");
   end test_reader_basics;

   procedure test_comments_and_labels is
      e1 : sexpr := read_from_string
        ("; comment" & ascii.lf & "(1 #; (skip this) 2 #| block |# 3)");
      e2 : sexpr := read_from_string
        ("#0=(a b . #0#)");
   begin
      assert_true (is_list (e1), "read with comments");
      assert_true (length (e1) = 3, "e1 length 3");
      assert_true (get_integer (list_ref (e1, 1)) = 1, "e1(1)=1");
      assert_true (get_integer (list_ref (e1, 2)) = 2, "e1(2)=2");
      assert_true (get_integer (list_ref (e1, 3)) = 3, "e1(3)=3");

      assert_true (is_pair (e2), "read labeled datum");
      assert_true (get_symbol_str (car (e2)) = "a",
                   "labeled datum car");
   end test_comments_and_labels;

   procedure test_alists is
      al : sexpr := make_null;
      f  : sexpr;
   begin
      al := acons (make_symbol ("name"), make_string ("iris"), al);
      al := acons (make_symbol ("version"), make_integer (1), al);

      f := assq ("name", al);
      assert_true (is_pair (f), "found name in alist");
      assert_true (get_string_str (cdr (f)) = "iris", "name is iris");

      f := assq ("version", al);
      assert_true (is_pair (f), "found version in alist");
      assert_true (get_integer (cdr (f)) = 1, "version is 1");

      f := assq ("nonexistent", al);
      assert_true (is_null (f), "nonexistent returns null");
   end test_alists;

begin
   test_null_and_booleans;
   test_numbers;
   test_characters_and_strings;
   test_symbols;
   test_pairs_and_lists;
   test_vectors_and_bytevectors;
   test_reader_basics;
   test_comments_and_labels;
   test_alists;

   if failed_tests = 0 then
      put_line ("All " & natural'image (total_tests) &
                " R7RS S-Expression unit tests PASSED.");
   else
      put_line (natural'image (failed_tests) & " of " &
                natural'image (total_tests) & " tests FAILED.");
      raise program_error with "Unit tests failed";
   end if;
end test_r7rs_sexpr;
