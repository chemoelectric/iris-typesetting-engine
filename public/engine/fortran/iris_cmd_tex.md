# `iris_cmd_tex` — TeX Document Compiler Command

## Architectural Overview
`iris_cmd_tex` is the dedicated command line executable (`iris-tex`) for compiling TeX source documents (`.tex`) directly to typeset PDF output.

## CLI Usage & Options
```sh
iris-tex <file> [options]
```

| Flag | Long Flag | Value | Description |
| :--- | :--- | :--- | :--- |
| `-o` | `--output` | `FILE` | Output PDF document filename (default: `output.pdf`) |
| `-m` | `--format` | `FMT` | TeX format specification (e.g. `plain`, `latex`) |
| `-h` | `--help` | N/A | Display command options and exit |

## Synchronization
- **Fortran Entry**: `fortran/iris_cmd_tex.f90`
- **Module Dependency**: `iris_tex`, `iris_batch_engine`, `iris_dynamic_string`, `iris_cli_args`, `iris_json`
