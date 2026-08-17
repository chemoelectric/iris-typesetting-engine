# Database Package Interface

The `database` package provides a unified, memory-safe, high-performance
associative database interface for the Iris Typesetting Engine.
It encapsulates key-value record management, associative lookups,
and string edit distance metrics with strict Ada 2022 contracts.

At the programmer's API level, the interface operates natively on
unbounded strings (`Ada.Strings.Unbounded.Unbounded_String`) with
automatic, deterministic RAII resource management via controlled
reference-counted handles, completely preventing dangling pointers,
memory leaks, length constraints, or double-free defects.

## Overview

- **Package**: `database`
- **Specification**: `database.ads`
- **Body**: `database.adb`

## Types

```ada
type database_type is new ada.finalization.controlled with private;
null_database : constant database_type;

type open_mode is
  (read_only,
   read_write,
   create_new,
   truncate_existing);
```

## Subprograms

### `db_open`

```ada
function db_open
  (path   : in unbounded_string;
   mode   : in open_mode := read_only;
   params : in unbounded_string := null_unbounded_string)
   return database_type
with
  Pre  => length (path) > 0,
  Post => (if db_is_open (db_open'result) then
             length (db_get_path (db_open'result)) >= 0);

function db_open
  (path   : in string;
   mode   : in open_mode := read_only;
   params : in string := "") return database_type
with
  Pre  => path'length > 0,
  Post => (if db_is_open (db_open'result) then
             length (db_get_path (db_open'result)) >= 0);
```

Opens or creates a database at the given filesystem path.

### `db_close`

```ada
procedure db_close (db : in out database_type)
with
  Post => db_is_closed (db);
```

Closes the open database handle safely. The controlled type also
ensures idempotent, automatic finalization upon scope exit.

### `db_is_open` / `db_is_closed`

```ada
function db_is_open (db : in database_type) return boolean;
function db_is_closed (db : in database_type) return boolean;
```

Inquires whether the database instance is open or closed.

### `db_exists`

```ada
function db_exists
  (db  : in database_type;
   key : in unbounded_string) return boolean
with
  Pre => db_is_open (db) and then length (key) > 0;

function db_exists
  (db  : in database_type;
   key : in string) return boolean
with
  Pre => db_is_open (db) and then key'length > 0;
```

Checks if a record with the specified key exists.

### `db_get`

```ada
function db_get
  (db      : in database_type;
   key     : in unbounded_string;
   default : in unbounded_string := null_unbounded_string)
   return unbounded_string
with
  Pre => db_is_open (db) and then length (key) > 0;

function db_get
  (db      : in database_type;
   key     : in string;
   default : in string := "") return string
with
  Pre => db_is_open (db) and then key'length > 0;
```

Retrieves the value for a key, returning `default` if absent.

### `db_set`

```ada
procedure db_set
  (db        : in out database_type;
   key       : in unbounded_string;
   value     : in unbounded_string;
   overwrite : in boolean := true)
with
  Pre => db_is_open (db) and then length (key) > 0;

procedure db_set
  (db        : in out database_type;
   key       : in string;
   value     : in string;
   overwrite : in boolean := true)
with
  Pre => db_is_open (db) and then key'length > 0;
```

Sets the string value for a key with optional overwrite control.

### `db_remove`

```ada
procedure db_remove
  (db  : in out database_type;
   key : in unbounded_string)
with
  Pre => db_is_open (db) and then length (key) > 0;

procedure db_remove
  (db  : in out database_type;
   key : in string)
with
  Pre => db_is_open (db) and then key'length > 0;
```

Deletes the record identified by `key`.

### `db_count`

```ada
function db_count
  (db : in database_type) return long_long_integer
with
  Pre  => db_is_open (db),
  Post => db_count'result >= 0;
```

Returns the total count of records stored in the database.

### `db_sync`

```ada
procedure db_sync
  (db   : in out database_type;
   hard : in boolean := false)
with
  Pre => db_is_open (db);
```

Flushes in-memory buffers to physical persistent storage.

### `db_edit_distance`

```ada
function db_edit_distance
  (str_a : in unbounded_string;
   str_b : in unbounded_string;
   utf   : in boolean := true) return integer
with
  Post => db_edit_distance'result >= 0;

function db_edit_distance
  (str_a : in string;
   str_b : in string;
   utf   : in boolean := true) return integer
with
  Post => db_edit_distance'result >= 0;
```

Calculates Levenshtein edit distance between two strings.

## C Foreign Function Interface Exports

- `iris_db_open`
- `iris_db_close`
- `iris_db_check`
- `iris_db_get`
- `iris_db_set`
- `iris_db_remove`
- `iris_db_count`
- `iris_db_sync`
- `iris_db_edit_distance`
- `iris_db_free`
