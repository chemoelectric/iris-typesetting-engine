--
--  SPDX-License-Identifier: MIT
--

pragma wide_character_encoding (utf8);
pragma ada_2022;

with ada.text_io;           use ada.text_io;
with ada.strings.unbounded; use ada.strings.unbounded;
with ada.containers;        use ada.containers;
with interfaces;            use interfaces;
with radix_tries;

procedure test_radix_tries is
   package integer_radix_tries is new
     radix_tries (element_type => integer);
   subtype integer_radix_trie is integer_radix_tries.radix_trie;

   package unbounded_string_radix_tries is new
     radix_tries (element_type => unbounded_string);
   subtype unbounded_string_radix_trie is
     unbounded_string_radix_tries.radix_trie;

   procedure try (predicate_string : in string; predicate : in boolean)
   is
   begin
      if not predicate then
         raise constraint_error
           with """" & predicate_string & """ failed";
      end if;
   end try;

   procedure test_aggregates is
      p : unbounded_string_radix_trie;
   begin
      put_line ("test_aggregates");
      try ("p.length = 0", p.length = 0);
      try ("p.is_empty", p.is_empty);
      p :=
        [1          => to_unbounded_string ("a"),
         3          => to_unbounded_string ("b"),
         5          => to_unbounded_string ("c"),
         1234567890 => to_unbounded_string ("d")];
      try ("p.length = 4", p.length = 4);
      try ("not p.is_empty", not p.is_empty);
      try
        ("p (1) = to_unbounded_string (""a"")",
         p (1) = to_unbounded_string ("a"));
      try
        ("p (3) = to_unbounded_string (""b"")",
         p (3) = to_unbounded_string ("b"));
      try
        ("p (5) = to_unbounded_string (""c"")",
         p (5) = to_unbounded_string ("c"));
      try
        ("p (1234567890) = to_unbounded_string (""d"")",
         p (1234567890) = to_unbounded_string ("d"));
      try
        ("p.element (1) = to_unbounded_string (""a"")",
         p.element (1) = to_unbounded_string ("a"));
      try
        ("p.element (3) = to_unbounded_string (""b"")",
         p.element (3) = to_unbounded_string ("b"));
      try
        ("p.element (5) = to_unbounded_string (""c"")",
         p.element (5) = to_unbounded_string ("c"));
      try
        ("p.element (1234567890) = to_unbounded_string (""d"")",
         p.element (1234567890) = to_unbounded_string ("d"));
      for s of p loop
         put_line (to_string (s));
      end loop;
   end test_aggregates;

   procedure test_indices is
      p : integer_radix_trie := [123 => 123];
   begin
      put_line ("test_indices");
      p (54321) := 54321;
      p (1234) := 1234;
      p (543210) := 543210;
      p (12345) := 12345;
      try ("p.length = 5", p.length = 5);
      try ("p (123) = 123", p (123) = 123);
      try ("p (1234) = 1234", p (1234) = 1234);
      try ("p (12345) = 12345", p (12345) = 12345);
      try ("p (54321) = 54321", p (54321) = 54321);
      try ("p (543210) = 543210", p (543210) = 543210);
      p (54321) := 2;
      p (12345) := 2;
      p (5555555) := 3;
      try ("p.length = 6", p.length = 6);
      try ("p (123) = 123", p (123) = 123);
      try ("p (1234) = 1234", p (1234) = 1234);
      try ("p (12345) = 2", p (12345) = 2);
      try ("p (5555555) = 3", p (5555555) = 3);
      try ("p (54321) = 2", p (54321) = 2);
      try ("p (543210) = 543210", p (543210) = 543210);
      for s of p loop
         put_line ((s'img));
      end loop;
      declare
         pos : integer_radix_tries.cursor :=
           integer_radix_tries.cursor (p.first);
      begin
         put_line (unsigned_32'image (pos.key));
         put_line (integer'image (pos.element));
      end;
   end test_indices;

begin
   test_aggregates;
   test_indices;
end test_radix_tries;
