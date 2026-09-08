--
--  SPDX-License-Identifier: MIT
--

--
-- Maps from unsigned 32-bit integers to elements.
--

pragma wide_character_encoding (utf8);
pragma ada_2022;

with unchecked_deallocation;

package body radix_tries is

   procedure free_node is new
     unchecked_deallocation (radix_node, radix_node_access);

   -- 32-bit integers four bits at a time.
   bits_per_step    : constant := 4;
   bits_per_integer : constant := 32;
   total_steps      : constant := bits_per_integer / bits_per_step;

   pragma warnings (off, "*predicate is redundant*");
   subtype total_steps_divides_bits_per_integer is boolean
   with
     unreferenced,
     static_predicate =>
       (total_steps * bits_per_step = bits_per_integer);
   pragma warnings (on, "*predicate is redundant*");

   function key_not_found (key : in unsigned_32) return string
   is ("key not found: " & key'img);

   function key_already_contained (key : in unsigned_32) return string
   is ("key already contained: " & key'img);

   function key_nibble
     (key : in unsigned_32; i : in integer) return natural
   is (natural
         ((key / (2**(i * bits_per_step))) mod (2**bits_per_step)))
   with pre => (0 <= i and i <= total_steps - 1);

   procedure insert
     (container : in out radix_trie;
      key       : in unsigned_32;
      new_item  : in element_type)
   is
      node            : radix_node_access := container.root;
      index           : natural;
      increment_count : boolean := false;
   begin
      for i in reverse 0 .. total_steps - 1 loop
         index := key_nibble (key, i);
         if node.children (index) = null then
            node.children (index) := new radix_node (is_leaf => i = 0);
            increment_count := true;
         end if;
         node := node.children (index);
      end loop;
      if increment_count then
         node.element := new_item;
         container.count := @ + 1;
      else
         raise key_error with key_already_contained (key);
      end if;
   end insert;

   procedure include
     (container : in out radix_trie;
      key       : in unsigned_32;
      new_item  : in element_type)
   is
      node            : radix_node_access := container.root;
      index           : natural;
      increment_count : boolean := false;
   begin
      for i in reverse 0 .. total_steps - 1 loop
         index := key_nibble (key, i);
         if node.children (index) = null then
            node.children (index) := new radix_node (is_leaf => i = 0);
            increment_count := true;
         end if;
         node := node.children (index);
      end loop;
      node.element := new_item;
      if increment_count then
         container.count := @ + 1;
      end if;
   end include;

   procedure replace
     (container : in out radix_trie;
      key       : in unsigned_32;
      new_item  : in element_type)
   is
      node : radix_node_access := container.root;
      i    : integer range -1 .. total_steps - 1;
   begin
      i := total_steps - 1;
      while i /= -1 and then node.children (key_nibble (key, i)) /= null
      loop
         node := node.children (key_nibble (key, i));
         i := @ - 1;
      end loop;
      if i /= -1 then
         raise key_error with key_not_found (key);
      else
         node.element := new_item;
      end if;
   end replace;

   function contains
     (container : radix_trie; key : unsigned_32) return boolean
   is
      node : radix_node_access := container.root;
      i    : integer range -1 .. total_steps - 1;
   begin
      i := total_steps - 1;
      while i /= -1 and then node.children (key_nibble (key, i)) /= null
      loop
         i := @ - 1;
      end loop;
      return (i = -1);
   end contains;

   function element
     (container : radix_trie; key : unsigned_32) return element_type
   is
      node        : radix_node_access := container.root;
      key_shifted : unsigned_32;
   begin
      key_shifted := key;
      for i in reverse 0 .. total_steps - 1 loop
         node := node.children (key_nibble (key, i));
      end loop;
      return node.element;
   end element;

   function has_no_children (node : radix_node_access) return boolean is
      i : integer;
   begin
      i := node.children'first;
      while i /= node.children'last + 1
        and then node.children (i) = null
      loop
         i := @ + 1;
      end loop;
      return (i = node.children'last + 1);
   end has_no_children;

   function delete_helper
     (node    : in out radix_node_access;
      key     : unsigned_32;
      i       : integer;
      deleted : in out boolean) return radix_node_access
   is
      index : natural;
   begin
      return result : radix_node_access do
         if node = null then
            result := null;
         elsif i < 0 then
            deleted := true;
            if has_no_children (node) then
               free_node (node);
               result := null;
            else
               result := node;
            end if;
         else
            index := key_nibble (key, i);
            node.children (index) :=
              delete_helper
                (node.children (index), key, i - 1, deleted);
            if has_no_children (node) then
               free_node (node);
               result := null;
            else
               result := node;
            end if;
         end if;
      end return;
   end delete_helper;

   procedure delete
     (container : in out radix_trie; key : in unsigned_32)
   is
      deleted : boolean := false;
      dummy   : radix_node_access;
   begin
      dummy :=
        delete_helper (container.root, key, total_steps - 1, deleted);
      if deleted then
         container.count := @ - 1;
      else
         raise key_error with key_not_found (key);
      end if;
   end delete;

   procedure exclude
     (container : in out radix_trie; key : in unsigned_32)
   is
      deleted : boolean := false;
      dummy   : radix_node_access;
   begin
      dummy :=
        delete_helper (container.root, key, total_steps - 1, deleted);
      if deleted then
         container.count := @ - 1;
      end if;
   end exclude;

   function length (container : in radix_trie) return count_type
   is (container.count);

   function is_empty (container : in radix_trie) return boolean
   is (container.count = 0);

   procedure empty_out (container : in out radix_trie) is
      procedure delete_node (node : in out radix_node_access) is
      begin
         if node = null then
            null;
         elsif node.is_leaf then
            free_node (node);
         else
            for j in node.children'range loop
               delete_node (node.children (j));
            end loop;
            free_node (node);
         end if;
      end;
   begin
      delete_node (container.root);
   end empty_out;

   procedure start_up (container : in out radix_trie) is
   begin
      container.root := new radix_node (is_leaf => false);
      container.count := 0;
   end start_up;

   procedure clear (container : in out radix_trie) is
   begin
      empty_out (container);
      start_up (container);
   end clear;

   overriding
   procedure initialize (container : in out radix_trie) is
   begin
      start_up (container);
   end initialize;

   overriding
   procedure finalize (container : in out radix_trie) is
   begin
      empty_out (container);
   end finalize;

end radix_tries;
