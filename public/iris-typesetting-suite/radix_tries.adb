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

   procedure deallocate is new
     unchecked_deallocation (radix_node, radix_node_access);

   function key_not_found (key : in unsigned_32) return string
   is ("key not found: " & key'img);

   function key_already_contained (key : in unsigned_32) return string
   is ("key already contained: " & key'img);

   function busy_delete (key : in unsigned_32) return string
   is ("trie busy, cannot delete: " & key'img);

   function busy_insert (key : in unsigned_32) return string
   is ("trie busy, cannot insert at: " & key'img);

   function busy_clear return string
   is ("trie busy, cannot clear it");

   function key_nybble
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
         index := key_nybble (key, i);
         if node.children (index) = null then
            if container.busy_count /= 0 then
               raise program_error with busy_insert (key);
            end if;
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
         container.element_count := @ + 1;
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
         container.element_count := @ + 1;
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
      while i /= -1 and then node.children (key_nybble (key, i)) /= null
      loop
         node := node.children (key_nybble (key, i));
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
      while i /= -1 and then node.children (key_nybble (key, i)) /= null
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
         node := node.children (key_nybble (key, i));
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
         node := node.children (key_nybble (key, i));
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

   subtype delete_aux_index is integer range -1 .. total_steps - 1;

   procedure delete_aux
     (node     : in out radix_node_access;
      key      : in unsigned_32;
      busy     : in boolean;
      i        : in delete_aux_index;
      node_out : out radix_node_access;
      deleted  : out boolean)
   is
      index     : natural;
      new_child : radix_node_access;
   begin
      if node = null then
         node_out := null;
         deleted := false;
      elsif node.is_leaf then
         if busy then
            raise program_error with busy_delete (key);
         end if;
         deallocate (node);
         node_out := null;
         deleted := true;
      else
         index := key_nybble (key, i);
         delete_aux
           (node.children (index),
            key,
            busy,
            i - 1,
            new_child,
            deleted);
         if deleted then
            node.children (index) := new_child;
            if has_no_children (node) then
               deallocate (node);
               node_out := null;
            else
               node_out := node;
            end if;
         else
            node_out := node;
         end if;
      end if;
   end delete_aux;

   procedure delete_aux
     (node    : in out radix_node_access;
      key     : in unsigned_32;
      busy    : in boolean;
      deleted : out boolean)
   is
      bit_bucket : radix_node_access;
   begin
      delete_aux
        (node, key, busy, total_steps - 1, bit_bucket, deleted);
   end delete_aux;

   procedure delete
     (container : in out radix_trie; key : in unsigned_32)
   is
      deleted : boolean;
   begin
      delete_aux
        (container.root, key, (container.busy_count /= 0), deleted);
      if deleted then
         container.element_count := @ - 1;
      else
         raise constraint_error with key_not_found (key);
      end if;
   end delete;

   procedure exclude
     (container : in out radix_trie; key : in unsigned_32)
   is
      deleted : boolean;
   begin
      delete_aux
        (container.root, key, (container.busy_count /= 0), deleted);
      if deleted then
         container.element_count := @ - 1;
      end if;
   end exclude;

   function length (container : in radix_trie) return count_type
   is (container.element_count);

   function is_empty (container : in radix_trie) return boolean
   is (container.element_count = 0);

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
      container.element_count := 0;
      container.busy_count := 0;
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
      if container.busy_count /= 0 then
         raise program_error with busy_clear;
      end if;
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
      container.busy_count := 0;
   end adjust;

   overriding
   procedure finalize (container : in out radix_trie) is
   begin
      empty_out (container);
   end finalize;

   ---------------------------------------------------------------------

   function first_cursor (container : in radix_trie) return cursor'class
   is
      temp : cursor;
   begin
      temp.container := container'unrestricted_access;
      temp.container.busy_count := @ + 1;
      temp.depth := 1;
      temp.nodes (1) := container.root;
      temp.next_indices (1) := 0;
      temp.current_node := container.root;
      return next_cursor (container, temp);
   end first_cursor;

   function first (container : in radix_trie'class) return cursor
   is (cursor (first_cursor (radix_trie (container))));

   function next_cursor
     (container : in radix_trie; position : in cursor'class)
      return cursor'class
   is
      searching : boolean := (position.current_node /= null);
   begin
      return result : cursor := cursor (position) do
         while searching and result.depth /= 0 loop
            if result.next_indices (result.depth) /= 2**bits_per_step
            then
               declare
                  current_parent : constant radix_node_access :=
                    result.nodes (result.depth);
                  child_index    : constant natural :=
                    result.next_indices (result.depth);
                  child          : constant radix_node_access :=
                    current_parent.children (child_index);
               begin
                  result.next_indices (result.depth) := child_index + 1;
                  if child /= null then
                     result.path_indices (result.depth) := child_index;
                     if result.depth /= total_steps then
                        result.depth := @ + 1;
                        result.nodes (result.depth) := child;
                        result.next_indices (result.depth) := 0;
                     end if;
                     if child.is_leaf then
                        result.current_node := child;
                        searching := false;
                     end if;
                  end if;
               end;
            else
               result.depth := @ - 1;
            end if;
         end loop;
         if searching then
            result.current_node := null;
         end if;
      end return;
   end next_cursor;

   function next (position : in cursor) return cursor
   is (cursor (next_cursor (position.container.all, position)));

   function has_element
     (container : in radix_trie; position : in cursor'class)
      return boolean
   is (position.current_node /= null);

   function has_element (position : in cursor) return boolean
   is (position.current_node /= null);

   function element
     (container : in radix_trie; position : in cursor'class)
      return element_type
   is (position.current_node.element);

   function element (position : in cursor) return element_type
   is (position.current_node.element);

   function key (position : in cursor) return unsigned_32 is
      key : unsigned_32;
   begin
      key := 0;
      for i in index_range loop
         key :=
           (@ * 2**bits_per_step)
           + unsigned_32 (position.path_indices (i));
      end loop;
      return key;
   end key;

   overriding
   procedure adjust (position : in out cursor) is
   begin
      if position.container = null then
         null;
      else
         position.container.busy_count := @ + 1;
      end if;
   end adjust;

   overriding
   procedure finalize (position : in out cursor) is
   begin
      if position.container = null then
         null;
      else
         position.container.busy_count := @ - 1;
         position.container := null;
      end if;
   end finalize;

   ---------------------------------------------------------------------

   function keys (container : aliased radix_trie) return keys_view
   is (keys_view'(target => container'access));

   function first_cursor (view : in keys_view) return cursor
   is (cursor (first_cursor (view.target.all)));

   function next_cursor
     (view : in keys_view; position : in cursor) return cursor
   is (cursor (next_cursor (view.target.all, position)));

   function has_key
     (view : in keys_view; position : in cursor) return boolean
   is (has_element (view.target.all, position));

   function key
     (view : in keys_view; position : in cursor) return unsigned_32
   is (position.key);

   ---------------------------------------------------------------------

end radix_tries;
