-- fontconfig_db.ads
--
-- SPDX-License-Identifier: MIT
--
-- Fontconfig system font database indexing interface in Ada 2022.
--

with ada.strings.unbounded; use ada.strings.unbounded;
with database;

package fontconfig_db is

   -- Returns default path for the Fontconfig Tkrzw database
   function default_fonts_db_path return string;
   function default_fonts_db_path return unbounded_string;

   -- Ingests font entries from fc-list output into open database
   procedure ingest_fc_list_output
     (db          : in out database.database_type;
      added_count : in out natural)
   with
     pre => database.db_is_open (db);

   -- Ingests font files found in a directory tree
   procedure ingest_font_directory
     (db          : in out database.database_type;
      dir_path    : in string;
      added_count : in out natural)
   with
     pre => database.db_is_open (db);

   -- Builds or rebuilds the entire Fontconfig database
   procedure build_fonts_database
     (db_path : in string := "";
      count   : out natural);

   procedure build_fonts_database
     (db_path : in unbounded_string;
      count   : out natural);

end fontconfig_db;
