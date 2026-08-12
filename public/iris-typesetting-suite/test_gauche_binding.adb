-- SPDX-License-Identifier: MIT

with gauche_binding; use gauche_binding;
with interfaces.c; use interfaces.c;
with interfaces.c.strings; use interfaces.c.strings;
with ada.command_line; use ada.command_line;

procedure test_gauche_binding is
   packet : aliased scm_eval_packet;
   status : int;
   v_int  : scm_obj;
   v_pair : scm_obj;
   ok     : boolean := true;
begin
   gauche_runtime_init;

   -- Test version and constant accessors
   if gauche_api_version <= 0 or else
      gauche_char_encoding_utf8 /= 1
   then
      ok := false;
   end if;

   -- Test immediate predicates
   if ok and then
      (scm_falsep (scm_false) /= 1 or else
       scm_truep (scm_true) /= 1 or else
       scm_nullp (scm_nil) /= 1)
   then
      ok := false;
   end if;

   -- Test int constructor and extractor
   if ok then
      v_int := scm_make_int (42);
      if scm_intp (v_int) /= 1 or else
         scm_int_value (v_int) /= 42
      then
         ok := false;
      end if;
   end if;

   -- Test pair constructor and car/cdr accessors
   if ok then
      v_pair := scm_cons (scm_make_int (100), scm_make_int (200));
      if scm_pairp (v_pair) /= 1 or else
         scm_int_value (scm_car (v_pair)) /= 100 or else
         scm_int_value (scm_cdr (v_pair)) /= 200
      then
         ok := false;
      end if;
   end if;

   -- Test Scheme evaluation
   if ok then
      status := scm_eval_c_string (
         str    => new_string ("(+ 1 2)"),
         env    => scm_user_module,
         packet => packet'access
      );

      if status < 0 then
         ok := false;
      end if;
   end if;

   if ok then
      set_exit_status (success);
   else
      set_exit_status (failure);
   end if;
end test_gauche_binding;
