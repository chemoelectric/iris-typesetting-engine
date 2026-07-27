# Iris TeX Parser Sub-Module (`iris_tex_parser`)

## Overview
The `iris_tex_parser` sub-module performs macro expansion, token stream parsing, and internal register lookup (`\count`, `\dimen`, `\skip`, `\toks`).

## API Procedures

### `tex_parser_init(parser)`
Initializes the TeX parser engine and register state.

### `tex_parse_tokens(parser, source, ast_out, status)`
Parses macro-expanded token stream into JSON layout AST.

### `tex_parser_free(parser)`
Frees parser memory resources.
