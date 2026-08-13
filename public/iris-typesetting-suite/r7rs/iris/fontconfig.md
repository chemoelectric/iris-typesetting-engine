# `(iris fontconfig)` Scheme Library

The `(iris fontconfig)` library provides Fontconfig (`fc-list`) font resolution for the Iris typesetting suite in standard R⁷RS Scheme.

## Exported Procedures

### `(fontconfig-find-font query)`
Resolves a font query string using the system `fc-list` tool and returns an S-expression structure containing a list of font entries.

- **Parameters**: `query` (String) - Query string (e.g., `"DejaVu Sans"`, `"Merriweather-Black.otf"`).
- **Returns**: An S-expression list of fonts:
  ```scheme
  (((query . "DejaVu Sans")
    (uris "file:///usr/share/fonts/truetype/dejavu/DejaVuSans.ttf")))
  ```

### `(fontconfig-lookup . args)`
Executes `fc-list` with the provided string arguments and returns a list of output lines.

### `(path->file-uri path)`
Converts a filesystem path string to a `file:///` URI string.
