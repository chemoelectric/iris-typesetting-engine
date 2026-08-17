-- database.ads
--
-- SPDX-License-Identifier: MIT
--
-- Specification of the high-performance database interface.

with System;
with Interfaces.C;
with Interfaces.C.Strings;

package database is

   use Interfaces.C;
   use Interfaces.C.Strings;

   type database_type is private;
   null_database : constant database_type;

   type open_mode is
     (read_only,
      read_write,
      create_new,
      truncate_existing);

   function db_open
     (path   : in string;
      mode   : in open_mode := read_only;
      params : in string := "") return database_type
   with
     Pre  => path'length > 0,
     Post => (if db_is_open (db_open'result) then
                db_get_path (db_open'result)'length >= 0);

   procedure db_close (db : in out database_type)
   with
     Post => db_is_closed (db);

   function db_is_open (db : in database_type) return boolean;

   function db_is_closed (db : in database_type) return boolean;

   function db_get_path (db : in database_type) return string;

   function db_exists
     (db  : in database_type;
      key : in string) return boolean
   with
     Pre => db_is_open (db) and then key'length > 0;

   function db_get
     (db      : in database_type;
      key     : in string;
      default : in string := "") return string
   with
     Pre => db_is_open (db) and then key'length > 0;

   procedure db_set
     (db        : in out database_type;
      key       : in string;
      value     : in string;
      overwrite : in boolean := true)
   with
     Pre => db_is_open (db) and then key'length > 0;

   procedure db_remove
     (db  : in out database_type;
      key : in string)
   with
     Pre => db_is_open (db) and then key'length > 0;

   function db_count
     (db : in database_type) return long_long_integer
   with
     Pre  => db_is_open (db),
     Post => db_count'result >= 0;

   procedure db_sync
     (db   : in out database_type;
      hard : in boolean := false)
   with
     Pre => db_is_open (db);

   function db_edit_distance
     (str_a : in string;
      str_b : in string;
      utf   : in boolean := true) return integer
   with
     Post => db_edit_distance'result >= 0;

   -- C Foreign Function Interface Exports
   function iris_db_open
     (path     : in chars_ptr;
      writable : in int;
      params   : in chars_ptr) return database_type
   with
     Export        => True,
     Convention    => C,
     External_Name => "iris_db_open";

   function iris_db_close (db : in database_type) return int
   with
     Export        => True,
     Convention    => C,
     External_Name => "iris_db_close";

   function iris_db_check
     (db       : in database_type;
      key_ptr  : in chars_ptr;
      key_size : in int) return int
   with
     Export        => True,
     Convention    => C,
     External_Name => "iris_db_check";

   function iris_db_get
     (db         : in database_type;
      key_ptr    : in chars_ptr;
      key_size   : in int;
      value_size : access int) return chars_ptr
   with
     Export        => True,
     Convention    => C,
     External_Name => "iris_db_get";

   function iris_db_set
     (db        : in database_type;
      key_ptr   : in chars_ptr;
      key_size  : in int;
      val_ptr   : in chars_ptr;
      val_size  : in int;
      overwrite : in int) return int
   with
     Export        => True,
     Convention    => C,
     External_Name => "iris_db_set";

   function iris_db_remove
     (db       : in database_type;
      key_ptr  : in chars_ptr;
      key_size : in int) return int
   with
     Export        => True,
     Convention    => C,
     External_Name => "iris_db_remove";

   function iris_db_count
     (db : in database_type) return long_long_integer
   with
     Export        => True,
     Convention    => C,
     External_Name => "iris_db_count";

   function iris_db_sync
     (db   : in database_type;
      hard : in int) return int
   with
     Export        => True,
     Convention    => C,
     External_Name => "iris_db_sync";

   function iris_db_edit_distance
     (str_a : in chars_ptr;
      str_b : in chars_ptr;
      utf   : in int) return int
   with
     Export        => True,
     Convention    => C,
     External_Name => "iris_db_edit_distance";

   procedure iris_db_free (ptr : in System.Address)
   with
     Export        => True,
     Convention    => C,
     External_Name => "iris_db_free";

private

   type database_type is new System.Address;
   null_database : constant database_type :=
     database_type (System.Null_Address);

end database;
