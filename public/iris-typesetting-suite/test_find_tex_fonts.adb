-- SPDX-License-Identifier: MIT

pragma wide_character_encoding (utf8);
pragma ada_2022;

with ada.text_io;
with ada.strings.unbounded;
with font_finders;

procedure test_find_tex_fonts is

   use ada.text_io;
   use ada.strings.unbounded;
   use font_finders;
   use font_finders.unbounded_string_vectors;

   sysfonts : vector := find_tex_fonts;

begin
   for font of sysfonts loop
      put_line (to_string (font));
   end loop;
end test_find_tex_fonts;
