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

   -- m4_pdf_initialize(font_properties)
   -- m4_pdf_finalize(font_properties)

   ---------------------------------------------------------------------
   --
   -- pdf_page_properties
   --

   -- m4_pdf_initialize(page_properties)
   -- m4_pdf_finalize(page_properties)

   procedure set_page_box
     (properties : in out pdf_page_properties;
      box_type : in pdf_page_box_type;
      x1, y1 : in double;
      x2, y2 : in double)
   is
      err : capypdf_ec;
   begin
      err :=
        capy_page_properties_set_pagebox
          (properties.pageprops,
           capypdf_page_box'enum_val
             (pdf_page_box_type'enum_rep (box_type)),
           x1, y1, x2, y2);
      if err /= 0 then
         raise pdf_error with "pdf_page_properties.set_page_box error";
      end if;
   end set_page_box;

   ---------------------------------------------------------------------
   --
   -- pdf_document_properties
   --

   -- m4_pdf_initialize(document_properties)
   -- m4_pdf_finalize(document_properties)

   -- m4_pdf_set_string(document_properties, title)
   -- m4_pdf_set_string(document_properties, author)
   -- m4_pdf_set_string(document_properties, creator)
   -- m4_pdf_set_boolean(document_properties, tagged)

   procedure set_default_page_properties
     (properties : in out pdf_document_properties;
      page_properties : in pdf_page_properties'class)
   is
      err : capypdf_ec;
   begin
      err :=
        capy_document_properties_set_default_page_properties
          (properties.docprops, page_properties.pageprops);
      if err /= 0 then
         raise pdf_error with
           "pdf_document_properties.set_default_page_properties error";
      end if;
   end set_default_page_properties;

   ---------------------------------------------------------------------
   --
   -- pdf_generator
   --

   procedure clean_up (generator : in out pdf_generator) is
   begin
      if generator.filename /= null_ptr then
         free (generator.filename);
         generator.filename := null_ptr;
      end if;
   end clean_up;

   procedure do_finalization (generator : in out pdf_generator) is
      err : capypdf_ec;
   begin
      if generator.filename /= null_ptr then
         err := capy_generator_destroy (generator.gen);
         if err = 0 then
            clean_up (generator);
         else
            raise pdf_error with "pdf_generator finalization error";
         end if;
      end if;
   end do_finalization;

   procedure initialize (generator : in out pdf_generator) is
   begin
      generator.filename := null_ptr;
   end initialize;

   procedure finalize (generator : in out pdf_generator) is
   begin
      do_finalization (generator);
   end finalize;

   procedure set_document
     (generator : in out pdf_generator;
      name : in string;
      properties : in pdf_document_properties'class)
   is
      err : capypdf_ec;
      gen : aliased access capypdf_generator;
   begin
      do_finalization (generator);
      generator.filename := new_string (name);
      err :=
        capy_generator_new
          (generator.filename, properties.docprops, gen'address);
      if err = 0 then
         generator.gen := gen;
      else
         raise pdf_error with "pdf_generator.set_document error";
      end if;
   exception
      when others =>
         clean_up (generator);
         raise;
   end set_document;

   function load_font
     (generator : in out pdf_generator'class; name : in string)
     return pdf_font_id
   is
      err : capypdf_ec;
      font_props : pdf_font_properties;
      fontname : chars_ptr;
      output_id : aliased capypdf_fontid;
      retval : pdf_font_id;
   begin
      fontname := new_string (name);
      err :=
        capy_generator_load_font
          (generator.gen, fontname, font_props.fprop, output_id'access);
      if err /= 0 then
         raise pdf_error with ("failed to load font '" & name & "'");
      end if;
      retval.id := output_id;
      return retval;
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
