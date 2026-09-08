--
--  SPDX-License-Identifier: MIT
--

pragma wide_character_encoding (utf8);
pragma ada_2022;

with ada.text_io;           use ada.text_io;
with ada.strings.unbounded; use ada.strings.unbounded;
with radix_tries;

procedure test_radix_tries is
   package string_radix_tries is new
     radix_tries (element_type => unbounded_string);
   use string_radix_tries;
begin
   put_line ("=== Entering Inner Scope Block ===");

   declare
      -- Initialize automatically executes here, making a fresh, safe
      -- root node.
      my_trie : radix_trie;
   begin
      include
        (my_trie,
         16#11223344#,
         to_unbounded_string ("Automated Engine Metric"));

      put_line
        ("Search Output: "
         & to_string (element (my_trie, 16#11223344#)));

   -- If you uncomment the line below, the compiler flags a legal syntax error:
   --
   -- declare duplicate : radix_trie := my_trie; -> Prohibited because type is limited.
   end;
   -- <<< Scope Block Ends Here.
   --
   -- Finalize automatically fires on My_Trie, cleanly destroying
   -- every node with zero leaks.

   put_line ("=== Inner Scope Terminated Cleanly ===");
end test_radix_tries;
