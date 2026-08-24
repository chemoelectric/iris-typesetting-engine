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

   type pdf_page_properties is new limited_controlled with private;
   procedure open (properties : in out pdf_page_properties);
   procedure close (properties : in out pdf_page_properties);
   function is_open
     (properties : in pdf_page_properties) return boolean;
   procedure set_page_box
     (properties : in out pdf_page_properties;
      box_type   : in pdf_page_box_type;
      x1, y1     : in double;
      x2, y2     : in double);

   type pdf_document_properties is new limited_controlled with private;
   procedure open (properties : in out pdf_document_properties);
   procedure close (properties : in out pdf_document_properties);
   function is_open
     (properties : in pdf_document_properties) return boolean;
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

private

   type pdf_page_properties is new limited_controlled with record
      is_open   : boolean := false;
      pageprops : access capypdf_pageproperties;
   end record;
   overriding
   procedure finalize (properties : in out pdf_page_properties);

   type pdf_document_properties is new limited_controlled with record
      is_open  : boolean := false;
      docprops : access capypdf_documentproperties;
   end record;
   overriding
   procedure finalize (properties : in out pdf_document_properties);

end pdf;
