------------------------------------------------------------------------
--
-- SPDX-License-Identifier: MIT
--
-- A wrapper around the CapyPDF FFI.
--
------------------------------------------------------------------------

pragma wide_character_encoding (utf8);
pragma ada_2022;

with ada.finalization;    use ada.finalization;
with interfaces.c;        use interfaces.c;
with capypdf_0_capypdf_h; use capypdf_0_capypdf_h;

package pdf is

   pdf_error : exception;

   type pdf_page_box_type is
     (pdf_page_box_media,
      pdf_page_box_crop,
      pdf_page_box_bleed,
      pdf_page_box_trim,
      pdf_page_box_art);
   for pdf_page_box_type use
     (pdf_page_box_media => capypdf_page_box'enum_rep (capy_box_media),
      pdf_page_box_crop  => capypdf_page_box'enum_rep (capy_box_crop),
      pdf_page_box_bleed => capypdf_page_box'enum_rep (capy_box_bleed),
      pdf_page_box_trim  => capypdf_page_box'enum_rep (capy_box_trim),
      pdf_page_box_art   => capypdf_page_box'enum_rep (capy_box_art));

   type pdf_font_id is new limited_controlled with private;

   type pdf_font_properties is new limited_controlled with private;

   type pdf_page_properties is new limited_controlled with private;
   procedure set_page_box
     (properties : in out pdf_page_properties;
      box_type   : in pdf_page_box_type;
      x1, y1     : in double;
      x2, y2     : in double);

   type pdf_document_properties is new limited_controlled with private;
   procedure set_title
     (properties : in out pdf_document_properties; title : in string);
   procedure set_author
     (properties : in out pdf_document_properties; author : in string);
   procedure set_creator
     (properties : in out pdf_document_properties; creator : in string);
   procedure set_tagged
     (properties : in out pdf_document_properties;
      is_tagged  : in boolean);
   procedure set_default_page_properties
     (properties      : in out pdf_document_properties;
      page_properties : in pdf_page_properties'class);

   type pdf_draw_context is new limited_controlled with private;
   procedure render_text
     (context    : in out pdf_draw_context;
      text       : in string;
      font_id    : in pdf_font_id'class;
      point_size : in double;
      x, y       : in double);

   type pdf_generator is new limited_controlled with private;
   function create
     (name : in string; properties : in pdf_document_properties'class)
      return pdf_generator;
   function load_font
     (generator : in out pdf_generator'class; name : in string)
      return pdf_font_id;
   function page_draw_context
     (generator : in out pdf_generator'class) return pdf_draw_context;
   procedure add_page
     (generator : in out pdf_generator;
      context   : in pdf_draw_context'class);
   procedure write (generator : in out pdf_generator);

private

   type pdf_font_id is new limited_controlled with record
      id : capypdf_fontid;
   end record;

   type pdf_font_properties is new limited_controlled with record
      fprop : access capypdf_fontproperties;
   end record;
   procedure initialize (properties : in out pdf_font_properties);
   overriding
   procedure finalize (properties : in out pdf_font_properties);

   type pdf_page_properties is new limited_controlled with record
      pageprops : access capypdf_pageproperties;
   end record;
   procedure initialize (properties : in out pdf_page_properties);
   overriding
   procedure finalize (properties : in out pdf_page_properties);

   type pdf_document_properties is new limited_controlled with record
      docprops : access capypdf_documentproperties;
   end record;
   procedure initialize (properties : in out pdf_document_properties);
   overriding
   procedure finalize (properties : in out pdf_document_properties);

   type pdf_draw_context is new limited_controlled with record
      ctx : access capypdf_drawcontext;
   end record;
   overriding
   procedure finalize (context : in out pdf_draw_context);

   type pdf_generator is new limited_controlled with record
      gen : access capypdf_generator;
   end record;
   overriding
   procedure finalize (generator : in out pdf_generator);

end pdf;
