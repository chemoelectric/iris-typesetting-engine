--  SPDX-License-Identifier: MIT

--
-- A program to test the “equal” function of sexpressions.ad[bs]
--

pragma wide_character_encoding (utf8);
pragma ada_2022;

with ada.command_line;
with ada.wide_wide_text_io;
with sexpressions;

procedure test_sexpressions_equal is

   use ada.command_line;
   use ada.wide_wide_text_io;
   use sexpressions;

   first  : sexpr;
   second : sexpr;

begin
   case argument_count is
      when 2      =>
         first := read_from_string (to_sexpr_string (argument (1)));
         second := read_from_string (to_sexpr_string (argument (2)));
         put ((if equal (first, second) then "1" else "0"));

      when others =>
         put_line ("argument_count must be 2");
         set_exit_status (1);
   end case;
end test_sexpressions_equal;

-- local variables:
-- coding: utf-8
-- end:
