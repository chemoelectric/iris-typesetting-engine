-- SPDX-License-Identifier: MIT
--
-- Thin binding to Gauche Scheme.
--

with interfaces.c; use interfaces.c;
with interfaces.c.strings; use interfaces.c.strings;
with system; use system;

package gauche_binding is

   -- Gauche core uses a uniform object model pointer.
   type scm_obj is new system.address;

   null_scm_obj : constant scm_obj :=
     scm_obj (system.null_address);

   -- Gauche can return multiple values.
   type scm_obj_array is array (0 .. 63) of scm_obj;

   -- Representation of ScmEvalPacket structure.
   type scm_eval_packet is
     record
       num_results      : int;
       results          : scm_obj_array;
       scheme_exception : scm_obj;
     end record
     with convention => c;

   -- Constants mirroring C macro constants
   scm_char_max     : constant long := 16#10ffff#;
   scm_char_invalid : constant long := -2;

   -- Comparison modes
   scm_cmp_eq    : constant int := 0;
   scm_cmp_eqv   : constant int := 1;
   scm_cmp_equal : constant int := 2;

   -- Procedure types
   scm_proc_subr        : constant int := 0;
   scm_proc_closure     : constant int := 1;
   scm_proc_generic     : constant int := 2;
   scm_proc_method      : constant int := 3;
   scm_proc_next_method : constant int := 4;

   -- Port error reasons
   scm_port_error_input            : constant int := 0;
   scm_port_error_output           : constant int := 1;
   scm_port_error_closed           : constant int := 2;
   scm_port_error_unit             : constant int := 3;
   scm_port_error_decoding         : constant int := 4;
   scm_port_error_encoding         : constant int := 5;
   scm_port_error_seek             : constant int := 6;
   scm_port_error_invalid_position : constant int := 7;
   scm_port_error_other            : constant int := 8;

   -- Raise flags
   scm_raise_non_continuable : constant unsigned_long := 1;

   -- Regexp flags
   scm_regexp_case_fold  : constant int := 1;
   scm_regexp_parse_only : constant int := 2;
   scm_regexp_multi_line : constant int := 16;

   -- Command line kinds
   scm_command_line_script : constant int := 1;
   scm_command_line_os     : constant int := 2;
   scm_command_line_both   : constant int := 3;

   -- Runtime states
   scm_runtime_initializing : constant int := 0;
   scm_runtime_initialized  : constant int := 1;
   scm_runtime_mini_repl    : constant int := 2;
   scm_runtime_full_repl    : constant int := 3;

   -- C constant accessors for macros
   function gauche_api_version return int
   with import,
        convention    => c,
        external_name => "gauche_c_api_version";

   function gauche_char_encoding_utf8 return int
   with import,
        convention    => c,
        external_name => "gauche_c_char_encoding_utf8";

   -- Immediate object C accessors
   function scm_false return scm_obj
   with import,
        convention    => c,
        external_name => "gauche_c_false";

   function scm_true return scm_obj
   with import,
        convention    => c,
        external_name => "gauche_c_true";

   function scm_nil return scm_obj
   with import,
        convention    => c,
        external_name => "gauche_c_nil";

   function scm_eof return scm_obj
   with import,
        convention    => c,
        external_name => "gauche_c_eof";

   function scm_undefined return scm_obj
   with import,
        convention    => c,
        external_name => "gauche_c_undefined";

   function scm_unbound return scm_obj
   with import,
        convention    => c,
        external_name => "gauche_c_unbound";

   function scm_uninitialized return scm_obj
   with import,
        convention    => c,
        external_name => "gauche_c_uninitialized";

   -- C Macro Predicate functions
   function scm_falsep (obj : in scm_obj) return int
   with import,
        convention    => c,
        external_name => "gauche_c_falsep";

   function scm_truep (obj : in scm_obj) return int
   with import,
        convention    => c,
        external_name => "gauche_c_truep";

   function scm_nullp (obj : in scm_obj) return int
   with import,
        convention    => c,
        external_name => "gauche_c_nullp";

   function scm_eofp (obj : in scm_obj) return int
   with import,
        convention    => c,
        external_name => "gauche_c_eofp";

   function scm_undefinedp (obj : in scm_obj) return int
   with import,
        convention    => c,
        external_name => "gauche_c_undefinedp";

   function scm_unboundp (obj : in scm_obj) return int
   with import,
        convention    => c,
        external_name => "gauche_c_unboundp";

   function scm_uninitializedp (obj : in scm_obj) return int
   with import,
        convention    => c,
        external_name => "gauche_c_uninitializedp";

   function scm_boolp (obj : in scm_obj) return int
   with import,
        convention    => c,
        external_name => "gauche_c_boolp";

   function scm_intp (obj : in scm_obj) return int
   with import,
        convention    => c,
        external_name => "gauche_c_intp";

   function scm_flonump (obj : in scm_obj) return int
   with import,
        convention    => c,
        external_name => "gauche_c_flonump";

   function scm_charp (obj : in scm_obj) return int
   with import,
        convention    => c,
        external_name => "gauche_c_charp";

   function scm_pairp (obj : in scm_obj) return int
   with import,
        convention    => c,
        external_name => "gauche_c_pairp";

   function scm_listp (obj : in scm_obj) return int
   with import,
        convention    => c,
        external_name => "gauche_c_listp";

   function scm_procedurep (obj : in scm_obj) return int
   with import,
        convention    => c,
        external_name => "gauche_c_procedurep";

   -- Value extractors and constructors
   function scm_int_value (obj : in scm_obj) return long
   with import,
        convention    => c,
        external_name => "gauche_c_int_value";

   function scm_make_int (val : in long) return scm_obj
   with import,
        convention    => c,
        external_name => "gauche_c_make_int";

   function scm_flonum_value (obj : in scm_obj) return double
   with import,
        convention    => c,
        external_name => "gauche_c_flonum_value";

   function scm_char_value (obj : in scm_obj) return long
   with import,
        convention    => c,
        external_name => "gauche_c_char_value";

   function scm_make_char (ch : in long) return scm_obj
   with import,
        convention    => c,
        external_name => "gauche_c_make_char";

   function scm_car (obj : in scm_obj) return scm_obj
   with import,
        convention    => c,
        external_name => "gauche_c_car";

   function scm_cdr (obj : in scm_obj) return scm_obj
   with import,
        convention    => c,
        external_name => "gauche_c_cdr";

   function scm_caar (obj : in scm_obj) return scm_obj
   with import,
        convention    => c,
        external_name => "gauche_c_caar";

   function scm_cadr (obj : in scm_obj) return scm_obj
   with import,
        convention    => c,
        external_name => "gauche_c_cadr";

   function scm_cdar (obj : in scm_obj) return scm_obj
   with import,
        convention    => c,
        external_name => "gauche_c_cdar";

   function scm_cddr (obj : in scm_obj) return scm_obj
   with import,
        convention    => c,
        external_name => "gauche_c_cddr";

   -- Gauche core API functions imported directly from libgauche

   procedure gauche_runtime_init
   with import,
        convention    => c,
        external_name => "gauche_runtime_init";

   procedure scm_cleanup
   with import,
        convention    => c,
        external_name => "Scm_Cleanup";

   procedure scm_exit (code : in int)
   with import,
        convention    => c,
        external_name => "Scm_Exit";

   function scm_user_module return scm_obj
   with import,
        convention    => c,
        external_name => "Scm_UserModule";

   function scm_eval_c_string
     (str    : in chars_ptr;
      env    : in scm_obj;
      packet : not null access scm_eval_packet) return int
   with import,
        convention    => c,
        external_name => "Scm_EvalCString";

   function scm_eval
     (form   : in scm_obj;
      env    : in scm_obj;
      packet : not null access scm_eval_packet) return int
   with import,
        convention    => c,
        external_name => "Scm_Eval";

   function scm_apply
     (proc   : in scm_obj;
      args   : in scm_obj;
      packet : not null access scm_eval_packet) return int
   with import,
        convention    => c,
        external_name => "Scm_Apply";

   function scm_eval_rec
     (form : in scm_obj;
      env  : in scm_obj) return scm_obj
   with import,
        convention    => c,
        external_name => "Scm_EvalRec";

   function scm_apply_rec
     (proc : in scm_obj;
      args : in scm_obj) return scm_obj
   with import,
        convention    => c,
        external_name => "Scm_ApplyRec";

   function scm_apply_rec0 (proc : in scm_obj) return scm_obj
   with import,
        convention    => c,
        external_name => "Scm_ApplyRec0";

   function scm_apply_rec1
     (proc : in scm_obj;
      arg0 : in scm_obj) return scm_obj
   with import,
        convention    => c,
        external_name => "Scm_ApplyRec1";

   function scm_apply_rec2
     (proc : in scm_obj;
      arg0 : in scm_obj;
      arg1 : in scm_obj) return scm_obj
   with import,
        convention    => c,
        external_name => "Scm_ApplyRec2";

   function scm_cons
     (car_val : in scm_obj;
      cdr_val : in scm_obj) return scm_obj
   with import,
        convention    => c,
        external_name => "Scm_Cons";

   function scm_length (obj : in scm_obj) return size_t
   with import,
        convention    => c,
        external_name => "Scm_Length";

   function scm_eq_p
     (x : in scm_obj;
      y : in scm_obj) return int
   with import,
        convention    => c,
        external_name => "Scm_EqP";

   function scm_eqv_p
     (x : in scm_obj;
      y : in scm_obj) return int
   with import,
        convention    => c,
        external_name => "Scm_EqvP";

   function scm_equal_p
     (x : in scm_obj;
      y : in scm_obj) return int
   with import,
        convention    => c,
        external_name => "Scm_EqualP";

   function scm_make_list
     (len  : in long;
      fill : in scm_obj) return scm_obj
   with import,
        convention    => c,
        external_name => "Scm_MakeList";

   function scm_read_from_c_string
     (str : in chars_ptr) return scm_obj
   with import,
        convention    => c,
        external_name => "Scm_ReadFromCString";

   function scm_make_string
     (str  : in chars_ptr;
      len  : in long;
      copy : in int) return scm_obj
   with import,
        convention    => c,
        external_name => "Scm_MakeString";

   function scm_get_string (str : in scm_obj) return chars_ptr
   with import,
        convention    => c,
        external_name => "Scm_GetString";

   function scm_get_string_const (str : in scm_obj) return chars_ptr
   with import,
        convention    => c,
        external_name => "Scm_GetStringConst";

   function scm_global_variable_ref
     (mod_obj : in scm_obj;
      var_sym : in scm_obj;
      flags   : in int) return scm_obj
   with import,
        convention    => c,
        external_name => "Scm_GlobalVariableRef";

   function scm_find_module
     (name  : in scm_obj;
      flags : in int) return scm_obj
   with import,
        convention    => c,
        external_name => "Scm_FindModule";

   function scm_intern (str : in chars_ptr) return scm_obj
   with import,
        convention    => c,
        external_name => "Scm_Intern";

end gauche_binding;
