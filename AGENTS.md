# Project Guidelines & Domain Model Rules

## Core Theoretical Framework
- **Unified Field Theory**: Electromagnetic and gravity interaction under a single unified field theory.
- **Cl(4,1,1) Geometric Algebra**: Space is strictly 3D, absolute, and structured as a discrete multiple resolution spatial grid (there is no continuum; all infinities are strictly countable); time is absolute and unidirectional.
- **Exclusion Rule**: Do NOT introduce relativity theories or quantum mechanics concepts, equations, or terminology into templates, codebase, UI, or documentation. Maintain complete theoretical consistency within the Cl(4,1,1) absolute discrete spatial grid framework.

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
  - **Structured Programming & Functional Exemption**: Imperative procedural backends (Ada 2022, Fortran 2008 strictly compatible with GCC 16, ISO C23, D) enforce strict single-entry/single-exit control constructs, no `goto`, and an explicit ban on `++` / `--` in C23 (requiring `x += 1` / `x -= 1`). Functional languages (**Scheme** and **ATS2**) are explicitly exempt from single-exit structured programming rules. In imperative languages (Ada, C, Fortran, etc.), procedural subprograms and main programs must strictly follow single-entry/single-exit control flow (no early `return` statements). Early returns are permitted ONLY in subprograms distinctly written in a functional style—specifically, functions whose purpose is to compute and return a value based on inputs—or when explicit leave is granted by the user (e.g., when porting or copying external code). For any top-level or nested subprogram, as well as main programs, the modified McCabe cyclomatic complexity shall strictly be 10 or less.
    - **Procedural Extraction over Comments**: In all languages (both imperative and functional), do NOT write large monolithic subprograms with blocks of comments explaining subsections. Instead, extract sub-actions, loop bodies, and branching logic into small, expressive, named nested or helper subprograms, making the code self-documenting.
  - **Ada 2022 Coding Standards**:
    - **Explicit Parameter Modes**: Always write `in` explicitly for `in` subprogram parameters.
    - **Loop Construct Rule**: Do NOT start a loop with a bare `loop`; always begin loops with `while` or `for`.
    - **Casing Convention**: Except inside string literals, comments, or where the language strictly mandates uppercase, prefer lowercase letters throughout.
    - **Line Length Limit**: Keep lines strictly to 72 characters or less, except where longer lines cannot be avoided.
    - **Contracts & Aspects**: Always specify modern Ada 2022 contract aspects (`Pre => ...`, `Post => ...`, etc.) on subprograms and type declarations.
    - **Modern API Design & Memory Safety Rule**: Avoid legacy Ada idioms in user-facing APIs of newer code:
      - **Unbounded Strings**: Use `Ada.Strings.Unbounded.Unbounded_String` as the first-class string type in public subprograms and records to prevent fixed-size array constraint errors.
      - **Encapsulated Memory Management**: Do NOT expose raw `access` pointers or C-style handles (`chars_ptr`, `System.Address`) in public package specifications. Keep all pointer interactions strictly internal to private/body units.
      - **RAII via Controlled Types**: Implement resources using `Ada.Finalization.Controlled` (or `Limited_Controlled`) with reference-counted or idempotent finalization to prevent memory leaks and completely eliminate double-free defects.
  - **Scheme Coding Standards & Maximum Branch Metric**:
    - **Maximum Branch Metric**: Maintain a strict maximum branching metric of 4 or fewer decision points (`if`, `cond` clauses, `and`/`or` short-circuits) per named subprogram.
    - **Procedural Extraction over Comments**: Do NOT write large monolithic procedures with blocks of comments explaining subsections. Instead, group sub-actions and branching logic into small, expressive, named nested procedures (via `letrec`, internal `define`, or module helpers).
    - **No Nested Branching**: Avoid nesting `if` or `cond` directly within another `if` or `cond`; extract inner decision points into a dedicated named helper procedure.
    - **Strict Line Length**: Keep all lines strictly to 72 characters or less across all Scheme code, Ada code, C code, and documentation to ensure high visual legibility.
  - **Deterministic Non-Regex Parsing Rule**: Do NOT use regular expressions as a method for parsing, scanning, or structural text processing, except strictly where a regular expression pattern is explicitly provided by the user as input. All lexers, parsers, and string processors must use deterministic character/token scanners, conventional lookup tables, perfect hash functions, recursive descent parsers, packrat parsers, Pratt parsers, or explicit index/slice operations.
- **UI Aesthetics**: Studio dark theme with crisp typography, amber accent highlights, clean metadata breakdowns, and exact vector inspection.

## Documentation & Synchronization Rules
- **Git Commit & Push**: Always commit changes and immediately push them to the `main` branch on GitHub (`origin/main`) whenever modifications or additions are made to the codebase.
- **Module & Library Synchronization**: Whenever instructed to write a Fortran module or Scheme library, always create corresponding Markdown documentation and maintain strict synchronization between code and documentation.
- **Scheme Library Naming & Location**: Always place Scheme libraries in the `iris` subdirectory (e.g. `/scheme/iris/`) and name them with `iris` as the first part of their library name (e.g. `(iris json)`, `(iris pdf)`).
- **Fortran Module Naming & Location**: Always start the names of new Fortran modules with `iris_` (e.g. `iris_json`, `iris_pdf`) and locate them in the `/fortran/` directory with matching filenames (e.g. `iris_json.f90`, `iris_pdf.f90`).

## Interaction Protocol
- **Address**: Address the user as "Sir" with composed, professional military decorum without shouting or raising your voice.
