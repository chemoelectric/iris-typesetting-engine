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

with interfaces.c;     use interfaces.c;
with ada.containers;   use ada.containers;
with ada.finalization; use ada.finalization;

generic
   type key_type is private;
   type element_type is private;
   with function hash (key : in key_type) return hash_type is <>;
   with
     function are_keys_equal (left, right : in key_type) return boolean
     is <>;
   sentinel_key : in key_type;
   sentinel_element : in element_type;
   default_initial_capacity : count_type := 16;
   -- expand_threshold_percent : positive := 90 with unreferenced;
   -- shrink_threshold_percent : natural := 0 with unreferenced;
package hash_tables is

   type table is limited private;
   --     with
   --       aggregate =>
   --         (empty     => hash_table,
   --          add_named =>
   --            include); -- FIXME FIXME FIXME FIXME FIXME FIXME FIXME: Change this to use insert

   ----   key_error : exception;

   function hash_table
     (initial_capacity : in count_type := default_initial_capacity)
      return table
   with
     pre  => (1 <= initial_capacity),
     post =>
       (capacity (hash_table'result) = initial_capacity
        and length (hash_table'result) = 0);

   function length (container : in table) return count_type;

   function capacity (container : in table) return count_type
   with post => (1 <= capacity'result);

   function is_empty (container : in table) return boolean
   with post => is_empty'result = (length (container) = 0);

   ---   function contains
   ---     (container : in table; key : in key_type) return boolean;
   ---
   ---   function element
   ---     (container : in table; key : in key_type) return element_type
   ---   with pre => contains (container, key);
   ---
   ---   procedure include
   ---     (container : in out table;
   ---      key       : in key_type;
   ---      new_item  : in element_type)
   ---   with
   ---     post =>
   ---       contains (container, key)
   ---       and then element (container, key) = new_item;
   ---
   ---   procedure delete (container : in out table; key : in key_type)
   ---   with post => not contains (container, key);
   ---
   ---   procedure clear (container : in out table)
   ---   with post => length (container) = 0;

private

   type uint32_t is mod 2**32 with convention => c;
   type uint32_array is array (size_t range <>) of uint32_t
   with convention => c;
   type uint32_array_access is access uint32_array;

   type table is new limited_controlled with record
      hashes           : uint32_array_access := null;
      element_capacity : count_type := 0;
      element_count    : count_type := 0;
   end record;

   overriding
   procedure finalize (container : in out table);

end hash_tables;
