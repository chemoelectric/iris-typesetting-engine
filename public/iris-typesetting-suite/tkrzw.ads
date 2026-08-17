-- SPDX-License-Identifier: MIT
--
-- Ada 2022 interface to the Tkrzw DBM key-value database, designed
-- to mirror the Gauche Scheme (iris tkrzw) / (iris dbm) DBM interface.
--

with system; use system;
with interfaces.c; use interfaces.c;
with interfaces.c.strings; use interfaces.c.strings;

package tkrzw is

   type tkrzw_dbm is private;

   null_dbm : constant tkrzw_dbm;

   type rw_mode is (read_only, read_write, create_new);

   -- DBM lifecycle matching Scheme dbm-open / dbm-close / dbm-closed?
   function dbm_open
     (path   : in string;
      mode   : in rw_mode := read_only;
      params : in string := "") return tkrzw_dbm
     with
       Pre => path'length > 0;

   procedure dbm_close (dbm : in out tkrzw_dbm)
     with
       Pre  => dbm_open_p (dbm),
       Post => dbm_closed_p (dbm);

   function dbm_open_p (dbm : in tkrzw_dbm) return boolean;
   function dbm_closed_p (dbm : in tkrzw_dbm) return boolean;

   -- Key-value operations matching Scheme dbm-get / dbm-put! / dbm-exists?
   function dbm_exists_p
     (dbm : in tkrzw_dbm;
      key : in string) return boolean
     with
       Pre => dbm_open_p (dbm) and key'length > 0;

   function dbm_get
     (dbm     : in tkrzw_dbm;
      key     : in string;
      default : in string := "") return string
     with
       Pre => dbm_open_p (dbm) and key'length > 0;

   procedure dbm_put
     (dbm       : in tkrzw_dbm;
      key       : in string;
      value     : in string;
      overwrite : in boolean := true)
     with
       Pre => dbm_open_p (dbm) and key'length > 0;

   procedure dbm_delete
     (dbm : in tkrzw_dbm;
      key : in string)
     with
       Pre => dbm_open_p (dbm) and key'length > 0;

   function dbm_count (dbm : in tkrzw_dbm) return long_long_integer
     with
       Pre => dbm_open_p (dbm);

   procedure dbm_sync
     (dbm  : in tkrzw_dbm;
      hard : in boolean := true)
     with
       Pre => dbm_open_p (dbm);

   -- Levenshtein distance matching Scheme tkrzw-edit-distance
   function tkrzw_edit_distance
     (str_a : in string;
      str_b : in string;
      utf   : in boolean := true) return integer
     with
       Pre => True;

   -- Cache path helpers matching Scheme (iris dbm builder)
   function default_texmf_db_path return string;
   function default_fonts_db_path return string;

   -- Compatibility aliases
   function is_open (dbm : in tkrzw_dbm) return boolean renames dbm_open_p;
   function open_dbm
     (path     : in string;
      writable : in boolean := true;
      params   : in string := "") return tkrzw_dbm;
   procedure close_dbm (dbm : in out tkrzw_dbm) renames dbm_close;
   function exists_key
     (dbm : in tkrzw_dbm;
      key : in string) return boolean renames dbm_exists_p;
   function get_value
     (dbm : in tkrzw_dbm;
      key : in string) return string;
   procedure put_value
     (dbm       : in tkrzw_dbm;
      key       : in string;
      value     : in string;
      overwrite : in boolean := true) renames dbm_put;
   procedure delete_key
     (dbm : in tkrzw_dbm;
      key : in string) renames dbm_delete;
   function count_records
     (dbm : in tkrzw_dbm) return long_long_integer renames dbm_count;
   procedure sync_dbm
     (dbm  : in tkrzw_dbm;
      hard : in boolean := true) renames dbm_sync;
   function edit_distance
     (str_a : in string;
      str_b : in string;
      utf   : in boolean := true) return integer renames tkrzw_edit_distance;

private

   type tkrzw_dbm is new system.address;

   null_dbm : constant tkrzw_dbm :=
     tkrzw_dbm (system.null_address);

end tkrzw;
