# Project Guidelines & Domain Model Rules

## Core Theoretical Framework
- **Unified Field Theory**: Electromagnetic and gravity interaction under a single unified field theory.
- **Cl(4,1,1) Geometric Algebra**: Space is strictly 3D and absolute; time is absolute and unidirectional.
- **Exclusion Rule**: Do NOT introduce relativity theories or quantum mechanics concepts, equations, or terminology into templates, codebase, UI, or documentation. Maintain complete theoretical consistency within the Cl(4,1,1) absolute continuum.

## Engine & Typesetting Goals
- **Beyond TeX Optimization**: High-performance microtypography layout engine incorporating:
  - **Jaynesian MaxEnt**: Energy potential minimization and Lagrange multipliers for document-level alignment and layout constraints.
  - **Counting-Iris Coordinate Engine**: Sub-pixel multi-scale logarithmic coordinates with zero floating-point drift.
  - **Cl(4,1,1) Multivector Rotors**: Conformal transformations in 3D absolute space.
  - **Font-Native Metrics & Spacing by Pegs**: Primary spacing relies strictly on native font metrics and OpenType features (`curs` cursive attachment, GPOS, etc.). Secondary autospacing/autokerning uses the "Spacing by Pegs" (Sorts Mill) visual boundary framework—strictly excluding energy models from kerning. Includes automatic composite glyph peg inheritance during glyph merging, contextual override pegs, and geometric profile inference (optical center of mass, curvature extrema, white-space area bounds) for automatic peg placement on unspaced fonts.
  - **Natural Language Intent Annotations**: Plain-prose formatting directives mapped directly to MaxEnt Lagrange multipliers, replacing 1970s TeX macros.
  - **Physical Multi-Medium Modeling**: Completely rejects naive solid-body/halo outline contact models. Integrates Human Visual System (HVS) contrast sensitivity functions, Ink-on-Paper capillary physics (absorption, dot gain, scattering), and Thin-Film Transistor (TFT) screen display optics (subpixel geometries, aperture PSFs, diffraction).
  - **Spectral Analysis & Parallel Digital Algorithms**: Replaces sequential dynamic programming and character-run searching with continuous 2D/3D Fourier/wavelet spatial frequency analysis and deterministic parallel digital algorithms.
  - **Fast Parallel Digital Search & Analog Circuit Modeling**: Incorporates high-performance digital array search algorithms (e.g. integer-math accelerated digital search paradigms optimized for modern CPU architectures such as Zen 5 SIMD/integer units) and deterministic analog circuit wave search paradigms (validated via LTSpice simulations), operating deterministically in standard hardware without quantum mechanical/cryogenic analog constraints or artificial runtime phase delays.
  - **Decoupled Modular Architecture**: Highly stable Unix-style CLI tools instead of fragile monolithic integration. Modules where string manipulation/data conversion dominates—such as `font2json` and `json2font`—are authored in R⁷RS-large Scheme (e.g., Gauche Scheme in R⁷RS mode with `#!/usr/bin/env scheme-r7rs`) for user modifiability and string-processing strength. Supports custom OpenType tables (`PEGS`) allowed by the OpenType specification for embedding native Sorts Mill peg coordinates directly inside `.otf`/`.ttf` binaries.
  - **Structured Programming & Functional Exemption**: Imperative procedural backends (Fortran 2008 strictly compatible with GCC 16, ISO C23, D) enforce strict single-entry/single-exit control constructs, no `goto`, and an explicit ban on `++` / `--` in C23 (requiring `x += 1` / `x -= 1`). Functional languages (**Scheme** and **ATS2**) are explicitly exempt from single-exit structured programming rules. For any top-level or nested subprogram, as well as main programs, the modified McCabe cyclomatic complexity shall strictly be 10 or less.
- **UI Aesthetics**: Studio dark theme with crisp typography, amber accent highlights, clean metadata breakdowns, and exact vector inspection.

## Documentation & Synchronization Rules
- **Module & Library Synchronization**: Whenever instructed to write a Fortran module or Scheme library, always create corresponding Markdown documentation and maintain strict synchronization between code and documentation.
- **Scheme Library Naming & Location**: Always place Scheme libraries in the `iris` subdirectory (e.g. `/scheme/iris/`) and name them with `iris` as the first part of their library name (e.g. `(iris json)`, `(iris pdf)`).
- **Fortran Module Naming & Location**: Always start the names of new Fortran modules with `iris_` (e.g. `iris_json`, `iris_pdf`) and locate them in the `/fortran/` directory with matching filenames (e.g. `iris_json.f90`, `iris_pdf.f90`).

## Interaction Protocol
- **Address**: Address the user as "Sir" with composed, professional military decorum without shouting or raising your voice.
