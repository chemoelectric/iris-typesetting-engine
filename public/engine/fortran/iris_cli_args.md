# Fortran 2008 CLI Argument Parser Engine (`iris_cli_args`)

## 1. Executive Summary
The `iris_cli_args` module provides a standard Fortran 2008 (ISO/IEC 1539-1:2010) declarative, specification-driven API for command-line argument parsing. 

This module is designed in **structural isomorphism** with the R7RS Scheme `(iris cli-args)` library.

---

## 2. Structural Isomorphism Matrix

| API Functionality | Fortran 2008 (`iris_cli_args`) | R7RS Scheme (`(iris cli-args)`) |
| :--- | :--- | :--- |
| **Parser Constructor** | `call cli_init_parser(parser, prog, desc)` | `(make-cli-parser prog desc)` |
| **Option Registration** | `call cli_add_option(parser, short, long, mode, val_name, help)` | `(cli-add-option! parser short long mode val-name help)` |
| **Parse Execution** | `call cli_parse(parser, res)` | `(cli-parse parser [args])` |
| **Option Query (Boolean)** | `call cli_has_option(parser, res, flag, present)` | `(cli-has-option? res flag)` |
| **Option Value Retrieval** | `call cli_get_option(parser, res, flag, val, status)` | `(cli-get-option res flag)` |
| **Option Occurrences** | `call cli_option_count(parser, res, flag, count)` | `(cli-option-count res flag)` |
| **Positional Count** | `call cli_positional_count(res, count)` | `(cli-positional-count res)` |
| **Positional Value** | `call cli_get_positional(res, idx, val, status)` | `(cli-get-positional res idx)` |
| **Help Generation** | `call cli_print_help(parser, unit)` | `(cli-print-help parser)` |
| **Cleanup** | `call cli_free(parser, res)` | N/A (Garbage Collected) |

---

## 3. Example Usage in Fortran 2008

```fortran
program test_cli_parser
  use iris_cli_args
  use, intrinsic :: iso_fortran_env, only: output_unit
  implicit none

  type(cli_parser_type) :: parser
  type(cli_result_type) :: res
  logical               :: verbose_present
  character(len=256)    :: input_file, pos_val
  integer               :: status, pos_cnt

  ! Initialize parser with program metadata
  call cli_init_parser(parser, "iris_fmt", "High-performance microtypography engine")

  ! Register option specifications
  call cli_add_option(parser, "v", "verbose", CLI_NO_ARG,  "",     "Enable verbose log output")
  call cli_add_option(parser, "i", "input",   CLI_REQ_ARG, "FILE", "Input document file path")
  call cli_add_option(parser, "h", "help",    CLI_NO_ARG,  "",     "Print help message")

  ! Parse command line arguments
  call cli_parse(parser, res)

  ! Check for error or --help
  call cli_has_option(parser, res, "help", verbose_present)
  if (res%status /= 0 .or. verbose_present) then
    call cli_print_help(parser, output_unit)
    stop
  end if

  ! Query parsed options
  call cli_has_option(parser, res, "verbose", verbose_present)
  call cli_get_option(parser, res, "input", input_file, status)

  ! Query positional arguments
  call cli_positional_count(res, pos_cnt)
  if (pos_cnt >= 1) then
    call cli_get_positional(res, 1, pos_val, status)
  end if

  call cli_free(parser, res)
end program test_cli_parser
```

---

## 4. Architectural Standards & Compliance
- **ISO Standard**: Standard Fortran 2008 (ISO/IEC 1539-1:2010).
- **Structured Control**: Enforces single-entry/single-exit control constructs without `goto` constructs.
- **McCabe Complexity**: Each procedure strictly maintains a modified McCabe cyclomatic complexity $\le 10$.
- **Module Synchronization**: Maintained in strict synchronization with `/fortran/iris_cli_args.f90`.
