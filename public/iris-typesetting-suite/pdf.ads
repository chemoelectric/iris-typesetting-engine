------------------------------------------------------------------------
--
-- SPDX-License-Identifier: MIT
--
-- A wrapper around the CapyPDF FFI.
--
------------------------------------------------------------------------

pragma wide_character_encoding (utf8);
pragma ada_2022;

with ada.finalization;     use ada.finalization;
with interfaces.c;         use interfaces.c;
with interfaces.c.strings; use interfaces.c.strings;
with capypdf_0_capypdf_h;  use capypdf_0_capypdf_h;

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

   type pdf_font_id is new controlled with private;

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

   type pdf_generator is new limited_controlled with private;
   procedure set_document
     (generator  : in out pdf_generator;
      name       : in string;
      properties : in pdf_document_properties'class);
   function load_font
     (generator : in out pdf_generator'class; name : in string)
      return pdf_font_id;

private

   type pdf_font_id is new controlled with record
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

   type pdf_generator is new limited_controlled with record
      gen      : access capypdf_generator;
      filename : chars_ptr := null_ptr;
   end record;
   procedure initialize (generator : in out pdf_generator);
   overriding
   procedure finalize (generator : in out pdf_generator);

end pdf;
