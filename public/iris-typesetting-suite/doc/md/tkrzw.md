# Tkrzw Database Interface for Iris

The Tkrzw interface provides a key-value database engine for the Iris typesetting suite. It integrates with Gauche Scheme's generic `<dbm>` framework and exposes an Ada 2022 API for high-performance font cataloging and metadata retrieval.

## Architecture

Tkrzw is a key-value database library supporting multiple storage formats:
- Hash databases (`.tkh`) for $O(1)$ constant-time lookup.
- B+ tree databases (`.tkt`) for sorted / ordered queries and range scans.
- Poly databases (automatic format selection based on extension).

## Scheme Interface (`(iris tkrzw)` / `(iris dbm tkrzw)`)

The Scheme library implements the Gauche `<dbm>` generic interface with `<tkrzw>` and `<tkrzw-meta>`:

```scheme
(import (iris tkrzw))

;; Open database
(define font-db (dbm-open <tkrzw> :path "iris-fonts.tkh" :rw-mode :create))

;; Write font record
(dbm-put! font-db "cmr10" "file:///usr/share/texlive/texmf-dist/fonts/type1/public/amsfonts/cm/cmr10.pfb")

;; Retrieve font record
(define font-path (dbm-get font-db "cmr10" #f))

;; Approximate / fuzzy search for font names within edit distance threshold
(define matches (tkrzw-search-approximate font-db "cmr10" 2))

;; Close database
(dbm-close font-db)
```

## Database Builder & Diagnostic Engine (`(iris dbm builder)` & `(iris dbm suggest)`)

The database builder module populates high-performance key-value databases from TeXLive's directory trees (`(iris texmf ls-R)`) and system font catalogs:

```scheme
(import (iris dbm builder)
        (iris dbm suggest))

;; Build TeXMF hash database and System font B+ tree database
(build-all-databases)

;; Instant font resolution via Tkrzw DBM
(define font-file (tkrzw-get font-db "ps:PlayfairDisplay-Regular" #f))

;; Fuzzy name suggestions for typographic diagnostics
(define suggestions (suggest-similar-names font-db "PlayfarDisplay" :capacity 3))
```

## Ada 2022 Interface (`tkrzw.ads` / `tkrzw.adb`)

The Ada 2022 binding mirrors the Scheme DBM naming and semantics:

```ada
with tkrzw; use tkrzw;

procedure demo is
   db        : tkrzw_dbm := null_dbm;
   font_file : string (1 .. 256) := (others => ' ');
begin
   db := dbm_open (default_fonts_db_path, mode => read_only);
   if dbm_open_p (db) then
      if dbm_exists_p (db, "ps:PlayfairDisplay-Regular") then
         declare
            val : constant string :=
              dbm_get (db, "ps:PlayfairDisplay-Regular");
         begin
            -- Use resolved font path
            null;
         end;
      end if;
      dbm_close (db);
   end if;
end demo;
```
