# `iris_cmd_trip` — TRIP Benchmark Diagnostic Command

## Architectural Overview
`iris_cmd_trip` is the dedicated command line executable (`iris-trip`) for executing the Knuthian TeX TRIP diagnostic test suite.

## CLI Usage & Options
```sh
iris-trip [options]
```

| Flag | Long Flag | Value | Description |
| :--- | :--- | :--- | :--- |
| `-h` | `--help` | N/A | Display command options and exit |

## Synchronization
- **Fortran Entry**: `fortran/iris_cmd_trip.f90`
- **Module Dependency**: `iris_tex`, `iris_cli_args`
