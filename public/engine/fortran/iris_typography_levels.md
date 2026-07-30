# Module: `iris_typography_levels`

## Overview
The `iris_typography_levels` module defines the architecture for progressive typography levels in the Iris typesetting system. It provides a clean, modular abstraction bridging traditional Knuth TeX box-and-glue macro processing with advanced microtypography and continuous spatial frequency algorithms.

## Theoretical Framework & Levels

### Level 0: Classic TeX Interception
- **Model**: Standard Knuth Box-and-Glue Node Model.
- **Compatibility**: Full compatibility with Plain TeX, LaTeX, AMS-LaTeX, and standard macro packages without modification.
- **Font Metrics**: Standard TFM/OpenType metrics.

### Level 1: Microtypography & Sorts Mill Pegs
- **Model**: Jaynesian MaxEnt paragraph energy optimization paired with Sorts Mill visual boundary pegs.
- **Features**: Sub-pixel kerning, contextual override pegs, automatic optical center-of-mass peg placement for unspaced fonts, and OpenType `PEGS` table integration.
- **Font Metrics**: Native font metrics + OpenType GPOS + Sorts Mill Peg boundary coordinates.

### Level 2: Continuous Fourier Spectral Typography
- **Model**: Continuous 2D/3D Fourier/wavelet spatial frequency analysis and $Cl(4,1,1)$ multivector rotors.
- **Features**: Complete bypass of discrete box-and-glue constraints for complex cursive connecting scripts (e.g., Caflisch Script), fluid glyph transformations, and absolute continuum 3D placement.

## Public API & Subroutines

- **`TYPO_LEVEL_0_CLASSIC_TEX`**: Parameter integer `0`.
- **`TYPO_LEVEL_1_MICROTYPO_PEGS`**: Parameter integer `1`.
- **`TYPO_LEVEL_2_FOURIER_SPECTRAL`**: Parameter integer `2`.
- **`typography_config_init(config, level)`**: Initializes configuration structure for specified level.
- **`typography_evaluate_level(config)`**: Returns descriptive string of active typesetting strategy.
- **`typography_export_json(config, json_obj)`**: Serializes active typography configuration into JSON AST representation.

## Synchronization & Standard
- **Language Standard**: Fortran 2008 (ISO/IEC 1539-1:2010).
- **Control Constructs**: Strict single-entry / single-exit routines, zero `goto` statements, cyclomatic complexity $\le 10$.
