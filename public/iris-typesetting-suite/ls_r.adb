-- ls_r.adb
--
-- SPDX-License-Identifier: MIT
--
-- Implementation of TeXMF ls-R database indexing in Ada 2022.
--

with ada.directories;
with ada.environment_variables;
with ada.text_io;
with ada.strings.unbounded; use ada.strings.unbounded;
with interfaces.c; use interfaces.c;
with interfaces.c.strings; use interfaces.c.strings;

package body ls_r is

   kpsewhich_configured : constant string := "kpsewhich";

   function c_run_command (cmd : in chars_ptr) return chars_ptr
   with
     import        => true,
     convention    => c,
     external_name => "iris_run_command_output";

   procedure c_free_command (ptr : in chars_ptr)
   with
     import        => true,
     convention    => c,
     external_name => "iris_free_command_output";

   function kpsewhich_command return string is
   begin
      if kpsewhich_configured'length > 0 then
         return kpsewhich_configured;
      else
         return "kpsewhich";
      end if;
   end kpsewhich_command;

   function default_texmf_db_path return unbounded_string is
      env_xdg  : constant string :=
        (if ada.environment_variables.exists ("XDG_DATA_HOME")
         then ada.environment_variables.value ("XDG_DATA_HOME")
         else "");
      env_home : constant string :=
        (if ada.environment_variables.exists ("HOME")
         then ada.environment_variables.value ("HOME")
         else "");
   begin
      if env_xdg'length > 0 then
         return to_unbounded_string (env_xdg & "/iris/texmf.tkh");
      elsif env_home'length > 0 then
         return to_unbounded_string
           (env_home & "/.local/share/iris/texmf.tkh");
      else
         return to_unbounded_string ("/tmp/iris-texmf.tkh");
      end if;
   end default_texmf_db_path;

   function default_texmf_db_path return string is
   begin
      return to_string (default_texmf_db_path);
   end default_texmf_db_path;

   function root_of_ls_r (ls_r_path : in string) return string is
      len      : constant natural := ls_r_path'length;
      last_idx : constant integer := ls_r_path'last;
   begin
      if len >= 4
        and then ls_r_path (last_idx - 3 .. last_idx) = "ls-R"
      then
         return ls_r_path (ls_r_path'first .. last_idx - 4);
      else
         return ls_r_path;
      end if;
   end root_of_ls_r;

   function ends_with
     (s  : in string;
      ch : in character) return boolean is
   begin
      return s'length > 0 and then s (s'last) = ch;
   end ends_with;

   function clean_dir_token (dir_tok : in string) return string is
   begin
      if dir_tok'length > 0 and then dir_tok (dir_tok'first) = '.' then
         if dir_tok'length > 1
           and then dir_tok (dir_tok'first + 1) = '/'
         then
            return dir_tok (dir_tok'first + 2 .. dir_tok'last);
         else
            return dir_tok (dir_tok'first + 1 .. dir_tok'last);
         end if;
      else
         return dir_tok;
      end if;
   end clean_dir_token;

   function combine_root_and_dir
     (root_prefix : in string;
      raw_dir     : in string) return string
   is
      cleaned : constant string := clean_dir_token (raw_dir);
   begin
      if root_prefix'length = 0 then
         return cleaned;
      elsif ends_with (root_prefix, '/') then
         return root_prefix & cleaned;
      else
         return root_prefix & "/" & cleaned;
      end if;
   end combine_root_and_dir;

   procedure process_ls_r_line
     (line        : in string;
      root_prefix : in string;
      current_dir : in out unbounded_string;
      db          : in out database.database_type;
      added_count : in out natural)
   is
   begin
      if line'length = 0 or else line (line'first) = '%' then
         return;
      end if;

      if ends_with (line, ':') then
         declare
            raw_dir : constant string :=
              line (line'first .. line'last - 1);
            full_dir : constant string :=
              combine_root_and_dir (root_prefix, raw_dir);
         begin
            current_dir := to_unbounded_string (full_dir);
         end;
      else
         declare
            dir_str  : constant string := to_string (current_dir);
            full_val : constant string :=
              (if dir_str'length > 0 and then ends_with (dir_str, '/')
               then dir_str & line
               elsif dir_str'length > 0
               then dir_str & "/" & line
               else line);
         begin
            database.db_set (db, line, full_val);
            added_count := added_count + 1;
         end;
      end if;
   end process_ls_r_line;

   procedure ingest_ls_r_file
     (db          : in out database.database_type;
      ls_r_path   : in string;
      added_count : in out natural)
   is
      file        : ada.text_io.file_type;
      root_prefix : constant string := root_of_ls_r (ls_r_path);
      current_dir : unbounded_string := null_unbounded_string;
   begin
      if not ada.directories.exists (ls_r_path) then
         return;
      end if;

      ada.text_io.open (file, ada.text_io.in_file, ls_r_path);
      while not ada.text_io.end_of_file (file) loop
         declare
            line : constant string := ada.text_io.get_line (file);
         begin
            process_ls_r_line
              (line        => line,
               root_prefix => root_prefix,
               current_dir => current_dir,
               db          => db,
               added_count => added_count);
         end;
      end loop;
      ada.text_io.close (file);
   exception
      when others =>
         if ada.text_io.is_open (file) then
            ada.text_io.close (file);
         end if;
   end ingest_ls_r_file;

   procedure ingest_candidate
     (cand : in string;
      db   : in out database.database_type;
      cnt  : in out natural)
   is
   begin
      if ada.directories.exists (cand) then
         ingest_ls_r_file (db, cand, cnt);
      end if;
   end ingest_candidate;

   procedure ingest_standard_candidates
     (db  : in out database.database_type;
      cnt : in out natural)
   is
   begin
      ingest_candidate
        ("/usr/local/texlive/2026/texmf-dist/ls-R", db, cnt);
      ingest_candidate
        ("/usr/local/texlive/2025/texmf-dist/ls-R", db, cnt);
      ingest_candidate
        ("/usr/local/texlive/2024/texmf-dist/ls-R", db, cnt);
      ingest_candidate
        ("/usr/share/texlive/texmf-dist/ls-R", db, cnt);
      ingest_candidate
        ("/usr/share/texmf/ls-R", db, cnt);
      ingest_candidate
        ("/var/lib/texmf/ls-R", db, cnt);
   end ingest_standard_candidates;

   procedure ingest_kpsewhich_output
     (db  : in out database.database_type;
      cnt : in out natural)
   is
      cmd      : constant string := kpsewhich_command & " -all ls-R";
      c_cmd    : chars_ptr       := new_string (cmd);
      raw_res  : chars_ptr       := c_run_command (c_cmd);
      idx      : positive        := 1;
      start    : positive        := 1;
   begin
      free (c_cmd);
      if raw_res /= null_ptr then
         declare
            out_str : constant string := value (raw_res);
         begin
            c_free_command (raw_res);
            while idx <= out_str'length loop
               if out_str (idx) = character'val (10)
                 or else out_str (idx) = character'val (13)
               then
                  if idx > start then
                     ingest_candidate
                       (out_str (start .. idx - 1), db, cnt);
                  end if;
                  start := idx + 1;
               end if;
               idx := idx + 1;
            end loop;
            if start <= out_str'length then
               ingest_candidate
                 (out_str (start .. out_str'last), db, cnt);
            end if;
         end;
      end if;
   exception
      when others =>
         null;
   end ingest_kpsewhich_output;

   procedure ensure_parent_directory (file_path : in string) is
      parent : constant string :=
        ada.directories.containing_directory (file_path);
   begin
      if parent'length > 0 and then not ada.directories.exists (parent)
      then
         ada.directories.create_path (parent);
      end if;
   exception
      when others =>
         null;
   end ensure_parent_directory;

   procedure build_texmf_database
     (db_path : in string := "";
      count   : out natural)
   is
      target_path : constant string :=
        (if db_path'length > 0 then db_path else default_texmf_db_path);
      db          : database.database_type;
      cnt         : natural := 0;
   begin
      count := 0;
      ensure_parent_directory (target_path);
      db := database.db_open
        (path   => target_path,
         mode   => database.create_or_truncate);
      if database.is_open (db) then
         ingest_kpsewhich_output (db, cnt);
         ingest_standard_candidates (db, cnt);
         database.db_sync (db);
         count := natural (database.db_count (db));
         database.db_close (db);
      end if;
   end build_texmf_database;

   procedure build_texmf_database
     (db_path : in unbounded_string;
      count   : out natural)
   is
   begin
      build_texmf_database (to_string (db_path), count);
   end build_texmf_database;

end ls_r;
