--  Thread-safe sequential unique identifiers.
--
--  SPDX-License-Identifier: MIT

pragma wide_character_encoding (utf8);
pragma ada_2022;

with interfaces;

package sequential_identifiers is

   type sequential_identifier is new interfaces.unsigned_64 with atomic;

   function next_sequential_identifier return sequential_identifier;

end sequential_identifiers;
