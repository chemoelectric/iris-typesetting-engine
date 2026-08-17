-- test_database.adb
--
-- SPDX-License-Identifier: MIT
--
-- Test program for the Iris database package.

with ada.command_line; use ada.command_line;
with ada.directories;  use ada.directories;
with database;         use database;

procedure test_database is

   test_file : constant string := "test_database.tkh";
   key_name  : constant string := "greeting";
   val_first : constant string := "Hello, Iris!";
   val_next  : constant string := "Welcome, Iris!";
   ok        : boolean := true;

   procedure cleanup_file is
   begin
      if exists (test_file) then
         delete_file (test_file);
      end if;
   end cleanup_file;

   procedure check_init (status : in out boolean) is
      db : constant database_type := null_database;
   begin
      if status and then not db_is_closed (db) then
         status := false;
      end if;
   end check_init;

   procedure check_write_read
     (db     : in out database_type;
      status : in out boolean) is
   begin
      if status then
         db_set (db, key_name, val_first, overwrite => true);
         if not db_exists (db, key_name) then
            status := false;
         elsif db_get (db, key_name) /= val_first then
            status := false;
         elsif db_count (db) /= 1 then
            status := false;
         end if;
      end if;
   end check_write_read;

   procedure check_update_remove
     (db     : in out database_type;
      status : in out boolean) is
   begin
      if status then
         db_set (db, key_name, val_next, overwrite => true);
         if db_get (db, key_name) /= val_next then
            status := false;
         end if;

         if status then
            db_remove (db, key_name);
            if db_exists (db, key_name) or else db_count (db) /= 0 then
               status := false;
            end if;
         end if;
      end if;
   end check_update_remove;

   procedure check_crud (status : in out boolean) is
      db : database_type := null_database;
   begin
      if status then
         db := db_open (test_file, create_new);
         if not db_is_open (db) then
            status := false;
         else
            check_write_read (db, status);
            check_update_remove (db, status);
            db_close (db);
            if not db_is_closed (db) then
               status := false;
            end if;
         end if;
      end if;
   end check_crud;

   procedure check_metrics (status : in out boolean) is
      dist : integer := 0;
   begin
      if status then
         dist := db_edit_distance ("Playfair", "PlayfairDisplay");
         if dist /= 7 then
            status := false;
         end if;
      end if;
   end check_metrics;

begin
   cleanup_file;
   check_init (ok);
   check_crud (ok);
   check_metrics (ok);
   cleanup_file;

   if ok then
      set_exit_status (success);
   else
      set_exit_status (failure);
   end if;
end test_database;
