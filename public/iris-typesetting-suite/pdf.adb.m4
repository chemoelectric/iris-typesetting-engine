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
   -- pdf_document_properties
   --

   -- m4_pdf_require_open(document_properties)
   -- m4_pdf_open(document_properties)
   -- m4_pdf_close_and_finalize(document_properties)
   -- m4_pdf_is_open(document_properties)
   -- m4_pdf_set_string(document_properties, title)
   -- m4_pdf_set_string(document_properties, author)
   -- m4_pdf_set_string(document_properties, creator)
   -- m4_pdf_set_boolean(document_properties, tagged)

   ---------------------------------------------------------------------

end pdf;

-- local variables:
-- mode: ada
-- end:
