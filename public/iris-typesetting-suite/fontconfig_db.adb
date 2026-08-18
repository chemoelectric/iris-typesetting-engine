-- fontconfig_db.adb
--
-- SPDX-License-Identifier: MIT
--
-- Implementation of Fontconfig database indexing in Ada 2022.
--

with ada.characters.handling;
with ada.directories; use ada.directories;
with ada.environment_variables;
with ada.strings.unbounded; use ada.strings.unbounded;
with interfaces.c; use interfaces.c;
with interfaces.c.strings; use interfaces.c.strings;

package body fontconfig_db is

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

   function to_lower (s : in string) return string is
   begin
      return ada.characters.handling.to_lower (s);
   end to_lower;

   function default_fonts_db_path return unbounded_string is
      env_xdg  : constant string :=
        (if ada.environment_variables.exists ("XDG_CACHE_HOME")
         then ada.environment_variables.value ("XDG_CACHE_HOME")
         else "");
      env_home : constant string :=
        (if ada.environment_variables.exists ("HOME")
         then ada.environment_variables.value ("HOME")
         else "");
   begin
      if env_xdg'length > 0 then
         return to_unbounded_string (env_xdg & "/iris/fonts.tkh");
      elsif env_home'length > 0 then
         return to_unbounded_string
           (env_home & "/.cache/iris/fonts.tkh");
      else
         return to_unbounded_string ("/tmp/iris-fonts.tkh");
      end if;
   end default_fonts_db_path;

   function default_fonts_db_path return string is
   begin
      return to_string (default_fonts_db_path);
   end default_fonts_db_path;

   procedure insert_font_metadata
     (db          : in out find_things.database_type;
      file_path   : in string;
      family      : in string;
      style       : in string;
      fullname    : in string;
      psname      : in string;
      added_count : in out natural)
   is
      basename : constant string :=
        ada.directories.simple_name (file_path);
   begin
      find_things.db_set (db, basename, file_path);
      find_things.db_set (db, to_lower (basename), file_path);
      if family'length > 0 then
         find_things.db_set (db, "family:" & family, file_path);
         find_things.db_set
           (db, "family:" & to_lower (family), file_path);
      end if;
      if psname'length > 0 then
         find_things.db_set (db, "ps:" & psname, file_path);
         find_things.db_set (db, "ps:" & to_lower (psname), file_path);
      end if;
      if fullname'length > 0 then
         find_things.db_set (db, "name:" & fullname, file_path);
         find_things.db_set
           (db, "name:" & to_lower (fullname), file_path);
      end if;
      if family'length > 0 and then style'length > 0 then
         find_things.db_set
           (db, "font:" & family & ":" & style, file_path);
      end if;
      added_count := added_count + 1;
   exception
      when others =>
         null;
   end insert_font_metadata;

   procedure parse_fc_line
     (line        : in string;
      db          : in out find_things.database_type;
      added_count : in out natural)
   is
      fields    : array (1 .. 5) of unbounded_string;
      field_idx : positive := 1;
      start_pos : positive := line'first;
      cur_pos   : positive := line'first;
   begin
      while cur_pos <= line'last and field_idx <= 5 loop
         if line (cur_pos) = ':' then
            if cur_pos > start_pos then
               fields (field_idx) := to_unbounded_string
                 (line (start_pos .. cur_pos - 1));
            end if;
            field_idx := field_idx + 1;
            start_pos := cur_pos + 1;
         end if;
         cur_pos := cur_pos + 1;
      end loop;
      if start_pos <= line'last and field_idx <= 5 then
         fields (field_idx) := to_unbounded_string
           (line (start_pos .. line'last));
      end if;

      if length (fields (1)) > 0 then
         insert_font_metadata
           (db          => db,
            file_path   => to_string (fields (1)),
            family      => to_string (fields (2)),
            style       => to_string (fields (3)),
            fullname    => to_string (fields (4)),
            psname      => to_string (fields (5)),
            added_count => added_count);
      end if;
   end parse_fc_line;

   procedure ingest_fc_list_output
     (db          : in out find_things.database_type;
      added_count : in out natural)
   is
      cmd     : constant string :=
        "fc-list -f """ &
        "%{file}:%{family}:%{style}:%{fullname}:%{postscriptname}\n""";
      c_cmd   : chars_ptr       := new_string (cmd);
      raw_res : chars_ptr       := c_run_command (c_cmd);
      idx     : positive        := 1;
      start   : positive        := 1;
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
                     parse_fc_line
                       (line        => out_str (start .. idx - 1),
                        db          => db,
                        added_count => added_count);
                  end if;
                  start := idx + 1;
               end if;
               idx := idx + 1;
            end loop;
            if start <= out_str'length then
               parse_fc_line
                 (line        => out_str (start .. out_str'last),
                  db          => db,
                  added_count => added_count);
            end if;
         end;
      end if;
   exception
      when others =>
         null;
   end ingest_fc_list_output;

   function is_font_extension (ext : in string) return boolean is
      low : constant string := to_lower (ext);
   begin
      return low = ".otf" or else low = ".ttf" or else low = ".ttc"
        or else low = ".woff" or else low = ".woff2"
        or else low = ".pfb" or else low = ".pfa";
   end is_font_extension;

   procedure process_directory_entry
     (item        : in ada.directories.directory_entry_type;
      db          : in out find_things.database_type;
      added_count : in out natural)
   is
      full : constant string := ada.directories.full_name (item);
      kind : constant ada.directories.file_kind :=
        ada.directories.kind (item);
   begin
      if kind = ada.directories.directory then
         declare
            sname : constant string :=
              ada.directories.simple_name (item);
         begin
            if sname /= "." and then sname /= ".." then
               ingest_font_directory (db, full, added_count);
            end if;
         end;
      elsif kind = ada.directories.ordinary_file then
         declare
            ext : constant string := ada.directories.extension (full);
         begin
            if is_font_extension ("." & ext) then
               declare
                  base : constant string :=
                    ada.directories.simple_name (full);
               begin
                  find_things.db_set (db, base, full);
                  find_things.db_set (db, to_lower (base), full);
                  added_count := added_count + 1;
               end;
            end if;
         end;
      end if;
   exception
      when others =>
         null;
   end process_directory_entry;

   procedure ingest_font_directory
     (db          : in out find_things.database_type;
      dir_path    : in string;
      added_count : in out natural)
   is
      search : ada.directories.search_type;
      item   : ada.directories.directory_entry_type;
   begin
      if not ada.directories.exists (dir_path) then
         return;
      end if;

      ada.directories.start_search
        (search    => search,
         directory => dir_path,
         pattern   => "*");
      while ada.directories.more_entries (search) loop
         ada.directories.get_next_entry (search, item);
         process_directory_entry (item, db, added_count);
      end loop;
      ada.directories.end_search (search);
   exception
      when others =>
         null;
   end ingest_font_directory;

   procedure scan_standard_font_directories
     (db  : in out find_things.database_type;
      cnt : in out natural)
   is
      home : constant string :=
        (if ada.environment_variables.exists ("HOME")
         then ada.environment_variables.value ("HOME")
         else "");
   begin
      ingest_font_directory (db, "/usr/share/fonts", cnt);
      ingest_font_directory (db, "/usr/local/share/fonts", cnt);
      ingest_font_directory
        (db, "/usr/share/texlive/texmf-dist/fonts", cnt);
      if home'length > 0 then
         ingest_font_directory (db, home & "/.fonts", cnt);
         ingest_font_directory (db, home & "/.local/share/fonts", cnt);
      end if;
   end scan_standard_font_directories;

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

   procedure build_fonts_database
     (db_path : in string := "";
      count   : out natural)
   is
      target_path : constant string :=
        (if db_path'length > 0 then db_path else default_fonts_db_path);
      db          : find_things.database_type;
      cnt         : natural := 0;
   begin
      count := 0;
      ensure_parent_directory (target_path);
      db := find_things.db_open
        (path   => target_path,
         mode   => find_things.create_or_truncate);
      if find_things.db_is_open (db) then
         ingest_fc_list_output (db, cnt);
         scan_standard_font_directories (db, cnt);
         find_things.db_sync (db);
         count := natural (find_things.db_count (db));
         find_things.db_close (db);
      end if;
   end build_fonts_database;

   procedure build_fonts_database
     (db_path : in unbounded_string;
      count   : out natural)
   is
   begin
      build_fonts_database (to_string (db_path), count);
   end build_fonts_database;

end fontconfig_db;
