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
   key_name : constant string := "font:cmr10";
   key_val  : constant string := "Computer Modern Roman 10pt";
begin
   -- Test dbm_open with create_new mode
   db := dbm_open ("test_iris.tkh", mode => create_new);
   if not dbm_open_p (db) or dbm_closed_p (db) then
      ok := false;
   end if;

   -- Test dbm_put and dbm_exists_p
   if ok then
      dbm_put (db, key_name, key_val, overwrite => true);
      if not dbm_exists_p (db, key_name) then
         ok := false;
      end if;
   end if;

   -- Test dbm_get and dbm_count
   if ok then
      declare
         retrieved : constant string := dbm_get (db, key_name);
         count     : constant long_long_integer := dbm_count (db);
      begin
         if retrieved /= key_val or count < 1 then
            ok := false;
         end if;
      end;
   end if;

   -- Test dbm_delete and dbm_close
   if dbm_open_p (db) then
      dbm_delete (db, key_name);
      if dbm_exists_p (db, key_name) then
         ok := false;
      end if;
      dbm_close (db);
      if not dbm_closed_p (db) then
         ok := false;
      end if;
   end if;

   -- Test edit distance & default path functions
   if ok then
      declare
         dist : constant integer :=
           tkrzw_edit_distance ("levenshtein", "levenshtein");
         fpath : constant string := default_fonts_db_path;
      begin
         if dist /= 0 or fpath'length = 0 then
            ok := false;
         end if;
      end;
   end if;

   if ok then
      set_exit_status (success);
   else
      set_exit_status (failure);
   end if;
end test_tkrzw;
