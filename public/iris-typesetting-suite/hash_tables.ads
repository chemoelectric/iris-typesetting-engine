--
--  SPDX-License-Identifier: MIT
--
--  Hash tables for vector parallel processors.
--
--  Search is brute-force vectorized linear search.

--  NOT TRUE YET!!! --->>> Empty slots are identified by a sentinel
--  value that is “stolen” from the hash value space.
--

pragma wide_character_encoding (utf8);
pragma ada_2022;

with ada.containers;
with ada.finalization;

generic
   type key_type is private;
   type element_type is private;
   with
   function hash (key : in key_type) return ada.containers.hash_type
   is <>;
   with
   function are_keys_equal (left, right : in key_type) return boolean
   is <>;
   default_initial_capacity : positive := 16;
   expand_threshold_percent : positive := 100;
   shrink_threshold_percent : natural := 25;
package hash_tables is

   type map is limited private;

   key_error : exception;

   function make
     (initial_capacity : in positive := default_initial_capacity)
     return map
     with
       post =>
         length (make'result) = 0
         and then capacity (make'result) >= initial_capacity;

   function length (container : in map) return natural;

   function capacity (container : in map) return positive;

   function is_empty (container : in map) return boolean
     with post => is_empty'result = (length (container) = 0);

   function contains
     (container : in map; key : in key_type) return boolean;

   function get
     (container : in map; key : in key_type) return element_type
     with pre => contains (container, key);

   procedure insert
     (container : in out map;
      key       : in key_type;
      element   : in element_type)
     with
       post =>
         contains (container, key)
         and then get (container, key) = element;

   procedure delete (container : in out map; key : in key_type)
     with post => not contains (container, key);

   procedure clear (container : in out map)
     with post => length (container) = 0;

   procedure release (container : in out map);

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

   use ada.finalization;

   type map is new limited_controlled with record
      buckets       : bucket_array_access := null;
      element_count : natural := 0;
      min_capacity  : positive := default_initial_capacity;
      expand_pct    : positive := expand_threshold_percent;
      shrink_pct    : natural := shrink_threshold_percent;
   end record;

   overriding
   procedure finalize (container : in out map);

   use type node_access;

end hash_tables;
