------------------------------------------------------------------------
--
-- SPDX-License-Identifier: MIT
--
-- A wrapper around the CapyPDF FFI.
--
------------------------------------------------------------------------

pragma wide_character_encoding (utf8);
pragma ada_2022;

with interfaces.c;
with interfaces.c.strings;
with capypdf_0_capypdf_h;
with bits_stdint_intn_h;

package body pdf is

   use interfaces.c;
   use interfaces.c.strings;
   use capypdf_0_capypdf_h;
   use bits_stdint_intn_h;

   ---------------------------------------------------------------------
   --
   -- pdf_font_properties
   --

   --
   procedure initialize (properties : in out pdf_font_properties) is
      err   : capypdf_ec;
      fprop : aliased access capypdf_fontproperties;
   begin
      err := capy_font_properties_new (fprop'address);
      if err = 0 then
         properties.fprop := fprop;
      else
         raise pdf_error
           with "pdf_font_properties initialization error";
      end if;
   end initialize;

   --
   procedure finalize (properties : in out pdf_font_properties) is
      err : capypdf_ec;
   begin
      err := capy_font_properties_destroy (properties.fprop);
      if err /= 0 then
         raise pdf_error with "pdf_font_properties finalization error";
      end if;
   end finalize;

   ---------------------------------------------------------------------
   --
   -- pdf_page_properties
   --

   --
   procedure initialize (properties : in out pdf_page_properties) is
      err       : capypdf_ec;
      pageprops : aliased access capypdf_pageproperties;
   begin
      err := capy_page_properties_new (pageprops'address);
      if err = 0 then
         properties.pageprops := pageprops;
      else
         raise pdf_error
           with "pdf_page_properties initialization error";
      end if;
   end initialize;

   --
   procedure finalize (properties : in out pdf_page_properties) is
      err : capypdf_ec;
   begin
      err := capy_page_properties_destroy (properties.pageprops);
      if err /= 0 then
         raise pdf_error with "pdf_page_properties finalization error";
      end if;
   end finalize;

   procedure set_page_box
     (properties : in out pdf_page_properties;
      box_type   : in pdf_page_box_type;
      x1, y1     : in double;
      x2, y2     : in double)
   is
      err : capypdf_ec;
   begin
      err :=
        capy_page_properties_set_pagebox
          (properties.pageprops,
           capypdf_page_box'enum_val
             (pdf_page_box_type'enum_rep (box_type)),
           x1,
           y1,
           x2,
           y2);
      if err /= 0 then
         raise pdf_error with "pdf_page_properties.set_page_box error";
      end if;
   end set_page_box;

   ---------------------------------------------------------------------
   --
   -- pdf_document_properties
   --

   --
   procedure initialize (properties : in out pdf_document_properties) is
      err      : capypdf_ec;
      docprops : aliased access capypdf_documentproperties;
   begin
      err := capy_document_properties_new (docprops'address);
      if err = 0 then
         properties.docprops := docprops;
      else
         raise pdf_error
           with "pdf_document_properties initialization error";
      end if;
   end initialize;

   --
   procedure finalize (properties : in out pdf_document_properties) is
      err : capypdf_ec;
   begin
      err := capy_document_properties_destroy (properties.docprops);
      if err /= 0 then
         raise pdf_error
           with "pdf_document_properties finalization error";
      end if;
   end finalize;

   --
   procedure set_title
     (properties : in out pdf_document_properties; title : in string)
   is
      err : capypdf_ec;
      s   : chars_ptr;
      n   : size_t;
   begin
      s := new_string (title);
      n := strlen (s);
      err :=
        capy_document_properties_set_title
          (properties.docprops, s, int32_t (n));
      if err /= 0 then
         raise pdf_error with "pdf_document_properties.set_title error";
      end if;
      free (s);
   exception
      when others =>
         if s /= null_ptr then
            free (s);
         end if;
         raise;
   end set_title;

   --
   procedure set_author
     (properties : in out pdf_document_properties; author : in string)
   is
      err : capypdf_ec;
      s   : chars_ptr;
      n   : size_t;
   begin
      s := new_string (author);
      n := strlen (s);
      err :=
        capy_document_properties_set_author
          (properties.docprops, s, int32_t (n));
      if err /= 0 then
         raise pdf_error
           with "pdf_document_properties.set_author error";
      end if;
      free (s);
   exception
      when others =>
         if s /= null_ptr then
            free (s);
         end if;
         raise;
   end set_author;

   --
   procedure set_creator
     (properties : in out pdf_document_properties; creator : in string)
   is
      err : capypdf_ec;
      s   : chars_ptr;
      n   : size_t;
   begin
      s := new_string (creator);
      n := strlen (s);
      err :=
        capy_document_properties_set_creator
          (properties.docprops, s, int32_t (n));
      if err /= 0 then
         raise pdf_error
           with "pdf_document_properties.set_creator error";
      end if;
      free (s);
   exception
      when others =>
         if s /= null_ptr then
            free (s);
         end if;
         raise;
   end set_creator;

   --
   procedure set_tagged
     (properties : in out pdf_document_properties;
      is_tagged  : in boolean)
   is
      err : capypdf_ec;
   begin
      err :=
        capy_document_properties_set_tagged
          (properties.docprops, (if is_tagged then 1 else 0));
      if err /= 0 then
         raise pdf_error
           with "pdf_document_properties.set_tagged error";
      end if;
   end set_tagged;

   procedure set_default_page_properties
     (properties      : in out pdf_document_properties;
      page_properties : in pdf_page_properties'class)
   is
      err : capypdf_ec;
   begin
      err :=
        capy_document_properties_set_default_page_properties
          (properties.docprops, page_properties.pageprops);
      if err /= 0 then
         raise pdf_error
           with
             "pdf_document_properties.set_default_page_properties error";
      end if;
   end set_default_page_properties;

   ---------------------------------------------------------------------
   --
   -- pdf_generator
   --

   procedure finalize (generator : in out pdf_generator) is
      err : capypdf_ec;
   begin
      err := capy_generator_destroy (generator.gen);
      if err /= 0 then
         raise pdf_error with "pdf_generator finalization error";
      end if;
   end finalize;

   function create
     (name : in string; properties : in pdf_document_properties'class)
      return pdf_generator
   is
      err      : capypdf_ec;
      gen      : aliased access capypdf_generator;
      filename : chars_ptr := null_ptr;
   begin
      filename := new_string (name);
      err :=
        capy_generator_new (filename, properties.docprops, gen'address);
      if err /= 0 then
         raise pdf_error with "pdf_generator.set_document error";
      end if;
      free (filename);
      return result : pdf_generator do
         result.gen := gen;
      end return;
   exception
      when others =>
         if (filename /= null_ptr) then
            free (filename);
         end if;
         raise;
   end create;

   function load_font
     (generator : in out pdf_generator'class; name : in string)
      return pdf_font_id
   is
      err        : capypdf_ec;
      font_props : pdf_font_properties;
      fontname   : chars_ptr;
      output_id  : aliased capypdf_fontid;
   begin
      fontname := new_string (name);
      err :=
        capy_generator_load_font
          (generator.gen, fontname, font_props.fprop, output_id'access);
      if err /= 0 then
         raise pdf_error with ("failed to load font '" & name & "'");
      end if;
      free (fontname);
      return result : pdf_font_id do
         result.id := output_id;
      end return;
   exception
      when others =>
         if fontname /= null_ptr then
            free (fontname);
         end if;
         raise;
   end load_font;

   ---------------------------------------------------------------------

end pdf;

-- local variables:
-- mode: ada
-- end:
