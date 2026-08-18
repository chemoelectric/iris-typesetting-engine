-- =====================================================================
-- package body capypdf
-- standard: ada 2022
-- SPDX-License-Identifier: MIT
-- description: low-level and thick ada 2022 binding implementation
--              for capypdf.
-- rules:
--   - explicit 'in' parameter modes on subprograms.
--   - no bare 'loop' constructs; use 'while' or 'for'.
--   - lowercase letters throughout (except string literals).
--   - lines kept strictly to 72 characters or less.
--   - mccabe cyclomatic complexity <= 10 per subprogram.
-- =====================================================================

package body capypdf is

   function create_document
     (filename : in string) return pdf_document
   is
      doc      : pdf_document;
      c_fname  : interfaces.c.strings.chars_ptr;
      opt_res  : capy_error;
      gen_res  : capy_error;
   begin
      opt_res := capy_document_properties_new (doc.opt);
      if opt_res /= capy_err_ok then
         doc.is_open := false;
         return doc;
      end if;

      c_fname := interfaces.c.strings.new_string (filename);
      gen_res := capy_generator_new (c_fname, doc.opt, doc.gen);
      interfaces.c.strings.free (c_fname);

      if gen_res = capy_err_ok then
         doc.is_open := true;
         doc.pages   := 0;
      else
         doc.is_open := false;
      end if;

      return doc;
   end create_document;

   function close_document
     (doc : in out pdf_document) return capy_error
   is
      capyerr : capy_error := capy_err_invalid_state;
   begin
      if doc.is_open then
         capyerr := capy_generator_write (doc.gen);
         if capyerr = capy_err_ok then
            capyerr := capy_generator_destroy (doc.gen);
         end if;
         if capyerr = capy_err_ok then
            capyerr := capy_document_properties_destroy (doc.opt);
         end if;
         if capyerr = capy_err_ok then
            doc.gen     := null_generator;
            doc.opt     := null_options;
            doc.is_open := false;
         end if;
      end if;
      return capyerr;
   end close_document;

   function create_page_config
     (width_pt  : in interfaces.c.double;
      height_pt : in interfaces.c.double) return page_config
   is
      config  : page_config;
      capyerr  : capy_error;
   begin
      config.width  := width_pt;
      config.height := height_pt;
      capyerr := capy_page_properties_new (config.prop);
      if capyerr /= capy_err_ok then
         config.prop := null_page_properties;
      end if;
      return config;
   end create_page_config;

   procedure destroy_page_config
     (config : in out page_config)
   is
      capyerr: capy_error;
   begin
      if config.prop /= null_page_properties then
         capyerr:= capy_page_properties_destroy (config.prop);
         config.prop := null_page_properties;
      end if;
   end destroy_page_config;

   function create_draw_context
     (doc : in pdf_document) return pdf_draw_context
   is
      context : pdf_draw_context;
      capyerr  : capy_error;
   begin
      if not is_valid (doc) then
         context.active := false;
      else
         capyerr := capy_page_draw_context_new (doc.gen, context.dc);
         if capyerr = capy_err_ok then
            context.active := true;
         else
            context.active := false;
         end if;
      end if;
      return context;
   end create_draw_context;

   function draw_rectangle
     (dc     : in pdf_draw_context;
      x      : in interfaces.c.double;
      y      : in interfaces.c.double;
      width  : in interfaces.c.double;
      height : in interfaces.c.double) return capy_error
   is
      capyerr : capy_error := capy_err_invalid_state;
   begin
      if dc.active then
         capyerr := capy_dc_cmd_re (dc.dc, x, y, width, height);
      end if;
      return capyerr;
   end draw_rectangle;

   function fill_path
     (dc : in pdf_draw_context) return capy_error
   is
      capyerr : capy_error := capy_err_invalid_state;
   begin
      if dc.active then
         capyerr := capy_dc_cmd_f (dc.dc);
      end if;
      return capyerr;
   end fill_path;

   function stroke_path
     (dc : in pdf_draw_context) return capy_error
   is
      capyerr : capy_error := capy_err_invalid_state;
   begin
      if dc.active then
         capyerr := capy_dc_cmd_s (dc.dc);
      end if;
      return capyerr;
   end stroke_path;

   function set_stroke_rgb
     (dc : in pdf_draw_context;
      r  : in interfaces.c.double;
      g  : in interfaces.c.double;
      b  : in interfaces.c.double) return capy_error
   is
      capyerr : capy_error := capy_err_invalid_state;
   begin
      if dc.active then
         capyerr :=  capy_dc_cmd_stroke_rg (dc.dc, r, g, b);
      end if;
      return capyerr;
   end set_stroke_rgb;

   function set_fill_rgb
     (dc : in pdf_draw_context;
      r  : in interfaces.c.double;
      g  : in interfaces.c.double;
      b  : in interfaces.c.double) return capy_error
   is
      capyerr : capy_error := capy_err_invalid_state;
   begin
      if dc.active then
         capyerr :=  capy_dc_cmd_rg (dc.dc, r, g, b);
      end if;
      return capyerr;
   end set_fill_rgb;

   function set_stroke_gray
     (dc   : in pdf_draw_context;
      gray : in interfaces.c.double) return capy_error
   is
      capyerr : capy_error := capy_err_invalid_state;
   begin
      if dc.active then
         capyerr :=  capy_dc_cmd_stroke_g (dc.dc, gray);
      end if;
      return capyerr;
   end set_stroke_gray;

   function set_fill_gray
     (dc   : in pdf_draw_context;
      gray : in interfaces.c.double) return capy_error
   is
      capyerr : capy_error := capy_err_invalid_state;
   begin
      if dc.active then
         capyerr :=  capy_dc_cmd_g (dc.dc, gray);
      end if;
      return capyerr;
   end set_fill_gray;

   function set_line_width
     (dc : in pdf_draw_context;
      w  : in interfaces.c.double) return capy_error
   is
      capyerr : capy_error := capy_err_invalid_state;
   begin
      if dc.active then
         capyerr :=  capy_dc_cmd_w (dc.dc, w);
      end if;
      return capyerr;
   end set_line_width;

   function save_state
     (dc : in pdf_draw_context) return capy_error
   is
      capyerr : capy_error := capy_err_invalid_state;
   begin
      if dc.active then
         capyerr := capy_dc_cmd_q (dc.dc);
      end if;
      return capyerr;
   end save_state;

   function restore_state
     (dc : in pdf_draw_context) return capy_error
   is
      capyerr : capy_error := capy_err_invalid_state;
   begin
      if dc.active then
         capyerr := capy_dc_cmd_restore_q (dc.dc);
      end if;
      return capyerr;
   end restore_state;

   function load_font
     (doc       : in pdf_document;
      font_path : in string;
      font      : out font_id) return capy_error
   is
      c_path : interfaces.c.strings.chars_ptr;
      capyerr   : capy_error := capy_err_invalid_state;
   begin
      if not is_valid (doc) then
         font := invalid_font_id;
      else
         c_path := interfaces.c.strings.new_string (font_path);
         capyerr:=
           capy_generator_load_font
             (doc.gen, c_path, null_font_properties, font);
         interfaces.c.strings.free (c_path);
      end if;
      return capyerr;
   end load_font;

   function render_text
     (dc        : in pdf_draw_context;
      text_str  : in string;
      font      : in font_id;
      font_size : in interfaces.c.double;
      x         : in interfaces.c.double;
      y         : in interfaces.c.double) return capy_error
   is
      c_str : interfaces.c.strings.chars_ptr;
      capyerr  : capy_error := capy_err_invalid_state;
   begin
      if dc.active then
         c_str := interfaces.c.strings.new_string (text_str);
         capyerr :=
           capy_dc_render_text (dc.dc, c_str, font, font_size, x, y);
         interfaces.c.strings.free (c_str);
      end if;
      return capyerr;
   end render_text;

   function add_page_with_context
     (doc : in out pdf_document;
      dc  : in out pdf_draw_context) return capy_error
   is
      capyerr  : capy_error := capy_err_invalid_state;
   begin
      if not is_valid (doc) or else not dc.active then
         null;
      else
         capyerr := capy_generator_add_page (doc.gen, dc.dc);
         if capyerr = capy_err_ok then
            doc.pages := doc.pages + 1;
            capyerr := capy_dc_destroy (dc.dc);
         end if;
         if capyerr = capy_err_ok then
            dc.dc     := null_draw_context;
            dc.active := false;
         end if;
      end if;
      return capyerr;
   end add_page_with_context;

end capypdf;
