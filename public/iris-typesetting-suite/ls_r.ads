-- ls_r.ads
--
-- SPDX-License-Identifier: MIT
--
-- TeXMF ls-R database indexing interface in Ada 2022.
--

with ada.strings.unbounded; use ada.strings.unbounded;
with find_things;

package ls_r is

   -- Returns the configured kpsewhich command path or name
   function kpsewhich_command return string;

   -- Returns default path for the TeXMF Tkrzw database
   function default_texmf_db_path return string;
   function default_texmf_db_path return unbounded_string;

   -- Ingests a single ls-R file into an open database
   procedure ingest_ls_r_file
     (db          : in out find_things.database_type;
      ls_r_path   : in string;
      added_count : in out natural)
   with
     pre => find_things.db_is_open (db);

   -- Builds or rebuilds the entire TeXMF database
   procedure build_texmf_database
     (db_path : in string := "";
      count   : out natural);

   procedure build_texmf_database
     (db_path : in unbounded_string;
      count   : out natural);

end ls_r;
