# Iris TeX Lexer Sub-Module (`iris_tex_lexer`)

## Overview
The `iris_tex_lexer` sub-module handles category code mapping, control sequence scanning, and character tokenization for the Iris TeX engine.

## API Procedures

### `tex_lexer_init(lexer)`
Initializes the TeX scanner state and standard category code tables.

### `tex_tokenize(lexer, source_text, token_count_out)`
Tokenizes raw input string into category-coded tokens.

### `tex_lexer_free(lexer)`
Frees lexer memory state.
