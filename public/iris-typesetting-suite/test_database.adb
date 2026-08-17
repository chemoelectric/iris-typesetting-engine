-- test_database.adb
--
-- SPDX-License-Identifier: MIT
--
-- Test program for the Iris database package.

with Ada.Text_IO; use Ada.Text_IO;
with database;    use database;

procedure test_database is

   db       : database_type := null_database;
   val      : string (1 .. 64);
   val_last : natural := 0;

   procedure verify_test
     (condition : in boolean;
      name      : in string) is
   begin
      if condition then
         put_line ("PASS: " & name);
      else
         put_line ("FAIL: " & name);
      end if;
   end verify_test;

begin
   put_line ("Running Database Interface Tests...");

   -- Test 1: Null database check
   verify_test (db_is_closed (db), "Null database is initially closed");

   -- Test 2: In-memory/temporary database creation
   db := db_open ("*test_db*", create_new);
   verify_test (db_is_open (db), "Database opened successfully");

   -- Test 3: Set and Get operations
   db_set (db, "greeting", "Hello, Iris!");
   verify_test (db_exists (db, "greeting"), "Key existence verified");

   declare
      read_val : constant string := db_get (db, "greeting");
   begin
      verify_test
        (read_val = "Hello, Iris!", "Value retrieval matches");
   end;

   -- Test 4: Key count
   verify_test (db_count (db) = 1, "Record count is 1");

   -- Test 5: Overwrite
   db_set (db, "greeting", "Welcome, Iris!");
   declare
      read_val : constant string := db_get (db, "greeting");
   begin
      verify_test
        (read_val = "Welcome, Iris!", "Value overwrite matches");
   end;

   -- Test 6: Levenshtein distance
   declare
      dist : constant integer :=
        db_edit_distance ("Playfair", "PlayfairDisplay");
   begin
      verify_test (dist = 7, "Edit distance calculation correct");
   end;

   -- Test 7: Remove key
   db_remove (db, "greeting");
   verify_test
     (not db_exists (db, "greeting"), "Key removed successfully");
   verify_test (db_count (db) = 0, "Record count is 0 after removal");

   -- Test 8: Close database
   db_close (db);
   verify_test (db_is_closed (db), "Database closed successfully");

   put_line ("Database Interface Tests Complete.");

end test_database;
