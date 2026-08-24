------------------------------------------------------------------------
--
-- SPDX-License-Identifier: MIT
--
-- A wrapper around the CapyPDF FFI.
--
------------------------------------------------------------------------

pragma wide_character_encoding (utf8);
pragma ada_2022;

with ada.finalization; use ada.finalization;
with capypdf_0_capypdf_h;

package pdf is

   pdf_error : exception;

   type pdf_document_properties is new limited_controlled with private;
   procedure open (properties : in out pdf_document_properties);
   procedure close (properties : in out pdf_document_properties);
   procedure set_title
     (properties : in out pdf_document_properties; title : in string);
   procedure set_tagged
     (properties : in out pdf_document_properties;
      is_tagged  : in boolean);

private

   use capypdf_0_capypdf_h;

   type pdf_document_properties is new limited_controlled with record
      is_open  : boolean := false;
      docprops : access capypdf_documentproperties;
   end record;

   overriding
   procedure finalize (properties : in out pdf_document_properties);

end pdf;
