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
         raise pdf_error with
           "pdf_page_properties.set_page_box error ("
           & err'image & ")";
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
           "pdf_document_properties.set_default_page_properties error ("
           & err'image & ")";
      end if;
   end set_default_page_properties;

   ---------------------------------------------------------------------
   --
   -- pdf_draw_context
   --

   -- m4_pdf_finalize(draw_context)

   procedure render_text
     (context : in out pdf_draw_context;
      text : in string;
      font_id : in pdf_font_id'class;
      point_size : in double;
      x, y : in double)
   is
      err : capypdf_ec;
      s   : chars_ptr;
      n   : size_t;
   begin
      s := new_string (text);
      n := strlen (s);
      err :=
        capy_dc_render_text
          (context.ctx, s, int32_t (n), font_id.id, point_size, x, y);
      if err /= 0 then
         raise pdf_error with
           "pdf_draw_context.render_text error (" & err'image & ")";
      end if;
      free (s);
   exception
      when others =>
         if s /= null_ptr then
            free (s);
         end if;
         raise;
   end render_text;

   ---------------------------------------------------------------------
   --
   -- pdf_generator
   --

   -- m4_pdf_finalize(generator)
   -- m4_pdf_plain_procedure(generator, write)

   function create
     (name : in string;
      properties : in pdf_document_properties'class)
     return pdf_generator
   is
      err : capypdf_ec;
      gen : aliased access capypdf_generator;
      filename : chars_ptr := null_ptr;
   begin
      filename := new_string (name);
      err :=
        capy_generator_new (filename, properties.docprops, gen'address);
      if err /= 0 then
         raise pdf_error with
           "pdf_generator.create error (" & err'image & ")";
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
      err : capypdf_ec;
      font_props : pdf_font_properties;
      fontname : chars_ptr;
      output_id : aliased capypdf_fontid;
   begin
      fontname := new_string (name);
      err :=
        capy_generator_load_font
          (generator.gen, fontname, font_props.fprop, output_id'access);
      if err /= 0 then
         raise pdf_error with
           ("failed to load font '" & name & "' (" & err'image & ")";
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

   function page_draw_context
     (generator : in out pdf_generator'class)
     return pdf_draw_context
   is
      err : capypdf_ec;
      ctx : aliased access capypdf_drawcontext;
   begin
      err := capy_page_draw_context_new (generator.gen, ctx'address);
      if err /= 0 then
         raise pdf_error with
           "pdf_generator.page_draw_context error (" & err'image & ")";
      end if;
      return result : pdf_draw_context do
         result.ctx := ctx;
      end return;
   end page_draw_context;

   procedure add_page
     (generator : in out pdf_generator;
      context   : in pdf_draw_context'class)
   is
      err : capypdf_ec;
   begin
      err := capy_generator_add_page (generator.gen, context.ctx);
      if err /= 0 then
         raise pdf_error with
           "pdf_generator.add_page error (" & err'image & ")";
      end if;
   end add_page;

   ---------------------------------------------------------------------

end pdf;

-- local variables:
-- mode: ada
-- end:
