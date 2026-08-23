pragma Ada_2012;

pragma Style_Checks (Off);
pragma Warnings (Off, "-gnatwu");

with Interfaces.C; use Interfaces.C;
with bits_types_h;
with bits_types_struct_timespec_h;

package bits_struct_stat_h is

   --  unsupported macro: st_atime st_atim.tv_sec
   --  unsupported macro: st_mtime st_mtim.tv_sec
   --  unsupported macro: st_ctime st_ctim.tv_sec
   type anon_array1094 is array (0 .. 2) of aliased bits_types_h.uu_syscall_slong_t;
   type stat is record
      st_dev : aliased bits_types_h.uu_dev_t;  -- /usr/local/include/bits/struct_stat.h:31
      st_ino : aliased bits_types_h.uu_ino_t;  -- /usr/local/include/bits/struct_stat.h:36
      st_nlink : aliased bits_types_h.uu_nlink_t;  -- /usr/local/include/bits/struct_stat.h:44
      st_mode : aliased bits_types_h.uu_mode_t;  -- /usr/local/include/bits/struct_stat.h:45
      st_uid : aliased bits_types_h.uu_uid_t;  -- /usr/local/include/bits/struct_stat.h:47
      st_gid : aliased bits_types_h.uu_gid_t;  -- /usr/local/include/bits/struct_stat.h:48
      uu_pad0 : aliased int;  -- /usr/local/include/bits/struct_stat.h:50
      st_rdev : aliased bits_types_h.uu_dev_t;  -- /usr/local/include/bits/struct_stat.h:52
      st_size : aliased bits_types_h.uu_off_t;  -- /usr/local/include/bits/struct_stat.h:57
      st_blksize : aliased bits_types_h.uu_blksize_t;  -- /usr/local/include/bits/struct_stat.h:61
      st_blocks : aliased bits_types_h.uu_blkcnt_t;  -- /usr/local/include/bits/struct_stat.h:63
      st_atim : aliased bits_types_struct_timespec_h.timespec;  -- /usr/local/include/bits/struct_stat.h:74
      st_mtim : aliased bits_types_struct_timespec_h.timespec;  -- /usr/local/include/bits/struct_stat.h:75
      st_ctim : aliased bits_types_struct_timespec_h.timespec;  -- /usr/local/include/bits/struct_stat.h:76
      uu_glibc_reserved : aliased anon_array1094;  -- /usr/local/include/bits/struct_stat.h:89
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/bits/struct_stat.h:26

end bits_struct_stat_h;

pragma Style_Checks (On);
pragma Warnings (On, "-gnatwu");
