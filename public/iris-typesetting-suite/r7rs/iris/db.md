# (iris db) --- Pure R7RS Database Interface

The `(iris db)` library provides a portable, pure R7RS Scheme
associative storage and diagnostic search interface for the
Iris Typesetting Engine.

## Library Identifier

```scheme
(define-library (iris db)
  (import (scheme base)
          (scheme char)
          (scheme file)
          (scheme write)
          (scheme process-context))
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
          db-keys
          db-search-prefix
          db-edit-distance
          db-for-each
          db-fold))
```

## Procedures

### `(db-open path [mode])`

Opens the database stored at `path`. The optional `mode` symbol may
be `'read`, `'write`, `'create`, or `'truncate`.

### `(db-close db)`

Flushes pending modifications to disk and closes the database.

### `(db-closed? db)`

Returns `#t` if the database instance has been closed, `#f` otherwise.

### `(db-path db)`

Returns the filesystem path associated with `db`.

### `(db-get db key [default])`

Retrieves the value for `key`. Returns `default` (or `#f`) if the key
is not present in the database.

### `(db-set! db key value)`

Sets the value associated with `key`. Signals an error if the database
is closed or was opened in read-only mode.

### `(db-exists? db key)`

Returns `#t` if `key` exists in `db`, otherwise `#f`.

### `(db-delete! db key)`

Deletes `key` from `db`. Returns `#t` on success, `#f` otherwise.

### `(db-count db)`

Returns the integer count of records stored in `db`.

### `(db-sync db)`

Synchronizes in-memory contents to the backing file.

### `(db-keys db [prefix])`

Returns a list of all keys in `db`, optionally matching `prefix`.

### `(db-search-prefix db prefix [capacity])`

Returns up to `capacity` keys matching `prefix`.

### `(db-edit-distance str-a str-b)`

Calculates Levenshtein edit distance between `str-a` and `str-b`.

### `(db-for-each proc db)`

Applies `(proc key value)` to each entry in the database.

### `(db-fold proc knil db)`

Folds `(proc key value accum)` across all entries starting from `knil`.
