-- =====================================================================
-- package fontconfig
-- standard: ada 2022
-- SPDX-License-Identifier: MIT
-- description: low-level and thick ada 2022 binding layer for fontconfig.
-- rules:
--   - explicit 'in' parameter modes on subprograms.
--   - no bare 'loop' constructs; use 'while' or 'for'.
--   - lowercase letters throughout (except string literals).
--   - lines kept strictly to 72 characters or less.
--   - modern ada 2022 contract aspects (pre, post).
--   - mccabe cyclomatic complexity <= 10 per subprogram.
-- =====================================================================

with interfaces.c; use interfaces.c;
with interfaces.c.strings; use interfaces.c.strings;
with system; use system;

package fontconfig is

   -- ------------------------------------------------------------------
   -- c primitive types, enums and opaque pointer handles
   -- ------------------------------------------------------------------

   type fc_bool is new interfaces.c.int;
   fc_false     : constant fc_bool := 0;
   fc_true      : constant fc_bool := 1;
   fc_dont_care : constant fc_bool := 2;

   type fc_result is
     (fc_result_match,
      fc_result_no_match,
      fc_result_type_mismatch,
      fc_result_no_id,
      fc_result_out_of_memory);
   for fc_result use
     (fc_result_match         => 0,
      fc_result_no_match      => 1,
      fc_result_type_mismatch => 2,
      fc_result_no_id         => 3,
      fc_result_out_of_memory => 4);
   pragma convention (c, fc_result);

   type fc_match_kind is
     (fc_match_pattern,
      fc_match_font,
      fc_match_scan);
   for fc_match_kind use
     (fc_match_pattern => 0,
      fc_match_font    => 1,
      fc_match_scan    => 2);
   pragma convention (c, fc_match_kind);

   type fc_set_name is
     (fc_set_system,
      fc_set_application);
   for fc_set_name use
     (fc_set_system      => 0,
      fc_set_application => 1);
   pragma convention (c, fc_set_name);

   type fc_pattern_ptr is new System.Address;
   type fc_font_set_ptr is new System.Address;
   type fc_object_set_ptr is new System.Address;
   type fc_config_ptr is new System.Address;
   type fc_char_set_ptr is new System.Address;

   null_pattern    : constant fc_pattern_ptr    := fc_pattern_ptr (System.Null_Address);
   null_font_set   : constant fc_font_set_ptr   := fc_font_set_ptr (System.Null_Address);
   null_object_set : constant fc_object_set_ptr := fc_object_set_ptr (System.Null_Address);
   null_config     : constant fc_config_ptr     := fc_config_ptr (System.Null_Address);

   -- ------------------------------------------------------------------
   -- font property constants
   -- ------------------------------------------------------------------

   fc_family_prop    : constant char_array := "family" & interfaces.c.nul;
   fc_style_prop     : constant char_array := "style" & interfaces.c.nul;
   fc_file_prop      : constant char_array := "file" & interfaces.c.nul;
   fc_index_prop     : constant char_array := "index" & interfaces.c.nul;
   fc_fullname_prop  : constant char_array := "fullname" & interfaces.c.nul;
   fc_postscript_prop: constant char_array := "postscriptname" & interfaces.c.nul;

   -- ------------------------------------------------------------------
   -- high-level ada 2022 subprogram specifications with contracts
   -- ------------------------------------------------------------------

   function init return boolean
   with
     post => init'result;

   procedure fini;

   function parse_name
     (name : in string) return fc_pattern_ptr
   with
     pre  => name'length > 0,
     post => parse_name'result /= null_pattern;

   procedure destroy_pattern
     (pat : in out fc_pattern_ptr)
   with
     post => pat = null_pattern;

   procedure destroy_font_set
     (fs : in out fc_font_set_ptr)
   with
     post => fs = null_font_set;

   procedure destroy_object_set
     (os : in out fc_object_set_ptr)
   with
     post => os = null_object_set;

   function match_font
     (pat : in fc_pattern_ptr) return fc_pattern_ptr
   with
     pre => pat /= null_pattern;

   function get_font_file
     (pat : in fc_pattern_ptr) return string
   with
     pre => pat /= null_pattern;

private

   -- ------------------------------------------------------------------
   -- low-level foreign c imports for libfontconfig
   -- ------------------------------------------------------------------

   function c_fc_init return fc_bool
   with
     import        => true,
     convention    => c,
     external_name => "FcInit";

   procedure c_fc_fini
   with
     import        => true,
     convention    => c,
     external_name => "FcFini";

   function c_fc_name_parse
     (name : in chars_ptr) return fc_pattern_ptr
   with
     import        => true,
     convention    => c,
     external_name => "FcNameParse";

   procedure c_fc_pattern_destroy
     (p : in fc_pattern_ptr)
   with
     import        => true,
     convention    => c,
     external_name => "FcPatternDestroy";

   function c_fc_pattern_get_string
     (p   : in fc_pattern_ptr;
      obj : in chars_ptr;
      n   : in int;
      s   : out chars_ptr) return int
   with
     import        => true,
     convention    => c,
     external_name => "FcPatternGetString";

   function c_fc_config_substitute
     (config : in fc_config_ptr;
      p      : in fc_pattern_ptr;
      kind   : in fc_match_kind) return fc_bool
   with
     import        => true,
     convention    => c,
     external_name => "FcConfigSubstitute";

   procedure c_fc_default_substitute
     (p : in fc_pattern_ptr)
   with
     import        => true,
     convention    => c,
     external_name => "FcDefaultSubstitute";

   function c_fc_font_match
     (config : in fc_config_ptr;
      p      : in fc_pattern_ptr;
      result : out fc_result) return fc_pattern_ptr
   with
     import        => true,
     convention    => c,
     external_name => "FcFontMatch";

   function c_fc_font_set_create return fc_font_set_ptr
   with
     import        => true,
     convention    => c,
     external_name => "FcFontSetCreate";

   procedure c_fc_font_set_destroy
     (s : in fc_font_set_ptr)
   with
     import        => true,
     convention    => c,
     external_name => "FcFontSetDestroy";

   function c_fc_object_set_create return fc_object_set_ptr
   with
     import        => true,
     convention    => c,
     external_name => "FcObjectSetCreate";

   function c_fc_object_set_add
     (os  : in fc_object_set_ptr;
      obj : in chars_ptr) return fc_bool
   with
     import        => true,
     convention    => c,
     external_name => "FcObjectSetAdd";

   procedure c_fc_object_set_destroy
     (os : in fc_object_set_ptr)
   with
     import        => true,
     convention    => c,
     external_name => "FcObjectSetDestroy";

   function c_fc_font_list
     (config : in fc_config_ptr;
      p      : in fc_pattern_ptr;
      os     : in fc_object_set_ptr) return fc_font_set_ptr
   with
     import        => true,
     convention    => c,
     external_name => "FcFontList";

end fontconfig;
