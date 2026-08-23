pragma Ada_2012;

pragma Style_Checks (Off);
pragma Warnings (Off, "-gnatwu");

with Interfaces.C; use Interfaces.C;
with bits_types_h;
with Interfaces.C.Strings;
limited with bits_struct_stat_h;
limited with bits_types_struct_timespec_h;

package sys_stat_h is

   --  unsupported macro: S_IFMT __S_IFMT
   --  unsupported macro: S_IFDIR __S_IFDIR
   --  unsupported macro: S_IFCHR __S_IFCHR
   --  unsupported macro: S_IFBLK __S_IFBLK
   --  unsupported macro: S_IFREG __S_IFREG
   --  unsupported macro: S_IFIFO __S_IFIFO
   --  unsupported macro: S_IFLNK __S_IFLNK
   --  unsupported macro: S_IFSOCK __S_IFSOCK
   --  arg-macro: procedure S_ISDIR (mode)
   --    __S_ISTYPE((mode), __S_IFDIR)
   --  arg-macro: procedure S_ISCHR (mode)
   --    __S_ISTYPE((mode), __S_IFCHR)
   --  arg-macro: procedure S_ISBLK (mode)
   --    __S_ISTYPE((mode), __S_IFBLK)
   --  arg-macro: procedure S_ISREG (mode)
   --    __S_ISTYPE((mode), __S_IFREG)
   --  arg-macro: procedure S_ISFIFO (mode)
   --    __S_ISTYPE((mode), __S_IFIFO)
   --  arg-macro: procedure S_ISLNK (mode)
   --    __S_ISTYPE((mode), __S_IFLNK)
   --  arg-macro: procedure S_ISSOCK (mode)
   --    __S_ISTYPE((mode), __S_IFSOCK)
   --  arg-macro: procedure S_TYPEISMQ (buf)
   --    __S_TYPEISMQ(buf)
   --  arg-macro: procedure S_TYPEISSEM (buf)
   --    __S_TYPEISSEM(buf)
   --  arg-macro: procedure S_TYPEISSHM (buf)
   --    __S_TYPEISSHM(buf)
   --  unsupported macro: S_ISUID __S_ISUID
   --  unsupported macro: S_ISGID __S_ISGID
   --  unsupported macro: S_ISVTX __S_ISVTX
   --  unsupported macro: S_IRUSR __S_IREAD
   --  unsupported macro: S_IWUSR __S_IWRITE
   --  unsupported macro: S_IXUSR __S_IEXEC
   --  unsupported macro: S_IRWXU (__S_IREAD|__S_IWRITE|__S_IEXEC)
   --  unsupported macro: S_IREAD S_IRUSR
   --  unsupported macro: S_IWRITE S_IWUSR
   --  unsupported macro: S_IEXEC S_IXUSR
   --  unsupported macro: S_IRGRP (S_IRUSR >> 3)
   --  unsupported macro: S_IWGRP (S_IWUSR >> 3)
   --  unsupported macro: S_IXGRP (S_IXUSR >> 3)
   --  unsupported macro: S_IRWXG (S_IRWXU >> 3)
   --  unsupported macro: S_IROTH (S_IRGRP >> 3)
   --  unsupported macro: S_IWOTH (S_IWGRP >> 3)
   --  unsupported macro: S_IXOTH (S_IXGRP >> 3)
   --  unsupported macro: S_IRWXO (S_IRWXG >> 3)
   --  unsupported macro: ACCESSPERMS (S_IRWXU|S_IRWXG|S_IRWXO)
   --  unsupported macro: ALLPERMS (S_ISUID|S_ISGID|S_ISVTX|S_IRWXU|S_IRWXG|S_IRWXO)
   --  unsupported macro: DEFFILEMODE (S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP|S_IROTH|S_IWOTH)
   S_BLKSIZE : constant := 512;  --  /usr/local/include/sys/stat.h:199

   subtype dev_t is bits_types_h.uu_dev_t;  -- /usr/local/include/sys/stat.h:40

   subtype gid_t is bits_types_h.uu_gid_t;  -- /usr/local/include/sys/stat.h:45

   subtype ino_t is bits_types_h.uu_ino_t;  -- /usr/local/include/sys/stat.h:51

   subtype mode_t is bits_types_h.uu_mode_t;  -- /usr/local/include/sys/stat.h:59

   subtype nlink_t is bits_types_h.uu_nlink_t;  -- /usr/local/include/sys/stat.h:64

   subtype off_t is bits_types_h.uu_off_t;  -- /usr/local/include/sys/stat.h:70

   subtype uid_t is bits_types_h.uu_uid_t;  -- /usr/local/include/sys/stat.h:78

   function stat2 (uu_file : Interfaces.C.Strings.chars_ptr; uu_buf : access bits_struct_stat_h.stat) return int  -- /usr/local/include/sys/stat.h:205
   with Import => True, 
        Convention => C, 
        External_Name => "stat";

   function fstat (uu_fd : int; uu_buf : access bits_struct_stat_h.stat) return int  -- /usr/local/include/sys/stat.h:210
   with Import => True, 
        Convention => C, 
        External_Name => "fstat";

   function fstatat
     (uu_fd : int;
      uu_file : Interfaces.C.Strings.chars_ptr;
      uu_buf : access bits_struct_stat_h.stat;
      uu_flag : int) return int  -- /usr/local/include/sys/stat.h:264
   with Import => True, 
        Convention => C, 
        External_Name => "fstatat";

   function lstat (uu_file : Interfaces.C.Strings.chars_ptr; uu_buf : access bits_struct_stat_h.stat) return int  -- /usr/local/include/sys/stat.h:313
   with Import => True, 
        Convention => C, 
        External_Name => "lstat";

   function chmod (uu_file : Interfaces.C.Strings.chars_ptr; uu_mode : bits_types_h.uu_mode_t) return int  -- /usr/local/include/sys/stat.h:352
   with Import => True, 
        Convention => C, 
        External_Name => "chmod";

   function lchmod (uu_file : Interfaces.C.Strings.chars_ptr; uu_mode : bits_types_h.uu_mode_t) return int  -- /usr/local/include/sys/stat.h:359
   with Import => True, 
        Convention => C, 
        External_Name => "lchmod";

   function fchmod (uu_fd : int; uu_mode : bits_types_h.uu_mode_t) return int  -- /usr/local/include/sys/stat.h:365
   with Import => True, 
        Convention => C, 
        External_Name => "fchmod";

   function fchmodat
     (uu_fd : int;
      uu_file : Interfaces.C.Strings.chars_ptr;
      uu_mode : bits_types_h.uu_mode_t;
      uu_flag : int) return int  -- /usr/local/include/sys/stat.h:371
   with Import => True, 
        Convention => C, 
        External_Name => "fchmodat";

   function umask (uu_mask : bits_types_h.uu_mode_t) return bits_types_h.uu_mode_t  -- /usr/local/include/sys/stat.h:380
   with Import => True, 
        Convention => C, 
        External_Name => "umask";

   function mkdir (uu_path : Interfaces.C.Strings.chars_ptr; uu_mode : bits_types_h.uu_mode_t) return int  -- /usr/local/include/sys/stat.h:389
   with Import => True, 
        Convention => C, 
        External_Name => "mkdir";

   function mkdirat
     (uu_fd : int;
      uu_path : Interfaces.C.Strings.chars_ptr;
      uu_mode : bits_types_h.uu_mode_t) return int  -- /usr/local/include/sys/stat.h:396
   with Import => True, 
        Convention => C, 
        External_Name => "mkdirat";

   function mknod
     (uu_path : Interfaces.C.Strings.chars_ptr;
      uu_mode : bits_types_h.uu_mode_t;
      uu_dev : bits_types_h.uu_dev_t) return int  -- /usr/local/include/sys/stat.h:404
   with Import => True, 
        Convention => C, 
        External_Name => "mknod";

   function mknodat
     (uu_fd : int;
      uu_path : Interfaces.C.Strings.chars_ptr;
      uu_mode : bits_types_h.uu_mode_t;
      uu_dev : bits_types_h.uu_dev_t) return int  -- /usr/local/include/sys/stat.h:411
   with Import => True, 
        Convention => C, 
        External_Name => "mknodat";

   function mkfifo (uu_path : Interfaces.C.Strings.chars_ptr; uu_mode : bits_types_h.uu_mode_t) return int  -- /usr/local/include/sys/stat.h:418
   with Import => True, 
        Convention => C, 
        External_Name => "mkfifo";

   function mkfifoat
     (uu_fd : int;
      uu_path : Interfaces.C.Strings.chars_ptr;
      uu_mode : bits_types_h.uu_mode_t) return int  -- /usr/local/include/sys/stat.h:425
   with Import => True, 
        Convention => C, 
        External_Name => "mkfifoat";

   function utimensat
     (uu_fd : int;
      uu_path : Interfaces.C.Strings.chars_ptr;
      uu_times : access constant bits_types_struct_timespec_h.timespec;
      uu_flags : int) return int  -- /usr/local/include/sys/stat.h:433
   with Import => True, 
        Convention => C, 
        External_Name => "utimensat";

   function futimens (uu_fd : int; uu_times : access constant bits_types_struct_timespec_h.timespec) return int  -- /usr/local/include/sys/stat.h:452
   with Import => True, 
        Convention => C, 
        External_Name => "futimens";

end sys_stat_h;

pragma Style_Checks (On);
pragma Warnings (On, "-gnatwu");
