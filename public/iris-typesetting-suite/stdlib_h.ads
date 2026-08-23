pragma Ada_2012;

pragma Style_Checks (Off);
pragma Warnings (Off, "-gnatwu");

with Interfaces.C; use Interfaces.C;
with Interfaces.C.Strings;
with System;
with Interfaces.C.Extensions;
with stddef_h;
with bits_stdint_intn_h;
with bits_types_h;

package stdlib_h is

   --  arg-macro: procedure WEXITSTATUS (status)
   --    __WEXITSTATUS (status)
   --  arg-macro: procedure WTERMSIG (status)
   --    __WTERMSIG (status)
   --  arg-macro: procedure WSTOPSIG (status)
   --    __WSTOPSIG (status)
   --  arg-macro: procedure WIFEXITED (status)
   --    __WIFEXITED (status)
   --  arg-macro: procedure WIFSIGNALED (status)
   --    __WIFSIGNALED (status)
   --  arg-macro: procedure WIFSTOPPED (status)
   --    __WIFSTOPPED (status)
   --  arg-macro: procedure WIFCONTINUED (status)
   --    __WIFCONTINUED (status)
   RAND_MAX : constant := 2147483647;  --  /usr/local/include/stdlib.h:87

   EXIT_FAILURE : constant := 1;  --  /usr/local/include/stdlib.h:92
   EXIT_SUCCESS : constant := 0;  --  /usr/local/include/stdlib.h:93
   --  unsupported macro: MB_CUR_MAX (__ctype_get_mb_cur_max ())

   type div_t is record
      quot : aliased int;  -- /usr/local/include/stdlib.h:61
      c_rem : aliased int;  -- /usr/local/include/stdlib.h:62
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/stdlib.h:63

   type ldiv_t is record
      quot : aliased long;  -- /usr/local/include/stdlib.h:69
      c_rem : aliased long;  -- /usr/local/include/stdlib.h:70
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/stdlib.h:71

   type lldiv_t is record
      quot : aliased Long_Long_Integer;  -- /usr/local/include/stdlib.h:79
      c_rem : aliased Long_Long_Integer;  -- /usr/local/include/stdlib.h:80
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/stdlib.h:81

   --  skipped func __ctype_get_mb_cur_max

   function atof (uu_nptr : Interfaces.C.Strings.chars_ptr) return double  -- /usr/local/include/stdlib.h:102
   with Import => True, 
        Convention => C, 
        External_Name => "atof";

   function atoi (uu_nptr : Interfaces.C.Strings.chars_ptr) return int  -- /usr/local/include/stdlib.h:105
   with Import => True, 
        Convention => C, 
        External_Name => "atoi";

   function atol (uu_nptr : Interfaces.C.Strings.chars_ptr) return long  -- /usr/local/include/stdlib.h:108
   with Import => True, 
        Convention => C, 
        External_Name => "atol";

   function atoll (uu_nptr : Interfaces.C.Strings.chars_ptr) return Long_Long_Integer  -- /usr/local/include/stdlib.h:113
   with Import => True, 
        Convention => C, 
        External_Name => "atoll";

   function strtod (uu_nptr : Interfaces.C.Strings.chars_ptr; uu_endptr : System.Address) return double  -- /usr/local/include/stdlib.h:118
   with Import => True, 
        Convention => C, 
        External_Name => "strtod";

   function strtof (uu_nptr : Interfaces.C.Strings.chars_ptr; uu_endptr : System.Address) return float  -- /usr/local/include/stdlib.h:124
   with Import => True, 
        Convention => C, 
        External_Name => "strtof";

   function strtold (uu_nptr : Interfaces.C.Strings.chars_ptr; uu_endptr : System.Address) return long_double  -- /usr/local/include/stdlib.h:127
   with Import => True, 
        Convention => C, 
        External_Name => "strtold";

   function strtol
     (uu_nptr : Interfaces.C.Strings.chars_ptr;
      uu_endptr : System.Address;
      uu_base : int) return long  -- /usr/local/include/stdlib.h:215
   with Import => True, 
        Convention => C, 
        External_Name => "__isoc23_strtol";

   function strtoul
     (uu_nptr : Interfaces.C.Strings.chars_ptr;
      uu_endptr : System.Address;
      uu_base : int) return unsigned_long  -- /usr/local/include/stdlib.h:219
   with Import => True, 
        Convention => C, 
        External_Name => "__isoc23_strtoul";

   function strtoq
     (uu_nptr : Interfaces.C.Strings.chars_ptr;
      uu_endptr : System.Address;
      uu_base : int) return Long_Long_Integer  -- /usr/local/include/stdlib.h:226
   with Import => True, 
        Convention => C, 
        External_Name => "__isoc23_strtoll";

   function strtouq
     (uu_nptr : Interfaces.C.Strings.chars_ptr;
      uu_endptr : System.Address;
      uu_base : int) return Extensions.unsigned_long_long  -- /usr/local/include/stdlib.h:231
   with Import => True, 
        Convention => C, 
        External_Name => "__isoc23_strtoull";

   function strtoll
     (uu_nptr : Interfaces.C.Strings.chars_ptr;
      uu_endptr : System.Address;
      uu_base : int) return Long_Long_Integer  -- /usr/local/include/stdlib.h:238
   with Import => True, 
        Convention => C, 
        External_Name => "__isoc23_strtoll";

   function strtoull
     (uu_nptr : Interfaces.C.Strings.chars_ptr;
      uu_endptr : System.Address;
      uu_base : int) return Extensions.unsigned_long_long  -- /usr/local/include/stdlib.h:243
   with Import => True, 
        Convention => C, 
        External_Name => "__isoc23_strtoull";

   function strfromd
     (uu_dest : Interfaces.C.Strings.chars_ptr;
      uu_size : stddef_h.size_t;
      uu_format : Interfaces.C.Strings.chars_ptr;
      uu_f : double) return int  -- /usr/local/include/stdlib.h:278
   with Import => True, 
        Convention => C, 
        External_Name => "strfromd";

   function strfromf
     (uu_dest : Interfaces.C.Strings.chars_ptr;
      uu_size : stddef_h.size_t;
      uu_format : Interfaces.C.Strings.chars_ptr;
      uu_f : float) return int  -- /usr/local/include/stdlib.h:282
   with Import => True, 
        Convention => C, 
        External_Name => "strfromf";

   function strfroml
     (uu_dest : Interfaces.C.Strings.chars_ptr;
      uu_size : stddef_h.size_t;
      uu_format : Interfaces.C.Strings.chars_ptr;
      uu_f : long_double) return int  -- /usr/local/include/stdlib.h:286
   with Import => True, 
        Convention => C, 
        External_Name => "strfroml";

   function l64a (uu_n : long) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/stdlib.h:505
   with Import => True, 
        Convention => C, 
        External_Name => "l64a";

   function a64l (uu_s : Interfaces.C.Strings.chars_ptr) return long  -- /usr/local/include/stdlib.h:508
   with Import => True, 
        Convention => C, 
        External_Name => "a64l";

   function random return long  -- /usr/local/include/stdlib.h:521
   with Import => True, 
        Convention => C, 
        External_Name => "random";

   procedure srandom (uu_seed : unsigned)  -- /usr/local/include/stdlib.h:524
   with Import => True, 
        Convention => C, 
        External_Name => "srandom";

   function initstate
     (uu_seed : unsigned;
      uu_statebuf : Interfaces.C.Strings.chars_ptr;
      uu_statelen : stddef_h.size_t) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/stdlib.h:530
   with Import => True, 
        Convention => C, 
        External_Name => "initstate";

   function setstate (uu_statebuf : Interfaces.C.Strings.chars_ptr) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/stdlib.h:535
   with Import => True, 
        Convention => C, 
        External_Name => "setstate";

   type random_data is record
      fptr : access bits_stdint_intn_h.int32_t;  -- /usr/local/include/stdlib.h:545
      rptr : access bits_stdint_intn_h.int32_t;  -- /usr/local/include/stdlib.h:546
      state : access bits_stdint_intn_h.int32_t;  -- /usr/local/include/stdlib.h:547
      rand_type : aliased int;  -- /usr/local/include/stdlib.h:548
      rand_deg : aliased int;  -- /usr/local/include/stdlib.h:549
      rand_sep : aliased int;  -- /usr/local/include/stdlib.h:550
      end_ptr : access bits_stdint_intn_h.int32_t;  -- /usr/local/include/stdlib.h:551
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/stdlib.h:543

   function random_r (uu_buf : access random_data; uu_result : access bits_stdint_intn_h.int32_t) return int  -- /usr/local/include/stdlib.h:554
   with Import => True, 
        Convention => C, 
        External_Name => "random_r";

   function srandom_r (uu_seed : unsigned; uu_buf : access random_data) return int  -- /usr/local/include/stdlib.h:557
   with Import => True, 
        Convention => C, 
        External_Name => "srandom_r";

   function initstate_r
     (uu_seed : unsigned;
      uu_statebuf : Interfaces.C.Strings.chars_ptr;
      uu_statelen : stddef_h.size_t;
      uu_buf : access random_data) return int  -- /usr/local/include/stdlib.h:560
   with Import => True, 
        Convention => C, 
        External_Name => "initstate_r";

   function setstate_r (uu_statebuf : Interfaces.C.Strings.chars_ptr; uu_buf : access random_data) return int  -- /usr/local/include/stdlib.h:565
   with Import => True, 
        Convention => C, 
        External_Name => "setstate_r";

   function rand return int  -- /usr/local/include/stdlib.h:573
   with Import => True, 
        Convention => C, 
        External_Name => "rand";

   procedure srand (uu_seed : unsigned)  -- /usr/local/include/stdlib.h:575
   with Import => True, 
        Convention => C, 
        External_Name => "srand";

   function rand_r (uu_seed : access unsigned) return int  -- /usr/local/include/stdlib.h:579
   with Import => True, 
        Convention => C, 
        External_Name => "rand_r";

   function drand48 return double  -- /usr/local/include/stdlib.h:587
   with Import => True, 
        Convention => C, 
        External_Name => "drand48";

   function erand48 (uu_xsubi : access unsigned_short) return double  -- /usr/local/include/stdlib.h:588
   with Import => True, 
        Convention => C, 
        External_Name => "erand48";

   function lrand48 return long  -- /usr/local/include/stdlib.h:591
   with Import => True, 
        Convention => C, 
        External_Name => "lrand48";

   function nrand48 (uu_xsubi : access unsigned_short) return long  -- /usr/local/include/stdlib.h:592
   with Import => True, 
        Convention => C, 
        External_Name => "nrand48";

   function mrand48 return long  -- /usr/local/include/stdlib.h:596
   with Import => True, 
        Convention => C, 
        External_Name => "mrand48";

   function jrand48 (uu_xsubi : access unsigned_short) return long  -- /usr/local/include/stdlib.h:597
   with Import => True, 
        Convention => C, 
        External_Name => "jrand48";

   procedure srand48 (uu_seedval : long)  -- /usr/local/include/stdlib.h:601
   with Import => True, 
        Convention => C, 
        External_Name => "srand48";

   function seed48 (uu_seed16v : access unsigned_short) return access unsigned_short  -- /usr/local/include/stdlib.h:602
   with Import => True, 
        Convention => C, 
        External_Name => "seed48";

   procedure lcong48 (uu_param : access unsigned_short)  -- /usr/local/include/stdlib.h:604
   with Import => True, 
        Convention => C, 
        External_Name => "lcong48";

   type anon_array1318 is array (0 .. 2) of aliased unsigned_short;
   type drand48_data is record
      uu_x : aliased anon_array1318;  -- /usr/local/include/stdlib.h:612
      uu_old_x : aliased anon_array1318;  -- /usr/local/include/stdlib.h:613
      uu_c : aliased unsigned_short;  -- /usr/local/include/stdlib.h:614
      uu_init : aliased unsigned_short;  -- /usr/local/include/stdlib.h:615
      uu_a : aliased Extensions.unsigned_long_long;  -- /usr/local/include/stdlib.h:616
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/stdlib.h:610

   function drand48_r (uu_buffer : access drand48_data; uu_result : access double) return int  -- /usr/local/include/stdlib.h:621
   with Import => True, 
        Convention => C, 
        External_Name => "drand48_r";

   function erand48_r
     (uu_xsubi : access unsigned_short;
      uu_buffer : access drand48_data;
      uu_result : access double) return int  -- /usr/local/include/stdlib.h:623
   with Import => True, 
        Convention => C, 
        External_Name => "erand48_r";

   function lrand48_r (uu_buffer : access drand48_data; uu_result : access long) return int  -- /usr/local/include/stdlib.h:628
   with Import => True, 
        Convention => C, 
        External_Name => "lrand48_r";

   function nrand48_r
     (uu_xsubi : access unsigned_short;
      uu_buffer : access drand48_data;
      uu_result : access long) return int  -- /usr/local/include/stdlib.h:631
   with Import => True, 
        Convention => C, 
        External_Name => "nrand48_r";

   function mrand48_r (uu_buffer : access drand48_data; uu_result : access long) return int  -- /usr/local/include/stdlib.h:637
   with Import => True, 
        Convention => C, 
        External_Name => "mrand48_r";

   function jrand48_r
     (uu_xsubi : access unsigned_short;
      uu_buffer : access drand48_data;
      uu_result : access long) return int  -- /usr/local/include/stdlib.h:640
   with Import => True, 
        Convention => C, 
        External_Name => "jrand48_r";

   function srand48_r (uu_seedval : long; uu_buffer : access drand48_data) return int  -- /usr/local/include/stdlib.h:646
   with Import => True, 
        Convention => C, 
        External_Name => "srand48_r";

   function seed48_r (uu_seed16v : access unsigned_short; uu_buffer : access drand48_data) return int  -- /usr/local/include/stdlib.h:649
   with Import => True, 
        Convention => C, 
        External_Name => "seed48_r";

   function lcong48_r (uu_param : access unsigned_short; uu_buffer : access drand48_data) return int  -- /usr/local/include/stdlib.h:652
   with Import => True, 
        Convention => C, 
        External_Name => "lcong48_r";

   function arc4random return bits_types_h.uu_uint32_t  -- /usr/local/include/stdlib.h:657
   with Import => True, 
        Convention => C, 
        External_Name => "arc4random";

   procedure arc4random_buf (uu_buf : System.Address; uu_size : stddef_h.size_t)  -- /usr/local/include/stdlib.h:661
   with Import => True, 
        Convention => C, 
        External_Name => "arc4random_buf";

   function arc4random_uniform (uu_upper_bound : bits_types_h.uu_uint32_t) return bits_types_h.uu_uint32_t  -- /usr/local/include/stdlib.h:666
   with Import => True, 
        Convention => C, 
        External_Name => "arc4random_uniform";

   function malloc (uu_size : stddef_h.size_t) return System.Address  -- /usr/local/include/stdlib.h:672
   with Import => True, 
        Convention => C, 
        External_Name => "malloc";

   function calloc (uu_nmemb : stddef_h.size_t; uu_size : stddef_h.size_t) return System.Address  -- /usr/local/include/stdlib.h:675
   with Import => True, 
        Convention => C, 
        External_Name => "calloc";

   function realloc (uu_ptr : System.Address; uu_size : stddef_h.size_t) return System.Address  -- /usr/local/include/stdlib.h:683
   with Import => True, 
        Convention => C, 
        External_Name => "realloc";

   procedure free (uu_ptr : System.Address)  -- /usr/local/include/stdlib.h:687
   with Import => True, 
        Convention => C, 
        External_Name => "free";

   function reallocarray
     (uu_ptr : System.Address;
      uu_nmemb : stddef_h.size_t;
      uu_size : stddef_h.size_t) return System.Address  -- /usr/local/include/stdlib.h:701
   with Import => True, 
        Convention => C, 
        External_Name => "reallocarray";

   function valloc (uu_size : stddef_h.size_t) return System.Address  -- /usr/local/include/stdlib.h:712
   with Import => True, 
        Convention => C, 
        External_Name => "valloc";

   function posix_memalign
     (uu_memptr : System.Address;
      uu_alignment : stddef_h.size_t;
      uu_size : stddef_h.size_t) return int  -- /usr/local/include/stdlib.h:718
   with Import => True, 
        Convention => C, 
        External_Name => "posix_memalign";

   function aligned_alloc (uu_alignment : stddef_h.size_t; uu_size : stddef_h.size_t) return System.Address  -- /usr/local/include/stdlib.h:724
   with Import => True, 
        Convention => C, 
        External_Name => "aligned_alloc";

   procedure c_abort  -- /usr/local/include/stdlib.h:730
   with Import => True, 
        Convention => C, 
        External_Name => "abort";

   function atexit (uu_func : access procedure) return int  -- /usr/local/include/stdlib.h:734
   with Import => True, 
        Convention => C, 
        External_Name => "atexit";

   function at_quick_exit (uu_func : access procedure) return int  -- /usr/local/include/stdlib.h:742
   with Import => True, 
        Convention => C, 
        External_Name => "at_quick_exit";

   function on_exit (uu_func : access procedure (arg1 : int; arg2 : System.Address); uu_arg : System.Address) return int  -- /usr/local/include/stdlib.h:749
   with Import => True, 
        Convention => C, 
        External_Name => "on_exit";

   procedure c_exit (uu_status : int)  -- /usr/local/include/stdlib.h:756
   with Import => True, 
        Convention => C, 
        External_Name => "exit";

   procedure quick_exit (uu_status : int)  -- /usr/local/include/stdlib.h:762
   with Import => True, 
        Convention => C, 
        External_Name => "quick_exit";

   --  skipped func _Exit

   function getenv (uu_name : Interfaces.C.Strings.chars_ptr) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/stdlib.h:773
   with Import => True, 
        Convention => C, 
        External_Name => "getenv";

   function putenv (uu_string : Interfaces.C.Strings.chars_ptr) return int  -- /usr/local/include/stdlib.h:786
   with Import => True, 
        Convention => C, 
        External_Name => "putenv";

   function setenv
     (uu_name : Interfaces.C.Strings.chars_ptr;
      uu_value : Interfaces.C.Strings.chars_ptr;
      uu_replace : int) return int  -- /usr/local/include/stdlib.h:792
   with Import => True, 
        Convention => C, 
        External_Name => "setenv";

   function unsetenv (uu_name : Interfaces.C.Strings.chars_ptr) return int  -- /usr/local/include/stdlib.h:796
   with Import => True, 
        Convention => C, 
        External_Name => "unsetenv";

   function clearenv return int  -- /usr/local/include/stdlib.h:803
   with Import => True, 
        Convention => C, 
        External_Name => "clearenv";

   function mktemp (uu_template : Interfaces.C.Strings.chars_ptr) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/stdlib.h:814
   with Import => True, 
        Convention => C, 
        External_Name => "mktemp";

   function mkstemp (uu_template : Interfaces.C.Strings.chars_ptr) return int  -- /usr/local/include/stdlib.h:827
   with Import => True, 
        Convention => C, 
        External_Name => "mkstemp";

   function mkstemps (uu_template : Interfaces.C.Strings.chars_ptr; uu_suffixlen : int) return int  -- /usr/local/include/stdlib.h:849
   with Import => True, 
        Convention => C, 
        External_Name => "mkstemps";

   function mkdtemp (uu_template : Interfaces.C.Strings.chars_ptr) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/stdlib.h:870
   with Import => True, 
        Convention => C, 
        External_Name => "mkdtemp";

   function c_system (uu_command : Interfaces.C.Strings.chars_ptr) return int  -- /usr/local/include/stdlib.h:923
   with Import => True, 
        Convention => C, 
        External_Name => "system";

   function realpath (uu_name : Interfaces.C.Strings.chars_ptr; uu_resolved : Interfaces.C.Strings.chars_ptr) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/stdlib.h:940
   with Import => True, 
        Convention => C, 
        External_Name => "realpath";

   type uu_compar_fn_t is access function (arg1 : System.Address; arg2 : System.Address) return int
   with Convention => C;  -- /usr/local/include/stdlib.h:948

   function bsearch
     (uu_key : System.Address;
      uu_base : System.Address;
      uu_nmemb : stddef_h.size_t;
      uu_size : stddef_h.size_t;
      uu_compar : uu_compar_fn_t) return System.Address  -- /usr/local/include/stdlib.h:960
   with Import => True, 
        Convention => C, 
        External_Name => "bsearch";

   procedure qsort
     (uu_base : System.Address;
      uu_nmemb : stddef_h.size_t;
      uu_size : stddef_h.size_t;
      uu_compar : uu_compar_fn_t)  -- /usr/local/include/stdlib.h:970
   with Import => True, 
        Convention => C, 
        External_Name => "qsort";

   function c_abs (uu_x : int) return int  -- /usr/local/include/stdlib.h:980
   with Import => True, 
        Convention => C, 
        External_Name => "abs";

   function labs (uu_x : long) return long  -- /usr/local/include/stdlib.h:981
   with Import => True, 
        Convention => C, 
        External_Name => "labs";

   function llabs (uu_x : Long_Long_Integer) return Long_Long_Integer  -- /usr/local/include/stdlib.h:984
   with Import => True, 
        Convention => C, 
        External_Name => "llabs";

   function div (uu_numer : int; uu_denom : int) return div_t  -- /usr/local/include/stdlib.h:992
   with Import => True, 
        Convention => C, 
        External_Name => "div";

   function ldiv (uu_numer : long; uu_denom : long) return ldiv_t  -- /usr/local/include/stdlib.h:994
   with Import => True, 
        Convention => C, 
        External_Name => "ldiv";

   function lldiv (uu_numer : Long_Long_Integer; uu_denom : Long_Long_Integer) return lldiv_t  -- /usr/local/include/stdlib.h:998
   with Import => True, 
        Convention => C, 
        External_Name => "lldiv";

   function ecvt
     (uu_value : double;
      uu_ndigit : int;
      uu_decpt : access int;
      uu_sign : access int) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/stdlib.h:1012
   with Import => True, 
        Convention => C, 
        External_Name => "ecvt";

   function fcvt
     (uu_value : double;
      uu_ndigit : int;
      uu_decpt : access int;
      uu_sign : access int) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/stdlib.h:1018
   with Import => True, 
        Convention => C, 
        External_Name => "fcvt";

   function gcvt
     (uu_value : double;
      uu_ndigit : int;
      uu_buf : Interfaces.C.Strings.chars_ptr) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/stdlib.h:1024
   with Import => True, 
        Convention => C, 
        External_Name => "gcvt";

   function qecvt
     (uu_value : long_double;
      uu_ndigit : int;
      uu_decpt : access int;
      uu_sign : access int) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/stdlib.h:1030
   with Import => True, 
        Convention => C, 
        External_Name => "qecvt";

   function qfcvt
     (uu_value : long_double;
      uu_ndigit : int;
      uu_decpt : access int;
      uu_sign : access int) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/stdlib.h:1033
   with Import => True, 
        Convention => C, 
        External_Name => "qfcvt";

   function qgcvt
     (uu_value : long_double;
      uu_ndigit : int;
      uu_buf : Interfaces.C.Strings.chars_ptr) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/stdlib.h:1036
   with Import => True, 
        Convention => C, 
        External_Name => "qgcvt";

   function ecvt_r
     (uu_value : double;
      uu_ndigit : int;
      uu_decpt : access int;
      uu_sign : access int;
      uu_buf : Interfaces.C.Strings.chars_ptr;
      uu_len : stddef_h.size_t) return int  -- /usr/local/include/stdlib.h:1042
   with Import => True, 
        Convention => C, 
        External_Name => "ecvt_r";

   function fcvt_r
     (uu_value : double;
      uu_ndigit : int;
      uu_decpt : access int;
      uu_sign : access int;
      uu_buf : Interfaces.C.Strings.chars_ptr;
      uu_len : stddef_h.size_t) return int  -- /usr/local/include/stdlib.h:1045
   with Import => True, 
        Convention => C, 
        External_Name => "fcvt_r";

   function qecvt_r
     (uu_value : long_double;
      uu_ndigit : int;
      uu_decpt : access int;
      uu_sign : access int;
      uu_buf : Interfaces.C.Strings.chars_ptr;
      uu_len : stddef_h.size_t) return int  -- /usr/local/include/stdlib.h:1049
   with Import => True, 
        Convention => C, 
        External_Name => "qecvt_r";

   function qfcvt_r
     (uu_value : long_double;
      uu_ndigit : int;
      uu_decpt : access int;
      uu_sign : access int;
      uu_buf : Interfaces.C.Strings.chars_ptr;
      uu_len : stddef_h.size_t) return int  -- /usr/local/include/stdlib.h:1053
   with Import => True, 
        Convention => C, 
        External_Name => "qfcvt_r";

   function mblen (uu_s : Interfaces.C.Strings.chars_ptr; uu_n : stddef_h.size_t) return int  -- /usr/local/include/stdlib.h:1062
   with Import => True, 
        Convention => C, 
        External_Name => "mblen";

   function mbtowc
     (uu_pwc : access stddef_h.wchar_t;
      uu_s : Interfaces.C.Strings.chars_ptr;
      uu_n : stddef_h.size_t) return int  -- /usr/local/include/stdlib.h:1065
   with Import => True, 
        Convention => C, 
        External_Name => "mbtowc";

   function wctomb (uu_s : Interfaces.C.Strings.chars_ptr; uu_wchar : stddef_h.wchar_t) return int  -- /usr/local/include/stdlib.h:1069
   with Import => True, 
        Convention => C, 
        External_Name => "wctomb";

   function mbstowcs
     (uu_pwcs : access stddef_h.wchar_t;
      uu_s : Interfaces.C.Strings.chars_ptr;
      uu_n : stddef_h.size_t) return stddef_h.size_t  -- /usr/local/include/stdlib.h:1073
   with Import => True, 
        Convention => C, 
        External_Name => "mbstowcs";

   function wcstombs
     (uu_s : Interfaces.C.Strings.chars_ptr;
      uu_pwcs : access stddef_h.wchar_t;
      uu_n : stddef_h.size_t) return stddef_h.size_t  -- /usr/local/include/stdlib.h:1077
   with Import => True, 
        Convention => C, 
        External_Name => "wcstombs";

   function rpmatch (uu_response : Interfaces.C.Strings.chars_ptr) return int  -- /usr/local/include/stdlib.h:1088
   with Import => True, 
        Convention => C, 
        External_Name => "rpmatch";

   function getsubopt
     (uu_optionp : System.Address;
      uu_tokens : System.Address;
      uu_valuep : System.Address) return int  -- /usr/local/include/stdlib.h:1099
   with Import => True, 
        Convention => C, 
        External_Name => "getsubopt";

   function getloadavg (uu_loadavg : access double; uu_nelem : int) return int  -- /usr/local/include/stdlib.h:1145
   with Import => True, 
        Convention => C, 
        External_Name => "getloadavg";

end stdlib_h;

pragma Style_Checks (On);
pragma Warnings (On, "-gnatwu");
