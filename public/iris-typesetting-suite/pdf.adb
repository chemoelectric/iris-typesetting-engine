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

   --
   procedure require_open (properties : in pdf_document_properties) is
   begin
      if not properties.is_open then
         raise pdf_error
           with "attempt to use a closed pdf_document_properties";
      end if;
   end require_open;

   --
   procedure open (properties : in out pdf_document_properties) is
      err      : capypdf_ec;
      docprops : aliased access capypdf_documentproperties;
   begin
      --
      -- It is allowed to “open” an already opened properties.
      --
      if not properties.is_open then
         err := capy_document_properties_new (docprops'address);
         if err = 0 then
            properties.is_open := true;
            properties.docprops := docprops;
         else
            raise pdf_error
              with "error opening pdf_document_properties";
         end if;
      end if;
   end open;

   --

   procedure close (properties : in out pdf_document_properties) is
      err : capypdf_ec;
   begin
      --
      -- It is allowed to “close” an already closed properties.
      --
      if properties.is_open then
         err := capy_document_properties_destroy (properties.docprops);
         if err = 0 then
            properties.is_open := false;
         else
            raise pdf_error
              with "error closing pdf_document_properties";
         end if;
      end if;
   end close;

   overriding
   procedure finalize (properties : in out pdf_document_properties) is
   begin
      properties.close;
   end finalize;

   --
   function is_open
     (properties : in pdf_document_properties) return boolean is
   begin
      return properties.is_open;
   end is_open;

   --
   procedure set_title
     (properties : in out pdf_document_properties; title : in string)
   is
      err : capypdf_ec;
      s   : chars_ptr;
      n   : size_t;
   begin
      properties.require_open;
      s := new_string (title);
      n := strlen (s);
      err :=
        capy_document_properties_set_title
          (properties.docprops, s, int32_t (n));
      if err /= 0 then
         free (s);
         raise pdf_error with "pdf_document_properties.set_title error";
      end if;
      free (s);
   exception
      when others =>
         if s /= null_ptr then
            free (s);
         end if;
         raise;
   end set_title;

   --
   procedure set_author
     (properties : in out pdf_document_properties; author : in string)
   is
      err : capypdf_ec;
      s   : chars_ptr;
      n   : size_t;
   begin
      properties.require_open;
      s := new_string (author);
      n := strlen (s);
      err :=
        capy_document_properties_set_author
          (properties.docprops, s, int32_t (n));
      if err /= 0 then
         free (s);
         raise pdf_error
           with "pdf_document_properties.set_author error";
      end if;
      free (s);
   exception
      when others =>
         if s /= null_ptr then
            free (s);
         end if;
         raise;
   end set_author;

   --
   procedure set_creator
     (properties : in out pdf_document_properties; creator : in string)
   is
      err : capypdf_ec;
      s   : chars_ptr;
      n   : size_t;
   begin
      properties.require_open;
      s := new_string (creator);
      n := strlen (s);
      err :=
        capy_document_properties_set_creator
          (properties.docprops, s, int32_t (n));
      if err /= 0 then
         free (s);
         raise pdf_error
           with "pdf_document_properties.set_creator error";
      end if;
      free (s);
   exception
      when others =>
         if s /= null_ptr then
            free (s);
         end if;
         raise;
   end set_creator;

   --
   procedure set_tagged
     (properties : in out pdf_document_properties;
      is_tagged  : in boolean)
   is
      err : capypdf_ec;
   begin
      properties.require_open;
      err :=
        capy_document_properties_set_tagged
          (properties.docprops, (if is_tagged then 1 else 0));
      if err /= 0 then
         raise pdf_error
           with "pdf_document_properties.set_tagged error";
      end if;
   end set_tagged;

   ---------------------------------------------------------------------
   --
   -- pdf_page_properties
   --

   --
   procedure require_open (properties : in pdf_page_properties) is
   begin
      if not properties.is_open then
         raise pdf_error
           with "attempt to use a closed pdf_page_properties";
      end if;
   end require_open;

   --
   procedure open (properties : in out pdf_page_properties) is
      err       : capypdf_ec;
      pageprops : aliased access capypdf_pageproperties;
   begin
      --
      -- It is allowed to “open” an already opened properties.
      --
      if not properties.is_open then
         err := capy_page_properties_new (pageprops'address);
         if err = 0 then
            properties.is_open := true;
            properties.pageprops := pageprops;
         else
            raise pdf_error with "error opening pdf_page_properties";
         end if;
      end if;
   end open;

   --

   procedure close (properties : in out pdf_page_properties) is
      err : capypdf_ec;
   begin
      --
      -- It is allowed to “close” an already closed properties.
      --
      if properties.is_open then
         err := capy_page_properties_destroy (properties.pageprops);
         if err = 0 then
            properties.is_open := false;
         else
            raise pdf_error with "error closing pdf_page_properties";
         end if;
      end if;
   end close;

   overriding
   procedure finalize (properties : in out pdf_page_properties) is
   begin
      properties.close;
   end finalize;

   --
   function is_open (properties : in pdf_page_properties) return boolean
   is
   begin
      return properties.is_open;
   end is_open;

   ---------------------------------------------------------------------

end pdf;

-- local variables:
-- mode: ada
-- end:
