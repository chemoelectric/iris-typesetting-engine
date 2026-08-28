------------------------------------------------------------------------
--
-- SPDX-License-Identifier: MIT
--
-- A wrapper around the CapyPDF FFI.
--
------------------------------------------------------------------------

pragma wide_character_encoding (utf8);
pragma ada_2022;

with system;               use system;
with interfaces;           use interfaces;
with interfaces.c;         use interfaces.c;
with interfaces.c.strings; use interfaces.c.strings;
with interfaces.c_streams; use interfaces.c_streams;
with ada.strings.unbounded;

package body font_finders is

   subtype int is interfaces.c.int;
   subtype fsize_t is interfaces.c_streams.size_t;

   -- POSIX standard: WIFEXITED checks if the low 7 bits are 0.
   function w_is_exited (status : int) return boolean is
   begin
      return ((unsigned_64 (status) and 16#7f#) = 0);
   end w_is_exited;

   -- POSIX standard: WEXITSTATUS shifts right by 8 bits and masks the
   -- low byte.
   function w_exit_status (status : int) return int is
   begin
      return (int ((unsigned_64 (status) / 256) and 16#ff#));
   end w_exit_status;

   function popen (command : chars_ptr; mode : chars_ptr) return files
   with import, convention => c, external_name => "popen";

   function pclose (stream : files) return int
   with import, convention => c, external_name => "pclose";

   function find_main_system_fonts
      return unbounded_string_vectors.vector is
   begin
      return find_fonts (main_system_fonts_command);
   end find_main_system_fonts;

   function find_tex_fonts return unbounded_string_vectors.vector is
   begin
      return find_fonts (tex_fonts_command);
   end find_tex_fonts;

   procedure find_fonts
     (vector : in out unbounded_string_vectors.vector;
      stream : in files)
   is
      bufsize : constant integer := 8192;
      buf     : string (1 .. bufsize);
      nread   : natural;
      line    : unbounded_string := null_unbounded_string;
      iline   : integer range 1 .. bufsize + 1;

      procedure fill_buf is
      begin
         nread :=
           natural
             (fread
                (buffer => buf'address,
                 size   => fsize_t (1),
                 count  => fsize_t (bufsize),
                 stream => stream));
      end fill_buf;

   begin
      --
      -- Break buffered input into lines.
      --
      fill_buf;
      while nread /= 0 loop
         iline := 1;
         for i in 1 .. nread loop
            if buf (i) = ascii.lf then
               append (line, buf (iline .. i - 1));
               vector.append (line);
               line := null_unbounded_string;
               iline := i + 1;
            end if;
         end loop;
         if iline <= nread then
            append (line, buf (iline .. nread));
         end if;
         fill_buf;
      end loop;
      if length (line) /= 0 then
         -- A final line that did not end in a newline.
         vector.append (line);
      end if;
   end find_fonts;

   function find_fonts
     (command : in unbounded_string)
      return unbounded_string_vectors.vector
   is
      cmd      : chars_ptr;
      mode     : chars_ptr;
      stream   : files;
      i_pclose : int;
      i_exit   : int;
      fonts    : unbounded_string_vectors.vector;
   begin
      if length (command) /= 0 then
         cmd := new_string (to_string (command));
         mode := new_string ("r");
         stream := popen (cmd, mode);
         if stream = null_stream then
            raise find_fonts_error
              with "failed to run $(" & to_string (command) & ")";
         end if;
         free (cmd);
         free (mode);
         find_fonts (vector => fonts, stream => stream);
         i_pclose := pclose (stream);
         if i_pclose = -1 then
            raise find_fonts_error with "pclose error";
         elsif not w_is_exited (i_pclose) then
            raise find_fonts_error
              with "child process exited abnormally";
         else
            i_exit := w_exit_status (i_pclose);
            if i_exit /= 0 then
               raise nonzero_exit_status with i_exit'image;
            end if;
         end if;
      end if;
      return fonts;
   exception
      when others =>
         if cmd /= null_ptr then
            free (cmd);
         end if;
         if mode /= null_ptr then
            free (mode);
         end if;
         raise;
   end find_fonts;

end font_finders;
