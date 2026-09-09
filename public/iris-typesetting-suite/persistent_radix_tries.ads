--
--  SPDX-License-Identifier: MIT
--

--
-- Maps from unsigned 32-bit integers to elements.
--
--  FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
--  This is not persistent yet.
--  FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
--

pragma wide_character_encoding (utf8);
pragma ada_2022;

with interfaces;     use interfaces;
with ada.containers; use ada.containers;
with ada.finalization;

generic
   type element_type is private;
package persistent_radix_tries is

   type radix_trie is tagged private
   with
     aggregate         =>
       (empty => empty_radix_trie, add_named => insert),
     constant_indexing => constant_reference,
     variable_indexing => variable_reference;

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

   function empty_radix_trie return radix_trie
   with post => is_empty (empty_radix_trie'result);

   procedure insert
     (container : in out radix_trie;
      key       : in unsigned_32;
      new_item  : in element_type)
   with
     warnings       => off,
     contract_cases =>
       (contains (container, key)     => raise constraint_error,
        not contains (container, key) =>
          length (container) = length (container)'old + 1);

   procedure include
     (container : in out radix_trie;
      key       : in unsigned_32;
      new_item  : in element_type)
   with
     contract_cases =>
       (contains (container, key)     =>
          length (container) = length (container)'old,
        not contains (container, key) =>
          length (container) = length (container)'old + 1);

   procedure replace
     (container : in out radix_trie;
      key       : in unsigned_32;
      new_item  : in element_type)
   with
     contract_cases =>
       (contains (container, key)     =>
          length (container) = length (container)'old,
        not contains (container, key) =>
          length (container) = length (container)'old + 1);

   procedure delete
     (container : in out radix_trie; key : in unsigned_32)
   with
     warnings       => off,
     contract_cases =>
       (contains (container, key)     =>
          length (container) = length (container)'old - 1,
        not contains (container, key) => raise constraint_error);

   procedure exclude
     (container : in out radix_trie; key : in unsigned_32)
   with
     contract_cases =>
       (contains (container, key)     =>
          length (container) = length (container)'old - 1,
        not contains (container, key) =>
          length (container) = length (container)'old);

   procedure clear (container : in out radix_trie)
   with post => is_empty (container);

   function contains
     (container : in radix_trie; key : in unsigned_32) return boolean;

   function element
     (container : in radix_trie; key : in unsigned_32)
      return element_type
   with pre => contains (container, key);

   function length (container : in radix_trie) return count_type;

   function is_empty (container : in radix_trie) return boolean
   with post => is_empty'result = (length (container) = 0);

   function constant_reference
     (container : in radix_trie; key : in unsigned_32)
      return constant_element_reference
   with pre => contains (container, key);

   function variable_reference
     (container : in out radix_trie; key : in unsigned_32)
      return variable_element_reference
   with pre => contains (container, key);

private

   type radix_node;
   type radix_node_access is access all radix_node;

   type children_array is array (0 .. 15) of radix_node_access;

   type radix_node (is_leaf : boolean) is record
      case is_leaf is
         when false =>
            children : children_array;

         when true =>
            element : aliased element_type;
      end case;
   end record;

   type radix_trie is new ada.finalization.controlled with record
      root  : radix_node_access;
      count : count_type;
   end record
   with dynamic_predicate => root /= null;

   overriding
   procedure initialize (container : in out radix_trie);
   overriding
   procedure adjust (container : in out radix_trie);
   overriding
   procedure finalize (container : in out radix_trie);

   type constant_element_reference
     (element : not null access constant element_type)
   is null record;
   type variable_element_reference
     (element : not null access element_type)
   is null record;

end persistent_radix_tries;
