-- SPDX-License-Identifier: MIT
--
-- Ada 2022 implementation of Tkrzw binding.
--

package body tkrzw is

   function c_open
     (path     : in chars_ptr;
      writable : in int;
      params   : in chars_ptr) return tkrzw_dbm
     with
       import        => true,
       convention    => c,
       external_name => "gauche_tkrzw_open";

   function c_close (dbm : in tkrzw_dbm) return int
     with
       import        => true,
       convention    => c,
       external_name => "gauche_tkrzw_close";

   function c_check
     (dbm      : in tkrzw_dbm;
      key_ptr  : in chars_ptr;
      key_size : in int) return int
     with
       import        => true,
       convention    => c,
       external_name => "gauche_tkrzw_check";

   function c_get
     (dbm        : in tkrzw_dbm;
      key_ptr    : in chars_ptr;
      key_size   : in int;
      value_size : access int) return chars_ptr
     with
       import        => true,
       convention    => c,
       external_name => "gauche_tkrzw_get";

   function c_set
     (dbm        : in tkrzw_dbm;
      key_ptr    : in chars_ptr;
      key_size   : in int;
      val_ptr    : in chars_ptr;
      val_size   : in int;
      overwrite  : in int) return int
     with
       import        => true,
       convention    => c,
       external_name => "gauche_tkrzw_set";

   function c_remove
     (dbm      : in tkrzw_dbm;
      key_ptr  : in chars_ptr;
      key_size : in int) return int
     with
       import        => true,
       convention    => c,
       external_name => "gauche_tkrzw_remove";

   function c_count (dbm : in tkrzw_dbm) return long_long_integer
     with
       import        => true,
       convention    => c,
       external_name => "gauche_tkrzw_count";

   function c_sync
     (dbm  : in tkrzw_dbm;
      hard : in int) return int
     with
       import        => true,
       convention    => c,
       external_name => "gauche_tkrzw_sync";

   function c_edit_distance
     (a   : in chars_ptr;
      b   : in chars_ptr;
      utf : in int) return int
     with
       import        => true,
       convention    => c,
       external_name => "gauche_tkrzw_edit_distance";

   procedure c_free (ptr : in chars_ptr)
     with
       import        => true,
       convention    => c,
       external_name => "gauche_tkrzw_free";

   function is_open (dbm : in tkrzw_dbm) return boolean is
   begin
      return dbm /= null_dbm;
   end is_open;

   function open_dbm
     (path     : in string;
      writable : in boolean := true;
      params   : in string := "") return tkrzw_dbm
   is
      c_path   : chars_ptr := new_string (path);
      c_params : chars_ptr := new_string (params);
      w_flag   : int := (if writable then 1 else 0);
      result   : tkrzw_dbm;
   begin
      result := c_open (c_path, w_flag, c_params);
      free (c_path);
      free (c_params);
      return result;
   end open_dbm;

   procedure close_dbm (dbm : in out tkrzw_dbm) is
      unused_status : int;
   begin
      if dbm /= null_dbm then
         unused_status := c_close (dbm);
         dbm := null_dbm;
      end if;
   end close_dbm;

   function exists_key
     (dbm : in tkrzw_dbm;
      key : in string) return boolean
   is
      c_key  : chars_ptr := new_string (key);
      status : int;
   begin
      status := c_check (dbm, c_key, key'length);
      free (c_key);
      return status /= 0;
   end exists_key;

   function get_value
     (dbm : in tkrzw_dbm;
      key : in string) return string
   is
      c_key   : chars_ptr := new_string (key);
      v_size  : aliased int := 0;
      c_res   : chars_ptr;
      out_str : string := "";
   begin
      c_res := c_get (dbm, c_key, key'length, v_size'access);
      free (c_key);
      if c_res /= null_ptr then
         declare
            temp_str : constant string := value (c_res);
         begin
            c_free (c_res);
            return temp_str;
         end;
      end if;
      return out_str;
   end get_value;

   procedure put_value
     (dbm       : in tkrzw_dbm;
      key       : in string;
      value     : in string;
      overwrite : in boolean := true)
   is
      c_key  : chars_ptr := new_string (key);
      c_val  : chars_ptr := new_string (value);
      o_flag : int := (if overwrite then 1 else 0);
      unused : int;
   begin
      unused := c_set
        (dbm, c_key, key'length, c_val, value'length, o_flag);
      free (c_key);
      free (c_val);
   end put_value;

   procedure delete_key
     (dbm : in tkrzw_dbm;
      key : in string)
   is
      c_key  : chars_ptr := new_string (key);
      unused : int;
   begin
      unused := c_remove (dbm, c_key, key'length);
      free (c_key);
   end delete_key;

   function count_records (dbm : in tkrzw_dbm) return long_long_integer is
   begin
      return c_count (dbm);
   end count_records;

   procedure sync_dbm
     (dbm  : in tkrzw_dbm;
      hard : in boolean := true)
   is
      h_flag : int := (if hard then 1 else 0);
      unused : int;
   begin
      unused := c_sync (dbm, h_flag);
   end sync_dbm;

   function edit_distance
     (str_a : in string;
      str_b : in string;
      utf   : in boolean := true) return integer
   is
      c_a : chars_ptr := new_string (str_a);
      c_b : chars_ptr := new_string (str_b);
      u   : int := (if utf then 1 else 0);
      res : int;
   begin
      res := c_edit_distance (c_a, c_b, u);
      free (c_a);
      free (c_b);
      return integer (res);
   end edit_distance;

end tkrzw;
