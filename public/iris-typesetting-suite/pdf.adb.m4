------------------------------------------------------------------------
--
-- SPDX-License-Identifier: MIT
--
-- A wrapper around the CapyPDF FFI.
--
------------------------------------------------------------------------

pragma wide_character_encoding (utf8);
pragma ada_2022;

with interfaces.c;
with interfaces.c.strings;
with capypdf_0_capypdf_h;
with bits_stdint_intn_h;

package body pdf is

   use interfaces.c;
   use interfaces.c.strings;
   use capypdf_0_capypdf_h;
   use bits_stdint_intn_h;

   ---------------------------------------------------------------------
   --
   -- pdf_page_properties
   --

   -- m4_pdf_initialize(page_properties)
   -- m4_pdf_finalize(page_properties)

   procedure set_page_box
     (properties : in out pdf_page_properties;
      box_type : in pdf_page_box_type;
      x1, y1 : in double;
      x2, y2 : in double)
   is
      err : capypdf_ec;
   begin
      err :=
        capy_page_properties_set_pagebox
          (properties.pageprops,
           capypdf_page_box'enum_val
             (pdf_page_box_type'enum_rep (box_type)),
           x1, y1, x2, y2);
      if err /= 0 then
         raise pdf_error with "pdf_page_properties.set_page_box error";
      end if;
   end set_page_box;

   ---------------------------------------------------------------------
   --
   -- pdf_document_properties
   --

   -- m4_pdf_initialize(document_properties)
   -- m4_pdf_finalize(document_properties)

   -- m4_pdf_set_string(document_properties, title)
   -- m4_pdf_set_string(document_properties, author)
   -- m4_pdf_set_string(document_properties, creator)
   -- m4_pdf_set_boolean(document_properties, tagged)

   procedure set_default_page_properties
     (properties : in out pdf_document_properties;
      page_properties : in pdf_page_properties'class)
   is
      err : capypdf_ec;
   begin
      err :=
        capy_document_properties_set_default_page_properties
          (properties.docprops, page_properties.pageprops);
      if err /= 0 then
         raise pdf_error with
           "pdf_document_properties.set_default_page_properties error";
      end if;
   end set_default_page_properties;

   ---------------------------------------------------------------------

end pdf;

-- local variables:
-- mode: ada
-- end:
