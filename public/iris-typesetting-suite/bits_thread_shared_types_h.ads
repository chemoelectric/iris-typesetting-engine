pragma Ada_2012;

pragma Style_Checks (Off);
pragma Warnings (Off, "-gnatwu");

with Interfaces.C; use Interfaces.C;
with bits_atomic_wide_counter_h;

package bits_thread_shared_types_h is

   type uu_pthread_internal_list;
   type uu_pthread_internal_list is record
      uu_prev : access uu_pthread_internal_list;  -- /usr/local/include/bits/thread-shared-types.h:53
      uu_next : access uu_pthread_internal_list;  -- /usr/local/include/bits/thread-shared-types.h:54
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/bits/thread-shared-types.h:51

   subtype uu_pthread_list_t is uu_pthread_internal_list;  -- /usr/local/include/bits/thread-shared-types.h:55

   type uu_pthread_internal_slist;
   type uu_pthread_internal_slist is record
      uu_next : access uu_pthread_internal_slist;  -- /usr/local/include/bits/thread-shared-types.h:59
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/bits/thread-shared-types.h:57

   subtype uu_pthread_slist_t is uu_pthread_internal_slist;  -- /usr/local/include/bits/thread-shared-types.h:60

   type anon_array1253 is array (0 .. 1) of aliased unsigned;
   type uu_pthread_cond_s is record
      uu_wseq : aliased bits_atomic_wide_counter_h.uu_atomic_wide_counter;  -- /usr/local/include/bits/thread-shared-types.h:96
      uu_g1_start : aliased bits_atomic_wide_counter_h.uu_atomic_wide_counter;  -- /usr/local/include/bits/thread-shared-types.h:97
      uu_g_size : aliased anon_array1253;  -- /usr/local/include/bits/thread-shared-types.h:98
      uu_g1_orig_size : aliased unsigned;  -- /usr/local/include/bits/thread-shared-types.h:99
      uu_wrefs : aliased unsigned;  -- /usr/local/include/bits/thread-shared-types.h:100
      uu_g_signals : aliased anon_array1253;  -- /usr/local/include/bits/thread-shared-types.h:101
      uu_unused_initialized_1 : aliased unsigned;  -- /usr/local/include/bits/thread-shared-types.h:102
      uu_unused_initialized_2 : aliased unsigned;  -- /usr/local/include/bits/thread-shared-types.h:103
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/bits/thread-shared-types.h:94

   subtype uu_tss_t is unsigned;  -- /usr/local/include/bits/thread-shared-types.h:106

   subtype uu_thrd_t is unsigned_long;  -- /usr/local/include/bits/thread-shared-types.h:107

   type uu_once_flag is record
      uu_data : aliased int;  -- /usr/local/include/bits/thread-shared-types.h:111
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/bits/thread-shared-types.h:112

end bits_thread_shared_types_h;

pragma Style_Checks (On);
pragma Warnings (On, "-gnatwu");
