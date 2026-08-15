-- =====================================================================
-- procedure test_fontconfig
-- standard: ada 2022
-- SPDX-License-Identifier: MIT
-- =====================================================================

with fontconfig; use fontconfig;
with ada.command_line; use ada.command_line;

procedure test_fontconfig is
   ok       : boolean := true;
   init_ok  : boolean;
   pat      : fc_pattern_ptr := null_pattern;
   match    : fc_pattern_ptr := null_pattern;
   filename : string (1 .. 1024) := [others => ' '];
   file_len : natural := 0;
begin
   init_ok := init;
   if not init_ok then
      ok := false;
   end if;

   if ok then
      pat := parse_name ("DejaVu Sans");
      if pat = null_pattern then
         ok := false;
      end if;
   end if;

   if ok then
      match := match_font (pat);
      if match /= null_pattern then
         declare
            f : constant string := get_font_file (match);
         begin
            file_len := natural'min (f'length, filename'length);
            filename (1 .. file_len) := f (1 .. file_len);
         end;
         destroy_pattern (match);
      end if;
      destroy_pattern (pat);
   end if;

   fini;

   if ok then
      set_exit_status (success);
   else
      set_exit_status (failure);
   end if;
end test_fontconfig;
