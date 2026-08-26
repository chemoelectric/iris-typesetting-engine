pragma Ada_2012;

pragma Style_Checks (Off);
pragma Warnings (Off, "-gnatwu");

with Interfaces.C; use Interfaces.C;

package stddef_h is

   --  unsupported macro: NULL ((void *)0)
   subtype size_t is unsigned_long;  -- /usr/local/lib/gcc/x86_64-unknown-linux-gnu/16.2.0/include/stddef.h:229

   subtype wchar_t is int;  -- /usr/local/lib/gcc/x86_64-unknown-linux-gnu/16.2.0/include/stddef.h:344

end stddef_h;

pragma Style_Checks (On);
pragma Warnings (On, "-gnatwu");
