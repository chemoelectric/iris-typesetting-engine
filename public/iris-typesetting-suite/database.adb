-- database.adb
--
-- SPDX-License-Identifier: MIT
--
-- Implementation of the high-performance database interface.

with System;
with Interfaces.C;
with Interfaces.C.Strings;

package body database is

   use Interfaces.C;
   use Interfaces.C.Strings;

   -- Internal C Interface Imports
   function c_open
     (path     : in chars_ptr;
      writable : in int;
      params   : in chars_ptr) return database_type
   with
     Import        => True,
     Convention    => C,
     External_Name => "gauche_tkrzw_open";

   function c_close (db : in database_type) return int
   with
     Import        => True,
     Convention    => C,
     External_Name => "gauche_tkrzw_close";

   function c_check
     (db       : in database_type;
      key_ptr  : in chars_ptr;
      key_size : in int) return int
   with
     Import        => True,
     Convention    => C,
     External_Name => "gauche_tkrzw_check";

   function c_get
     (db         : in database_type;
      key_ptr    : in chars_ptr;
      key_size   : in int;
      value_size : access int) return chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "gauche_tkrzw_get";

   function c_set
     (db        : in database_type;
      key_ptr   : in chars_ptr;
      key_size  : in int;
      val_ptr   : in chars_ptr;
      val_size  : in int;
      overwrite : in int) return int
   with
     Import        => True,
     Convention    => C,
     External_Name => "gauche_tkrzw_set";

   function c_remove
     (db       : in database_type;
      key_ptr  : in chars_ptr;
      key_size : in int) return int
   with
     Import        => True,
     Convention    => C,
     External_Name => "gauche_tkrzw_remove";

   function c_count (db : in database_type) return long_long_integer
   with
     Import        => True,
     Convention    => C,
     External_Name => "gauche_tkrzw_count";

   function c_sync
     (db   : in database_type;
      hard : in int) return int
   with
     Import        => True,
     Convention    => C,
     External_Name => "gauche_tkrzw_sync";

   function c_edit_distance
     (str_a : in chars_ptr;
      str_b : in chars_ptr;
      utf   : in int) return int
   with
     Import        => True,
     Convention    => C,
     External_Name => "gauche_tkrzw_edit_distance";

   procedure c_free (ptr : in System.Address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "gauche_tkrzw_free";

   -- Helper to determine writable flag
   function is_writable_mode (mode : in open_mode) return int is
      result : int := 0;
   begin
      if mode /= read_only then
         result := 1;
      end if;
      return result;
   end is_writable_mode;

   function db_open
     (path   : in string;
      mode   : in open_mode := read_only;
      params : in string := "") return database_type
   is
      c_path   : chars_ptr     := new_string (path);
      c_params : chars_ptr     := new_string (params);
      writable : constant int  := is_writable_mode (mode);
      result   : database_type := null_database;
   begin
      result := c_open (c_path, writable, c_params);
      free (c_path);
      free (c_params);
      return result;
   end db_open;

   procedure db_close (db : in out database_type) is
      status : int := 0;
   begin
      if db /= null_database then
         status := c_close (db);
         db     := null_database;
      end if;
   end db_close;

   function db_is_open (db : in database_type) return boolean is
   begin
      return db /= null_database;
   end db_is_open;

   function db_is_closed (db : in database_type) return boolean is
   begin
      return db = null_database;
   end db_is_closed;

   function db_get_path (db : in database_type) return string is
   begin
      return (if db /= null_database then "database" else "");
   end db_get_path;

   function db_exists
     (db  : in database_type;
      key : in string) return boolean
   is
      c_key  : chars_ptr := new_string (key);
      status : int       := 0;
      result : boolean   := false;
   begin
      if db /= null_database then
         status := c_check (db, c_key, int (key'length));
         result := (status /= 0);
      end if;
      free (c_key);
      return result;
   end db_exists;

   function fetch_c_value
     (db      : in database_type;
      c_key   : in chars_ptr;
      len     : in int;
      default : in string) return string
   is
      val_len : aliased int := 0;
      val_ptr : chars_ptr   := null_ptr;
      result  : string      := default;
   begin
      val_ptr := c_get (db, c_key, len, val_len'access);
      if val_ptr /= null_ptr then
         declare
            str_val : constant string := value (val_ptr);
         begin
            free (val_ptr);
            return str_val;
         end;
      end if;
      return result;
   end fetch_c_value;

   function db_get
     (db      : in database_type;
      key     : in string;
      default : in string := "") return string
   is
      c_key  : chars_ptr := new_string (key);
      result : string    := default;
   begin
      if db /= null_database then
         result := fetch_c_value (db, c_key, int (key'length), default);
      end if;
      free (c_key);
      return result;
   end db_get;

   procedure db_set
     (db        : in out database_type;
      key       : in string;
      value     : in string;
      overwrite : in boolean := true)
   is
      c_key  : chars_ptr     := new_string (key);
      c_val  : chars_ptr     := new_string (value);
      ow_int : constant int  := (if overwrite then 1 else 0);
      status : int           := 0;
   begin
      if db /= null_database then
         status := c_set
           (db,
            c_key,
            int (key'length),
            c_val,
            int (value'length),
            ow_int);
      end if;
      free (c_key);
      free (c_val);
   end db_set;

   procedure db_remove
     (db  : in out database_type;
      key : in string)
   is
      c_key  : chars_ptr := new_string (key);
      status : int       := 0;
   begin
      if db /= null_database then
         status := c_remove (db, c_key, int (key'length));
      end if;
      free (c_key);
   end db_remove;

   function db_count (db : in database_type) return long_long_integer is
      result : long_long_integer := 0;
   begin
      if db /= null_database then
         result := c_count (db);
      end if;
      return result;
   end db_count;

   procedure db_sync
     (db   : in out database_type;
      hard : in boolean := false)
   is
      hard_int : constant int := (if hard then 1 else 0);
      status   : int          := 0;
   begin
      if db /= null_database then
         status := c_sync (db, hard_int);
      end if;
   end db_sync;

   function db_edit_distance
     (str_a : in string;
      str_b : in string;
      utf   : in boolean := true) return integer
   is
      c_a     : chars_ptr    := new_string (str_a);
      c_b     : chars_ptr    := new_string (str_b);
      utf_int : constant int := (if utf then 1 else 0);
      dist    : int          := 0;
   begin
      dist := c_edit_distance (c_a, c_b, utf_int);
      free (c_a);
      free (c_b);
      return integer (dist);
   end db_edit_distance;

   -- C-Compatible FFI Implementation
   function iris_db_open
     (path     : in chars_ptr;
      writable : in int;
      params   : in chars_ptr) return database_type is
   begin
      return c_open (path, writable, params);
   end iris_db_open;

   function iris_db_close (db : in database_type) return int is
   begin
      return c_close (db);
   end iris_db_close;

   function iris_db_check
     (db       : in database_type;
      key_ptr  : in chars_ptr;
      key_size : in int) return int is
   begin
      return c_check (db, key_ptr, key_size);
   end iris_db_check;

   function iris_db_get
     (db         : in database_type;
      key_ptr    : in chars_ptr;
      key_size   : in int;
      value_size : access int) return chars_ptr is
   begin
      return c_get (db, key_ptr, key_size, value_size);
   end iris_db_get;

   function iris_db_set
     (db        : in database_type;
      key_ptr   : in chars_ptr;
      key_size  : in int;
      val_ptr   : in chars_ptr;
      val_size  : in int;
      overwrite : in int) return int is
   begin
      return c_set
        (db, key_ptr, key_size, val_ptr, val_size, overwrite);
   end iris_db_set;

   function iris_db_remove
     (db       : in database_type;
      key_ptr  : in chars_ptr;
      key_size : in int) return int is
   begin
      return c_remove (db, key_ptr, key_size);
   end iris_db_remove;

   function iris_db_count
     (db : in database_type) return long_long_integer is
   begin
      return c_count (db);
   end iris_db_count;

   function iris_db_sync
     (db   : in database_type;
      hard : in int) return int is
   begin
      return c_sync (db, hard);
   end iris_db_sync;

   function iris_db_edit_distance
     (str_a : in chars_ptr;
      str_b : in chars_ptr;
      utf   : in int) return int is
   begin
      return c_edit_distance (str_a, str_b, utf);
   end iris_db_edit_distance;

   procedure iris_db_free (ptr : in System.Address) is
   begin
      c_free (ptr);
   end iris_db_free;

end database;
