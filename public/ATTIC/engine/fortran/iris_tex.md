# Iris Modular TeX Engine (`iris_tex`)

## Overview
The `iris_tex` Fortran module provides modular TeX macro expansion, tokenization, typesetting AST generation, and typography level selection for the Iris typographic system.

## API Procedures

### `tex_init(engine, jobname)`
Initializes the TeX engine instance with specified job name, default dimensions, and Level 0 Classic TeX typography configuration.

### `tex_compile_string(engine, tex_source, ast_out, status)`
Compiles TeX input source string into a structured layout AST object.

### `tex_run_trip_test(status, report_msg)`
Runs Knuth's TRIP diagnostic benchmark suite for TeX compatibility validation.

### `tex_free(engine)`
Releases TeX engine resources.
