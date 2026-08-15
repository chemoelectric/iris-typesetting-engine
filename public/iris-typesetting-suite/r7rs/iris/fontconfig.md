# `(iris fontconfig)` Scheme Library

The `(iris fontconfig)` library provides Fontconfig (`libfontconfig`) C library font resolution for the Iris typesetting suite in standard R⁷RS Scheme using Gauche's C foreign function interface (`(c-wrapper)`).

## Exported Procedures

### `(fontconfig-find-font query)`
Resolves a font query string directly through the Fontconfig C API (`FcInit`, `FcNameParse`, `FcFontList`, `FcFontMatch`) and returns an S-expression structure containing a list of font entries with `file:///` URIs and companion files (such as Type 1 `.pfb`/`.pfa` companion files for `.afm` metrics).

- **Parameters**: `query` (String) - Query string (e.g., `"DejaVu Sans"`, `"Merriweather-Black.otf"`, `":family=Nimbus Roman"`).
- **Returns**: An S-expression list of fonts:
  ```scheme
  (((query . "DejaVu Sans")
    (uris "file:///usr/share/fonts/truetype/dejavu/DejaVuSans.ttf")))
  ```

### `(fontconfig-search query)`
Queries `libfontconfig` for all matching filesystem font paths matching `query`.

- **Parameters**: `query` (String)
- **Returns**: A list of filesystem path strings (`"/path/to/font.ttf"`).

### `(path->file-uri path)`
Converts a filesystem path string to a canonical `file:///` URI string.
