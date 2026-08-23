pragma Ada_2012;

pragma Style_Checks (Off);
pragma Warnings (Off, "-gnatwu");

with Interfaces.C; use Interfaces.C;

package stddef_h is

   subtype size_t is unsigned_long;  -- /usr/local/lib/gcc/x86_64-unknown-linux-gnu/16.1.0/include/stddef.h:229

end stddef_h;

pragma Style_Checks (On);
pragma Warnings (On, "-gnatwu");
