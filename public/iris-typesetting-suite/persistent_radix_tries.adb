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

with unchecked_deallocation;

package body persistent_radix_tries is

   -- 32-bit integers four bits at a time.
   bits_per_step    : constant := 4;
   bits_per_integer : constant := 32;
   total_steps      : constant := bits_per_integer / bits_per_step;

   subtype total_steps_divides_bits_per_integer is boolean
   with
     unreferenced,
     warnings         => off,
     static_predicate =>
       (total_steps * bits_per_step = bits_per_integer);

   procedure deallocate is new
     unchecked_deallocation (radix_node, radix_node_access);

   function key_not_found (key : in unsigned_32) return string
   is ("key not found: " & key'img);

   function key_already_contained (key : in unsigned_32) return string
   is ("key already contained: " & key'img);

   function key_nibble
     (key : in unsigned_32; i : in integer) return natural
   is (natural
         ((key / (2**(i * bits_per_step))) mod (2**bits_per_step)))
   with pre => (0 <= i and i <= total_steps - 1);

   function empty_radix_trie return radix_trie is
   begin
      return result : radix_trie do
         null;
      end return;
   end empty_radix_trie;

   procedure insert_aux
     (container           : in out radix_trie;
      key                 : in unsigned_32;
      node_out            : out radix_node_access;
      increment_the_count : out boolean)
   is
      index          : natural;
      node           : radix_node_access := container.root;
      incr_the_count : boolean := false;
   begin
      for i in reverse 0 .. total_steps - 1 loop
         index := key_nibble (key, i);
         if node.children (index) = null then
            node.children (index) := new radix_node (is_leaf => i = 0);
            incr_the_count := true;
         end if;
         node := node.children (index);
      end loop;
      node_out := node;
      increment_the_count := incr_the_count;
   end insert_aux;

   procedure insert
     (container : in out radix_trie;
      key       : in unsigned_32;
      new_item  : in element_type)
   is
      node                : radix_node_access;
      increment_the_count : boolean;
   begin
      insert_aux (container, key, node, increment_the_count);
      if increment_the_count then
         node.element := new_item;
         container.count := @ + 1;
      else
         raise constraint_error with key_already_contained (key);
      end if;
   end insert;

   procedure include_aux
     (container : in out radix_trie;
      key       : in unsigned_32;
      node_out  : out radix_node_access)
   is
      node                : radix_node_access;
      increment_the_count : boolean;
   begin
      insert_aux (container, key, node, increment_the_count);
      if increment_the_count then
         container.count := @ + 1;
      end if;
      node_out := node;
   end include_aux;

   procedure include
     (container : in out radix_trie;
      key       : in unsigned_32;
      new_item  : in element_type)
   is
      node : radix_node_access;
   begin
      include_aux (container, key, node);
      node.element := new_item;
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
         raise constraint_error with key_not_found (key);
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
      node : radix_node_access := container.root;
   begin
      for i in reverse 0 .. total_steps - 1 loop
         node := node.children (key_nibble (key, i));
      end loop;
      return node.element;
   end element;

   function constant_reference
     (container : in radix_trie; key : in unsigned_32)
      return constant_element_reference
   is
      node : radix_node_access := container.root;
   begin
      for i in reverse 0 .. total_steps - 1 loop
         node := node.children (key_nibble (key, i));
      end loop;
      return (element => node.element'access);
   end constant_reference;

   function variable_reference
     (container : in out radix_trie; key : in unsigned_32)
      return variable_element_reference
   is
      node : radix_node_access;
   begin
      include_aux (container, key, node);
      return (element => node.element'access);
   end variable_reference;

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

   procedure delete_aux
     (node     : in out radix_node_access;
      key      : unsigned_32;
      i        : integer;
      node_out : out radix_node_access;
      deleted  : out boolean)
   is
      deletion_done : boolean;
      child_deleted : boolean;
      index         : natural;
      new_child     : radix_node_access;
   begin
      deletion_done := false;
      if node = null then
         node_out := null;
      elsif i < 0 then
         deleted := true;
         if has_no_children (node) then
            deallocate (node);
            node_out := null;
         else
            node_out := node;
         end if;
      else
         index := key_nibble (key, i);
         delete_aux
           (node.children (index),
            key,
            i - 1,
            new_child,
            child_deleted);
         node.children (index) := new_child;
         deletion_done := @ or child_deleted;
         if has_no_children (node) then
            deallocate (node);
            node_out := null;
         else
            node_out := node;
         end if;
      end if;
      deleted := deletion_done;
   end delete_aux;

   procedure delete_aux
     (node    : in out radix_node_access;
      key     : unsigned_32;
      i       : integer;
      deleted : out boolean)
   is
      bit_bucket : radix_node_access;
   begin
      delete_aux (node, key, i, bit_bucket, deleted);
   end delete_aux;

   procedure delete
     (container : in out radix_trie; key : in unsigned_32)
   is
      deleted : boolean;
   begin
      delete_aux (container.root, key, total_steps - 1, deleted);
      if deleted then
         container.count := @ - 1;
      else
         raise constraint_error with key_not_found (key);
      end if;
   end delete;

   procedure exclude
     (container : in out radix_trie; key : in unsigned_32)
   is
      deleted : boolean;
   begin
      delete_aux (container.root, key, total_steps - 1, deleted);
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
            deallocate (node);
         else
            for j in node.children'range loop
               delete_node (node.children (j));
            end loop;
            deallocate (node);
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

   procedure deep_copy (container : in out radix_trie) is
      function copy_node
        (old_node : in radix_node_access) return radix_node_access is
      begin
         return node : radix_node_access do
            if old_node = null then
               node := null;
            elsif old_node.is_leaf then
               node := new radix_node (is_leaf => true);
               node.element := old_node.element;
            else
               node := new radix_node (is_leaf => false);
               for j in node.children'range loop
                  node.children (j) :=
                    copy_node (old_node.children (j));
               end loop;
            end if;
         end return;
      end copy_node;
   begin
      container.root := copy_node (container.root);
   end deep_copy;

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
   procedure adjust (container : in out radix_trie) is
   begin
      --
      -- There is no attempt to share structure. A full deep copy is
      -- done.
      --
      deep_copy (container);
   end adjust;

   overriding
   procedure finalize (container : in out radix_trie) is
   begin
      empty_out (container);
   end finalize;

end persistent_radix_tries;
