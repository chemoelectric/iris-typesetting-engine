-- SPDX-License-Identifier: MIT

pragma wide_character_encoding (utf8);
pragma ada_2022;

with pdf;

procedure test_pdf_01 is

   use pdf;

   doc_props  : pdf_document_properties;
   page_props : pdf_page_properties;
   generator  : pdf_generator;
   font_id    : pdf_font_id;

begin
   doc_props.set_title (title => "title");
   doc_props.set_author (author => "author");
   doc_props.set_tagged (is_tagged => false);
   page_props.set_page_box (pdf_page_box_media, 0.0, 0.0, 612.0, 792.0);
   doc_props.set_default_page_properties (page_props);
   generator.set_document ("test_pdf_01-001.pdf", doc_props);
   font_id := generator.load_font ("/home/trashman/src/chemoelectric/iris-typesetting-engine/public/iris-typesetting-suite/___build___/FanwoodText-Italic.ttf");
end test_pdf_01;
