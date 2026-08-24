-- SPDX-License-Identifier: MIT

pragma wide_character_encoding (utf8);
pragma ada_2022;

with pdf;

procedure test_pdf_01 is

   use pdf;

   doc_props  : pdf_document_properties;
   page_props : pdf_page_properties;

begin
   doc_props.open;
   doc_props.set_title (title => "title");
   doc_props.set_author (author => "author");
   doc_props.set_tagged (is_tagged => false);
   page_props.open;
   page_props.set_page_box (pdf_page_box_media, 0.0, 0.0, 612.0, 792.0);
   doc_props.set_default_page_properties (page_props);
end test_pdf_01;
