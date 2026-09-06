--
--  SPDX-License-Identifier: MIT
--
--  Hash tables for vector parallel processors.
--
--  Search is brute-force vectorized linear search. Empty slots are
--  identified by a sentinel value that is “stolen” from the hash
--  value space.
--

pragma wide_character_encoding (utf8);
pragma ada_2022;

with ada.text_io; use ada.text_io;
with hash_tables;

procedure test_hash_tables is

   function int_hash
     (k : in integer) return natural is
   begin
      return natural (abs (k));
   end int_hash;

   function int_equal
     (left  : in integer;
      right : in integer) return boolean is
   begin
      return left = right;
   end int_equal;

   package int_int_maps is new hash_tables
     (key_type                 => integer,
      element_type             => integer,
      hash                     => int_hash,
      are_keys_equal           => int_equal,
      default_initial_capacity => 8,
      expand_threshold_percent => 100,
      shrink_threshold_percent => 25);

   use int_int_maps;

   table : map := make (8);
   idx   : integer;
   procedure test_01 is
   begin
      put ("test 1: basic insertion, lookup, and deletion ... ");
      insert (table, 1, 100);
      insert (table, 2, 200);
      insert (table, 3, 300);

      if length (table) /= 3 or else
         get (table, 1) /= 100 or else
         get (table, 2) /= 200 or else
         get (table, 3) /= 300
      then
         raise program_error with "failed basic lookup";
      end if;

      delete (table, 2);
      if contains (table, 2) or else length (table) /= 2 then
         raise program_error with "failed deletion";
      end if;
      put_line ("passed.");
   end test_01;

   procedure test_02 is
   begin
      put ("test 2: expansion triggering under load ... ");
      idx := 10;
      while idx <= 20 loop
         insert (table, idx, idx * 10);
         idx := idx + 1;
      end loop;

      if capacity (table) <= 8 then
         raise program_error with "table failed to expand under load";
      end if;

      idx := 10;
      while idx <= 20 loop
         if not contains (table, idx) or else get (table, idx) /= idx * 10 then
            raise program_error with "element missing after expansion";
         end if;
         idx := idx + 1;
      end loop;
      put_line ("passed.");
   end test_02;

   procedure test_03 is
   begin
      put ("test 3: contraction triggering after deletions ... ");
      declare
         peak_cap : constant positive := capacity (table);
      begin
         idx := 10;
         while idx <= 20 loop
            delete (table, idx);
            idx := idx + 1;
         end loop;

         if capacity (table) >= peak_cap then
            raise program_error with "table failed to shrink after deletions";
         end if;

         if not contains (table, 1) or else not contains (table, 3) then
            raise program_error with
              "original elements corrupted after shrink";
         end if;
      end;
      put_line ("passed.");
   end test_03;

   procedure test_04 is
   begin
      put ("test 4: update existing key values ... ");
      insert (table, 1, 999);
      if get (table, 1) /= 999 or else length (table) /= 2 then
         raise program_error with "failed updating existing key";
      end if;
      put_line ("passed.");
   end test_04;

   procedure test_05 is
   begin
      put ("test 5: reset and clear table ... ");
      clear (table);
      if length (table) /= 0 or else contains (table, 1) then
         raise program_error with "failed clearing table";
      end if;
      release (table);
      put_line ("passed.");
   end test_05;
   
begin
   put_line ("=== running self-resizing hash table test suite ===");
   test_01;
   test_02;
   test_03;
   test_04;
   test_05;
   put_line ("=== all tests passed successfully ===");
end test_hash_tables;
