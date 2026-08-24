dnl  SPDX-License-Identifier: MIT
include(ada-macros.m4)m4_divert(-1)

m4_define({m4_capypdf_type},
  {m4_ifelse($1,{document_properties},{capypdf_documentproperties},
             $1,{page_properties},{capypdf_pageproperties})})

m4_define({m4_capypdf_field},
  {m4_ifelse($1,{document_properties},{docprops},
             $1,{page_properties},{pageprops})})

m4_define({m4_capypdf_argname},
  {m4_ifelse($1,{document_properties},{properties},
             $1,{page_properties},{properties})})

m4_define({m4_pdf_require_open},{
procedure require_open (m4_capypdf_argname({$1}) : in pdf_$1) is
begin
   if not m4_capypdf_argname({$1}).is_open then
      raise pdf_error
        with "attempt to use a closed pdf_$1";
   end if;
end require_open;
})

m4_define({m4_pdf_open},{
procedure open (m4_capypdf_argname({$1}) : in out pdf_$1) is
   err : capypdf_ec;
   m4_capypdf_field({$1}) : aliased access m4_capypdf_type({$1});
begin
   --
   -- It is allowed to “open” an already opened m4_capypdf_argname({$1}).
   --
   if not m4_capypdf_argname({$1}).is_open then
      err := capy_$1_new (m4_capypdf_field({$1})'address);
      if err = 0 then
         m4_capypdf_argname({$1}).is_open := true;
         m4_capypdf_argname({$1}).m4_capypdf_field({$1}) :=
            m4_capypdf_field({$1});
      else
         raise pdf_error
           with "error opening pdf_$1";
      end if;
   end if;
end open;
})

m4_define({m4_pdf_close},{
procedure close (m4_capypdf_argname({$1}) : in out pdf_$1) is
   err : capypdf_ec;
begin
   --
   -- It is allowed to “close” an already closed m4_capypdf_argname({$1}).
   --
   if m4_capypdf_argname({$1}).is_open then
      err :=
         capy_$1_destroy
            (m4_capypdf_argname({$1}).m4_capypdf_field({$1}));
      if err = 0 then
         m4_capypdf_argname({$1}).is_open := false;
      else
         raise pdf_error
         with "error closing pdf_$1";
      end if;
   end if;
end close;
})

m4_define({m4_pdf_close_and_finalize},{
m4_pdf_close({$1})

overriding
procedure finalize (m4_capypdf_argname({$1}) : in out pdf_$1) is
begin
   m4_capypdf_argname({$1}).close;
end finalize;
})

m4_define({m4_pdf_is_open},{
function is_open
   (m4_capypdf_argname({$1}) : in pdf_$1) return boolean is
begin
   return m4_capypdf_argname({$1}).is_open;
end is_open;
})

m4_define({m4_pdf_set_string},{
procedure set_$2 (m4_capypdf_argname({$1}) : in out pdf_$1;
                  $2 : in string)
is
   err : capypdf_ec;
   s   : chars_ptr;
   n   : size_t;
begin
   m4_capypdf_argname({$1}).require_open;
   s := new_string ($2);
   n := strlen (s);
   err :=
      capy_$1_set_$2
         (m4_capypdf_argname({$1}).m4_capypdf_field({$1}),
          s, int32_t (n));
   if err /= 0 then
      free (s);
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
   m4_capypdf_argname({$1}).require_open;
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
