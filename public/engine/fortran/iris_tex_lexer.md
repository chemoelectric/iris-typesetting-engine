# Iris TeX Lexer Sub-Module (`iris_tex_lexer`)

## Overview
The `iris_tex_lexer` sub-module handles category code mapping, control sequence scanning, comment filtering (`%`), character tokenization, and blank line `\par` macro generation for the Iris TeX engine.

## API Procedures

### `tex_lexer_init(lexer)`
Initializes the TeX scanner state and standard category code tables.

### `tex_tokenize(lexer, source_text, token_count_out)`
Tokenizes raw input string into category-coded tokens according to TeX catcode rules (0: Escape, 1: Left Brace, 2: Right Brace, 3: Math Shift, 11: Letter, 12: Other, 14: Comment), mapping blank lines to `\par` escape tokens.

### `tex_lexer_free(lexer)`
Frees lexer memory state.

