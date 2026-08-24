--
-- SPDX-License-Identifier: MIT
--
-- A wrapper around the CapyPDF FFI.
--

pragma wide_character_encoding (utf8);
pragma ada_2022;

with interfaces.c;
with capypdf_0_capypdf_h;

package body pdf is

   use interfaces.c;
   use capypdf_0_capypdf_h;

   procedure open (object : in out pdf_document_properties) is
      err      : capypdf_ec;
      docprops : aliased access capypdf_documentproperties;
   begin
      --
      -- It is allowed to “open” an already opened object.
      --
      if not object.is_open then
         err := capy_document_properties_new (docprops'address);
         if err = 0 then
            object.is_open := true;
            object.docprops := docprops;
         else
            raise pdf_error
              with "error opening pdf_document_properties";
         end if;
      end if;
   end open;

   procedure close (object : in out pdf_document_properties) is
      err : capypdf_ec;
   begin
      --
      -- It is allowed to “close” an already closed object.
      --
      if object.is_open then
         err := capy_document_properties_destroy (object.docprops);
         if err = 0 then
            object.is_open := false;
         else
            raise pdf_error
              with "error closing pdf_document_properties";
         end if;
      end if;
   end close;

   overriding
   procedure finalize (object : in out pdf_document_properties) is
   begin
      object.close;
   end finalize;

end pdf;
