-- SPDX-License-Identifier: MIT

with gauche_binding; use gauche_binding;
with interfaces.c; use interfaces.c;
with interfaces.c.strings; use interfaces.c.strings;
with ada.text_io; use ada.text_io;
with ada.command_line; use ada.command_line;

procedure test_gauche_binding is
   packet : aliased ScmEvalPacket;
   status : int;
begin
   gauche_runtime_init;

   status := Scm_EvalCString (
      str    => new_string ("(if (equal? ""apple"" ""apple"") 'match 'mismatch)"),
      env    => Scm_UserModule,
      packet => packet'access
   );

   set_exit_status (if status < 0 then failure else success);
end test_gauche_binding;
