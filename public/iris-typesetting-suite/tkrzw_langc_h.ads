pragma Ada_2012;

pragma Style_Checks (Off);
pragma Warnings (Off, "-gnatwu");

with Interfaces.C; use Interfaces.C;
with Interfaces.C.Strings;
with bits_stdint_intn_h;
with System;
with bits_stdint_uintn_h;
with Interfaces.C.Extensions;
with stddef_h;

package tkrzw_langc_h is

   TKRZW_PACKAGE_VERSION : constant Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:26
   with Import => True, 
        Convention => C, 
        External_Name => "TKRZW_PACKAGE_VERSION";

   TKRZW_LIBRARY_VERSION : constant Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:29
   with Import => True, 
        Convention => C, 
        External_Name => "TKRZW_LIBRARY_VERSION";

   TKRZW_OS_NAME : constant Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:32
   with Import => True, 
        Convention => C, 
        External_Name => "TKRZW_OS_NAME";

   TKRZW_PAGE_SIZE : aliased constant bits_stdint_intn_h.int32_t  -- /usr/local/include/tkrzw_langc.h:35
   with Import => True, 
        Convention => C, 
        External_Name => "TKRZW_PAGE_SIZE";

   TKRZW_INT64MIN : aliased constant bits_stdint_intn_h.int64_t  -- /usr/local/include/tkrzw_langc.h:38
   with Import => True, 
        Convention => C, 
        External_Name => "TKRZW_INT64MIN";

   TKRZW_INT64MAX : aliased constant bits_stdint_intn_h.int64_t  -- /usr/local/include/tkrzw_langc.h:41
   with Import => True, 
        Convention => C, 
        External_Name => "TKRZW_INT64MAX";

   type TkrzwStatus is record
      code : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/tkrzw_langc.h:80
      message : Interfaces.C.Strings.chars_ptr;  -- /usr/local/include/tkrzw_langc.h:82
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/tkrzw_langc.h:83

   type TkrzwFuture is record
      u_dummy_u : System.Address;  -- /usr/local/include/tkrzw_langc.h:90
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/tkrzw_langc.h:91

   type TkrzwDBM is record
      u_dummy_u : System.Address;  -- /usr/local/include/tkrzw_langc.h:98
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/tkrzw_langc.h:99

   type TkrzwDBMIter is record
      u_dummy_u : System.Address;  -- /usr/local/include/tkrzw_langc.h:106
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/tkrzw_langc.h:107

   type TkrzwAsyncDBM is record
      u_dummy_u : System.Address;  -- /usr/local/include/tkrzw_langc.h:114
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/tkrzw_langc.h:115

   type TkrzwFile is record
      u_dummy_u : System.Address;  -- /usr/local/include/tkrzw_langc.h:122
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/tkrzw_langc.h:123

   type TkrzwIndex is record
      u_dummy_u : System.Address;  -- /usr/local/include/tkrzw_langc.h:130
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/tkrzw_langc.h:131

   type TkrzwIndexIter is record
      u_dummy_u : System.Address;  -- /usr/local/include/tkrzw_langc.h:138
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/tkrzw_langc.h:139

   TKRZW_ANY_DATA : constant Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:142
   with Import => True, 
        Convention => C, 
        External_Name => "TKRZW_ANY_DATA";

   type tkrzw_record_processor is access function
        (arg1 : System.Address;
         arg2 : Interfaces.C.Strings.chars_ptr;
         arg3 : bits_stdint_intn_h.int32_t;
         arg4 : Interfaces.C.Strings.chars_ptr;
         arg5 : bits_stdint_intn_h.int32_t;
         arg6 : access bits_stdint_intn_h.int32_t) return Interfaces.C.Strings.chars_ptr
   with Convention => C;  -- /usr/local/include/tkrzw_langc.h:152

   TKRZW_REC_PROC_NOOP : constant Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:156
   with Import => True, 
        Convention => C, 
        External_Name => "TKRZW_REC_PROC_NOOP";

   TKRZW_REC_PROC_REMOVE : constant Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:159
   with Import => True, 
        Convention => C, 
        External_Name => "TKRZW_REC_PROC_REMOVE";

   type TkrzwStr is record
      ptr : Interfaces.C.Strings.chars_ptr;  -- /usr/local/include/tkrzw_langc.h:166
      size : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/tkrzw_langc.h:168
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/tkrzw_langc.h:169

   type TkrzwKeyValuePair is record
      key_ptr : Interfaces.C.Strings.chars_ptr;  -- /usr/local/include/tkrzw_langc.h:176
      key_size : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/tkrzw_langc.h:178
      value_ptr : Interfaces.C.Strings.chars_ptr;  -- /usr/local/include/tkrzw_langc.h:180
      value_size : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/tkrzw_langc.h:182
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/tkrzw_langc.h:183

   type TkrzwKeyProcPair is record
      key_ptr : Interfaces.C.Strings.chars_ptr;  -- /usr/local/include/tkrzw_langc.h:190
      key_size : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/tkrzw_langc.h:192
      proc : tkrzw_record_processor;  -- /usr/local/include/tkrzw_langc.h:194
      proc_arg : System.Address;  -- /usr/local/include/tkrzw_langc.h:196
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/tkrzw_langc.h:197

   type tkrzw_file_processor is access procedure (arg1 : System.Address; arg2 : Interfaces.C.Strings.chars_ptr)
   with Convention => C;  -- /usr/local/include/tkrzw_langc.h:204

   procedure tkrzw_set_last_status (code : bits_stdint_intn_h.int32_t; message : Interfaces.C.Strings.chars_ptr)  -- /usr/local/include/tkrzw_langc.h:211
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_set_last_status";

   function tkrzw_get_last_status return TkrzwStatus  -- /usr/local/include/tkrzw_langc.h:219
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_get_last_status";

   function tkrzw_get_last_status_code return bits_stdint_intn_h.int32_t  -- /usr/local/include/tkrzw_langc.h:225
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_get_last_status_code";

   function tkrzw_get_last_status_message return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:233
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_get_last_status_message";

   function tkrzw_status_code_name (code : bits_stdint_intn_h.int32_t) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:240
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_status_code_name";

   function tkrzw_get_wall_time return double  -- /usr/local/include/tkrzw_langc.h:246
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_get_wall_time";

   function tkrzw_get_memory_capacity return bits_stdint_intn_h.int64_t  -- /usr/local/include/tkrzw_langc.h:252
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_get_memory_capacity";

   function tkrzw_get_memory_usage return bits_stdint_intn_h.int64_t  -- /usr/local/include/tkrzw_langc.h:258
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_get_memory_usage";

   function tkrzw_primary_hash
     (data_ptr : Interfaces.C.Strings.chars_ptr;
      data_size : bits_stdint_intn_h.int32_t;
      num_buckets : bits_stdint_uintn_h.uint64_t) return bits_stdint_uintn_h.uint64_t  -- /usr/local/include/tkrzw_langc.h:267
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_primary_hash";

   function tkrzw_secondary_hash
     (data_ptr : Interfaces.C.Strings.chars_ptr;
      data_size : bits_stdint_intn_h.int32_t;
      num_shards : bits_stdint_uintn_h.uint64_t) return bits_stdint_uintn_h.uint64_t  -- /usr/local/include/tkrzw_langc.h:276
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_secondary_hash";

   procedure tkrzw_free_str_array (c_array : access TkrzwStr; size : bits_stdint_intn_h.int32_t)  -- /usr/local/include/tkrzw_langc.h:283
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_free_str_array";

   procedure tkrzw_free_str_map (c_array : access TkrzwKeyValuePair; size : bits_stdint_intn_h.int32_t)  -- /usr/local/include/tkrzw_langc.h:290
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_free_str_map";

   function tkrzw_search_str_map
     (c_array : access TkrzwKeyValuePair;
      size : bits_stdint_intn_h.int32_t;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t) return access TkrzwKeyValuePair  -- /usr/local/include/tkrzw_langc.h:300
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_search_str_map";

   function tkrzw_str_search_regex (text : Interfaces.C.Strings.chars_ptr; pattern : Interfaces.C.Strings.chars_ptr) return bits_stdint_intn_h.int32_t  -- /usr/local/include/tkrzw_langc.h:310
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_str_search_regex";

   function tkrzw_str_replace_regex
     (text : Interfaces.C.Strings.chars_ptr;
      pattern : Interfaces.C.Strings.chars_ptr;
      replace : Interfaces.C.Strings.chars_ptr) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:320
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_str_replace_regex";

   function tkrzw_str_edit_distance_lev
     (a : Interfaces.C.Strings.chars_ptr;
      b : Interfaces.C.Strings.chars_ptr;
      utf : Extensions.bool) return bits_stdint_intn_h.int32_t  -- /usr/local/include/tkrzw_langc.h:329
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_str_edit_distance_lev";

   function tkrzw_str_to_int_be (ptr : System.Address; size : stddef_h.size_t) return bits_stdint_uintn_h.uint64_t  -- /usr/local/include/tkrzw_langc.h:338
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_str_to_int_be";

   function tkrzw_str_to_float_be (ptr : System.Address; size : stddef_h.size_t) return long_double  -- /usr/local/include/tkrzw_langc.h:346
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_str_to_float_be";

   function tkrzw_int_to_str_be (data : bits_stdint_uintn_h.uint64_t; size : stddef_h.size_t) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:354
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_int_to_str_be";

   function tkrzw_float_to_str_be (data : long_double; size : stddef_h.size_t) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:362
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_float_to_str_be";

   function tkrzw_str_escape_c
     (ptr : Interfaces.C.Strings.chars_ptr;
      size : bits_stdint_intn_h.int32_t;
      esc_nonasc : Extensions.bool;
      res_size : access bits_stdint_intn_h.int32_t) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:373
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_str_escape_c";

   function tkrzw_str_unescape_c
     (ptr : Interfaces.C.Strings.chars_ptr;
      size : bits_stdint_intn_h.int32_t;
      res_size : access bits_stdint_intn_h.int32_t) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:383
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_str_unescape_c";

   function tkrzw_str_append (modified : Interfaces.C.Strings.chars_ptr; appended : Interfaces.C.Strings.chars_ptr) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:392
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_str_append";

   procedure tkrzw_future_free (future : access TkrzwFuture)  -- /usr/local/include/tkrzw_langc.h:398
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_future_free";

   function tkrzw_future_wait (future : access TkrzwFuture; timeout : double) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:406
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_future_wait";

   procedure tkrzw_future_get (future : access TkrzwFuture)  -- /usr/local/include/tkrzw_langc.h:416
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_future_get";

   function tkrzw_future_get_str (future : access TkrzwFuture; size : access bits_stdint_intn_h.int32_t) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:431
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_future_get_str";

   function tkrzw_future_get_str_pair (future : access TkrzwFuture) return access TkrzwKeyValuePair  -- /usr/local/include/tkrzw_langc.h:443
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_future_get_str_pair";

   function tkrzw_future_get_str_array (future : access TkrzwFuture; num_elems : access bits_stdint_intn_h.int32_t) return access TkrzwStr  -- /usr/local/include/tkrzw_langc.h:457
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_future_get_str_array";

   function tkrzw_future_get_str_map (future : access TkrzwFuture; num_elems : access bits_stdint_intn_h.int32_t) return access TkrzwKeyValuePair  -- /usr/local/include/tkrzw_langc.h:471
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_future_get_str_map";

   function tkrzw_future_get_int (future : access TkrzwFuture) return bits_stdint_intn_h.int64_t  -- /usr/local/include/tkrzw_langc.h:482
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_future_get_int";

   function tkrzw_dbm_open
     (path : Interfaces.C.Strings.chars_ptr;
      writable : Extensions.bool;
      params : Interfaces.C.Strings.chars_ptr) return access TkrzwDBM  -- /usr/local/include/tkrzw_langc.h:495
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_open";

   function tkrzw_dbm_close (dbm : access TkrzwDBM) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:502
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_close";

   function tkrzw_dbm_process
     (dbm : access TkrzwDBM;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t;
      proc : tkrzw_record_processor;
      proc_arg : System.Address;
      writable : Extensions.bool) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:518
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_process";

   function tkrzw_dbm_check
     (dbm : access TkrzwDBM;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:529
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_check";

   function tkrzw_dbm_get
     (dbm : access TkrzwDBM;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t;
      value_size : access bits_stdint_intn_h.int32_t) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:543
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_get";

   function tkrzw_dbm_get_multi
     (dbm : access TkrzwDBM;
      keys : access constant TkrzwStr;
      num_keys : bits_stdint_intn_h.int32_t;
      num_matched : access bits_stdint_intn_h.int32_t) return access TkrzwKeyValuePair  -- /usr/local/include/tkrzw_langc.h:557
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_get_multi";

   function tkrzw_dbm_set
     (dbm : access TkrzwDBM;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t;
      value_ptr : Interfaces.C.Strings.chars_ptr;
      value_size : bits_stdint_intn_h.int32_t;
      overwrite : Extensions.bool) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:573
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_set";

   function tkrzw_dbm_set_and_get
     (dbm : access TkrzwDBM;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t;
      value_ptr : Interfaces.C.Strings.chars_ptr;
      value_size : bits_stdint_intn_h.int32_t;
      overwrite : Extensions.bool;
      old_value_size : access bits_stdint_intn_h.int32_t) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:594
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_set_and_get";

   function tkrzw_dbm_set_multi
     (dbm : access TkrzwDBM;
      records : access constant TkrzwKeyValuePair;
      num_records : bits_stdint_intn_h.int32_t;
      overwrite : Extensions.bool) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:609
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_set_multi";

   function tkrzw_dbm_remove
     (dbm : access TkrzwDBM;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:620
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_remove";

   function tkrzw_dbm_remove_and_get
     (dbm : access TkrzwDBM;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t;
      value_size : access bits_stdint_intn_h.int32_t) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:634
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_remove_and_get";

   function tkrzw_dbm_remove_multi
     (dbm : access TkrzwDBM;
      keys : access constant TkrzwStr;
      num_keys : bits_stdint_intn_h.int32_t) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:645
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_remove_multi";

   function tkrzw_dbm_append
     (dbm : access TkrzwDBM;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t;
      value_ptr : Interfaces.C.Strings.chars_ptr;
      value_size : bits_stdint_intn_h.int32_t;
      delim_ptr : Interfaces.C.Strings.chars_ptr;
      delim_size : bits_stdint_intn_h.int32_t) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:659
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_append";

   function tkrzw_dbm_append_multi
     (dbm : access TkrzwDBM;
      records : access constant TkrzwKeyValuePair;
      num_records : bits_stdint_intn_h.int32_t;
      delim_ptr : Interfaces.C.Strings.chars_ptr;
      delim_size : bits_stdint_intn_h.int32_t) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:674
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_append_multi";

   function tkrzw_dbm_compare_exchange
     (dbm : access TkrzwDBM;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t;
      expected_ptr : Interfaces.C.Strings.chars_ptr;
      expected_size : bits_stdint_intn_h.int32_t;
      desired_ptr : Interfaces.C.Strings.chars_ptr;
      desired_size : bits_stdint_intn_h.int32_t) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:692
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_compare_exchange";

   function tkrzw_dbm_compare_exchange_and_get
     (dbm : access TkrzwDBM;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t;
      expected_ptr : Interfaces.C.Strings.chars_ptr;
      expected_size : bits_stdint_intn_h.int32_t;
      desired_ptr : Interfaces.C.Strings.chars_ptr;
      desired_size : bits_stdint_intn_h.int32_t;
      actual_size : access bits_stdint_intn_h.int32_t) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:715
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_compare_exchange_and_get";

   function tkrzw_dbm_increment
     (dbm : access TkrzwDBM;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t;
      increment : bits_stdint_intn_h.int64_t;
      initial : bits_stdint_intn_h.int64_t) return bits_stdint_intn_h.int64_t  -- /usr/local/include/tkrzw_langc.h:732
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_increment";

   function tkrzw_dbm_process_multi
     (dbm : access TkrzwDBM;
      key_proc_pairs : access TkrzwKeyProcPair;
      num_pairs : bits_stdint_intn_h.int32_t;
      writable : Extensions.bool) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:748
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_process_multi";

   function tkrzw_dbm_compare_exchange_multi
     (dbm : access TkrzwDBM;
      expected : access constant TkrzwKeyValuePair;
      num_expected : bits_stdint_intn_h.int32_t;
      desired : access constant TkrzwKeyValuePair;
      num_desired : bits_stdint_intn_h.int32_t) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:764
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_compare_exchange_multi";

   function tkrzw_dbm_rekey
     (dbm : access TkrzwDBM;
      old_key_ptr : Interfaces.C.Strings.chars_ptr;
      old_key_size : bits_stdint_intn_h.int32_t;
      new_key_ptr : Interfaces.C.Strings.chars_ptr;
      new_key_size : bits_stdint_intn_h.int32_t;
      overwrite : Extensions.bool;
      copying : Extensions.bool) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:783
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_rekey";

   function tkrzw_dbm_process_first
     (dbm : access TkrzwDBM;
      proc : tkrzw_record_processor;
      proc_arg : System.Address;
      writable : Extensions.bool) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:798
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_process_first";

   function tkrzw_dbm_pop_first
     (dbm : access TkrzwDBM;
      key_ptr : System.Address;
      key_size : access bits_stdint_intn_h.int32_t;
      value_ptr : System.Address;
      value_size : access bits_stdint_intn_h.int32_t) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:816
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_pop_first";

   function tkrzw_dbm_push_last
     (dbm : access TkrzwDBM;
      value_ptr : Interfaces.C.Strings.chars_ptr;
      value_size : bits_stdint_intn_h.int32_t;
      wtime : double) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:831
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_push_last";

   function tkrzw_dbm_process_each
     (dbm : access TkrzwDBM;
      proc : tkrzw_record_processor;
      proc_arg : System.Address;
      writable : Extensions.bool) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:845
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_process_each";

   function tkrzw_dbm_count (dbm : access TkrzwDBM) return bits_stdint_intn_h.int64_t  -- /usr/local/include/tkrzw_langc.h:853
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_count";

   function tkrzw_dbm_get_file_size (dbm : access TkrzwDBM) return bits_stdint_intn_h.int64_t  -- /usr/local/include/tkrzw_langc.h:860
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_get_file_size";

   function tkrzw_dbm_get_file_path (dbm : access TkrzwDBM) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:868
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_get_file_path";

   function tkrzw_dbm_get_timestamp (dbm : access TkrzwDBM) return double  -- /usr/local/include/tkrzw_langc.h:875
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_get_timestamp";

   function tkrzw_dbm_clear (dbm : access TkrzwDBM) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:882
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_clear";

   function tkrzw_dbm_rebuild (dbm : access TkrzwDBM; params : Interfaces.C.Strings.chars_ptr) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:891
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_rebuild";

   function tkrzw_dbm_should_be_rebuilt (dbm : access TkrzwDBM) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:897
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_should_be_rebuilt";

   function tkrzw_dbm_synchronize
     (dbm : access TkrzwDBM;
      hard : Extensions.bool;
      proc : tkrzw_file_processor;
      proc_arg : System.Address;
      params : Interfaces.C.Strings.chars_ptr) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:911
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_synchronize";

   function tkrzw_dbm_copy_file_data
     (dbm : access TkrzwDBM;
      dest_path : Interfaces.C.Strings.chars_ptr;
      sync_hard : Extensions.bool) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:923
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_copy_file_data";

   function tkrzw_dbm_export (dbm : access TkrzwDBM; dest_dbm : access TkrzwDBM) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:931
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_export";

   function tkrzw_dbm_export_to_flat_records (dbm : access TkrzwDBM; dest_file : access TkrzwFile) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:939
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_export_to_flat_records";

   function tkrzw_dbm_import_from_flat_records (dbm : access TkrzwDBM; src_file : access TkrzwFile) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:947
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_import_from_flat_records";

   function tkrzw_dbm_export_keys_as_lines (dbm : access TkrzwDBM; dest_file : access TkrzwFile) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:955
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_export_keys_as_lines";

   function tkrzw_dbm_inspect (dbm : access TkrzwDBM; num_records : access bits_stdint_intn_h.int32_t) return access TkrzwKeyValuePair  -- /usr/local/include/tkrzw_langc.h:966
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_inspect";

   function tkrzw_dbm_is_writable (dbm : access TkrzwDBM) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:973
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_is_writable";

   function tkrzw_dbm_is_healthy (dbm : access TkrzwDBM) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:980
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_is_healthy";

   function tkrzw_dbm_is_ordered (dbm : access TkrzwDBM) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:987
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_is_ordered";

   function tkrzw_dbm_search
     (dbm : access TkrzwDBM;
      mode : Interfaces.C.Strings.chars_ptr;
      pattern_ptr : Interfaces.C.Strings.chars_ptr;
      pattern_size : bits_stdint_intn_h.int32_t;
      capacity : bits_stdint_intn_h.int32_t;
      num_matched : access bits_stdint_intn_h.int32_t) return access TkrzwStr  -- /usr/local/include/tkrzw_langc.h:1011
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_search";

   function tkrzw_dbm_make_iterator (dbm : access TkrzwDBM) return access TkrzwDBMIter  -- /usr/local/include/tkrzw_langc.h:1020
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_make_iterator";

   procedure tkrzw_dbm_iter_free (iter : access TkrzwDBMIter)  -- /usr/local/include/tkrzw_langc.h:1026
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_iter_free";

   function tkrzw_dbm_iter_first (iter : access TkrzwDBMIter) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1034
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_iter_first";

   function tkrzw_dbm_iter_last (iter : access TkrzwDBMIter) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1043
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_iter_last";

   function tkrzw_dbm_iter_jump
     (iter : access TkrzwDBMIter;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1055
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_iter_jump";

   function tkrzw_dbm_iter_jump_lower
     (iter : access TkrzwDBMIter;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t;
      inclusive : Extensions.bool) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1067
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_iter_jump_lower";

   function tkrzw_dbm_iter_jump_upper
     (iter : access TkrzwDBMIter;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t;
      inclusive : Extensions.bool) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1080
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_iter_jump_upper";

   function tkrzw_dbm_iter_next (iter : access TkrzwDBMIter) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1090
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_iter_next";

   function tkrzw_dbm_iter_previous (iter : access TkrzwDBMIter) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1099
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_iter_previous";

   function tkrzw_dbm_iter_process
     (iter : access TkrzwDBMIter;
      proc : tkrzw_record_processor;
      proc_arg : System.Address;
      writable : Extensions.bool) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1114
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_iter_process";

   function tkrzw_dbm_iter_get
     (iter : access TkrzwDBMIter;
      key_ptr : System.Address;
      key_size : access bits_stdint_intn_h.int32_t;
      value_ptr : System.Address;
      value_size : access bits_stdint_intn_h.int32_t) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1133
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_iter_get";

   function tkrzw_dbm_iter_get_key (iter : access TkrzwDBMIter; key_size : access bits_stdint_intn_h.int32_t) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:1145
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_iter_get_key";

   function tkrzw_dbm_iter_get_value (iter : access TkrzwDBMIter; value_size : access bits_stdint_intn_h.int32_t) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:1155
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_iter_get_value";

   function tkrzw_dbm_iter_set
     (iter : access TkrzwDBMIter;
      value_ptr : Interfaces.C.Strings.chars_ptr;
      value_size : bits_stdint_intn_h.int32_t) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1164
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_iter_set";

   function tkrzw_dbm_iter_remove (iter : access TkrzwDBMIter) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1171
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_iter_remove";

   function tkrzw_dbm_iter_step
     (iter : access TkrzwDBMIter;
      key_ptr : System.Address;
      key_size : access bits_stdint_intn_h.int32_t;
      value_ptr : System.Address;
      value_size : access bits_stdint_intn_h.int32_t) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1187
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_iter_step";

   function tkrzw_dbm_restore_database
     (old_file_path : Interfaces.C.Strings.chars_ptr;
      new_file_path : Interfaces.C.Strings.chars_ptr;
      class_name : Interfaces.C.Strings.chars_ptr;
      end_offset : bits_stdint_intn_h.int64_t;
      cipher_key : Interfaces.C.Strings.chars_ptr) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1204
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_dbm_restore_database";

   function tkrzw_async_dbm_new (dbm : access TkrzwDBM; num_worker_threads : bits_stdint_intn_h.int32_t) return access TkrzwAsyncDBM  -- /usr/local/include/tkrzw_langc.h:1223
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_new";

   procedure tkrzw_async_dbm_free (async : access TkrzwAsyncDBM)  -- /usr/local/include/tkrzw_langc.h:1229
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_free";

   function tkrzw_async_dbm_get
     (async : access TkrzwAsyncDBM;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t) return access TkrzwFuture  -- /usr/local/include/tkrzw_langc.h:1240
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_get";

   function tkrzw_async_dbm_get_multi
     (async : access TkrzwAsyncDBM;
      keys : access constant TkrzwStr;
      num_keys : bits_stdint_intn_h.int32_t) return access TkrzwFuture  -- /usr/local/include/tkrzw_langc.h:1251
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_get_multi";

   function tkrzw_async_dbm_set
     (async : access TkrzwAsyncDBM;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t;
      value_ptr : Interfaces.C.Strings.chars_ptr;
      value_size : bits_stdint_intn_h.int32_t;
      overwrite : Extensions.bool) return access TkrzwFuture  -- /usr/local/include/tkrzw_langc.h:1268
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_set";

   function tkrzw_async_dbm_set_multi
     (async : access TkrzwAsyncDBM;
      records : access constant TkrzwKeyValuePair;
      num_records : bits_stdint_intn_h.int32_t;
      overwrite : Extensions.bool) return access TkrzwFuture  -- /usr/local/include/tkrzw_langc.h:1284
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_set_multi";

   function tkrzw_async_dbm_remove
     (async : access TkrzwAsyncDBM;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t) return access TkrzwFuture  -- /usr/local/include/tkrzw_langc.h:1297
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_remove";

   function tkrzw_async_dbm_remove_multi
     (async : access TkrzwAsyncDBM;
      keys : access constant TkrzwStr;
      num_keys : bits_stdint_intn_h.int32_t) return access TkrzwFuture  -- /usr/local/include/tkrzw_langc.h:1308
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_remove_multi";

   function tkrzw_async_dbm_append
     (async : access TkrzwAsyncDBM;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t;
      value_ptr : Interfaces.C.Strings.chars_ptr;
      value_size : bits_stdint_intn_h.int32_t;
      delim_ptr : Interfaces.C.Strings.chars_ptr;
      delim_size : bits_stdint_intn_h.int32_t) return access TkrzwFuture  -- /usr/local/include/tkrzw_langc.h:1324
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_append";

   function tkrzw_async_dbm_append_multi
     (async : access TkrzwAsyncDBM;
      records : access constant TkrzwKeyValuePair;
      num_records : bits_stdint_intn_h.int32_t;
      delim_ptr : Interfaces.C.Strings.chars_ptr;
      delim_size : bits_stdint_intn_h.int32_t) return access TkrzwFuture  -- /usr/local/include/tkrzw_langc.h:1340
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_append_multi";

   function tkrzw_async_dbm_compare_exchange
     (async : access TkrzwAsyncDBM;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t;
      expected_ptr : Interfaces.C.Strings.chars_ptr;
      expected_size : bits_stdint_intn_h.int32_t;
      desired_ptr : Interfaces.C.Strings.chars_ptr;
      desired_size : bits_stdint_intn_h.int32_t) return access TkrzwFuture  -- /usr/local/include/tkrzw_langc.h:1359
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_compare_exchange";

   function tkrzw_async_dbm_increment
     (async : access TkrzwAsyncDBM;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t;
      increment : bits_stdint_intn_h.int64_t;
      initial : bits_stdint_intn_h.int64_t) return access TkrzwFuture  -- /usr/local/include/tkrzw_langc.h:1377
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_increment";

   function tkrzw_async_dbm_compare_exchange_multi
     (async : access TkrzwAsyncDBM;
      expected : access constant TkrzwKeyValuePair;
      num_expected : bits_stdint_intn_h.int32_t;
      desired : access constant TkrzwKeyValuePair;
      num_desired : bits_stdint_intn_h.int32_t) return access TkrzwFuture  -- /usr/local/include/tkrzw_langc.h:1395
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_compare_exchange_multi";

   function tkrzw_async_dbm_rekey
     (async : access TkrzwAsyncDBM;
      old_key_ptr : Interfaces.C.Strings.chars_ptr;
      old_key_size : bits_stdint_intn_h.int32_t;
      new_key_ptr : Interfaces.C.Strings.chars_ptr;
      new_key_size : bits_stdint_intn_h.int32_t;
      overwrite : Extensions.bool;
      copying : Extensions.bool) return access TkrzwFuture  -- /usr/local/include/tkrzw_langc.h:1415
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_rekey";

   function tkrzw_async_dbm_pop_first (async : access TkrzwAsyncDBM) return access TkrzwFuture  -- /usr/local/include/tkrzw_langc.h:1426
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_pop_first";

   function tkrzw_async_dbm_push_last
     (async : access TkrzwAsyncDBM;
      value_ptr : Interfaces.C.Strings.chars_ptr;
      value_size : bits_stdint_intn_h.int32_t;
      wtime : double) return access TkrzwFuture  -- /usr/local/include/tkrzw_langc.h:1441
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_push_last";

   function tkrzw_async_dbm_clear (async : access TkrzwAsyncDBM) return access TkrzwFuture  -- /usr/local/include/tkrzw_langc.h:1450
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_clear";

   function tkrzw_async_dbm_rebuild (async : access TkrzwAsyncDBM; params : Interfaces.C.Strings.chars_ptr) return access TkrzwFuture  -- /usr/local/include/tkrzw_langc.h:1460
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_rebuild";

   function tkrzw_async_dbm_synchronize
     (async : access TkrzwAsyncDBM;
      hard : Extensions.bool;
      params : Interfaces.C.Strings.chars_ptr) return access TkrzwFuture  -- /usr/local/include/tkrzw_langc.h:1472
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_synchronize";

   function tkrzw_async_dbm_copy_file_data
     (async : access TkrzwAsyncDBM;
      dest_path : Interfaces.C.Strings.chars_ptr;
      sync_hard : Extensions.bool) return access TkrzwFuture  -- /usr/local/include/tkrzw_langc.h:1485
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_copy_file_data";

   function tkrzw_async_dbm_export (async : access TkrzwAsyncDBM; dest_dbm : access TkrzwDBM) return access TkrzwFuture  -- /usr/local/include/tkrzw_langc.h:1496
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_export";

   function tkrzw_async_dbm_export_to_flat_records (async : access TkrzwAsyncDBM; dest_file : access TkrzwFile) return access TkrzwFuture  -- /usr/local/include/tkrzw_langc.h:1506
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_export_to_flat_records";

   function tkrzw_async_dbm_import_from_flat_records (async : access TkrzwAsyncDBM; src_file : access TkrzwFile) return access TkrzwFuture  -- /usr/local/include/tkrzw_langc.h:1517
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_import_from_flat_records";

   function tkrzw_async_dbm_search
     (async : access TkrzwAsyncDBM;
      mode : Interfaces.C.Strings.chars_ptr;
      pattern_ptr : Interfaces.C.Strings.chars_ptr;
      pattern_size : bits_stdint_intn_h.int32_t;
      capacity : bits_stdint_intn_h.int32_t) return access TkrzwFuture  -- /usr/local/include/tkrzw_langc.h:1536
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_async_dbm_search";

   function tkrzw_file_open
     (path : Interfaces.C.Strings.chars_ptr;
      writable : Extensions.bool;
      params : Interfaces.C.Strings.chars_ptr) return access TkrzwFile  -- /usr/local/include/tkrzw_langc.h:1563
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_file_open";

   function tkrzw_file_close (file : access TkrzwFile) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1570
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_file_close";

   function tkrzw_file_read
     (file : access TkrzwFile;
      off : bits_stdint_intn_h.int64_t;
      buf : System.Address;
      size : stddef_h.size_t) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1580
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_file_read";

   function tkrzw_file_write
     (file : access TkrzwFile;
      off : bits_stdint_intn_h.int64_t;
      buf : System.Address;
      size : stddef_h.size_t) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1590
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_file_write";

   function tkrzw_file_append
     (file : access TkrzwFile;
      buf : System.Address;
      size : stddef_h.size_t;
      off : access bits_stdint_intn_h.int64_t) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1601
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_file_append";

   function tkrzw_file_truncate (file : access TkrzwFile; size : bits_stdint_intn_h.int64_t) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1611
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_file_truncate";

   function tkrzw_file_synchronize
     (file : access TkrzwFile;
      hard : Extensions.bool;
      off : bits_stdint_intn_h.int64_t;
      size : bits_stdint_intn_h.int64_t) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1626
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_file_synchronize";

   function tkrzw_file_get_size (file : access TkrzwFile) return bits_stdint_intn_h.int64_t  -- /usr/local/include/tkrzw_langc.h:1633
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_file_get_size";

   function tkrzw_file_get_path (file : access TkrzwFile) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:1641
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_file_get_path";

   function tkrzw_file_search
     (file : access TkrzwFile;
      mode : Interfaces.C.Strings.chars_ptr;
      pattern_ptr : Interfaces.C.Strings.chars_ptr;
      pattern_size : bits_stdint_intn_h.int32_t;
      capacity : bits_stdint_intn_h.int32_t;
      num_matched : access bits_stdint_intn_h.int32_t) return access TkrzwStr  -- /usr/local/include/tkrzw_langc.h:1660
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_file_search";

   function tkrzw_index_open
     (path : Interfaces.C.Strings.chars_ptr;
      writable : Extensions.bool;
      params : Interfaces.C.Strings.chars_ptr) return access TkrzwIndex  -- /usr/local/include/tkrzw_langc.h:1681
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_index_open";

   function tkrzw_index_close (index : access TkrzwIndex) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1688
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_index_close";

   function tkrzw_index_check
     (index : access TkrzwIndex;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t;
      value_ptr : Interfaces.C.Strings.chars_ptr;
      value_size : bits_stdint_intn_h.int32_t) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1699
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_index_check";

   function tkrzw_index_get_values
     (index : access TkrzwIndex;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t;
      max : bits_stdint_intn_h.int32_t;
      num_elems : access bits_stdint_intn_h.int32_t) return access TkrzwStr  -- /usr/local/include/tkrzw_langc.h:1714
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_index_get_values";

   function tkrzw_index_add
     (index : access TkrzwIndex;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t;
      value_ptr : Interfaces.C.Strings.chars_ptr;
      value_size : bits_stdint_intn_h.int32_t) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1726
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_index_add";

   function tkrzw_index_remove
     (index : access TkrzwIndex;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t;
      value_ptr : Interfaces.C.Strings.chars_ptr;
      value_size : bits_stdint_intn_h.int32_t) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1739
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_index_remove";

   function tkrzw_index_count (index : access TkrzwIndex) return bits_stdint_intn_h.int32_t  -- /usr/local/include/tkrzw_langc.h:1748
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_index_count";

   function tkrzw_index_get_file_path (index : access TkrzwIndex) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/tkrzw_langc.h:1756
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_index_get_file_path";

   function tkrzw_index_clear (index : access TkrzwIndex) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1763
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_index_clear";

   function tkrzw_index_rebuild (index : access TkrzwIndex) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1770
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_index_rebuild";

   function tkrzw_index_synchronize (index : access TkrzwIndex; hard : Extensions.bool) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1779
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_index_synchronize";

   function tkrzw_index_is_writable (index : access TkrzwIndex) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1786
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_index_is_writable";

   function tkrzw_index_make_iterator (index : access TkrzwIndex) return access TkrzwIndexIter  -- /usr/local/include/tkrzw_langc.h:1793
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_index_make_iterator";

   procedure tkrzw_index_iter_free (iter : access TkrzwIndexIter)  -- /usr/local/include/tkrzw_langc.h:1799
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_index_iter_free";

   procedure tkrzw_index_iter_first (iter : access TkrzwIndexIter)  -- /usr/local/include/tkrzw_langc.h:1805
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_index_iter_first";

   procedure tkrzw_index_iter_last (iter : access TkrzwIndexIter)  -- /usr/local/include/tkrzw_langc.h:1811
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_index_iter_last";

   procedure tkrzw_index_iter_jump
     (iter : access TkrzwIndexIter;
      key_ptr : Interfaces.C.Strings.chars_ptr;
      key_size : bits_stdint_intn_h.int32_t;
      value_ptr : Interfaces.C.Strings.chars_ptr;
      value_size : bits_stdint_intn_h.int32_t)  -- /usr/local/include/tkrzw_langc.h:1821
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_index_iter_jump";

   procedure tkrzw_index_iter_next (iter : access TkrzwIndexIter)  -- /usr/local/include/tkrzw_langc.h:1828
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_index_iter_next";

   procedure tkrzw_index_iter_previous (iter : access TkrzwIndexIter)  -- /usr/local/include/tkrzw_langc.h:1834
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_index_iter_previous";

   function tkrzw_index_iter_get
     (iter : access TkrzwIndexIter;
      key_ptr : System.Address;
      key_size : access bits_stdint_intn_h.int32_t;
      value_ptr : System.Address;
      value_size : access bits_stdint_intn_h.int32_t) return Extensions.bool  -- /usr/local/include/tkrzw_langc.h:1852
   with Import => True, 
        Convention => C, 
        External_Name => "tkrzw_index_iter_get";

end tkrzw_langc_h;

pragma Style_Checks (On);
pragma Warnings (On, "-gnatwu");
