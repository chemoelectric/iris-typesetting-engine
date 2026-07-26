# Iris Main Command-Line Compiler (`iris_main`)

## Overview
The `iris_main` program serves as the primary command-line executable interface for the Iris Typographic Engine. It compiles natural prose and troff/groff formatted input text into high-performance CUPS-compliant PDF documents using Jaynesian MaxEnt optimization and Sorts Mill peg coordinate layout metrics.

## Usage
```bash
iris [OPTIONS] [INPUT_FILE]
```

If `INPUT_FILE` is omitted, `iris` reads markup text directly from standard input.

## Command-Line Options
- `-o, --output FILE`: Specify the target output PDF file path (default: `output.pdf`).
- `-f, --font-size POINTS`: Set the baseline document font size in points (default: `11.0`).
- `-h, --help`: Display command-line option specifications and exit.

## Error Codes
- `0`: Successful document compilation.
- `1`: Invalid command-line argument syntax or flag specification.
- `2`: Unable to locate or open specified input file.
- `3`: Document compilation or PDF generation error.
