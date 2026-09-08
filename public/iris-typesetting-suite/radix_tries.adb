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

   function key_nibble
     (key : in unsigned_32; i : in integer) return natural
   is (natural
         ((key / (2**(i * bits_per_step))) mod (2**bits_per_step)))
   with pre => (0 <= i and i <= total_steps - 1);

   overriding
   procedure initialize (container : in out radix_trie) is
   begin
      container.root := new radix_node;
      container.count := 0;
   end initialize;

   procedure recursive_wipe (current : in out radix_node_access) is
   begin
      if current /= null then
         for i in current.children'range loop
            recursive_wipe (current.children (i));
         end loop;
         free_node (current);
      end if;
   end recursive_wipe;

   overriding
   procedure finalize (container : in out radix_trie) is
   begin
      recursive_wipe (container.root);
   end finalize;

   procedure include
     (container : in out radix_trie;
      key       : in unsigned_32;
      new_item  : in element_type)
   is
      current         : radix_node_access := container.root;
      index           : natural;
      increment_count : boolean := false;
   begin
      for step in reverse 0 .. total_steps - 1 loop
         index := key_nibble (key, step);
         if current.children (index) = null then
            current.children (index) := new radix_node;
            increment_count := true;
         end if;
         current := current.children (index);
      end loop;
      current.element := new_item;
      if increment_count then
         container.count := @ + 1;
      end if;
   end include;

   function contains
     (container : radix_trie; key : unsigned_32) return boolean
   is
      current : radix_node_access := container.root;
      step    : integer range -1 .. total_steps - 1;
   begin
      step := total_steps - 1;
      while step /= -1
        and then current.children (key_nibble (key, step)) /= null
      loop
         step := @ - 1;
      end loop;
      return (step = -1);
   end contains;

   function element
     (container : radix_trie; key : unsigned_32) return element_type
   is
      current     : radix_node_access := container.root;
      key_shifted : unsigned_32;
   begin
      key_shifted := key;
      for step in reverse 0 .. total_steps - 1 loop
         current := current.children (key_nibble (key, step));
      end loop;
      return current.element;
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
     (current : in out radix_node_access;
      key     : unsigned_32;
      step    : integer;
      deleted : in out boolean) return radix_node_access
   is
      index : natural;
   begin
      return result : radix_node_access do
         if current = null then
            result := null;
         elsif step < 0 then
            deleted := true;
            if has_no_children (current) then
               free_node (current);
               result := null;
            else
               result := current;
            end if;
         else
            index := key_nibble (key, step);
            current.children (index) :=
              delete_helper
                (current.children (index), key, step - 1, deleted);
            if has_no_children (current) then
               free_node (current);
               result := null;
            else
               result := current;
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
         raise key_error with "key not found: " & key'img;
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

end radix_tries;
