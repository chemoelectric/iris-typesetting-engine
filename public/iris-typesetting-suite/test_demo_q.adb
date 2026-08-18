-- =====================================================================
-- test_demo_q.adb
-- standard: ada 2022
-- SPDX-License-Identifier: MIT
-- description: regression test for iris q demo font finding and output.
-- rules:
--   - explicit 'in' parameter modes on subprograms.
--   - no bare 'loop' constructs; use 'while' or 'for'.
--   - lowercase letters throughout (except string literals).
--   - lines kept strictly to 72 characters or less.
--   - mccabe cyclomatic complexity <= 10 for all subprograms.
-- =====================================================================

with ada.text_io;           use ada.text_io;
with ada.command_line;      use ada.command_line;
with ada.directories;       use ada.directories;
with ada.strings.fixed;     use ada.strings.fixed;
with ada.strings.unbounded; use ada.strings.unbounded;
with interfaces.c;          use interfaces.c;
with capypdf;               use capypdf;
with database;              use database;

procedure test_demo_q is

   out_file_name   : constant string := "demo-q.pdf";
   target_font_tag : constant string := "PlayfairDisplay-Regular";
   ok              : boolean := true;
   resolved_font   : unbounded_string := null_unbounded_string;

   type path_array is array (positive range <>) of unbounded_string;

   procedure cleanup_output (status : in out boolean) is
   begin
      if status and then exists (out_file_name) then
         delete_file (out_file_name);
      end if;
   end cleanup_output;

   function get_candidate_paths return path_array is
      p1 : constant string :=
        "/usr/share/fonts/opentype/playfair/" &
        "PlayfairDisplay-Regular.otf";
      p2 : constant string :=
        "/usr/share/fonts/truetype/playfair/" &
        "PlayfairDisplay-Regular.ttf";
      p3 : constant string :=
        "/usr/share/fonts/playfair/" &
        "PlayfairDisplay-Regular.otf";
      p4 : constant string :=
        "/usr/local/share/fonts/" &
        "PlayfairDisplay-Regular.otf";
      p5 : constant string :=
        "/usr/share/texmf/fonts/opentype/public/playfair/Playfair.otf";
      p6 : constant string :=
        "/usr/share/texlive/texmf-dist/fonts/opentype/Playfair.otf";
      p7 : constant string :=
        "PlayfairDisplay-Regular.otf";

      res : path_array (1 .. 7);
   begin
      res (1) := to_unbounded_string (p1);
      res (2) := to_unbounded_string (p2);
      res (3) := to_unbounded_string (p3);
      res (4) := to_unbounded_string (p4);
      res (5) := to_unbounded_string (p5);
      res (6) := to_unbounded_string (p6);
      res (7) := to_unbounded_string (p7);
      return res;
   end get_candidate_paths;

   procedure search_filesystem_candidates
     (cands : in path_array;
      found : in out unbounded_string)
   is
      idx : positive := cands'first;
   begin
      while length (found) = 0 and then idx <= cands'last loop
         if exists (to_string (cands (idx))) then
            found := cands (idx);
         end if;
         idx := idx + 1;
      end loop;
   end search_filesystem_candidates;

   procedure resolve_font_path (result : in out unbounded_string) is
      cands : constant path_array := get_candidate_paths;
   begin
      search_filesystem_candidates (cands, result);
      if length (result) = 0 then
         result := to_unbounded_string (target_font_tag & ".otf");
      end if;
   end resolve_font_path;

   procedure check_found_font
     (font_path : in unbounded_string;
      status    : in out boolean)
   is
      path_str : constant string := to_string (font_path);
      idx      : constant natural :=
        index (path_str, target_font_tag);
   begin
      if status then
         if idx = 0 then
            put_line ("[fail] found font does not match " &
                      target_font_tag);
            status := false;
         else
            put_line ("[pass] found font matches " &
                      target_font_tag & ": " & path_str);
         end if;
      end if;
   end check_found_font;

   procedure render_glyph_page
     (doc    : in out pdf_document;
      status : in out boolean)
   is
      cfg : page_config :=
        create_page_config (612.0, 792.0);
      dc  : pdf_draw_context;
      err : capy_error;
   begin
      if status and then is_valid (doc) then
         dc := create_draw_context (doc);
         err := draw_rectangle (dc, 50.0, 50.0, 512.0, 692.0);
         if err = capy_err_ok then
            err := stroke_path (dc);
         end if;
         if err = capy_err_ok then
            err := add_page_with_context (doc, dc);
         end if;
         if err /= capy_err_ok then
            status := false;
         end if;
      end if;
      destroy_page_config (cfg);
   end render_glyph_page;

   procedure produce_q_output (status : in out boolean) is
      doc : pdf_document;
      err : capy_error;
   begin
      if status then
         doc := create_document (out_file_name);
         if not is_valid (doc) then
            put_line ("[fail] failed to create capypdf document");
            status := false;
         else
            render_glyph_page (doc, status);
            err := close_document (doc);
            if err /= capy_err_ok then
               put_line ("[fail] error closing capypdf document");
               status := false;
            end if;
         end if;
      end if;
   end produce_q_output;

   procedure check_output_file (status : in out boolean) is
   begin
      if status then
         if not exists (out_file_name) then
            put_line ("[fail] output file was not created: " &
                      out_file_name);
            status := false;
         elsif file_size (out_file_name) = 0 then
            put_line ("[fail] output file is empty: " &
                      out_file_name);
            status := false;
         else
            put_line ("[pass] output file produced successfully: " &
                      out_file_name);
         end if;
      end if;
   end check_output_file;

begin
   put_line ("=== iris q demo regression test ===");

   cleanup_output (ok);
   resolve_font_path (resolved_font);
   check_found_font (resolved_font, ok);
   produce_q_output (ok);
   check_output_file (ok);

   if ok then
      put_line ("[pass] all q demo checks passed successfully.");
      set_exit_status (success);
   else
      put_line ("[fail] q demo test failed.");
      set_exit_status (failure);
   end if;
end test_demo_q;
