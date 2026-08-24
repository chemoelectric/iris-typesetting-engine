-- SPDX-License-Identifier: MIT

pragma wide_character_encoding (utf8);
pragma ada_2022;

with pdf;

procedure test_pdf_1 is

   use pdf;

   properties : pdf_document_properties;

begin
   properties.open;
   properties.set_title ("document");
   properties.set_tagged (false);
   properties.close;
end test_pdf_1;
