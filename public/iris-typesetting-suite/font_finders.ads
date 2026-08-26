------------------------------------------------------------------------
--
-- SPDX-License-Identifier: MIT
--
------------------------------------------------------------------------

pragma wide_character_encoding (utf8);
pragma ada_2022;

with ada.containers.indefinite_vectors;
with ada.strings.unbounded; use ada.strings.unbounded;

package font_finders is

   find_fonts_error    : exception;
   nonzero_exit_status : exception;

   package unbounded_string_vectors is new
     ada.containers.indefinite_vectors
       (index_type   => positive,
        element_type => unbounded_string);

   default_main_system_fonts_command : constant unbounded_string :=
     to_unbounded_string
       ("fc-list -b | sed 's|^\s*file:\s\s*""\(.*\)"".*|\1|p;d'");

   default_tex_fonts_command : constant unbounded_string :=
     to_unbounded_string
       ("find $(kpsewhich --var-value=TEXMFDIST && " &
        "kpsewhich --var-value=TEXMFLOCAL) -type f -print | " &
        " sed '/\.[otOT][tT][fF]$/p;d'");

   main_system_fonts_command : unbounded_string :=
     default_main_system_fonts_command;

   tex_fonts_command : unbounded_string :=
     default_tex_fonts_command;

   function find_main_system_fonts
      return unbounded_string_vectors.vector;

   function find_tex_fonts
     return unbounded_string_vectors.vector;

   function find_fonts
     (command : in unbounded_string)
      return unbounded_string_vectors.vector;

end font_finders;
