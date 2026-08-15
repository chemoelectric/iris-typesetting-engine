-- SPDX-License-Identifier: MIT
--
-- Ada 2022 binding to the Tkrzw key-value database.
--

with system; use system;
with interfaces.c; use interfaces.c;
with interfaces.c.strings; use interfaces.c.strings;

package tkrzw is

   type tkrzw_dbm is private;

   null_dbm : constant tkrzw_dbm;

   function is_open (dbm : in tkrzw_dbm) return boolean;

   function open_dbm
     (path     : in string;
      writable : in boolean := true;
      params   : in string := "") return tkrzw_dbm
     with
       Pre  => path'length > 0,
       Post => True;

   procedure close_dbm (dbm : in out tkrzw_dbm)
     with
       Pre  => is_open (dbm),
       Post => not is_open (dbm);

   function exists_key
     (dbm : in tkrzw_dbm;
      key : in string) return boolean
     with
       Pre => is_open (dbm) and key'length > 0;

   function get_value
     (dbm : in tkrzw_dbm;
      key : in string) return string
     with
       Pre => is_open (dbm) and key'length > 0;

   procedure put_value
     (dbm       : in tkrzw_dbm;
      key       : in string;
      value     : in string;
      overwrite : in boolean := true)
     with
       Pre => is_open (dbm) and key'length > 0;

   procedure delete_key
     (dbm : in tkrzw_dbm;
      key : in string)
     with
       Pre => is_open (dbm) and key'length > 0;

   function count_records (dbm : in tkrzw_dbm) return long_long_integer
     with
       Pre => is_open (dbm);

   procedure sync_dbm
     (dbm  : in tkrzw_dbm;
      hard : in boolean := true)
     with
       Pre => is_open (dbm);

   function edit_distance
     (str_a : in string;
      str_b : in string;
      utf   : in boolean := true) return integer
     with
       Pre => True;

private

   type tkrzw_dbm is new system.address;

   null_dbm : constant tkrzw_dbm :=
     tkrzw_dbm (system.null_address);

end tkrzw;
