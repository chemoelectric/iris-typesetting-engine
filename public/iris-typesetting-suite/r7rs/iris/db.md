# (iris db) --- Scheme Wrapper for Ada Database Engine

The `(iris db)` library provides a high-performance R7RS Scheme
wrapper around the C interface to the Iris Ada find_things engine
(`find_things.ads` / `find_things.adb`).

## Architecture

All database handles, binary serialization, indexing, and on-disk
storage are managed exclusively by the Ada find_things engine:

```
+-------------------------------------------------------------+
|               Scheme Application Layer / Scripts            |
|                  (e.g., iris-findfont, test_demo_q)         |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|              (iris db) Scheme Library Wrapper               |
|            r7rs/iris/db.sld (%make-db <iris-db>)            |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|              Gauche C Bridge (gauche_iris_db.c)             |
|              gauche_iris_db_* wrappers                      |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|          Ada C Foreign Function Interface Exports           |
|          (find_things.ads / iris_db_* C symbols)            |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|                Ada find_things Engine Core                  |
|            (find_things.adb / database_type)                |
|             Binary Database Format (.tkh / .tkt)            |
+-------------------------------------------------------------+
```

## Zero Scheme File I/O Guarantee

Scheme code performs zero file writes or S-expression formatting on
database files. All operations dispatch directly through the C boundary
to the Ada database engine, ensuring strict binary persistence.

## Library Identifier

```scheme
(define-library (iris db)
  (import (scheme base)
          (scheme char)
          (scheme file)
          (scheme write)
          (scheme process-context)
          (gauche base))
  (export make-db
          db?
          db-open
          db-close
          db-closed?
          db-path
          db-get
          db-set!
          db-exists?
          db-delete!
          db-count
          db-sync
          db-edit-distance
          db-keys
          db-search-prefix
          db-for-each
          db-fold))
```

## Procedures

### `(db-open path [mode])`

Opens the binary database stored at `path` through `iris_db_open`.

### `(db-close db)`

Closes the database handle and flushes modifications via
`iris_db_close`.

### `(db-closed? db)`

Returns `#t` if the database instance has been closed, `#f` otherwise.

### `(db-path db)`

Returns the filesystem path associated with `db`.

### `(db-get db key [default])`

Retrieves the value for `key` via `iris_db_get`.

### `(db-set! db key value)`

Sets the value associated with `key` via `iris_db_set`.

### `(db-exists? db key)`

Returns `#t` if `key` exists in `db` via `iris_db_check`.

### `(db-delete! db key)`

Deletes `key` from `db` via `iris_db_remove`.

### `(db-count db)`

Returns the count of records stored in `db` via `iris_db_count`.

### `(db-sync db)`

Flushes pending database modifications to disk via `iris_db_sync`.

### `(db-edit-distance str-a str-b)`

Calculates Levenshtein edit distance via `iris_db_edit_distance`.
