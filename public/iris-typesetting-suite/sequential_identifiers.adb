--  Thread-safe sequential unique identifiers.
--
--  SPDX-License-Identifier: MIT

pragma wide_character_encoding (utf8);
pragma ada_2022;

with interfaces;
with ada.containers;
with system.atomic_operations.modular_arithmetic;

package body sequential_identifiers is

   use interfaces;
   use ada.containers;

   type atomic_result_type is new sequential_identifier with atomic;

   package atomic_result_type_operations is new
     system.atomic_operations.modular_arithmetic
       (atomic_type => atomic_result_type);
   use atomic_result_type_operations;

   counter : aliased atomic_result_type := 0;

   function next_sequential_identifier return sequential_identifier is
      atomic_result : atomic_result_type;
   begin
      atomic_result :=
        atomic_fetch_and_add (item => counter, value => 1);
      return sequential_identifier (atomic_result);
   end next_sequential_identifier;

   function "<" (left, right : in sequential_identifier) return boolean
   is
   begin
      return "<" (unsigned_64 (left), unsigned_64 (right));
   end "<";

   function ">" (left, right : in sequential_identifier) return boolean
   is
   begin
      return ">" (unsigned_64 (left), unsigned_64 (right));
   end ">";

   function "=" (left, right : in sequential_identifier) return boolean
   is
   begin
      return "=" (unsigned_64 (left), unsigned_64 (right));
   end "=";

   function "<=" (left, right : in sequential_identifier) return boolean
   is
   begin
      return "<=" (unsigned_64 (left), unsigned_64 (right));
   end "<=";

   function ">=" (left, right : in sequential_identifier) return boolean
   is
   begin
      return ">=" (unsigned_64 (left), unsigned_64 (right));
   end ">=";

   function hash_sequential_identifier
     (key : in sequential_identifier) return hash_type
   is
      --
      -- FIXME: USE SPOOKYHASH. IN FACT, USE SPOOKYHASH EVERYWHERE AND
      -- ADD SUPPORT FOR INCREMENTAL HASHING.
      --
      -- Knuth’s method must be as old as the hills. It surely is not
      -- bad, but we now have incremental hashing methods that can
      -- deal better with arrays, lists, etc.
      --

      --
      -- Knuth’s multiplier that (they say) does something such as use
      -- the golden ratio to subdivide the space of hashes repeatedly
      -- without running out of space. FIXME: LOOK UP THE REFERENCE IN
      -- THE ART OF COMPUTER PROGRAMMING, AND FIX THIS COMMENT.
      --
      multiplier : constant sequential_identifier :=
        11400714819323198485;

      x : sequential_identifier;
   begin
      -- Use the multiplier, after mixing high and low bits.
      x := multiplier * (shift_right (key, 30) xor key);
      -- Mix high and low bits again.
      return hash_type'mod (shift_right (x, 27) xor x);
   end hash_sequential_identifier;

end sequential_identifiers;
