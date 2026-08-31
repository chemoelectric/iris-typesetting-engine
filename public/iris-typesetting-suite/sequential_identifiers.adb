--  Thread-safe sequential unique identifiers.
--
--  SPDX-License-Identifier: MIT

pragma wide_character_encoding (utf8);
pragma ada_2022;

with system.atomic_operations.modular_arithmetic;

package body sequential_identifiers is

   type atomic_result_type is new sequential_identifier with atomic;

   package atomic_result_type_operations is new
     system.atomic_operations.modular_arithmetic
       (atomic_type => atomic_result_type);
   use atomic_result_type_operations;

   counter : aliased atomic_result_type := 0;

   function next_sequential_identifier return sequential_identifier is
      atomic_result : atomic_result_type;
   begin
      atomic_result := atomic_fetch_and_add (item => counter, value => 1);
      return sequential_identifier (atomic_result);
   end next_sequential_identifier;

end sequential_identifiers;
