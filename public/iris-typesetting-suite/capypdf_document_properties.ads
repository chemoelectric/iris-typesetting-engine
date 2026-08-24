-- SPDX-License-Identifier: MIT
--
-- A wrapper around
--
--   capy_document_properties_new
--
--   capy_document_properties_destroy
--
-- and various document properties functionalities of CapyPDF.
--

pragma wide_character_encoding (utf8);
pragma ada_2022;

with ada.finalization; use ada.finalization;
with capypdf_0_capypdf_h;

package capypdf_document_properties is

   pdf_document_properties_error : exception;

   type pdf_document_properties is new limited_controlled with private;

   procedure open (object : in out pdf_document_properties);
   procedure close (object : in out pdf_document_properties);

private

   use capypdf_0_capypdf_h;

   type pdf_document_properties is new limited_controlled with record
      is_open  : boolean := false;
      docprops : access capypdf_documentproperties;
   end record;

   overriding
   procedure finalize (object : in out pdf_document_properties);

end capypdf_document_properties;
