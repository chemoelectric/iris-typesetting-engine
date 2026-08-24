-- SPDX-License-Identifier: MIT

pragma wide_character_encoding (utf8);
pragma ada_2022;

with capypdf_document_properties;

procedure test_capypdf_1 is

   use capypdf_document_properties;

   docprops : pdf_document_properties;

begin
   docprops.open;
end test_capypdf_1;

