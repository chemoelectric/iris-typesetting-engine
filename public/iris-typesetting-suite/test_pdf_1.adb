-- SPDX-License-Identifier: MIT

pragma wide_character_encoding (utf8);
pragma ada_2022;

with pdf;

procedure test_pdf_1 is

   use pdf;

   docprops : pdf_document_properties;

begin
   docprops.open;
end test_pdf_1;

