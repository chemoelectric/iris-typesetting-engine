--
--  SPDX-License-Identifier: MIT
--

pragma wide_character_encoding (utf8);
pragma ada_2022;

with ada.text_io;           use ada.text_io;
with ada.strings.unbounded; use ada.strings.unbounded;
with ada.containers;        use ada.containers;
with radix_tries;

procedure test_radix_tries is
   package string_radix_tries is new
     radix_tries (element_type => unbounded_string);
   use string_radix_tries;

   procedure try (predicate_string : in string; predicate : in boolean)
   is
   begin
      if not predicate then
         raise constraint_error
           with """" & predicate_string & """ failed";
      end if;
   end try;

   procedure test_aggregates is
      p : radix_trie;
   begin
      put_line ("test_aggregates");
      try ("length (p) = 0", length (p) = 0);
      p :=
        [1          => to_unbounded_string ("a"),
         3          => to_unbounded_string ("b"),
         5          => to_unbounded_string ("c"),
         1234567890 => to_unbounded_string ("d")];
      try ("length (p) = 4", length (p) = 4);
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
   end test_aggregates;

begin
   test_aggregates;
end test_radix_tries;
