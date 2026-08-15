# `(iris tkrzw)` Scheme Library

The `(iris tkrzw)` and `(iris dbm tkrzw)` libraries provide a Gauche DBM interface and key-value database system built on Tkrzw for the Iris typesetting suite in standard R⁷RS Scheme.

## Gauche Generic DBM Integration

The library defines the `<tkrzw>` class (with metaclass `<tkrzw-meta>`) implementing Gauche's `<dbm>` generic interface.

### Opening and Closing
```scheme
(import (iris tkrzw))

;; Open or create a Tkrzw database
(define db (dbm-open <tkrzw>
             :path "fonts.tkh"
             :rw-mode :create))

;; Close the database
(dbm-close db)
```

### Supported Read/Write Modes (`:rw-mode`)
- `:read` — Open read-only.
- `:write` — Open read-write (must exist).
- `:create` — Open read-write, creating if absent.
- `:truncate` — Open read-write, truncating existing data.

### Record Access and Mutation
- `(dbm-put! db key value)` — Store a key-value record.
- `(dbm-get db key [default])` — Retrieve value for `key`, or return `default` if absent.
- `(dbm-exists? db key)` — Check if `key` exists (`#t` / `#f`).
- `(dbm-delete! db key)` — Delete record by `key`.
- `(dbm-sync db)` — Flush data to disk.

### Database Iteration
- `(dbm-first db)` — Return `(key . value)` of the first record or `#f`.
- `(dbm-next db)` — Return `(key . value)` of the next record or `#f`.
- `(dbm-fold db proc knil)` — Fold `(proc key value acc)` over all records.
- `(dbm-for-each db proc)` — Execute `(proc key value)` for every record.
- `(dbm-map db proc)` — Map `(proc key value)` across all records.

### Database Management
- `(dbm-db-exists? <tkrzw-meta> name)` — Test if database file exists.
- `(dbm-db-remove <tkrzw-meta> name)` — Delete database file from storage.

---

## Direct Tkrzw Procedures

In addition to the standard Gauche DBM interface, `(iris tkrzw)` provides direct high-performance procedures:

- `(tkrzw-open path [options...])` — Open database with keyword parameters (`:rw-mode`, `:params`).
- `(tkrzw-close db)` — Close database instance.
- `(tkrzw-closed? db)` — Check if database is closed.
- `(tkrzw-count db)` — Return total record count.
- `(tkrzw-file-size db)` — Return database file size in bytes.
- `(tkrzw-file-path db)` — Return database file path.
- `(tkrzw-clear! db)` — Clear all records.
- `(tkrzw-search db pattern [:mode "contain"] [:capacity 0])` — Search keys by mode (`"contain"`, `"begin"`, `"end"`).
- `(tkrzw-increment! db key [step] [initial])` — Atomic integer counter increment.
- `(tkrzw-append! db key value [delim])` — Atomic string append.
- `(tkrzw-rekey! db old-key new-key [:overwrite #t] [:copying #f])` — Atomic key renaming.
- `(tkrzw-inspect db)` — Return an alist of database diagnostic properties.
