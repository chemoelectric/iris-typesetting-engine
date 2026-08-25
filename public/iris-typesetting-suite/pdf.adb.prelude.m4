dnl  SPDX-License-Identifier: MIT
include(ada-macros.m4)m4_divert(-1)

m4_define({m4_capypdf_type},
  {m4_ifelse($1,{font_id},{capypdf_fontid},
             $1,{font_properties},{capypdf_fontproperties},
             $1,{page_properties},{capypdf_pageproperties},
             $1,{document_properties},{capypdf_documentproperties},
             $1,{generator},{capypdf_generator})})

m4_define({m4_capypdf_field},
  {m4_ifelse($1,{font_id},{id},
             $1,{font_properties},{fprop},
             $1,{page_properties},{pageprops},
             $1,{document_properties},{docprops},
             $1,{generator},{gen})})

m4_define({m4_capypdf_argname},
  {m4_ifelse($1,{font_id},{id},
             $1,{font_properties},{properties},
             $1,{page_properties},{properties},
             $1,{document_properties},{properties},
             $1,{generator},{generator})})

m4_define({m4_pdf_initialize},{
procedure initialize (m4_capypdf_argname({$1}) : in out pdf_$1) is
   err : capypdf_ec;
   m4_capypdf_field({$1}) : aliased access m4_capypdf_type({$1});
begin
   err := capy_$1_new (m4_capypdf_field({$1})'address);
   if err = 0 then
      m4_capypdf_argname({$1}).m4_capypdf_field({$1}) :=
         m4_capypdf_field({$1});
   else
      raise pdf_error with "pdf_$1 initialization error";
   end if;
end initialize;
})

m4_define({m4_pdf_finalize},{
procedure finalize (m4_capypdf_argname({$1}) : in out pdf_$1) is
   err : capypdf_ec;
begin
   err :=
      capy_$1_destroy
         (m4_capypdf_argname({$1}).m4_capypdf_field({$1}));
   if err /= 0 then
      raise pdf_error with "pdf_$1 finalization error";
   end if;
end finalize;
})

m4_define({m4_pdf_set_string},{
procedure set_$2 (m4_capypdf_argname({$1}) : in out pdf_$1;
                  $2 : in string)
is
   err : capypdf_ec;
   s   : chars_ptr;
   n   : size_t;
begin
   s := new_string ($2);
   n := strlen (s);
   err :=
      capy_$1_set_$2
         (m4_capypdf_argname({$1}).m4_capypdf_field({$1}),
          s, int32_t (n));
   if err /= 0 then
      raise pdf_error with "pdf_$1.set_$2 error";
   end if;
   free (s);
exception
   when others =>
      if s /= null_ptr then
         free (s);
      end if;
      raise;
end set_$2;
})

m4_define({m4_pdf_set_boolean},{
procedure set_$2
  (m4_capypdf_argname({$1}) : in out pdf_$1;
   is_$2  : in boolean)
is
   err : capypdf_ec;
begin
   err :=
     capy_$1_set_$2
       (m4_capypdf_argname({$1}).m4_capypdf_field({$1}),
        (if is_$2 then 1 else 0));
   if err /= 0 then
      raise pdf_error with "pdf_$1.set_$2 error";
   end if;
end set_$2;
})

m4_divert{}m4_dnl
