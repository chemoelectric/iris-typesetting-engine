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

The database builder module populates high-performance key-value databases from TeXLive's directory trees (`(iris texmf ls-R)`) and system font configurations (`(iris fontconfig)`):

```scheme
(import (iris dbm builder)
        (iris dbm suggest))

;; Build TeXMF hash database and System font B+ tree database
(build-all-databases)

;; Query for misspelled font name or file
(define font-db (tkrzw-open (default-fonts-db-path) :rw-mode :read))
(define suggestion (suggest-did-you-mean font-db "NimbusRomn-Bld" 3))
;; suggestion => "NimbusRoman-Bold"

;; Produce formatted compiler diagnostic note
(format-did-you-mean-diagnostic "font" "NimbusRomn-Bld" suggestion)
;; => "error: font 'NimbusRomn-Bld' was not found.\n  = note: did you mean 'NimbusRoman-Bold'?"
```

## Ada 2022 Interface (`tkrzw.ads`)

The Ada 2022 interface `tkrzw` provides typed database access with formal pre- and post-condition contracts:

```ada
with tkrzw; use tkrzw;

declare
   db : tkrzw_dbm := open_dbm ("iris-fonts.tkh", writable => true);
begin
   put_value (db, "cmr10", "/path/to/cmr10.pfb");
   if exists_key (db, "cmr10") then
      declare
         val : constant string := get_value (db, "cmr10");
      begin
         null;
      end;
   end if;
   declare
      d : constant integer := edit_distance ("cmr10", "cmr12");
   begin
      null;
   end;
   close_dbm (db);
end;
```
