-- database.ads
--
-- SPDX-License-Identifier: MIT
--
-- Specification of the high-performance database interface.

with system;
with ada.finalization;
with ada.strings.unbounded; use ada.strings.unbounded;
with interfaces.c;
with interfaces.c.strings;

package database is

   use interfaces.c;
   use interfaces.c.strings;

   type database_type is new ada.finalization.controlled with private;
   null_database : constant database_type;

   type open_mode is
     (read_only,
      read_write,
      create_new,
      truncate_existing,
      create_or_truncate);

   -- TeXMF (kpsewhich / ls-R) and Fontconfig Database Builders
   procedure build_texmf_database
     (db_path : in string := "";
      count   : out natural);

   procedure build_texmf_database
     (db_path : in unbounded_string;
      count   : out natural);

   procedure build_fonts_database
     (db_path : in string := "";
      count   : out natural);

   procedure build_fonts_database
     (db_path : in unbounded_string;
      count   : out natural);

   procedure build_all_databases
     (texmf_count : out natural;
      fonts_count : out natural);

   function default_texmf_db_path return string;
   function default_texmf_db_path return unbounded_string;

   function default_fonts_db_path return string;
   function default_fonts_db_path return unbounded_string;

   -- Transparent Font and File Resolution API
   function find_font
     (font_name : in string) return string;

   function find_font
     (font_name : in unbounded_string) return unbounded_string;

   function find_texmf_file
     (file_name : in string) return string;

   function find_texmf_file
     (file_name : in unbounded_string) return unbounded_string;

   function find_file
     (file_name : in string) return string;

   function find_file
     (file_name : in unbounded_string) return unbounded_string;

   -- Unbounded String Primary API
   function db_open
     (path   : in unbounded_string;
      mode   : in open_mode := read_only;
      params : in unbounded_string := null_unbounded_string)
      return database_type
   with
     Pre  => length (path) > 0,
     Post => (if db_is_open (db_open'result) then
                length (db_get_path (db_open'result)) >= 0);

   function db_open
     (path   : in string;
      mode   : in open_mode := read_only;
      params : in string := "") return database_type
   with
     Pre  => path'length > 0,
     Post => (if db_is_open (db_open'result) then
                length (db_get_path (db_open'result)) >= 0);

   procedure db_close (db : in out database_type)
   with
     Post => db_is_closed (db);

   function db_is_open (db : in database_type) return boolean;

   function db_is_closed (db : in database_type) return boolean;

   function db_get_path
     (db : in database_type) return unbounded_string;

   function db_get_path (db : in database_type) return string;

   function db_exists
     (db  : in database_type;
      key : in unbounded_string) return boolean
   with
     Pre => db_is_open (db) and then length (key) > 0;

   function db_exists
     (db  : in database_type;
      key : in string) return boolean
   with
     Pre => db_is_open (db) and then key'length > 0;

   function db_get
     (db      : in database_type;
      key     : in unbounded_string;
      default : in unbounded_string := null_unbounded_string)
      return unbounded_string
   with
     Pre => db_is_open (db) and then length (key) > 0;

   function db_get
     (db      : in database_type;
      key     : in string;
      default : in string := "") return string
   with
     Pre => db_is_open (db) and then key'length > 0;

   procedure db_set
     (db        : in out database_type;
      key       : in unbounded_string;
      value     : in unbounded_string;
      overwrite : in boolean := true)
   with
     Pre => db_is_open (db) and then length (key) > 0;

   procedure db_set
     (db        : in out database_type;
      key       : in string;
      value     : in string;
      overwrite : in boolean := true)
   with
     Pre => db_is_open (db) and then key'length > 0;

   procedure db_remove
     (db  : in out database_type;
      key : in unbounded_string)
   with
     Pre => db_is_open (db) and then length (key) > 0;

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
     (str_a : in unbounded_string;
      str_b : in unbounded_string;
      utf   : in boolean := true) return integer
   with
     Post => db_edit_distance'result >= 0;

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
      params   : in chars_ptr) return system.address
   with
     Export        => True,
     Convention    => C,
     External_Name => "iris_db_open";

   function iris_db_close (db : in system.address) return int
   with
     Export        => True,
     Convention    => C,
     External_Name => "iris_db_close";

   function iris_db_check
     (db       : in system.address;
      key_ptr  : in chars_ptr;
      key_size : in int) return int
   with
     Export        => True,
     Convention    => C,
     External_Name => "iris_db_check";

   function iris_db_get
     (db         : in system.address;
      key_ptr    : in chars_ptr;
      key_size   : in int;
      value_size : access int) return chars_ptr
   with
     Export        => True,
     Convention    => C,
     External_Name => "iris_db_get";

   function iris_db_set
     (db        : in system.address;
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
     (db       : in system.address;
      key_ptr  : in chars_ptr;
      key_size : in int) return int
   with
     Export        => True,
     Convention    => C,
     External_Name => "iris_db_remove";

   function iris_db_count
     (db : in system.address) return long_long_integer
   with
     Export        => True,
     Convention    => C,
     External_Name => "iris_db_count";

   function iris_db_sync
     (db   : in system.address;
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

   procedure iris_db_free (ptr : in system.address)
   with
     Export        => True,
     Convention    => C,
     External_Name => "iris_db_free";

private

   type db_core is record
      handle    : system.address   := system.null_address;
      path      : unbounded_string := null_unbounded_string;
      ref_count : natural          := 1;
   end record;

   type db_core_ptr is access all db_core;

   type database_type is new ada.finalization.controlled with record
      core : db_core_ptr := null;
   end record;

   overriding
   procedure initialize (db : in out database_type);

   overriding
   procedure adjust (db : in out database_type);

   overriding
   procedure finalize (db : in out database_type);

   null_database : constant database_type :=
     (ada.finalization.controlled with core => null);

end database;
