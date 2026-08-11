# `iris_cmd_kpsewhich` — Kpathsea File Resolver Command

## Architectural Overview
`iris_cmd_kpsewhich` is the dedicated command line executable (`iris-kpsewhich`) for searching TeX path structures and TeX Live metrics or package files.

## CLI Usage & Options
```sh
iris-kpsewhich <file> [options]
```

| Flag | Long Flag | Value | Description |
| :--- | :--- | :--- | :--- |
| `-m` | `--format` | `FMT` | Format specification for search (e.g. `tfm`, `tex`, `fmt`) |
| `-h` | `--help` | N/A | Display command options and exit |

## Synchronization
- **Fortran Entry**: `fortran/iris_cmd_kpsewhich.f90`
- **Module Dependency**: `iris_kpsewhich`, `iris_cli_args`
