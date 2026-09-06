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

generic
   type key_type is private;
   type element_type is private;
   with function hash
     (key : in key_type) return natural is <>;
   with function are_keys_equal
     (left  : in key_type;
      right : in key_type) return boolean is <>;
   default_initial_capacity : positive := 16;
   expand_threshold_percent  : positive := 100;
   shrink_threshold_percent  : natural  := 25;
package hash_tables is

   type map is limited private;

   key_error : exception;

   function make
     (initial_capacity : in positive := default_initial_capacity)
     return map
     with
       post => length (make'result) = 0 and then
               capacity (make'result) >= initial_capacity;

   function length
     (m : in map) return natural;

   function capacity
     (m : in map) return positive;

   function is_empty
     (m : in map) return boolean
     with
       post => is_empty'result = (length (m) = 0);

   function contains
     (m   : in map;
      key : in key_type) return boolean;

   function get
     (m   : in map;
      key : in key_type) return element_type
     with
       pre => contains (m, key);

   procedure insert
     (m       : in out map;
      key     : in key_type;
      element : in element_type)
     with
       post => contains (m, key) and then
               get (m, key) = element;

   procedure delete
     (m   : in out map;
      key : in key_type)
     with
       post => not contains (m, key);

   procedure clear
     (m : in out map)
     with
       post => length (m) = 0;

   procedure release
     (m : in out map);

private

   type node;
   type node_access is access node;

   type node is record
      key     : key_type;
      element : element_type;
      next    : node_access := null;
   end record;

   type bucket_array is array (natural range <>) of node_access;
   type bucket_array_access is access bucket_array;

   type map is limited record
      buckets          : bucket_array_access := null;
      element_count    : natural             := 0;
      min_capacity     : positive            := default_initial_capacity;
      expand_pct       : positive            := expand_threshold_percent;
      shrink_pct       : natural             := shrink_threshold_percent;
   end record;

   use type node_access;

end hash_tables;
