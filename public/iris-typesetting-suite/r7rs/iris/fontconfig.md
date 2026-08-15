# `(iris fontconfig)` Scheme Library

The `(iris fontconfig)` library provides Fontconfig and system font resolution for the Iris typesetting suite in standard R⁷RS Scheme.

## Exported Procedures

### `(fontconfig-find-font query)`
Resolves a font query string across Fontconfig queries and known system font directories, returning an S-expression structure containing a list of font entries with canonical `file:///` URIs and companion files (such as companion `.pfb`/`.pfa` files for `.afm` metrics).

- **Parameters**: `query` (String) - Query string (e.g., `"DejaVu Sans"`, `"Mokka"`, `"AdobeGaramond"`, `"Merriweather-Black.otf"`).
- **Returns**: An S-expression list of font entries:
  ```scheme
  (((query . "DejaVu Sans")
    (uris "file:///usr/share/fonts/truetype/dejavu/DejaVuSans.ttf")))
  ```

### `(fontconfig-search query)`
Queries Fontconfig and filesystem paths for all font files matching `query`.

- **Parameters**: `query` (String)
- **Returns**: A list of filesystem path strings (`"/path/to/font.ttf"`).

### `(path->file-uri path)`
Converts a filesystem path string to a canonical `file:///` URI string.
