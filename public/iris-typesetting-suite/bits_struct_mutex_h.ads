pragma Ada_2012;

pragma Style_Checks (Off);
pragma Warnings (Off, "-gnatwu");

with Interfaces.C; use Interfaces.C;
with bits_thread_shared_types_h;

package bits_struct_mutex_h is

   type uu_pthread_mutex_s is record
      uu_lock : aliased int;  -- /usr/local/include/bits/struct_mutex.h:24
      uu_count : aliased unsigned;  -- /usr/local/include/bits/struct_mutex.h:25
      uu_owner : aliased int;  -- /usr/local/include/bits/struct_mutex.h:26
      uu_nusers : aliased unsigned;  -- /usr/local/include/bits/struct_mutex.h:28
      uu_kind : aliased int;  -- /usr/local/include/bits/struct_mutex.h:32
      uu_spins : aliased short;  -- /usr/local/include/bits/struct_mutex.h:34
      uu_elision : aliased short;  -- /usr/local/include/bits/struct_mutex.h:35
      uu_list : aliased bits_thread_shared_types_h.uu_pthread_list_t;  -- /usr/local/include/bits/struct_mutex.h:36
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/bits/struct_mutex.h:22

end bits_struct_mutex_h;

pragma Style_Checks (On);
pragma Warnings (On, "-gnatwu");
