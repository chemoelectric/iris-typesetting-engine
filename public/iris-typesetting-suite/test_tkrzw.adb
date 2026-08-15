-- =====================================================================
-- procedure test_tkrzw
-- standard: ada 2022
-- SPDX-License-Identifier: MIT
-- =====================================================================

with tkrzw; use tkrzw;
with ada.command_line; use ada.command_line;

procedure test_tkrzw is
   ok       : boolean := true;
   db       : tkrzw_dbm := null_dbm;
   val      : string (1 .. 64) := [others => ' '];
   val_len  : natural := 0;
   key_name : constant string := "font:cmr10";
   key_val  : constant string := "Computer Modern Roman 10pt";
begin
   db := open_dbm ("test_iris.tkh", writable => true);
   if not is_open (db) then
      ok := false;
   end if;

   if ok then
      put_value (db, key_name, key_val, overwrite => true);
      if not exists_key (db, key_name) then
         ok := false;
      end if;
   end if;

   if ok then
      declare
         retrieved : constant string := get_value (db, key_name);
      begin
         if retrieved /= key_val then
            ok := false;
         else
            val_len := natural'min (retrieved'length, val'length);
            val (1 .. val_len) := retrieved (1 .. val_len);
         end if;
      end;
   end if;

   if is_open (db) then
      delete_key (db, key_name);
      if exists_key (db, key_name) then
         ok := false;
      end if;
      close_dbm (db);
   end if;

   if ok then
      set_exit_status (success);
   else
      set_exit_status (failure);
   end if;
end test_tkrzw;
