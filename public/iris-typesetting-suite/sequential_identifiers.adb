--  Thread-safe sequential unique identifiers.
--
--  SPDX-License-Identifier: MIT

pragma wide_character_encoding (utf8);
pragma ada_2022;

with system.atomic_operations.modular_arithmetic;

package body sequential_identifiers is

   package sequential_identifier_operations is new
     system.atomic_operations.modular_arithmetic
       (atomic_type => sequential_identifier);
   use sequential_identifier_operations;

   counter : aliased sequential_identifier := 0;

   function next_sequential_identifier return sequential_identifier is
   begin
      return atomic_fetch_and_add (item => counter, value => 1);
   end next_sequential_identifier;

end sequential_identifiers;
