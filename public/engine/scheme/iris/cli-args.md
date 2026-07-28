# Scheme CLI Argument Parser Engine (`(iris cli-args)`)

## 1. Executive Summary
The `(iris cli-args)` R7RS-large Scheme library provides a functional data-structure interface for declarative, specification-driven command-line argument parsing.

This library is designed in **structural isomorphism** with the Fortran 2008 `iris_cli_args` module.

---

## 2. Structural Isomorphism Matrix

| API Functionality | R7RS Scheme (`(iris cli-args)`) | Fortran 2008 (`iris_cli_args`) |
| :--- | :--- | :--- |
| **Parser Constructor** | `(make-cli-parser prog desc)` | `call cli_init_parser(parser, prog, desc)` |
| **Option Registration** | `(cli-add-option! parser short long mode val-name help)` | `call cli_add_option(parser, short, long, mode, val_name, help)` |
| **Mode/Subcommand Registration** | `(cli-add-mode! parser mode-name mode-args help)` | `call cli_add_mode(parser, mode_name, mode_args, help)` |
| **Parse Execution** | `(cli-parse parser [args])` | `call cli_parse(parser, res)` |
| **Option Query (Boolean)** | `(cli-has-option? res flag)` | `call cli_has_option(parser, res, flag, present)` |
| **Option Value Retrieval** | `(cli-get-option res flag)` | `call cli_get_option(parser, res, flag, val, status)` |
| **Option Occurrences** | `(cli-option-count res flag)` | `call cli_option_count(parser, res, flag, count)` |
| **Positional Count** | `(cli-positional-count res)` | `call cli_positional_count(res, count)` |
| **Positional Value** | `(cli-get-positional res idx)` | `call cli_get_positional(res, idx, val, status)` |
| **Help Generation** | `(cli-print-help parser)` | `call cli_print_help(parser, unit)` |

---

## 3. Example Usage in R7RS Scheme

```scheme
(import (scheme base)
        (scheme write)
        (iris cli-args))

(let ((parser (make-cli-parser "iris_fmt" "High-performance microtypography engine")))
  ;; Register option specifications
  (cli-add-option! parser #\v "verbose" 'none "" "Enable verbose log output")
  (cli-add-option! parser #\i "input" 'required "FILE" "Input document file path")
  (cli-add-option! parser #\h "help" 'none "" "Print help message")

  ;; Parse command line arguments
  (let ((res (cli-parse parser)))
    (if (or (not (= (result-status res) 0))
            (cli-has-option? res "help"))
        (cli-print-help parser)
        (begin
          (when (cli-has-option? res "verbose")
            (display "Verbose mode enabled.\n"))
          (let ((file (cli-get-option res "input")))
            (if file
                (display (string-append "Input file: " file "\n"))
                (display "No input file specified.\n")))
          (display (string-append "Positional count: "
                                 (number->string (cli-positional-count res))
                                 "\n"))))))
```

---

## 4. Architectural Standards & Compliance
- **R7RS Conformance**: Standard Scheme library structure using `(define-library (iris cli-args) ...)` with explicit exports.
- **Functional Exemption**: In accordance with system design rules, Scheme code is explicitly exempt from imperative single-exit control flow constraints.
- **Module Synchronization**: Maintained in strict synchronization with `/scheme/iris/cli-args.sld` and `/fortran/iris_cli_args.f90`.
