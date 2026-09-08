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

with interfaces.c; use interfaces.c;
with ada.finalization;
with ada.unchecked_deallocation;
with ada.containers;

package body hash_tables is

   ---------------------------------------------------------------------

   type ssize_t is
     range -(2**(size_t'size - 1)) .. 2**(size_t'size - 1) - 1
   with convention => c;

   function parallel_search_u32x16
     (keys   : in out uint32_array;
      count  : in size_t;
      target : in uint32_t) return ssize_t
   with
     import        => true,
     convention    => c,
     external_name => "parallel_search_u32x16";

   function new_uint32_array
     (capacity : in count_type; default_value : in uint32_t)
      return uint32_array_access
   with
     pre  => (1 <= capacity),
     post =>
       (new_uint32_array'result'first = 0
        and new_uint32_array'result'last = size_t (capacity) - 1)
   is
   begin
      return
         p : uint32_array_access :=
           new uint32_array (0 .. size_t (capacity) - 1)
      do
         for i in p'range loop
            p (i) := default_value;
         end loop;
      end return;
   end new_uint32_array;

   procedure deallocate is new
     ada.unchecked_deallocation
       (object => uint32_array,
        name   => uint32_array_access);

   procedure reallocate
     (container     : in out uint32_array_access;
      new_capacity  : in count_type;
      default_value : in uint32_t)
   with
     pre  => (1 <= new_capacity),
     post =>
       (container'first = 0
        and container'last = size_t (new_capacity) - 1)
   is
      old_capacity  : constant count_type :=
        count_type (container'length);
      new_container : uint32_array_access;
   begin
      if old_capacity < new_capacity then
         new_container :=
           new_uint32_array (new_capacity, default_value);
         for i in container'first .. container'last loop
            new_container (i) := container (i);
         end loop;
         deallocate (container);
         container := new_container;
      elsif new_capacity < old_capacity then
         -- This would allocate a smaller array and defragment the
         -- contents.
         raise constraint_error
           with "shrinking a hash table is not yet supported";
      end if;
   end reallocate;

   ---------------------------------------------------------------------

   sentinel_hash : constant hash_type := hash_type (0);

   function hash_table
     (initial_capacity : in count_type := default_initial_capacity)
      return table is
   begin
      return result : table do
         result.hashes :=
           new_uint32_array
             (initial_capacity, uint32_t (sentinel_hash));
         result.element_capacity := initial_capacity;
         result.element_count := 0;
      end return;
   end hash_table;

   overriding
   procedure finalize (container : in out table) is
   begin
      deallocate (container.hashes);
   -- FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME FIXME
   end finalize;

   function length (container : in table) return count_type
   is (container.element_count);

   function capacity (container : in table) return count_type
   is (container.element_capacity);

   function is_empty (container : in table) return boolean
   is (container.element_count = 0);

   ---------------------------------------------------------------------

   ---   procedure free_node is new
   ---     ada.unchecked_deallocation (object => node, name => node_access);
   ---
   ---   procedure free_buckets is new
   ---     ada.unchecked_deallocation
   ---       (object => bucket_array,
   ---        name   => bucket_array_access);
   ---
   ---   procedure resize
   ---     (container : in out table; new_capacity : in count_type);
   ---
   ---   procedure release (container : in out table);
   ---
   ---   function bucket_index
   ---     (key : in key_type; table_size : in count_type) return natural
   ---     is (natural (hash (key) mod hash_type (table_size)));
   ---
   ---   function hash_table
   ---     (initial_capacity : in count_type := default_initial_capacity)
   ---     return table is
   ---   begin
   ---      return result : table do
   ---         result.min_capacity := initial_capacity;
   ---         result.buckets :=
   ---           new bucket_array (0 .. positive (initial_capacity) - 1);
   ---         result.element_count := 0;
   ---      end return;
   ---   end hash_table;
   ---
   ---   function length (container : in table) return count_type
   ---     is (count_type (container.element_count));
   ---
   ---   function capacity (container : in table) return count_type
   ---     is (if container.buckets = null
   ---         then count_type (container.min_capacity)
   ---         else count_type (container.buckets'length));
   ---
   ---   function is_empty (container : in table) return boolean
   ---     is (container.element_count = 0);
   ---
   ---   function contains
   ---     (container : in table; key : in key_type) return boolean
   ---   is
   ---      current : node_access;
   ---      index   : natural;
   ---      result  : boolean := false;
   ---   begin
   ---      if container.buckets /= null and container.element_count > 0 then
   ---         index := bucket_index (key, container.buckets'length);
   ---         current := container.buckets (index);
   ---         while current /= null and not result loop
   ---            if are_keys_equal (current.key, key) then
   ---               result := true;
   ---            else
   ---               current := current.next;
   ---            end if;
   ---         end loop;
   ---      end if;
   ---      return result;
   ---   end contains;
   ---
   ---   function element
   ---     (container : in table; key : in key_type) return element_type
   ---   is
   ---      current : node_access;
   ---      result  : element_type;
   ---      index   : natural;
   ---      found   : boolean := false;
   ---   begin
   ---      if container.buckets /= null then
   ---         index := bucket_index (key, container.buckets'length);
   ---         current := container.buckets (index);
   ---         while current /= null loop
   ---            if are_keys_equal (current.key, key) then
   ---               result := current.element;
   ---               found := true;
   ---               current := null;
   ---            else
   ---               current := current.next;
   ---            end if;
   ---         end loop;
   ---      end if;
   ---      if not found then
   ---         raise key_error with "key not present in hash table";
   ---      end if;
   ---      return result;
   ---   end element;
   ---
   ---   procedure include
   ---     (container : in out table;
   ---      key       : in key_type;
   ---      new_item  : in element_type)
   ---   is
   ---      index   : natural;
   ---      current : node_access;
   ---      updated : boolean := false;
   ---   begin
   ---      if container.buckets = null then
   ---         container.buckets :=
   ---           new bucket_array
   ---             (0 .. positive (container.min_capacity) - 1);
   ---      end if;
   ---
   ---      index := bucket_index (key, container.buckets'length);
   ---      current := container.buckets (index);
   ---      while current /= null and then not updated loop
   ---         if are_keys_equal (current.key, key) then
   ---            current.element := new_item;
   ---            updated := true;
   ---         else
   ---            current := current.next;
   ---         end if;
   ---      end loop;
   ---
   ---      if not updated then
   ---         container.buckets (index) :=
   ---           new node'
   ---                     (key     => key,
   ---                      element => new_item,
   ---                      next    => container.buckets (index));
   ---         container.element_count := container.element_count + 1;
   ---
   ---         if (container.element_count * 100)
   ---            >= (container.buckets'length * container.expand_pct)
   ---         then
   ---            resize (container, container.buckets'length * 2);
   ---         end if;
   ---      end if;
   ---   end include;
   ---
   ---   procedure delete (container : in out table; key : in key_type) is
   ---      index     : natural;
   ---      current   : node_access;
   ---      prev      : node_access := null;
   ---      to_delete : node_access := null;
   ---      new_cap   : count_type;
   ---   begin
   ---      if container.buckets = null or container.element_count = 0 then
   ---         null;
   ---      else
   ---         index := bucket_index (key, container.buckets'length);
   ---         current := container.buckets (index);
   ---         while current /= null and to_delete = null loop
   ---            if are_keys_equal (current.key, key) then
   ---               to_delete := current;
   ---            else
   ---               prev := current;
   ---               current := current.next;
   ---            end if;
   ---         end loop;
   ---
   ---         if to_delete /= null then
   ---            if prev = null then
   ---               container.buckets (index) := to_delete.next;
   ---            else
   ---               prev.next := to_delete.next;
   ---            end if;
   ---            free_node (to_delete);
   ---            container.element_count := container.element_count - 1;
   ---
   ---            if container.buckets'length > container.min_capacity
   ---               and then (container.element_count * 100)
   ---               < (container.buckets'length
   ---                                      * container.shrink_pct)
   ---            then
   ---               new_cap := container.buckets'length / 2;
   ---               if new_cap < container.min_capacity then
   ---                  new_cap := container.min_capacity;
   ---               end if;
   ---               if new_cap /= container.buckets'length then
   ---                  resize (container, new_cap);
   ---               end if;
   ---            end if;
   ---         end if;
   ---      end if;
   ---   end delete;
   ---
   ---   procedure resize
   ---     (container : in out table; new_capacity : in count_type)
   ---   is
   ---      old_buckets  : bucket_array_access := container.buckets;
   ---      b_index      : natural;
   ---      current      : node_access;
   ---      next_node    : node_access;
   ---      target_index : natural;
   ---   begin
   ---      container.buckets :=
   ---        new bucket_array (0 .. positive (new_capacity) - 1);
   ---      if old_buckets /= null then
   ---         b_index := 0;
   ---         while b_index <= old_buckets'last loop
   ---            current := old_buckets (b_index);
   ---            while current /= null loop
   ---               next_node := current.next;
   ---               target_index := bucket_index (current.key, new_capacity);
   ---               current.next := container.buckets (target_index);
   ---               container.buckets (target_index) := current;
   ---               current := next_node;
   ---            end loop;
   ---            b_index := @ + 1;
   ---         end loop;
   ---         free_buckets (old_buckets);
   ---      end if;
   ---   end resize;
   ---
   ---   procedure clear (container : in out table) is
   ---   begin
   ---      release (container);
   ---      container.buckets :=
   ---        new bucket_array (0 .. positive (container.min_capacity) - 1);
   ---      container.element_count := 0;
   ---   end clear;
   ---
   ---   procedure release (container : in out table) is
   ---   begin
   ---      if container.buckets /= null then
   ---         declare
   ---            i : natural := container.buckets'first;
   ---         begin
   ---            while i <= container.buckets'last loop
   ---               while container.buckets (i) /= null loop
   ---                  declare
   ---                     tmp : node_access := container.buckets (i);
   ---                  begin
   ---                     container.buckets (i) := tmp.next;
   ---                     free_node (tmp);
   ---                  end;
   ---               end loop;
   ---               i := @ + 1;
   ---            end loop;
   ---         end;
   ---         free_buckets (container.buckets);
   ---         container.buckets := null;
   ---      end if;
   ---      container.element_count := 0;
   ---   end release;
   ---
   ---   overriding
   ---   procedure finalize (container : in out table) is
   ---   begin
   ---      release (container);
   ---   end finalize;

end hash_tables;
