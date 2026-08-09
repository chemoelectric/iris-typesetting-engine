# `iris_cmd_compile` — Document Compiler Command

## Architectural Overview
`iris_cmd_compile` is the dedicated command line executable (`iris-compile`) for processing Iris markup prose into typeset PDF documents.

## CLI Usage & Options
```sh
iris-compile [file] [options]
```

| Flag | Long Flag | Value | Description |
| :--- | :--- | :--- | :--- |
| `-o` | `--output` | `FILE` | Output PDF document filename (default: `output.pdf`) |
| `-f` | `--font-size` | `POINTS` | Base font size in points (default: `11.0`) |
| `-h` | `--help` | N/A | Display command options and exit |

## Synchronization
- **Fortran Entry**: `fortran/iris_cmd_compile.f90`
- **Module Dependency**: `iris_batch_engine`, `iris_cli_args`, `iris_dynamic_string`
