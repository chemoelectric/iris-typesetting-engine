# Iris Main Command-Line Compiler (`iris_main`)

## Overview
The `iris_main` program serves as the primary command-line executable interface for the Iris Typographic Engine. It compiles natural prose and troff/groff formatted input text into high-performance CUPS-compliant PDF documents using Jaynesian MaxEnt optimization and Sorts Mill peg coordinate layout metrics.

## Usage
```bash
iris [OPTIONS] [MODE] [ARGUMENTS]
```

## Execution Modes / Subcommands
- `tex <file>`: Compile TeX document using Iris TeX Engine.
- `kpsewhich <file>`: Search TeX path or format specification for file location.
- `trip`: Run TRIP benchmark diagnostic test suite.
- `[file]`: Compile Iris markup or prose file directly to PDF (default mode). If omitted, reads from standard input.

## Command-Line Options
- `-o, --output FILE`: Specify the target output PDF file path (default: `output.pdf`).
- `-f, --font-size POINTS`: Set the baseline document font size in points (default: `11.0`).
- `-m, --format FMT`: Format specification for `kpsewhich` or `tex` search mode.
- `-h, --help`: Display command-line options and execution modes, then exit.

## Error Codes
- `0`: Successful document compilation.
- `1`: Invalid command-line argument syntax or flag specification.
- `2`: Unable to locate or open specified input file.
- `3`: Document compilation or PDF generation error.
