--  SPDX-License-Identifier: MIT

--
-- A program to read and write s-expressions.
--

pragma wide_character_encoding (utf8);
pragma ada_2022;

with ada.command_line;
with ada.wide_wide_text_io;
with ada.wide_wide_text_io.text_streams;
with sexpressions;

procedure test_sexpressions_read_write is

   use ada.command_line;
   use ada.wide_wide_text_io;
   use ada.wide_wide_text_io.text_streams;
   use sexpressions;

   expression : sexpr;

begin
   case argument_count is
      when 1      =>
         expression :=
           read_from_string (to_sexpr_fixstr (argument (1)));
         sexpr_fixstr'output
           (stream (current_output),
            to_sexpr_fixstr (write_simple_to_string (expression)));

      when others =>
         put_line ("argument_count must be 1");
         set_exit_status (1);
   end case;
end test_sexpressions_read_write;

-- local variables:
-- coding: utf-8
-- end:
