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

;; Close database
(dbm-close font-db)
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
   close_dbm (db);
end;
```
