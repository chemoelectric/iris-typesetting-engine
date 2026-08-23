pragma Ada_2012;

pragma Style_Checks (Off);
pragma Warnings (Off, "-gnatwu");

with Interfaces.C; use Interfaces.C;
with bits_types_h;

package bits_types_struct_timeval_h is

   type timeval is record
      tv_sec : aliased bits_types_h.uu_time_t;  -- /usr/local/include/bits/types/struct_timeval.h:14
      tv_usec : aliased bits_types_h.uu_suseconds_t;  -- /usr/local/include/bits/types/struct_timeval.h:15
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/bits/types/struct_timeval.h:8

end bits_types_struct_timeval_h;

pragma Style_Checks (On);
pragma Warnings (On, "-gnatwu");
