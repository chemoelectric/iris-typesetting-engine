--  Thread-safe sequential unique identifiers.
--
--  SPDX-License-Identifier: MIT

pragma wide_character_encoding (utf8);
pragma ada_2022;

with ada.containers;

package body sequential_identifiers is

   use ada.containers;

   protected body thread_safe_counter is

      procedure increment_counter_value is
      begin
         counter_value := @ + 1;
      end increment_counter_value;

      function get_counter_value return sequential_identifier is
      begin
         return counter_value;
      end get_counter_value;

   end thread_safe_counter;

   counter : thread_safe_counter;

   function next_sequential_identifier return sequential_identifier is
      result : constant sequential_identifier :=
        counter.get_counter_value;
   begin
      counter.increment_counter_value;
      return result;
   end next_sequential_identifier;

   function hash_sequential_identifier
     (key : in sequential_identifier) return hash_type
   is
      --
      -- FNV-1a hash. FIXME: ********** USE SPOOKYHASH **************
      --
      -- 32-bit FNV-1a constants.
      --
      fnv_prime : constant hash_type := 16777619;
      hash      : hash_type := 2166136261;

      --
      -- Extract 32-bit chunks from the 128-bit key.
      --
      chunk_0 : constant hash_type := hash_type (key and 16#ffff_ffff#);
      chunk_1 : constant hash_type :=
        hash_type ((key / 2**32) and 16#ffff_ffff#);
      chunk_2 : constant hash_type :=
        hash_type ((key / 2**64) and 16#ffff_ffff#);
      chunk_3 : constant hash_type :=
        hash_type ((key / 2**96) and 16#ffff_ffff#);
   begin
      hash := hash xor chunk_0;
      hash := hash * fnv_prime;

      hash := hash xor chunk_1;
      hash := hash * fnv_prime;

      hash := hash xor chunk_2;
      hash := hash * fnv_prime;

      hash := hash xor chunk_3;
      hash := hash * fnv_prime;

      return hash;
   end hash_sequential_identifier;

end sequential_identifiers;
