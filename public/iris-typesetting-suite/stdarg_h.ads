pragma Ada_2012;

pragma Style_Checks (Off);
pragma Warnings (Off, "-gnatwu");

with Interfaces.C; use Interfaces.C;
with System;

package stdarg_h is

   --  unsupported macro: va_start(...) __builtin_c23_va_start(__VA_ARGS__)
   --  arg-macro: procedure va_end (v)
   --    __builtin_va_end(v)
   --  arg-macro: procedure va_arg (v, l)
   --    __builtin_va_arg(v,l)
   --  arg-macro: procedure va_copy (d, s)
   --    __builtin_va_copy(d,s)
   subtype uu_gnuc_va_list is System.Address;  -- /usr/local/lib/gcc/x86_64-unknown-linux-gnu/16.1.0/include/stdarg.h:40

   subtype va_list is uu_gnuc_va_list;  -- /usr/local/lib/gcc/x86_64-unknown-linux-gnu/16.1.0/include/stdarg.h:104

end stdarg_h;

pragma Style_Checks (On);
pragma Warnings (On, "-gnatwu");
