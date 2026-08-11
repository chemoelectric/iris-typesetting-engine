-- =====================================================================
-- package capypdf
-- standard: ada 2022
-- description: low-level and thick ada 2022 binding layer for capypdf.
-- rules:
--   - explicit 'in' parameter modes on subprograms.
--   - no bare 'loop' constructs; use 'while' or 'for'.
--   - lowercase letters throughout (except string literals).
--   - lines kept strictly to 72 characters or less.
--   - modern ada 2022 contract aspects (pre, post).
--   - mccabe cyclomatic complexity <= 10 per subprogram.
-- =====================================================================

with interfaces.c;
with interfaces.c.strings;

package capypdf is

   -- ------------------------------------------------------------------
   -- c primitive types and opaque handles
   -- ------------------------------------------------------------------

   type capy_error is new interfaces.c.int;
   
   capy_err_ok            : constant capy_error := 0;
   capy_err_null_pointer  : constant capy_error := 1;
   capy_err_invalid_state : constant capy_error := 2;
   capy_err_io_failure    : constant capy_error := 3;

   type generator_handle is new interfaces.c.size_t;
   type options_handle is new interfaces.c.size_t;
   type page_properties_handle is new interfaces.c.size_t;
   type draw_context_handle is new interfaces.c.size_t;
   type font_id is new interfaces.c.int;

   null_generator       : constant generator_handle := 0;
   null_options         : constant options_handle := 0;
   null_page_properties : constant page_properties_handle := 0;
   null_draw_context    : constant draw_context_handle := 0;
   invalid_font_id      : constant font_id := -1;

   -- ------------------------------------------------------------------
   -- high-level ada 2022 object record types
   -- ------------------------------------------------------------------

   type pdf_document is record
      gen     : generator_handle       := null_generator;
      opt     : options_handle         := null_options;
      is_open : boolean                := false;
      pages   : interfaces.c.int       := 0;
   end record;

   type page_config is record
      prop   : page_properties_handle := null_page_properties;
      width  : interfaces.c.double     := 595.28; -- a4 width in pt
      height : interfaces.c.double     := 841.89; -- a4 height in pt
   end record;

   type pdf_draw_context is record
      dc     : draw_context_handle    := null_draw_context;
      active : boolean                := false;
   end record;

   -- ------------------------------------------------------------------
   -- high-level ada 2022 subprogram specifications with contracts
   -- ------------------------------------------------------------------

   function is_valid (doc : in pdf_document) return boolean is
     (doc.gen /= null_generator and then doc.is_open);

   function create_document
     (filename : in string) return pdf_document
   with
     pre  => filename'length > 0,
     post => (if create_document'result.is_open then
                is_valid (create_document'result));

   function close_document
     (doc : in out pdf_document) return capy_error
   with
     pre  => is_valid (doc),
     post => not is_valid (doc) and then not doc.is_open;

   function create_page_config
     (width_pt  : in interfaces.c.double;
      height_pt : in interfaces.c.double) return page_config
   with
     pre  => width_pt > 0.0 and then height_pt > 0.0,
     post => page_config'result.prop /= null_page_properties;

   procedure destroy_page_config
     (config : in out page_config)
   with
     post => config.prop = null_page_properties;

   function create_draw_context
     (doc : in pdf_document) return pdf_draw_context
   with
     pre  => is_valid (doc),
     post => pdf_draw_context'result.active;

   function draw_rectangle
     (dc     : in pdf_draw_context;
      x      : in interfaces.c.double;
      y      : in interfaces.c.double;
      width  : in interfaces.c.double;
      height : in interfaces.c.double) return capy_error
   with
     pre => dc.active and then width >= 0.0 and then height >= 0.0;

   function fill_path
     (dc : in pdf_draw_context) return capy_error
   with
     pre => dc.active;

   function stroke_path
     (dc : in pdf_draw_context) return capy_error
   with
     pre => dc.active;

   function add_page_with_context
     (doc : in out pdf_document;
      dc  : in out pdf_draw_context) return capy_error
   with
     pre  => is_valid (doc) and then dc.active,
     post => not dc.active and then doc.pages = doc.pages'old + 1;

private

   -- ------------------------------------------------------------------
   -- low-level foreign c imports for capypdf shared library
   -- ------------------------------------------------------------------

   function capy_options_new
     (opt_out : out options_handle) return capy_error
   with
     import        => true,
     convention    => c,
     external_name => "capy_generator_options_new";

   function capy_options_destroy
     (opt : in options_handle) return capy_error
   with
     import        => true,
     convention    => c,
     external_name => "capy_generator_options_destroy";

   function capy_generator_new
     (filename : in interfaces.c.strings.chars_ptr;
      options  : in options_handle;
      gen_out  : out generator_handle) return capy_error
   with
     import        => true,
     convention    => c,
     external_name => "capy_generator_new";

   function capy_generator_add_page
     (gen : in generator_handle;
      dc  : in draw_context_handle) return capy_error
   with
     import        => true,
     convention    => c,
     external_name => "capy_generator_add_page";

   function capy_generator_write
     (gen : in generator_handle) return capy_error
   with
     import        => true,
     convention    => c,
     external_name => "capy_generator_write";

   function capy_generator_destroy
     (gen : in generator_handle) return capy_error
   with
     import        => true,
     convention    => c,
     external_name => "capy_generator_destroy";

   function capy_page_properties_new
     (prop_out : out page_properties_handle) return capy_error
   with
     import        => true,
     convention    => c,
     external_name => "capy_page_properties_new";

   function capy_page_properties_destroy
     (prop : in page_properties_handle) return capy_error
   with
     import        => true,
     convention    => c,
     external_name => "capy_page_properties_destroy";

   function capy_dc_new
     (gen    : in generator_handle;
      dc_out : out draw_context_handle) return capy_error
   with
     import        => true,
     convention    => c,
     external_name => "capy_generator_new_page_draw_context";

   function capy_dc_destroy
     (dc : in draw_context_handle) return capy_error
   with
     import        => true,
     convention    => c,
     external_name => "capy_dc_destroy";

   function capy_dc_cmd_re
     (dc     : in draw_context_handle;
      x      : in interfaces.c.double;
      y      : in interfaces.c.double;
      w      : in interfaces.c.double;
      h      : in interfaces.c.double) return capy_error
   with
     import        => true,
     convention    => c,
     external_name => "capy_dc_cmd_re";

   function capy_dc_cmd_f
     (dc : in draw_context_handle) return capy_error
   with
     import        => true,
     convention    => c,
     external_name => "capy_dc_cmd_f";

   function capy_dc_cmd_s
     (dc : in draw_context_handle) return capy_error
   with
     import        => true,
     convention    => c,
     external_name => "capy_dc_cmd_s";

end capypdf;
