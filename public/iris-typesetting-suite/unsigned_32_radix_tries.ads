--
--  SPDX-License-Identifier: MIT
--

--
-- Maps from unsigned 32-bit integers to elements.
--

pragma wide_character_encoding (utf8);
pragma ada_2022;

with interfaces;     use interfaces;
with ada.containers; use ada.containers;
with ada.finalization;

------------------------------------------------------------------------

generic

   type element_type is private;

package unsigned_32_radix_tries
is

   ---------------------------------------------------------------------

   type map is tagged private
   with
     aggregate         => (empty => empty_map, add_named => insert),
     constant_indexing => constant_reference,
     variable_indexing => variable_reference,
     iterable          =>
       (first       => first_cursor,
        next        => next_cursor,
        has_element => has_element,
        element     => element);

   type keys_view (target : access constant map) is null record
   with
     iterable =>
       (first       => first_cursor,
        next        => next_cursor,
        has_element => has_key,
        element     => key);

   ---------------------------------------------------------------------

   function keys (container : aliased map) return keys_view;

   ---------------------------------------------------------------------

   function empty_map return map
   with post => is_empty (empty_map'result);

   procedure insert
     (container : in out map;
      key       : in unsigned_32;
      new_item  : in element_type)
   with
     warnings       => off,
     contract_cases =>
       (contains (container, key)     => raise constraint_error,
        not contains (container, key) =>
          length (container) = length (container)'old + 1);

   procedure include
     (container : in out map;
      key       : in unsigned_32;
      new_item  : in element_type)
   with
     contract_cases =>
       (contains (container, key)     =>
          length (container) = length (container)'old,
        not contains (container, key) =>
          length (container) = length (container)'old + 1);

   procedure replace
     (container : in out map;
      key       : in unsigned_32;
      new_item  : in element_type)
   with
     contract_cases =>
       (contains (container, key)     =>
          length (container) = length (container)'old,
        not contains (container, key) =>
          length (container) = length (container)'old + 1);

   procedure delete (container : in out map; key : in unsigned_32)
   with
     warnings       => off,
     contract_cases =>
       (contains (container, key)     =>
          length (container) = length (container)'old - 1,
        not contains (container, key) => raise constraint_error);

   procedure exclude (container : in out map; key : in unsigned_32)
   with
     contract_cases =>
       (contains (container, key)     =>
          length (container) = length (container)'old - 1,
        not contains (container, key) =>
          length (container) = length (container)'old);

   procedure clear (container : in out map)
   with post => is_empty (container);

   function contains
     (container : in map; key : in unsigned_32) return boolean;

   function element
     (container : in map; key : in unsigned_32) return element_type
   with pre => contains (container, key);

   function length (container : in map) return count_type;

   function is_empty (container : in map) return boolean
   with post => is_empty'result = (length (container) = 0);

   ---------------------------------------------------------------------
   --
   -- Iterables and cursors.
   --

   type cursor is tagged private;

   function first_cursor (container : in map) return cursor'class;

   function first (container : in map'class) return cursor;

   function next_cursor
     (container : in map; position : in cursor'class)
      return cursor'class;

   function next (position : in cursor) return cursor;

   function has_element
     (container : in map; position : in cursor'class) return boolean;

   function has_element (position : in cursor) return boolean;

   function element
     (container : in map; position : in cursor'class)
      return element_type
   with pre => has_element (container, position);

   function element (position : in cursor) return element_type
   with pre => has_element (position);

   function key (position : in cursor) return unsigned_32
   with pre => has_element (position);

   --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  --  -

   function first_cursor (view : in keys_view) return cursor;

   function next_cursor
     (view : in keys_view; position : in cursor) return cursor;

   function has_key
     (view : in keys_view; position : in cursor) return boolean;

   function key
     (view : in keys_view; position : in cursor) return unsigned_32
   with pre => has_key (view, position);

   ---------------------------------------------------------------------
   --
   -- Indices.
   --

   type constant_element_reference
     (element : not null access constant element_type)
   is
     private
   with implicit_dereference => element;

   type variable_element_reference
     (element : not null access element_type)
   is
     private
   with implicit_dereference => element;

   function constant_reference
     (container : in map; key : in unsigned_32)
      return constant_element_reference
   with pre => contains (container, key);

   function variable_reference
     (container : in out map; key : in unsigned_32)
      return variable_element_reference
   with pre => contains (container, key);

   ---------------------------------------------------------------------

private

   ---------------------------------------------------------------------

   -- 32-bit integers, read high nybble first, four bits at a time, to
   -- go through the trie.
   bits_per_step    : constant := 4;
   bits_per_integer : constant := 32;
   total_steps      : constant := bits_per_integer / bits_per_step;

   subtype total_steps_divides_bits_per_integer is boolean
   with
     unreferenced,
     warnings         => off,
     static_predicate =>
       (total_steps * bits_per_step = bits_per_integer);

   ---------------------------------------------------------------------

   subtype controlled is ada.finalization.controlled;

   ---------------------------------------------------------------------

   type radix_node;
   type radix_node_access is access all radix_node;

   type children_array is
     array (0 .. (2**bits_per_step) - 1) of radix_node_access;

   type radix_node (is_leaf : boolean) is record
      case is_leaf is
         when false =>
            children : children_array;

         when true =>
            element : aliased element_type;
      end case;
   end record;

   type map is new controlled with record
      root          : radix_node_access;
      element_count : count_type;
      busy_count    : natural;
   end record
   with dynamic_predicate => root /= null;

   overriding
   procedure initialize (container : in out map);
   overriding
   procedure adjust (container : in out map);
   overriding
   procedure finalize (container : in out map);

   ---------------------------------------------------------------------

   type constant_element_reference
     (element : not null access constant element_type)
   is null record;   -- 32-bit integers, four bits at a time.

   type variable_element_reference
     (element : not null access element_type)
   is null record;

   ---------------------------------------------------------------------

   subtype depth_range is integer range 0 .. total_steps;
   subtype index_range is integer range 1 .. total_steps;

   type cursor_nodes_array is array (index_range) of radix_node_access;
   type cursor_next_indices_array is
     array (index_range) of integer range 0 .. 2**bits_per_step;
   type cursor_path_indices_array is
     array (index_range) of integer range 0 .. 2**bits_per_step - 1;

   type cursor is new controlled with record
      container    : access map;
      current_node : radix_node_access;
      nodes        : cursor_nodes_array;
      next_indices : cursor_next_indices_array;
      path_indices : cursor_path_indices_array;
      depth        : depth_range := 0;
   end record;

   overriding
   procedure adjust (position : in out cursor);
   overriding
   procedure finalize (position : in out cursor);

   ---------------------------------------------------------------------

end unsigned_32_radix_tries;
