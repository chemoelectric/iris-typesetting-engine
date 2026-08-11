# Iris TeX Math Sub-Module (`iris_tex_math`)

## Overview
The `iris_tex_math` sub-module formats inline and display mathematical formulas according to Knuthian math mode layout rules (Appendix G of The TeXbook).

## API Procedures

### `tex_math_init(math_eng)`
Initializes math mode layout engine and font style parameters.

### `tex_typeset_math(math_eng, formula_str, math_ast, status)`
Typesets mathematical expressions into structured AST boxes and glue.

### `tex_math_free(math_eng)`
Frees math layout engine memory state.
