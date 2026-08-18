-- database.adb
--
-- SPDX-License-Identifier: MIT
--
-- Implementation of the high-performance database interface.

with system; use system;
with ada.directories;
with ada.finalization;
with ada.strings.unbounded; use ada.strings.unbounded;
with ada.unchecked_deallocation;
with interfaces.c;
with interfaces.c.strings;

package body database is

   use interfaces.c;
   use interfaces.c.strings;

   -- Internal C Interface Imports
   function c_build_from_ls_r (path : in chars_ptr) return int
   with
     Import        => True,
     Convention    => C,
     External_Name => "gauche_iris_db_build_from_ls_r";

   function c_open
     (path     : in chars_ptr;
      writable : in int;
      params   : in chars_ptr) return system.address
   with
     Import        => True,
     Convention    => C,
     External_Name => "gauche_tkrzw_open";

   function c_close (db : in system.address) return int
   with
     Import        => True,
     Convention    => C,
     External_Name => "gauche_tkrzw_close";

   function c_check
     (db       : in system.address;
      key_ptr  : in chars_ptr;
      key_size : in int) return int
   with
     Import        => True,
     Convention    => C,
     External_Name => "gauche_tkrzw_check";

   function c_get
     (db         : in system.address;
      key_ptr    : in chars_ptr;
      key_size   : in int;
      value_size : access int) return chars_ptr
   with
     Import        => True,
     Convention    => C,
     External_Name => "gauche_tkrzw_get";

   function c_set
     (db        : in system.address;
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
     (db       : in system.address;
      key_ptr  : in chars_ptr;
      key_size : in int) return int
   with
     Import        => True,
     Convention    => C,
     External_Name => "gauche_tkrzw_remove";

   function c_count (db : in system.address) return long_long_integer
   with
     Import        => True,
     Convention    => C,
     External_Name => "gauche_tkrzw_count";

   function c_sync
     (db   : in system.address;
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

   procedure c_free (ptr : in system.address)
   with
     Import        => True,
     Convention    => C,
     External_Name => "gauche_tkrzw_free";

   procedure free_core is new ada.unchecked_deallocation
     (object => db_core, name => db_core_ptr);

   -- Controlled Lifecycle Overrides
   procedure initialize (db : in out database_type) is
   begin
      null;
   end initialize;

   procedure adjust (db : in out database_type) is
   begin
      if db.core /= null then
         db.core.ref_count := db.core.ref_count + 1;
      end if;
   end adjust;

   procedure finalize (db : in out database_type) is
      status : int := 0;
   begin
      if db.core /= null then
         db.core.ref_count := db.core.ref_count - 1;
         if db.core.ref_count = 0 then
            if db.core.handle /= system.null_address then
               status := c_close (db.core.handle);
               db.core.handle := system.null_address;
            end if;
            free_core (db.core);
         end if;
         db.core := null;
      end if;
   end finalize;

   -- Helper to determine writable flag
   function is_writable_mode (mode : in open_mode) return int is
      result : int := 0;
   begin
      if mode /= read_only then
         result := 1;
      end if;
      return result;
   end is_writable_mode;

   procedure ensure_database_exists (path_str : in string) is
      c_path : chars_ptr := null_ptr;
      status : int       := 0;
   begin
      if not ada.directories.exists (path_str) then
         c_path := new_string (path_str);
         status := c_build_from_ls_r (c_path);
         free (c_path);
      end if;
   end ensure_database_exists;

   function db_open
     (path   : in unbounded_string;
      mode   : in open_mode := read_only;
      params : in unbounded_string := null_unbounded_string)
      return database_type
   is
      path_str : constant string  := to_string (path);
      par_str  : constant string  := to_string (params);
      c_path   : chars_ptr        := null_ptr;
      c_params : chars_ptr        := null_ptr;
      writable : constant int     := is_writable_mode (mode);
      raw_ptr  : system.address   := system.null_address;
      result   : database_type;
   begin
      ensure_database_exists (path_str);
      c_path := new_string (path_str);
      c_params := new_string (par_str);
      raw_ptr := c_open (c_path, writable, c_params);
      free (c_path);
      free (c_params);
      if raw_ptr /= system.null_address then
         result.core := new db_core'
           (handle    => raw_ptr,
            path      => path,
            ref_count => 1);
      end if;
      return result;
   end db_open;

   function db_open
     (path   : in string;
      mode   : in open_mode := read_only;
      params : in string := "") return database_type is
   begin
      return db_open
        (path   => to_unbounded_string (path),
         mode   => mode,
         params => to_unbounded_string (params));
   end db_open;

   procedure db_close (db : in out database_type) is
      status : int := 0;
   begin
      if db.core /= null then
         if db.core.handle /= system.null_address then
            status := c_close (db.core.handle);
            db.core.handle := system.null_address;
         end if;
      end if;
   end db_close;

   function db_is_open (db : in database_type) return boolean is
   begin
      return db.core /= null
        and then db.core.handle /= system.null_address;
   end db_is_open;

   function db_is_closed (db : in database_type) return boolean is
   begin
      return db.core = null
        or else db.core.handle = system.null_address;
   end db_is_closed;

   function db_get_path
     (db : in database_type) return unbounded_string is
   begin
      if db.core /= null then
         return db.core.path;
      else
         return null_unbounded_string;
      end if;
   end db_get_path;

   function db_get_path (db : in database_type) return string is
   begin
      return to_string (db_get_path (db));
   end db_get_path;

   function db_exists
     (db  : in database_type;
      key : in unbounded_string) return boolean
   is
      key_str : constant string := to_string (key);
      c_key   : chars_ptr       := new_string (key_str);
      status  : int             := 0;
      result  : boolean         := false;
   begin
      if db_is_open (db) then
         status := c_check
           (db.core.handle,
            c_key,
            int (key_str'length));
         result := (status /= 0);
      end if;
      free (c_key);
      return result;
   end db_exists;

   function db_exists
     (db  : in database_type;
      key : in string) return boolean is
   begin
      return db_exists (db, to_unbounded_string (key));
   end db_exists;

   function fetch_c_unbounded
     (handle  : in system.address;
      c_key   : in chars_ptr;
      len     : in int;
      default : in unbounded_string) return unbounded_string
   is
      val_len : aliased int := 0;
      val_ptr : chars_ptr   := null_ptr;
   begin
      val_ptr := c_get (handle, c_key, len, val_len'access);
      if val_ptr /= null_ptr then
         declare
            str_val : constant string := value (val_ptr);
         begin
            free (val_ptr);
            return to_unbounded_string (str_val);
         end;
      end if;
      return default;
   end fetch_c_unbounded;

   function db_get
     (db      : in database_type;
      key     : in unbounded_string;
      default : in unbounded_string := null_unbounded_string)
      return unbounded_string
   is
      key_str : constant string := to_string (key);
      c_key   : chars_ptr       := new_string (key_str);
   begin
      if db_is_closed (db) then
         free (c_key);
         return default;
      end if;

      declare
         val : constant unbounded_string :=
           fetch_c_unbounded
             (db.core.handle,
              c_key,
              int (key_str'length),
              default);
      begin
         free (c_key);
         return val;
      end;
   end db_get;

   function db_get
     (db      : in database_type;
      key     : in string;
      default : in string := "") return string is
   begin
      return to_string
        (db_get
           (db      => db,
            key     => to_unbounded_string (key),
            default => to_unbounded_string (default)));
   end db_get;

   procedure db_set
     (db        : in out database_type;
      key       : in unbounded_string;
      value     : in unbounded_string;
      overwrite : in boolean := true)
   is
      key_str : constant string := to_string (key);
      val_str : constant string := to_string (value);
      c_key   : chars_ptr       := new_string (key_str);
      c_val   : chars_ptr       := new_string (val_str);
      ow_int  : constant int    := (if overwrite then 1 else 0);
      status  : int             := 0;
   begin
      if db_is_open (db) then
         status := c_set
           (db.core.handle,
            c_key,
            int (key_str'length),
            c_val,
            int (val_str'length),
            ow_int);
      end if;
      free (c_key);
      free (c_val);
   end db_set;

   procedure db_set
     (db        : in out database_type;
      key       : in string;
      value     : in string;
      overwrite : in boolean := true) is
   begin
      db_set
        (db        => db,
         key       => to_unbounded_string (key),
         value     => to_unbounded_string (value),
         overwrite => overwrite);
   end db_set;

   procedure db_remove
     (db  : in out database_type;
      key : in unbounded_string)
   is
      key_str : constant string := to_string (key);
      c_key   : chars_ptr       := new_string (key_str);
      status  : int             := 0;
   begin
      if db_is_open (db) then
         status := c_remove
           (db.core.handle,
            c_key,
            int (key_str'length));
      end if;
      free (c_key);
   end db_remove;

   procedure db_remove
     (db  : in out database_type;
      key : in string) is
   begin
      db_remove (db, to_unbounded_string (key));
   end db_remove;

   function db_count (db : in database_type) return long_long_integer is
      result : long_long_integer := 0;
   begin
      if db_is_open (db) then
         result := c_count (db.core.handle);
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
      if db_is_open (db) then
         status := c_sync (db.core.handle, hard_int);
      end if;
   end db_sync;

   function db_edit_distance
     (str_a : in unbounded_string;
      str_b : in unbounded_string;
      utf   : in boolean := true) return integer
   is
      sa_str  : constant string := to_string (str_a);
      sb_str  : constant string := to_string (str_b);
      c_a     : chars_ptr       := new_string (sa_str);
      c_b     : chars_ptr       := new_string (sb_str);
      utf_int : constant int    := (if utf then 1 else 0);
      dist    : int             := 0;
   begin
      dist := c_edit_distance (c_a, c_b, utf_int);
      free (c_a);
      free (c_b);
      return integer (dist);
   end db_edit_distance;

   function db_edit_distance
     (str_a : in string;
      str_b : in string;
      utf   : in boolean := true) return integer is
   begin
      return db_edit_distance
        (str_a => to_unbounded_string (str_a),
         str_b => to_unbounded_string (str_b),
         utf   => utf);
   end db_edit_distance;

   -- C-Compatible FFI Implementation
   function iris_db_open
     (path     : in chars_ptr;
      writable : in int;
      params   : in chars_ptr) return system.address is
   begin
      return c_open (path, writable, params);
   end iris_db_open;

   function iris_db_close (db : in system.address) return int is
   begin
      return c_close (db);
   end iris_db_close;

   function iris_db_check
     (db       : in system.address;
      key_ptr  : in chars_ptr;
      key_size : in int) return int is
   begin
      return c_check (db, key_ptr, key_size);
   end iris_db_check;

   function iris_db_get
     (db         : in system.address;
      key_ptr    : in chars_ptr;
      key_size   : in int;
      value_size : access int) return chars_ptr is
   begin
      return c_get (db, key_ptr, key_size, value_size);
   end iris_db_get;

   function iris_db_set
     (db        : in system.address;
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
     (db       : in system.address;
      key_ptr  : in chars_ptr;
      key_size : in int) return int is
   begin
      return c_remove (db, key_ptr, key_size);
   end iris_db_remove;

   function iris_db_count
     (db : in system.address) return long_long_integer is
   begin
      return c_count (db);
   end iris_db_count;

   function iris_db_sync
     (db   : in system.address;
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

   procedure iris_db_free (ptr : in system.address) is
   begin
      c_free (ptr);
   end iris_db_free;

end database;
