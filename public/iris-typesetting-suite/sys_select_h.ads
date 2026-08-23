pragma Ada_2012;

pragma Style_Checks (Off);
pragma Warnings (Off, "-gnatwu");

with Interfaces.C; use Interfaces.C;
with bits_types_h;
limited with bits_types_struct_timeval_h;
limited with bits_types_struct_timespec_h;
limited with bits_types_u_sigset_t_h;

package sys_select_h is

   --  unsupported macro: FD_SETSIZE __FD_SETSIZE
   --  unsupported macro: NFDBITS __NFDBITS
   --  arg-macro: procedure FD_SET (fd, fdsetp)
   --    __FD_SET (fd, fdsetp)
   --  arg-macro: procedure FD_CLR (fd, fdsetp)
   --    __FD_CLR (fd, fdsetp)
   --  arg-macro: procedure FD_ISSET (fd, fdsetp)
   --    __FD_ISSET (fd, fdsetp)
   --  arg-macro: procedure FD_ZERO (fdsetp)
   --    __FD_ZERO (fdsetp)
   subtype suseconds_t is bits_types_h.uu_suseconds_t;  -- /usr/local/include/sys/select.h:43

   subtype uu_fd_mask is long;  -- /usr/local/include/sys/select.h:49

   type anon_array1208 is array (0 .. 15) of aliased uu_fd_mask;
   type fd_set is record
      uu_fds_bits : aliased anon_array1208;  -- /usr/local/include/sys/select.h:67
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/sys/select.h:70

   subtype fd_mask is uu_fd_mask;  -- /usr/local/include/sys/select.h:77

   function c_select
     (uu_nfds : int;
      uu_readfds : access fd_set;
      uu_writefds : access fd_set;
      uu_exceptfds : access fd_set;
      uu_timeout : access bits_types_struct_timeval_h.timeval) return int  -- /usr/local/include/sys/select.h:102
   with Import => True, 
        Convention => C, 
        External_Name => "select";

   function pselect
     (uu_nfds : int;
      uu_readfds : access fd_set;
      uu_writefds : access fd_set;
      uu_exceptfds : access fd_set;
      uu_timeout : access constant bits_types_struct_timespec_h.timespec;
      uu_sigmask : access constant bits_types_u_sigset_t_h.uu_sigset_t) return int  -- /usr/local/include/sys/select.h:127
   with Import => True, 
        Convention => C, 
        External_Name => "pselect";

end sys_select_h;

pragma Style_Checks (On);
pragma Warnings (On, "-gnatwu");
