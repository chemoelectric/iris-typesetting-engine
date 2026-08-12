# `(iris kpsewhich)` Scheme Library

The `(iris kpsewhich)` library provides Kpathsea-based font resolution for the Iris typesetting suite in standard R⁷RS Scheme.

## Exported Procedures

### `(kpsewhich-find-font query)`
Resolves a font query string using the TeX Live `kpsewhich` tool and returns an S-expression structure containing the original query and the list of resolved resource URIs.

- **Parameters**: `query` (String) - Query string (e.g., `"cmr10"`, `"file:lmroman10-regular.otf"`, `"name:ptmr8a"`).
- **Returns**: An S-expression alist:
  ```scheme
  ((query . "cmr10")
   (uris . ("file:///usr/share/texmf-dist/fonts/tfm/public/cm/cmr10.tfm")))
  ```

### `(kpsewhich-lookup . args)`
Executes `kpsewhich` with the provided string arguments and returns a list of trimmed file paths.

### `(path->file-uri path)`
Converts a filesystem path string to a `file:///` URI string.
