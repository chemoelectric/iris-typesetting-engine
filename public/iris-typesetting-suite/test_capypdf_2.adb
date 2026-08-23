-- SPDX-License-Identifier: MIT

with interfaces.c;
with ada.text_io;
with ada.strings.unbounded;
with capypdf;

procedure test_capypdf_2 is
   use interfaces.c;
   use ada.text_io;
   use ada.strings.unbounded;
   use capypdf;

   bp_per_inch : constant double := double'(72.0);

   test_failed : exception;
   capyerr : capy_error;

   pagecfg1 : page_config;

   doc1_name : constant unbounded_string :=
     to_unbounded_string ("capypdf_2-001.pdf");
   doc1 : pdf_document;

   procedure fail_if (predicate : boolean;
                      message : string)
   is
   begin
      if predicate then
         raise test_failed with message;
      end if;
   end fail_if;

begin
   pagecfg1 :=
     create_page_config (double'(8.5) * bp_per_inch,
                         double'(11.0) * bp_per_inch);

   doc1 := create_document (doc1_name);
   fail_if (not doc1.is_open, "doc1 not opened");
   
   capyerr := close_document (doc1);
   fail_if (capyerr /= capy_err_ok, capyerr'image);

   destroy_page_config (pagecfg1);
end test_capypdf_2;
