pragma Ada_2012;

pragma Style_Checks (Off);
pragma Warnings (Off, "-gnatwu");

with Interfaces.C; use Interfaces.C;
with bits_types_h;

package bits_types_time_t_h is

   subtype time_t is bits_types_h.uu_time_t;  -- /usr/local/include/bits/types/time_t.h:10

end bits_types_time_t_h;

pragma Style_Checks (On);
pragma Warnings (On, "-gnatwu");
