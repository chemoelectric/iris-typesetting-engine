# Iris Kpathsea Locator Engine (`iris_kpsewhich`)

## Overview
The `iris_kpsewhich` Fortran module provides path searching, font metric location, and environment tree resolution for the Iris typographic engine.

## API Procedures

### `kpse_set_search_path(new_path)`
Configures custom search path tree for kpathsea locator.

### `kpse_search_file(filename, fmt, resolved_path, status)`
Locates a file by name and format extension (`tfm`, `otf`, `tex`, `pdf`) across search paths.

### `kpse_find_font(font_name, font_path, status)`
Resolves font metric and outline files (`TFM`, `OTF`, `TTF`, `PFB`).
