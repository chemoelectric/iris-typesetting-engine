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

with ada.finalization;
with ada.unchecked_deallocation;
with ada.containers;

package body hash_tables is

   use ada.finalization;
   use ada.containers;

   procedure free_node is new
     ada.unchecked_deallocation (object => node, name => node_access);

   procedure free_buckets is new
     ada.unchecked_deallocation
       (object => bucket_array,
        name   => bucket_array_access);

   procedure resize
     (container : in out map; new_capacity : in positive);

   function bucket_index
     (key : in key_type; table_size : in positive) return natural
   is (natural (hash (key) mod hash_type (table_size)));

   function make
     (initial_capacity : in positive := default_initial_capacity)
      return map is
   begin
      return result : map do
         result.min_capacity := initial_capacity;
         result.buckets := new bucket_array (0 .. initial_capacity - 1);
         result.element_count := 0;
      end return;
   end make;

   function length (container : in map) return natural is
   begin
      return container.element_count;
   end length;

   function capacity (container : in map) return positive is
   begin
      if container.buckets = null then
         return container.min_capacity;
      end if;
      return container.buckets'length;
   end capacity;

   function is_empty (container : in map) return boolean is
   begin
      return container.element_count = 0;
   end is_empty;

   function contains
     (container : in map; key : in key_type) return boolean
   is
      curr : node_access;
      idx  : natural;
      res  : boolean := false;
   begin
      if container.buckets /= null and then container.element_count > 0
      then
         idx := bucket_index (key, container.buckets'length);
         curr := container.buckets (idx);
         while curr /= null and then not res loop
            if are_keys_equal (curr.key, key) then
               res := true;
            else
               curr := curr.next;
            end if;
         end loop;
      end if;
      return res;
   end contains;

   function get
     (container : in map; key : in key_type) return element_type
   is
      curr  : node_access;
      res   : element_type;
      idx   : natural;
      found : boolean := false;
   begin
      if container.buckets /= null then
         idx := bucket_index (key, container.buckets'length);
         curr := container.buckets (idx);
         while curr /= null loop
            if are_keys_equal (curr.key, key) then
               res := curr.element;
               found := true;
               curr := null;
            else
               curr := curr.next;
            end if;
         end loop;
      end if;
      if not found then
         raise key_error with "key not present in hash table";
      end if;
      return res;
   end get;

   procedure insert
     (container : in out map;
      key       : in key_type;
      element   : in element_type)
   is
      idx     : natural;
      curr    : node_access;
      updated : boolean := false;
   begin
      if container.buckets = null then
         container.buckets :=
           new bucket_array (0 .. container.min_capacity - 1);
      end if;

      idx := bucket_index (key, container.buckets'length);
      curr := container.buckets (idx);
      while curr /= null and then not updated loop
         if are_keys_equal (curr.key, key) then
            curr.element := element;
            updated := true;
         else
            curr := curr.next;
         end if;
      end loop;

      if not updated then
         container.buckets (idx) :=
           new node'
             (key     => key,
              element => element,
              next    => container.buckets (idx));
         container.element_count := container.element_count + 1;

         if (container.element_count * 100)
           >= (container.buckets'length * container.expand_pct)
         then
            resize (container, container.buckets'length * 2);
         end if;
      end if;
   end insert;

   procedure delete (container : in out map; key : in key_type) is
      idx       : natural;
      curr      : node_access;
      prev      : node_access := null;
      to_delete : node_access := null;
      new_cap   : positive;
   begin
      if container.buckets = null or else container.element_count = 0
      then
         return;
      end if;

      idx := bucket_index (key, container.buckets'length);
      curr := container.buckets (idx);
      while curr /= null and then to_delete = null loop
         if are_keys_equal (curr.key, key) then
            to_delete := curr;
         else
            prev := curr;
            curr := curr.next;
         end if;
      end loop;

      if to_delete /= null then
         if prev = null then
            container.buckets (idx) := to_delete.next;
         else
            prev.next := to_delete.next;
         end if;
         free_node (to_delete);
         container.element_count := container.element_count - 1;

         if container.buckets'length > container.min_capacity
           and then (container.element_count * 100)
                    < (container.buckets'length * container.shrink_pct)
         then
            new_cap := container.buckets'length / 2;
            if new_cap < container.min_capacity then
               new_cap := container.min_capacity;
            end if;
            if new_cap /= container.buckets'length then
               resize (container, new_cap);
            end if;
         end if;
      end if;
   end delete;

   procedure resize (container : in out map; new_capacity : in positive)
   is
      old_buckets : bucket_array_access := container.buckets;
      b_idx       : natural;
      curr        : node_access;
      next_node   : node_access;
      target_idx  : natural;
   begin
      container.buckets := new bucket_array (0 .. new_capacity - 1);
      if old_buckets /= null then
         b_idx := 0;
         while b_idx <= old_buckets'last loop
            curr := old_buckets (b_idx);
            while curr /= null loop
               next_node := curr.next;
               target_idx := bucket_index (curr.key, new_capacity);
               curr.next := container.buckets (target_idx);
               container.buckets (target_idx) := curr;
               curr := next_node;
            end loop;
            b_idx := b_idx + 1;
         end loop;
         free_buckets (old_buckets);
      end if;
   end resize;

   procedure clear (container : in out map) is
   begin
      release (container);
      container.buckets :=
        new bucket_array (0 .. container.min_capacity - 1);
      container.element_count := 0;
   end clear;

   procedure release (container : in out map) is
   begin
      if container.buckets /= null then
         declare
            i : natural := container.buckets'first;
         begin
            while i <= container.buckets'last loop
               while container.buckets (i) /= null loop
                  declare
                     tmp : node_access := container.buckets (i);
                  begin
                     container.buckets (i) := tmp.next;
                     free_node (tmp);
                  end;
               end loop;
               i := i + 1;
            end loop;
         end;
         free_buckets (container.buckets);
         container.buckets := null;
      end if;
      container.element_count := 0;
   end release;

   overriding
   procedure finalize (container : in out map) is
   begin
      release (container);
   end finalize;

end hash_tables;
