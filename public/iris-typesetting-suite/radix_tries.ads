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

generic
   type element_type is private;
package radix_tries is

   key_error : exception;

   type radix_trie is limited private;

   procedure insert
     (container : in out radix_trie;
      key       : in unsigned_32;
      new_item  : in element_type)
   with
     warnings       => off,
     contract_cases =>
       (contains (container, key)     => raise key_error,
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

   procedure delete
     (container : in out radix_trie; key : in unsigned_32)
   with
     warnings       => off,
     contract_cases =>
       (contains (container, key)     =>
          length (container) = length (container)'old - 1,
        not contains (container, key) => raise key_error);

   procedure exclude
     (container : in out radix_trie; key : in unsigned_32)
   with
     contract_cases =>
       (contains (container, key)     =>
          length (container) = length (container)'old - 1,
        not contains (container, key) =>
          length (container) = length (container)'old);

   function contains
     (container : in radix_trie; key : in unsigned_32) return boolean;

   function element
     (container : in radix_trie; key : in unsigned_32)
      return element_type
   with pre => contains (container, key);

   function length (container : in radix_trie) return count_type;

   function is_empty (container : in radix_trie) return boolean
   with post => is_empty'result = (length (container) = 0);

private

   type radix_node;
   type radix_node_access is access all radix_node;

   type children_array is array (0 .. 15) of radix_node_access;

   type radix_node is record
      children : children_array;
      element  : element_type;
   end record;

   type radix_trie is new ada.finalization.limited_controlled
   with record
      root  : radix_node_access;
      count : count_type;
   end record
   with dynamic_predicate => root /= null;

   overriding
   procedure initialize (container : in out radix_trie);
   overriding
   procedure finalize (container : in out radix_trie);

end radix_tries;
