-- =====================================================================
-- package body fontconfig
-- standard: ada 2022
-- SPDX-License-Identifier: MIT
-- =====================================================================

with system;

package body fontconfig is

   function init return boolean is
      res : fc_bool;
   begin
      res := c_fc_init;
      return res /= fc_false;
   end init;

   procedure fini is
   begin
      c_fc_fini;
   end fini;

   function parse_name
     (name : in string) return fc_pattern_ptr
   is
      c_str : chars_ptr;
      pat   : fc_pattern_ptr;
   begin
      c_str := new_string (name);
      pat   := c_fc_name_parse (c_str);
      free (c_str);
      return pat;
   end parse_name;

   procedure destroy_pattern
     (pat : in out fc_pattern_ptr)
   is
   begin
      if pat /= null_pattern then
         c_fc_pattern_destroy (pat);
         pat := null_pattern;
      end if;
   end destroy_pattern;

   procedure destroy_font_set
     (fs : in out fc_font_set_ptr)
   is
   begin
      if fs /= null_font_set then
         c_fc_font_set_destroy (fs);
         fs := null_font_set;
      end if;
   end destroy_font_set;

   procedure destroy_object_set
     (os : in out fc_object_set_ptr)
   is
   begin
      if os /= null_object_set then
         c_fc_object_set_destroy (os);
         os := null_object_set;
      end if;
   end destroy_object_set;

   function match_font
     (pat : in fc_pattern_ptr) return fc_pattern_ptr
   is
      sub_ok  : fc_bool;
      res     : fc_result;
      matched : fc_pattern_ptr := null_pattern;
   begin
      if pat /= null_pattern then
         sub_ok := c_fc_config_substitute
           (null_config, pat, fc_match_pattern);
         c_fc_default_substitute (pat);
         matched := c_fc_font_match (null_config, pat, res);
      end if;
      return matched;
   end match_font;

   function get_font_file
     (pat : in fc_pattern_ptr) return string
   is
      c_prop : chars_ptr;
      c_file : chars_ptr;
      ret    : int;
      output : string (1 .. 1024) := [others => ' '];
      last   : natural := 0;
   begin
      if pat /= null_pattern then
         c_prop := new_string ("file");
         ret    := c_fc_pattern_get_string (pat, c_prop, 0, c_file);
         free (c_prop);
         if ret = 0 and then c_file /= null_ptr then
            declare
               s : constant string := value (c_file);
            begin
               last := natural'min (s'length, output'length);
               output (1 .. last) := s (1 .. last);
            end;
         end if;
      end if;
      return output (1 .. last);
   end get_font_file;

end fontconfig;
