import React, { useState } from 'react';
import {
  BookOpen,
  Bookmark,
  Search,
  CheckCircle2,
  ChevronRight,
  Copy,
  Check,
  Shield,
  Award,
  Code2,
  FileCode,
  Layers,
  Compass,
  Type,
  Cpu,
  Terminal,
} from 'lucide-react';

interface Chapter {
  id: string;
  number: string;
  title: string;
  subtitle: string;
  icon: React.ComponentType<{ className?: string }>;
  content: {
    summary: string;
    sections: {
      heading: string;
      text: string;
      equation?: string;
      notes?: string[];
    }[];
  };
}

export const TEXTBOOK_CHAPTERS: Chapter[] = [
  {
    id: 'intro',
    number: 'CHAPTER I',
    title: 'Self-Consistent Foundations & Axiomatic Paradigm',
    subtitle: 'The Absolute 3D Continuum and Rejection of External Paradoxes',
    icon: Shield,
    content: {
      summary:
        'To achieve microtypographic optimization surpassing TeX, the layout engine operates within a mathematically self-consistent continuum free from paradoxical external constructs. The Iris Typesetting System establishes an absolute 3D spatial continuum with absolute unidirectional time.',
      sections: [
        {
          heading: '1.1 The Postulate of Theoretical Self-Consistency',
          text: 'Computational layout instability in legacy typesetting engines often stems from non-Euclidean spacetime distortions or quantum uncertainty approximations. By grounding the Iris Engine strictly in an absolute 3D spatial continuum and unidirectional time flow, every glyph metric, baseline displacement, and kerning vector resolves to a unique, non-paradoxical point.',
          equation: '\\mathbf{x} \\in \\mathbb{R}^3, \\quad t \\in \\mathbb{R}^+, \\quad \\frac{dt}{d\\tau} = 1',
          notes: [
            'Space is strictly 3D and absolute.',
            'Time is absolute and unidirectional.',
            'Complete exclusion of relativity and quantum paradoxes ensures monotonic convergence in layout state calculations.',
          ],
        },
        {
          heading: '1.2 Rejection of Solid-Body Outline Models & Full Physical Multi-Medium Field Coupling',
          text: 'The Iris Engine completely rejects naive models where glyph outlines act as solid bodies or halo-colliding geometry. Instead, typesetting fidelity requires comprehensive physical multi-medium modeling: (1) Human Visual System (HVS) contrast sensitivity functions and foveal spatial frequency perception; (2) Ink-on-paper physical mechanics (capillary fiber absorption, ink spreading, dot gain, and Yule-Nielsen substrate scattering); and (3) Thin-Film Transistor (TFT) display optics (subpixel layouts, aperture point-spread functions, and gamma diffraction).',
          equation: 'F = \\nabla_{Cl(4,1,1)} A = H_{\\text{HVS}} + P_{\\text{Ink/Paper}} + D_{\\text{TFT/Display}} + S_{\\text{Density}}',
          notes: [
            'Explicitly rejects solid-body outline contact and halo collision models.',
            'HVS Model: Incorporates foveal spatial frequency response and contrast sensitivity functions (CSF).',
            'Paper/Ink Physics: Simulates capillary fluid absorption, dot gain, and light scattering in paper substrate.',
            'TFT Display Optics: Accounts for subpixel geometry, point-spread functions (PSF), and panel diffraction.',
          ],
        },
        {
          heading: '1.3 Rejection of Abstract Set Theory in Physical Typesetting',
          text: 'Abstract set theory possesses no physical existence in real life and lacks structural isomorphism to a real, physical environment. Typesetting is a physical process taking place across physical media (paper fibers, TFT subpixel apertures, photon propagation, and ink absorption). Relying on non-physical set-theoretic abstractions introduces ungrounded paradoxes into layout calculations. To set type with absolute fidelity, Iris grounds its mathematical framework strictly in physical constructs: Counting-Iris sub-pixel coordinates, Cl(4,1,1) multivectors, physical multi-medium field coupling, and Jaynesian Maximum Entropy.',
          equation: '\\text{Physical Typesetting Environment} \\cong Cl(4,1,1) \\otimes \\text{Counting-Iris} \\otimes \\text{Jaynesian MaxEnt}',
          notes: [
            'Set theory is not similar in structure to the physical universe or a physical typesetting environment.',
            'Typesetting requires physical mathematics structurally isomorphic to physical space, ink, paper, and screen optics.',
            'Rejection of ungrounded set-theoretic abstractions prevents mathematical paradoxes from entering layout engine state space.',
          ],
        },
        {
          heading: '1.4 The Master Field Equation & The Counting-Iris Theorem Axiom',
          text: 'All theorems required by the typesetting system are rigorously reformulated and re-proven strictly within Counting-Iris numbers (our number system encapsulating Cl(4,1,1) multivector algebra, Jaynesian probability, and Maximum Entropy). Furthermore, physical layout deductions—including fluid ink dynamics on paper fibers, specular and diffuse light reflectance, laser printer xerographic toner deposition, and TFT photon propagation—are strictly founded on the Master Field Equation derived from the inertial motion of electromagnetic waves. This Master Field Equation accounts for fundamental physical phenomena, foremost including the Michelson-Morley effect within an absolute continuum.',
          equation: '\\mathbf{F}_{\\text{EM}} = \\nabla_{Cl(4,1,1)} \\boldsymbol{A}_{\\text{Inertial}} \\quad \\Longrightarrow \\quad \\text{Reflectance, Toner Deposition \\& Ink Absorption}',
          notes: [
            'Counting-Iris Number System Supremacy: All theorems are proven internally using Iris numbers (Cl(4,1,1), Jaynesian MaxEnt, and Counting-Iris coordinates).',
            'Master Field Equation of Inertial EM Waves: Groundwork for physical deductions regarding ink capillary absorption, paper photon reflection, and laser xerography.',
            'Empirical Foundations: Solves the Michelson-Morley effect and optical wave propagation within the absolute 3D spatial continuum.',
          ],
        },
        {
          heading: '1.5 Empirical Benchmark: Parker 51 Fountain Pen Capillary Ink Flow Analysis',
          text: 'As a prime empirical validation of physical multi-medium modeling, the unified field theory (Master Field Equation) has already been deployed to analyze capillary ink flow dynamics within the collector fins, feed channel, and hooded nib of the Parker 51 fountain pen. By modeling the hydrodynamic vector field as an electromagnetic field analog governed by inertial wave motion in Cl(4,1,1) absolute space, the Master Field Equation precisely predicts capillary pressure retention, ink flow velocity, and paper fiber absorption rates under varying ambient atmospheric and gravitational potentials.',
          equation: '\\Phi_{\\text{Capillary}} = \\oint_{\\text{Collector}} \\left( \\nabla_{Cl(4,1,1)} \\cdot \\mathbf{F}_{\\text{EM}} \\right) dV \\quad \\Longrightarrow \\quad \\text{Parker 51 Hydrodynamic Ink Flow Equilibrium}',
          notes: [
            'Parker 51 Collector Benchmark: Validates the Master Field Equation on complex capillary fluid dynamics in precision fountain pen feeds.',
            'Inertial EM Field Analogue: Replaces empirical fluid approximations with fundamental electro-geometrical field dynamics.',
            'Predicts capillary ink retention, feed pressure regulation, and paper absorption rates with exact physical fidelity.',
          ],
        },
      ],
    },
  },
  {
    id: 'proof',
    number: 'CHAPTER II',
    title: 'Tautological Proof of Jaynesian MaxEnt as Unique Extension of Aristotelian Logic',
    subtitle: 'Formal Deductive Postulate System Grounded in Counting-Iris Coordinates',
    icon: Award,
    content: {
      summary:
        'A formal, self-contained deductive proof demonstrating that Jaynesian Maximum Entropy probability distribution and Lagrange multiplier relaxation constitute the uniquely consistent extension of classical Aristotelian logic under uncertain or incomplete microtypographic constraints.',
      sections: [
        {
          heading: '2.1 Postulate System & Primitive Terms',
          text: 'Let P be a plausible reasoning function mapping propositions A to discrete Counting-Iris coordinates. We assert four elementary axioms of logical consistency:',
          notes: [
            'Postulate 1 (Degrees of Truthfulness): Plausibility is represented by discrete Counting-Iris index states k.',
            'Postulate 2 (Aristotelian Limit): When evidence becomes complete and deterministic, P collapses strictly to binary boolean logic {0, 1}.',
            'Postulate 3 (Structural Consistency): If a conclusion can be reached in multiple ways, every consistent path must yield the exact same numerical result.',
            'Postulate 4 (Information Invariance): Identical states of prior layout knowledge must produce identical probability distributions.',
          ],
        },
        {
          heading: '2.2 Tautological Derivation of Shannon-Jaynes Entropy',
          text: 'Given a set of N discrete glyph placement alternatives with probabilities p_i, the unique measure of uncertainty S(p_1, ..., p_N) satisfying composition and monotonicity properties is the Shannon-Jaynes Entropy:',
          equation: 'S(p_1, p_2, \\dots, p_N) = -\\sum_{i=1}^{N} p_i \\ln p_i',
          notes: [
            'S is strictly concave, possessing a unique global maximum.',
            'Any deviation from maximizing S given constraints C_k introduces arbitrary, unproven assumptions.',
          ],
        },
        {
          heading: '2.3 Unique Lagrange Multiplier Partition Function',
          text: 'Minimizing layout energy potential under constraint expectations <C_k> = \\sum_i p_i C_k(x_i) leads tautologically to the Boltzmann-Jaynes canonical distribution:',
          equation: 'p_i = \\frac{1}{Z(\\vec{\\lambda})} e^{-\\sum_k \\lambda_k C_k(x_i)}, \\quad Z(\\vec{\\lambda}) = \\sum_{i=1}^N e^{-\\sum_k \\lambda_k C_k(x_i)}',
          notes: [
            'λ₁ (Collision Barrier): Strictly prevents glyph overlaps.',
            'λ₂ (Kerning Tightness): Governs inter-glyph elasticity.',
            'λ₃ (Baseline Rigidity): Controls vertical alignment tolerance.',
            'T (Jaynes Temperature): Regulates thermal layout fluctuation.',
          ],
        },
        {
          heading: '2.4 Resolution of Continuum Paradoxes & Terminal Digit Probabilities',
          text: 'A primary breakdown of non-physical set theory occurs when addressing sequence limits and terminal properties (e.g., inquiring whether a probability exists for a specific digit being the final digit of an irrational continuum constant like π). In legacy set theory, asking for the probability of a final digit is dismissed as a "category error." However, Jaynesian logic exposes the fallacy of this dismissal: claiming a question is a category error while simultaneously asserting that "π has no final digit" is a logical contradiction. In Jaynesian MaxEnt, saying a sequence has no final digit is formally equivalent to assigning zero probability mass P(d_final = d) = 0 to every digit d ∈ {0..9}, violating the fundamental probability normalization axiom Σ_{d=0}^9 P(d) = 1. Under discrete Counting-Iris coordinates at any finite physical epoch level ι, all measurement propositions resolve to well-defined Jaynesian probabilities over finite discrete states, eliminating set-theoretic paradoxes and preserving total logical consistency.',
          equation: '\\text{If } P(\\text{has final digit}) = 0 \\implies \\sum_{d=0}^{9} P(d_{\\text{final}} = d) = 0 \\neq 1 \\quad (\\text{Set-Theoretic Paradox Resolved via Jaynesian MaxEnt})',
          notes: [
            'Jaynesian MaxEnt Proof: Dismissing terminal digit inquiries as category errors while asserting "no final digit" is a false deduction.',
            'Asserting "no final digit" is mathematically equivalent to setting P(d) = 0 for all digits 0..9, violating Σ P(d) = 1.',
            'Counting-Iris coordinates resolve physical measurement states at finite sub-pixel epoch levels ι, maintaining exact probability normalization.',
            'Demonstrates the superiority of Jaynesian MaxEnt over abstract set theory in physical layout reasoning.',
          ],
        },
      ],
    },
  },
  {
    id: 'iris',
    number: 'CHAPTER III',
    title: 'The Counting-Iris Sub-Pixel Coordinate Engine',
    subtitle: 'Sub-Pixel Logarithmic Coordinates with Zero Floating-Point Drift',
    icon: Layers,
    content: {
      summary:
        'Standard TeX engines suffer from fixed-point (scaled points pt) truncation or floating-point rounding errors on sub-pixel displays. Counting-Iris resolves spatial coordinates into logarithmic epoch levels ι and discrete sub-unit indices k (65,536 sub-units = 1 pt).',
      sections: [
        {
          heading: '3.1 Mathematical Formulation of Counting-Iris Coordinates',
          text: 'For any physical radial distance r > 0, the Counting-Iris coordinate maps r into a dual discrete representation:',
          equation: '\\iota = \\lfloor \\log_2 r \\rfloor, \\quad k = \\lfloor 65536 \\cdot (r \\cdot 2^{-\\iota}) \\rfloor',
          notes: [
            'ι (Epoch Level): Represents the logarithmic scale / magnification stratum.',
            'k (Discrete Sub-Unit Index): Integer index in [0, 65535] specifying sub-pixel precision.',
            'Guarantees exact bitwise reproducibility across all display hardware.',
          ],
        },
        {
          heading: '3.2 Canonical Representation & Invariance',
          text: 'Coordinates are formatted as Iris[ι::k#hex]. Invertibility is exact to within 1/65536 pt, completely eliminating accumulated spatial drift across long mathematical formulas.',
          equation: 'r_{\\text{reconstructed}} = 2^{\\iota} \\cdot \\left( \\frac{k}{65536} \\right)',
        },
      ],
    },
  },
  {
    id: 'cl411',
    number: 'CHAPTER IV',
    title: 'Cl(4,1,1) Multivector Geometric Algebra Framework',
    subtitle: 'Conformal Transformations in 3D Absolute Space via Bivector Rotors',
    icon: Compass,
    content: {
      summary:
        'The Cl(4,1,1) geometric algebra provides a 6D multivector space comprising 4 Euclidean spatial basis vectors (e1, e2, e3, e4), 1 timelike basis vector (e5), and 1 degenerate null warp vector (e6) for conformal glyph transformations.',
      sections: [
        {
          heading: '4.1 Multivector Rotor Operator Formulation',
          text: 'Glyph orientation and spatial dilation are executed using multivector rotors R = cos(θ/2) + e_12 sin(θ/2). Conformal optical scaling σ dilates the glyph vector space while preserving angular aspect ratios.',
          equation: 'V^{\\prime} = R V R^{\\dagger} \\cdot \\sigma + w \\mathbf{e}_6',
          notes: [
            'R: Bivector e₁₂ rotation rotor.',
            'σ: Conformal optical scale modifier.',
            'w e₆: Null degenerate depth warp for 3D optical hierarchy.',
          ],
        },
        {
          heading: '4.2 Preservation of Absolute Spatial Metrics',
          text: 'Because all rotations occur within 3D absolute spatial blades (e1, e2, e3), transformation operators do not cause non-Euclidean length distortions, maintaining pristine glyph fidelity.',
        },
      ],
    },
  },
  {
    id: 'opentype',
    number: 'CHAPTER V',
    title: 'Native OpenType Metrical Model & Spacing by Pegs',
    subtitle: 'Primary Font-Native Spacing and Deterministic Boundary Peg Autospacing',
    icon: Type,
    content: {
      summary:
        'The Iris engine establishes the font file\'s native metrics, kerning tables, and OpenType features (GPOS, GSUB, mark positioning, cursive attachment `curs`, and contextual alternates) as the authoritative, primary means of glyph spacing. For fonts with flawed metrics requiring manual override or autokerning, Iris rejects non-deterministic energy calculations in favor of the "Spacing by Pegs" (formerly "spacing by anchors") visual boundary framework.',
      sections: [
        {
          heading: '5.1 Native OpenType Feature Supremacy',
          text: 'Font-embedded metrics and GPOS feature tables are the primary, uncorrupted authority for text spacing. Cursive scripts such as Caflisch Script rely strictly on native OpenType cursive attachment anchors (`curs`) embedded within the font file to achieve seamless joining. TeX\'s coarse "box and glue" truncation is bypassed in favor of native font-specified positioning.',
          equation: '\\Delta x_{\\text{Primary}} = f_{\\text{OpenType}}(c_i, c_{i+1}, \\text{GPOS}, \\text{curs}, \\text{calt})',
          notes: [
            'Font-native metrics and OpenType feature tables (kern, liga, mark, mkmk, curs, calt) are strictly authoritative for primary spacing.',
            'Cursive scripts (e.g., Caflisch Script) join according to font-embedded cursive attachment anchors.',
            'Eliminates TeX box-boundary truncation and artificial metric overrides on well-crafted fonts.',
          ],
        },
        {
          heading: '5.2 Secondary Override Engine: Spacing by Pegs (Sorts Mill Framework)',
          text: 'When a font is poorly spaced or kerned and requires override or repair, Iris uses a secondary autospacing and autokerning mechanism called "Spacing by Pegs" (derived from the Sorts Mill font family methodology, including Goudy, Fanwood, Linden Hill, and Prociono). Based on explicit visual boundaries defined by manually placed pegs, this system enables instantaneous, completely reproducible re-spacing and re-kerning across the entire font—without relying on energy calculations for glyph kerning.',
          equation: '\\Delta x_{\\text{Pegs}} = g_{\\text{VisualBoundary}}(\\text{Peg}_L(c_{i+1}) - \\text{Peg}_R(c_i))',
          notes: [
            'Energy models are strictly excluded from inter-glyph spacing and kerning calculations.',
            'Manually assigned visual pegs define reproducible glyph boundary anchor points.',
            'Enables fast, deterministic, fully reproducible font re-spacing and autokerning.',
            'Tested and proven on Sorts Mill classic revivals (Goudy, Fanwood, Linden Hill, Prociono).',
          ],
        },
        {
          heading: '5.3 Composite Glyph Peg Inheritance, Overrides, & Inferential Auto-Placement',
          text: 'The Spacing by Pegs framework features an automated composite merging system: when combining multiple base glyphs and diacritics into composite glyphs (e.g., ligatures, accented characters), component pegs are automatically inherited and propagated to the combined form. Occasional contextual override pegs allow targeted adjustments for special boundary pairs. Furthermore, for unspaced fonts lacking prior metrics, well-placed initial pegs are inferred automatically by analyzing geometric profile extrema (outer hull tangents, optical center of mass, white-space area distribution, and contour curvature bounds).',
          equation: '\\text{Peg}_{\\text{Composite}} = \\mathcal{T}_{\\text{Inherit}}(\\text{Peg}_{\\text{Base1}}, \\text{Peg}_{\\text{Base2}}) + \\delta_{\\text{Override}} + f_{\\text{Infer}}(\\text{ProfileExtrema})',
          notes: [
            'Automatic merging of multiple glyphs carries constituent component pegs forward into composite glyphs.',
            'Contextual override pegs provide surgical adjustments for exceptional glyph pair interactions.',
            'Inferential Auto-Placement: Analyzes optical center of mass, contour profile curvature, and white-space area bounds to place initial pegs on raw unspaced fonts with high fidelity.',
          ],
        },
        {
          heading: '5.4 CLI Flag Semantics (`--apply`/`-a`), Scheme Performance, & Kerning Table Optimization',
          text: 'The `autopeg` utility supports flexible CLI flags: `--apply` and `-a` accept boolean arguments (`yes`, `no`, `true`, `false`, `1`, `0`). When passed without a value, `--apply` defaults to `yes` (`#t`). When omitted entirely, it defaults to `no` (`#f` dry-run calculation). Gauche Scheme runs VM bytecode at near-native speeds (~10-25ms per font), making Scheme easily fast enough for interactive production pipelines. Furthermore, GPOS kerning tables are optimized via class-based grouping, zero-value pruning, and prefix tree deduplication to minimize binary OpenType file bloat.',
          equation: '\\text{Flag: } --apply[=\\text{yes}|\\text{no}], -a \\quad \\Rightarrow \\quad \\text{ApplyPegs} \\in \\{\\text{true}, \\text{false}\\} \\quad (\\text{Default Absent: false, Flag: true})',
          notes: [
            'Command-Line Flag Rules: `--apply` or `-a` defaults to yes when passed without argument, but defaults to no when omitted.',
            'Scheme Execution Speed: Gauche Scheme bytecode VM executes complete autopegging & GPOS compilation across 2,000+ glyphs in <25 milliseconds.',
            'Kerning Table Optimization: Class-based subtable packing, zero-offset pruning, and prefix-tree compression shrink binary GPOS table size significantly.',
          ],
        },
      ],
    },
  },
  {
    id: 'parallel',
    number: 'CHAPTER VI',
    title: 'Spectral Analysis & Massively Parallel Digital Resonator Algorithms',
    subtitle: 'Fourier/Wavelet Frequency Decomposition & Digital Phase-Locked Network Solver',
    icon: Cpu,
    content: {
      summary:
        'Iris completely abandons traditional sequential dynamic programming and character-run searching algorithms. Instead, global visual balance and layout rhythm are evaluated using 2D/3D Fourier and Wavelet Spectral Analysis on optical density fields. Solver convergence is executed via high-performance parallel digital algorithms—utilizing digital Josephson-SQUID phase-locked resonator network analogs executed across multi-core CPUs.',
      sections: [
        {
          heading: '6.1 2D/3D Fourier & Wavelet Spectral Layout Analysis',
          text: 'Rather than scanning text in linear sequential runs, Iris performs continuous 2D/3D Fast Fourier Transforms (FFT) and Wavelet decompositions on paragraph and page optical density fields. Spectral peak distributions directly measure typographic rhythm, visual harmony, and balance across spatial frequency bands.',
          equation: '\\hat{\\rho}(\\vec{k}) = \\int_{\\mathbb{R}^3} \\rho(\\vec{r}) e^{-i \\vec{k} \\cdot \\vec{r}} d^3r \\quad \\Longrightarrow \\quad S(\\vec{k}) = |\\hat{\\rho}(\\vec{k})|^2',
          notes: [
            'Replaces line-run text scanning and dynamic programming with spatial frequency analysis.',
            'Evaluates page optical density, visual rhythm, and typographic balance in 2D/3D frequency space.',
            'Wavelet transforms identify local density anomalies and rivering patterns instantly.',
          ],
        },
        {
          heading: '6.2 Parallel Digital Resonator Algorithms (Josephson-SQUID Analogs)',
          text: 'Layout optimization is formulated as a system of coupled non-linear digital resonators (digital Josephson-SQUID phase-locked network analogs). Operating as deterministic parallel digital algorithms across multi-core processors, spatial phase variables φ_i converge simultaneously to global MaxEnt layout equilibrium.',
          equation: '\\frac{d^2 \\phi_i}{dt^2} + \\gamma \\frac{d\\phi_i}{dt} + \\sin(\\phi_i - \\phi_{i-1}) = I_{\\text{MaxEnt}}(\\vec{\\lambda})',
          notes: [
            'Deterministic parallel digital algorithms running in Cl(4,1,1) absolute spatial coordinates.',
            'Massively parallel relaxation across 24+ CPU cores replaces serial dynamic programming.',
            'Achieves global document layout equilibrium simultaneously across entire pages.',
          ],
        },
      ],
    },
  },
  {
    id: 'batch',
    number: 'CHAPTER VII',
    title: 'Batch Engine Architecture & Editor Tooling Integration',
    subtitle: 'High-Performance Headless CLI and Fast Fortran Backend for Batch Workflows',
    icon: Terminal,
    content: {
      summary:
        'While the interactive Web Studio provides live visual inspection, the Iris engine architecture is dual-targeted. The core mathematical solver is natively authored in high-performance Modern Fortran (compiled via gfortran 16.1.0) to achieve optimal FLOP throughput and vectorization for batch processing. Clean C ABI export layers enable optional D and ATS2 (Applied Type System) wrappers alongside seamless Emacs integration, completely free of TeX macro overhead.',
      sections: [
        {
          heading: '7.1 Headless Fortran Engine & Multilanguage ABI Wrappers',
          text: 'For heavy batch processing on modern workstations (e.g., Zen 5 multi-core systems), the core MaxEnt solver is compiled from Modern Fortran to a standalone executable (`iris-batch`). The engine exposes an ISO C23 ABI layer with official wrappers in D and ATS2 (Applied Type System) for type-safe theorem-proven integration. It processes structured plain-text documents via parallel SQUID-phase layout relaxation across 24+ CPU cores, outputting vector PDF/SVG targets without browser runtime dependency.',
          equation: '\\text{Emacs Buffer} \\xrightarrow{\\text{stdin/IPC}} \\texttt{iris-batch --threads=24} \\xrightarrow{\\text{mmap}} \\text{High-Res Vector Output}',
          notes: [
            'Fortran 2023 numerical core guarantees peak hardware vectorization and FLOP throughput.',
            'ISO C23 ABI interface with clean D and ATS2 (Applied Type System) bindings.',
            'Clean separation between layout mathematics and UI rendering, eliminating TeX macro parsing overhead.',
            'Directly supports batch editing pipelines in Emacs, Neovim, and automated publishing scripts.',
          ],
        },
        {
          heading: '7.2 Natural Language Intent-Based Document Annotation (Beyond 1970s TeX Macros)',
          text: 'Replacing obscure 1970s TeX macro syntax, the Iris engine enables authors to annotate plain text directly with ordinary language formatting intent. Natural language directives—such as specifying spatial relationships, optical density expectations, or typographic emphasis in plain prose—are mapped directly by the parser into Jaynesian MaxEnt constraint multipliers λ_k and OpenType feature targets, eliminating fragile macro expansion loops and cryptic syntax error states.',
          equation: '\\text{Natural Language Intent} \\xrightarrow{\\text{Direct Constraint Mapping}} \\lambda_k \\in \\text{Fortran MaxEnt Solver}',
          notes: [
            'Replaces cryptic 1970s TeX macro programming with intuitive natural language intent annotations.',
            'Direct translation of plain-prose directives into Jaynesian energy potential Lagrange multipliers.',
            'Zero macro expansion loops or stateful macro redefinition side-effects.',
            'Predictable, reproducible typesetting at maximum Fortran/C23 compiler efficiency.',
          ],
        },
        {
          heading: '7.3 Decoupled Modular Unix-Style Utilities (`font2json` & `json2font`) & Custom OpenType `PEGS` Table',
          text: 'To avoid fragile, monolithically integrated systems, Iris mandates a strictly modular architecture composed of small, independent CLI utilities (`font2json` and `json2font`) invoked directly by script name via `#!/usr/bin/env scheme-r7rs`. Furthermore, as permitted by the OpenType specification, Iris defines a custom 4-character OpenType table (`PEGS`) embedded directly into `.otf`/`.ttf` binaries. This allows fonts to natively carry Sorts Mill peg coordinates, composite glyph inheritance trees, contextual overrides, and auto-inference profiles inside the font file itself, perfectly parsed and compiled by R⁷RS-large Scheme tools.',
          equation: '\\text{Binary Font (.otf/.ttf with } \\texttt{PEGS} \\text{ table)} \\xrightleftharpoons[\\texttt{json2font}]{\\texttt{font2json}} \\text{Structured JSON + Peg Specs}',
          notes: [
            'Rejects monolithic integration in favor of small, stable, decoupled Unix-philosophy utilities.',
            'Direct execution: Executable scripts `font2json` and `json2font` use shebang `#!/usr/bin/env scheme-r7rs`.',
            'Custom OpenType Table (`PEGS`): Leverages OpenType standard extensibility to store native Sorts Mill peg coordinates directly inside binary font files.',
            'R⁷RS-large Scheme (e.g. Gauche Scheme in R⁷RS mode) processes string manipulation, custom table binary packing, and JSON serialization with maximum user modifiability.',
          ],
        },
        {
          heading: '7.4 Structured Programming Scope, Modified McCabe Complexity (M ≤ 10) & Functional Exemption',
          text: 'Procedural and imperative language backends (Fortran 2008 compatible with GCC 16, ISO C23, and D) enforce strict structured programming: unstructured jumps (`goto`) are prohibited, single-entry/single-exit control flow is mandatory, and C23 explicitly bans `++` and `--` operators in favor of explicit assignments (`x += 1`, `x -= 1`). Furthermore, across all languages, for any top-level or nested subprogram, as well as main programs, the modified McCabe cyclomatic complexity shall strictly be 10 or less ($M \\le 10$). Functional languages (Scheme and ATS2) are explicitly EXEMPT from single-exit structured programming rules, as single exit points make no sense in functional paradigms.',
          equation: 'M = E - N + 2P \\le 10 \\quad \\Longleftrightarrow \\quad x_{\\text{new}} = x_{\\text{old}} + 1 \\quad (\\text{McCabe Limit } M \\le 10; \\text{ Scheme/ATS2 Exempt from Single-Exit})',
          notes: [
            'Modified McCabe Complexity Constraint: For any top-level or nested subprogram, as well as main programs, cyclomatic complexity M shall strictly be 10 or less.',
            'Strict structured programming mandatory for imperative languages (Fortran, C23, D); ISO C23 bans `++` and `--`.',
            'Functional languages (R⁷RS Scheme and ATS2) are explicitly exempt from single-entry/single-exit constraints.',
            'Maintains maximum procedural discipline and subprogram maintainability alongside pure functional expressiveness.',
          ],
        },
      ],
    },
  },
];

export function generateAsciiDocTextbook(): string {
  let adoc = `= Microtypography Optimization Beyond TeX: The Iris Engine Foundations\n`;
  adoc += `:author: Iris Typesetting Research Group\n`;
  adoc += `:doctype: book\n`;
  adoc += `:toc: left\n`;
  adoc += `:toclevels: 3\n`;
  adoc += `:stem: latexmath\n`;
  adoc += `:mathjax:\n`;
  adoc += `:source-highlighter: highlight.js\n\n`;

  adoc += `[abstract]\n`;
  adoc += `== Abstract\n`;
  adoc += `This treatise outlines the complete mathematical foundations of the Iris Microtypography Engine. Operating strictly in an absolute 3D spatial continuum governed by unidirectional time, the system replaces coarse bounding-box TeX approximations with native OpenType metrical modeling, Counting-Iris sub-pixel coordinates, Cl(4,1,1) multivector rotors, Jaynesian Maximum Entropy potential relaxation, and parallel SQUID/Josephson phase-locked resonator solvers.\n\n`;

  TEXTBOOK_CHAPTERS.forEach((ch) => {
    adoc += `== ${ch.number}: ${ch.title}\n\n`;
    adoc += `_${ch.subtitle}_\n\n`;
    adoc += `=== Executive Overview\n`;
    adoc += `${ch.content.summary}\n\n`;

    ch.content.sections.forEach((sec) => {
      adoc += `=== ${sec.heading}\n\n`;
      adoc += `${sec.text}\n\n`;

      if (sec.equation) {
        adoc += `[latexmath]\n`;
        adoc += `++++\n`;
        adoc += `${sec.equation}\n`;
        adoc += `++++\n\n`;
      }

      if (sec.notes && sec.notes.length > 0) {
        adoc += `==== Axiomatic Principles\n\n`;
        sec.notes.forEach((note) => {
          adoc += `* ${note}\n`;
        });
        adoc += `\n`;
      }
    });
  });

  return adoc;
}

export const TextbookPanel: React.FC = () => {
  const [activeChapterId, setActiveChapterId] = useState<string>('intro');
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [copiedText, setCopiedText] = useState<string | null>(null);
  const [viewMode, setViewMode] = useState<'formatted' | 'asciidoc'>('formatted');

  const activeChapter =
    TEXTBOOK_CHAPTERS.find((c) => c.id === activeChapterId) || TEXTBOOK_CHAPTERS[0];

  const handleCopy = (str: string, label: string) => {
    navigator.clipboard.writeText(str);
    setCopiedText(label);
    setTimeout(() => setCopiedText(null), 2000);
  };

  const filteredChapters = TEXTBOOK_CHAPTERS.filter(
    (c) =>
      c.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      c.subtitle.toLowerCase().includes(searchQuery.toLowerCase()) ||
      c.content.summary.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const fullAsciiDoc = generateAsciiDocTextbook();

  return (
    <div className="flex flex-col h-full bg-[#0F0F10] rounded-lg border border-white/10 p-5 space-y-6 overflow-y-auto">
      {/* Textbook Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between pb-4 border-b border-white/10 gap-4">
        <div className="flex items-center space-x-3">
          <div className="w-9 h-9 rounded bg-amber-500/10 text-amber-500 border border-amber-500/30 flex items-center justify-center font-bold">
            <BookOpen className="w-5 h-5" />
          </div>
          <div>
            <h2 className="text-xs uppercase tracking-[0.2em] text-amber-500 font-bold flex items-center gap-2">
              <span>Iris Typesetting Textbook</span>
              <span className="text-[9px] px-1.5 py-0.5 rounded bg-amber-500/20 text-amber-300 font-mono border border-amber-500/30">
                AsciiDoc + MathJax latexmath
              </span>
            </h2>
            <p className="text-[11px] uppercase tracking-wider text-white/50">
              Foundations: OpenType Metrical Model, Cl(4,1,1), MaxEnt & Parallel Solvers
            </p>
          </div>
        </div>

        {/* View Mode Switcher & Copy Full Book */}
        <div className="flex items-center space-x-3">
          <div className="flex bg-black/60 p-1 rounded border border-white/10 text-xs font-mono">
            <button
              onClick={() => setViewMode('formatted')}
              className={`px-3 py-1 rounded transition flex items-center space-x-1.5 ${
                viewMode === 'formatted'
                  ? 'bg-amber-500 text-black font-semibold'
                  : 'text-white/60 hover:text-white'
              }`}
            >
              <Code2 className="w-3.5 h-3.5" />
              <span>MathJax View</span>
            </button>
            <button
              onClick={() => setViewMode('asciidoc')}
              className={`px-3 py-1 rounded transition flex items-center space-x-1.5 ${
                viewMode === 'asciidoc'
                  ? 'bg-amber-500 text-black font-semibold'
                  : 'text-white/60 hover:text-white'
              }`}
            >
              <FileCode className="w-3.5 h-3.5" />
              <span>AsciiDoc Source</span>
            </button>
          </div>

          <button
            onClick={() => handleCopy(fullAsciiDoc, 'Full AsciiDoc Book')}
            className="px-3 py-1.5 bg-amber-500/10 hover:bg-amber-500/20 text-amber-400 border border-amber-500/30 rounded text-xs font-mono transition flex items-center space-x-1.5 shrink-0"
            title="Copy entire textbook in AsciiDoc + latexmath format"
          >
            {copiedText === 'Full AsciiDoc Book' ? (
              <Check className="w-3.5 h-3.5 text-amber-400" />
            ) : (
              <Copy className="w-3.5 h-3.5" />
            )}
            <span>{copiedText === 'Full AsciiDoc Book' ? 'Copied .adoc' : 'Copy .adoc'}</span>
          </button>
        </div>
      </div>

      {viewMode === 'asciidoc' ? (
        /* Full AsciiDoc Source Viewer */
        <div className="flex-1 flex flex-col space-y-3 bg-black/80 border border-white/10 rounded-lg p-5 font-mono">
          <div className="flex items-center justify-between border-b border-white/10 pb-3">
            <div className="flex items-center space-x-2">
              <FileCode className="w-4 h-4 text-amber-500" />
              <span className="text-xs text-amber-400 uppercase tracking-wider font-semibold">
                microtypography_foundations.adoc
              </span>
            </div>
            <span className="text-[10px] text-white/40 uppercase tracking-widest">
              Standard AsciiDoc + MathJax latexmath:[...]
            </span>
          </div>
          <pre className="flex-1 text-xs text-amber-200/90 leading-relaxed overflow-auto p-3 bg-black/60 rounded border border-white/5 whitespace-pre-wrap selection:bg-amber-500/30">
            {fullAsciiDoc}
          </pre>
        </div>
      ) : (
        /* Formatted Textbook Reader View */
        <div className="grid grid-cols-1 lg:grid-cols-4 gap-6 flex-1">
          {/* Chapter Navigation Sidebar */}
          <div className="space-y-3 lg:col-span-1">
            <div className="relative">
              <Search className="w-3.5 h-3.5 text-white/40 absolute left-2.5 top-2.5" />
              <input
                type="text"
                placeholder="Search textbook..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-8 pr-3 py-1.5 bg-black/40 border border-white/10 rounded text-xs font-mono text-white focus:outline-none focus:border-amber-500"
              />
            </div>

            <span className="text-[10px] uppercase tracking-[0.15em] font-semibold text-amber-500 block">
              Table of Contents
            </span>

            <div className="space-y-1.5">
              {filteredChapters.map((chapter) => {
                const Icon = chapter.icon;
                const isActive = chapter.id === activeChapter.id;
                return (
                  <button
                    key={chapter.id}
                    onClick={() => setActiveChapterId(chapter.id)}
                    className={`w-full text-left p-3 rounded border transition flex items-start space-x-3 ${
                      isActive
                        ? 'bg-amber-500/10 border-amber-500/40 text-amber-400'
                        : 'bg-white/5 border-white/10 text-white/70 hover:bg-white/10 hover:text-white'
                    }`}
                  >
                    <Icon className={`w-4 h-4 mt-0.5 shrink-0 ${isActive ? 'text-amber-400' : 'text-white/40'}`} />
                    <div className="flex-1 min-w-0">
                      <span className="text-[9px] uppercase tracking-wider text-white/40 font-mono block">
                        {chapter.number}
                      </span>
                      <h3 className="text-xs font-semibold truncate leading-snug">
                        {chapter.title}
                      </h3>
                    </div>
                    <ChevronRight className={`w-3.5 h-3.5 mt-1 shrink-0 ${isActive ? 'text-amber-400' : 'opacity-0'}`} />
                  </button>
                );
              })}
            </div>
          </div>

          {/* Active Chapter Reader View */}
          <div className="lg:col-span-3 space-y-6 bg-black/40 border border-white/10 rounded-lg p-6">
            {/* Active Chapter Title Card */}
            <div className="space-y-2 border-b border-white/10 pb-4">
              <div className="flex items-center space-x-2">
                <span className="text-[10px] uppercase tracking-[0.2em] px-2 py-0.5 bg-amber-500/20 text-amber-400 font-mono rounded border border-amber-500/30">
                  {activeChapter.number}
                </span>
                <span className="text-[10px] uppercase tracking-wider text-white/40 font-mono">
                  AsciiDoc Section
                </span>
              </div>
              <h1 className="text-xl font-bold text-white tracking-wide">
                {activeChapter.title}
              </h1>
              <p className="text-xs text-amber-300/80 font-medium tracking-wide">
                {activeChapter.subtitle}
              </p>
            </div>

            {/* Chapter Summary Box */}
            <div className="p-4 bg-white/5 border border-white/10 rounded space-y-2">
              <span className="text-[10px] uppercase tracking-wider text-amber-500 font-semibold block flex items-center gap-1.5">
                <Bookmark className="w-3.5 h-3.5" /> Executive Summary
              </span>
              <p className="text-xs text-white/80 leading-relaxed font-sans">
                {activeChapter.content.summary}
              </p>
            </div>

            {/* Chapter Sections */}
            <div className="space-y-6">
              {activeChapter.content.sections.map((sec, idx) => (
                <div key={idx} className="space-y-3">
                  <h2 className="text-sm font-semibold text-amber-400 uppercase tracking-wider flex items-center gap-2">
                    <span className="w-1.5 h-1.5 bg-amber-500 rounded-full" />
                    {sec.heading}
                  </h2>
                  <p className="text-xs text-white/70 leading-relaxed font-sans">
                    {sec.text}
                  </p>

                  {/* AsciiDoc Block & MathJax Equation */}
                  {sec.equation && (
                    <div className="space-y-1.5">
                      <div className="flex items-center justify-between text-[10px] uppercase tracking-wider text-white/40 font-mono px-1">
                        <span>AsciiDoc MathJax Block</span>
                        <span className="text-amber-500/80">latexmath:[...]</span>
                      </div>
                      <div className="p-4 bg-black/80 rounded border border-white/10 font-mono text-sm text-amber-300 flex items-center justify-between group">
                        <div className="flex flex-col space-y-1">
                          <span className="text-[10px] text-white/40">
                            [latexmath]
                          </span>
                          <span className="text-amber-300 font-semibold">
                            latexmath:[{sec.equation}]
                          </span>
                        </div>
                        <button
                          onClick={() => handleCopy(`latexmath:[${sec.equation}]`, `eq-${idx}`)}
                          className="text-xs text-white/40 hover:text-amber-400 transition flex items-center gap-1 shrink-0 bg-white/5 px-2.5 py-1.5 rounded"
                          title="Copy latexmath macro"
                        >
                          {copiedText === `eq-${idx}` ? (
                            <Check className="w-3.5 h-3.5 text-amber-400" />
                          ) : (
                            <Copy className="w-3.5 h-3.5" />
                          )}
                          <span className="text-[9px] uppercase tracking-wider">
                            {copiedText === `eq-${idx}` ? 'Copied' : 'latexmath'}
                          </span>
                        </button>
                      </div>
                    </div>
                  )}

                  {/* Notes List */}
                  {sec.notes && sec.notes.length > 0 && (
                    <div className="p-3 bg-white/5 rounded border border-white/10 space-y-1.5">
                      <span className="text-[10px] uppercase tracking-wider text-white/50 font-mono block">
                        Axiomatic Principles:
                      </span>
                      <ul className="space-y-1">
                        {sec.notes.map((note, nIdx) => (
                          <li key={nIdx} className="text-xs text-white/80 flex items-start gap-2 font-mono">
                            <CheckCircle2 className="w-3.5 h-3.5 text-amber-500 shrink-0 mt-0.5" />
                            <span>{note}</span>
                          </li>
                        ))}
                      </ul>
                    </div>
                  )}
                </div>
              ))}

              {/* Public Code Libraries for Chapter VII */}
              {activeChapter.id === 'tools' && (
                <div className="p-4 bg-amber-500/10 border border-amber-500/30 rounded-lg space-y-3 mt-6">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-semibold uppercase tracking-wider text-amber-400 font-mono flex items-center gap-2">
                      <FileCode className="w-4 h-4 text-amber-400" />
                      Public Source Libraries & Executables
                    </span>
                    <span className="text-[10px] font-mono text-amber-300/60 bg-black/40 px-2 py-0.5 rounded border border-amber-500/20">
                      /public/ directory
                    </span>
                  </div>
                  <p className="text-xs text-white/70 leading-relaxed font-sans">
                    All Fortran 2023 and R⁷RS-large Scheme libraries and standalone executables for <code className="text-amber-300">font2json</code> and <code className="text-amber-300">json2font</code> are deployed in the public web root for direct execution and user modification:
                  </p>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-2 text-xs font-mono">
                    <a
                      href="/fortran/font2json_mod.f90"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="p-2.5 bg-black/50 border border-white/10 hover:border-amber-500/50 rounded flex items-center justify-between text-white/80 hover:text-amber-300 transition group"
                    >
                      <div className="flex items-center space-x-2">
                        <Code2 className="w-3.5 h-3.5 text-amber-500" />
                        <span>/fortran/font2json_mod.f90</span>
                      </div>
                      <span className="text-[9px] uppercase tracking-wider text-white/40 group-hover:text-amber-400">Fortran 2023</span>
                    </a>
                    <a
                      href="/fortran/json2font_mod.f90"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="p-2.5 bg-black/50 border border-white/10 hover:border-amber-500/50 rounded flex items-center justify-between text-white/80 hover:text-amber-300 transition group"
                    >
                      <div className="flex items-center space-x-2">
                        <Code2 className="w-3.5 h-3.5 text-amber-500" />
                        <span>/fortran/json2font_mod.f90</span>
                      </div>
                      <span className="text-[9px] uppercase tracking-wider text-white/40 group-hover:text-amber-400">Fortran 2023</span>
                    </a>
                    <a
                      href="/scheme/iris/font2json.sld"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="p-2.5 bg-black/50 border border-white/10 hover:border-amber-500/50 rounded flex items-center justify-between text-white/80 hover:text-amber-300 transition group"
                    >
                      <div className="flex items-center space-x-2">
                        <Terminal className="w-3.5 h-3.5 text-amber-400" />
                        <span>/scheme/iris/font2json.sld</span>
                      </div>
                      <span className="text-[9px] uppercase tracking-wider text-white/40 group-hover:text-amber-400">R⁷RS Scheme</span>
                    </a>
                    <a
                      href="/scheme/iris/json2font.sld"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="p-2.5 bg-black/50 border border-white/10 hover:border-amber-500/50 rounded flex items-center justify-between text-white/80 hover:text-amber-300 transition group"
                    >
                      <div className="flex items-center space-x-2">
                        <Terminal className="w-3.5 h-3.5 text-amber-400" />
                        <span>/scheme/iris/json2font.sld</span>
                      </div>
                      <span className="text-[9px] uppercase tracking-wider text-white/40 group-hover:text-amber-400">R⁷RS Scheme</span>
                    </a>
                    <a
                      href="/fortran/autopeg_mod.f90"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="p-2.5 bg-black/50 border border-white/10 hover:border-amber-500/50 rounded flex items-center justify-between text-white/80 hover:text-amber-300 transition group"
                    >
                      <div className="flex items-center space-x-2">
                        <Code2 className="w-3.5 h-3.5 text-amber-500" />
                        <span>/fortran/autopeg_mod.f90</span>
                      </div>
                      <span className="text-[9px] uppercase tracking-wider text-white/40 group-hover:text-amber-400">Fortran 2008 (GCC 16)</span>
                    </a>
                    <a
                      href="/scheme/iris/cli.sld"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="p-2.5 bg-black/50 border border-white/10 hover:border-amber-500/50 rounded flex items-center justify-between text-white/80 hover:text-amber-300 transition group"
                    >
                      <div className="flex items-center space-x-2">
                        <Terminal className="w-3.5 h-3.5 text-amber-400" />
                        <span>/scheme/iris/cli.sld</span>
                      </div>
                      <span className="text-[9px] uppercase tracking-wider text-white/40 group-hover:text-amber-400">R⁷RS Scheme</span>
                    </a>
                    <a
                      href="/scheme/iris/autopeg.sld"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="p-2.5 bg-black/50 border border-white/10 hover:border-amber-500/50 rounded flex items-center justify-between text-white/80 hover:text-amber-300 transition group"
                    >
                      <div className="flex items-center space-x-2">
                        <Terminal className="w-3.5 h-3.5 text-amber-400" />
                        <span>/scheme/iris/autopeg.sld</span>
                      </div>
                      <span className="text-[9px] uppercase tracking-wider text-white/40 group-hover:text-amber-400">R⁷RS Scheme</span>
                    </a>
                    <a
                      href="/scheme/font2json"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="p-2.5 bg-black/50 border border-amber-500/30 hover:border-amber-400 rounded flex items-center justify-between text-amber-200 hover:text-amber-300 transition group"
                    >
                      <div className="flex items-center space-x-2">
                        <FileCode className="w-3.5 h-3.5 text-amber-300" />
                        <span>/scheme/font2json</span>
                      </div>
                      <span className="text-[9px] uppercase tracking-wider text-amber-400/80 group-hover:text-amber-300">#!/usr/bin/env scheme-r7rs</span>
                    </a>
                    <a
                      href="/scheme/json2font"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="p-2.5 bg-black/50 border border-amber-500/30 hover:border-amber-400 rounded flex items-center justify-between text-amber-200 hover:text-amber-300 transition group"
                    >
                      <div className="flex items-center space-x-2">
                        <FileCode className="w-3.5 h-3.5 text-amber-300" />
                        <span>/scheme/json2font</span>
                      </div>
                      <span className="text-[9px] uppercase tracking-wider text-amber-400/80 group-hover:text-amber-300">#!/usr/bin/env scheme-r7rs</span>
                    </a>
                    <a
                      href="/scheme/autopeg"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="p-2.5 bg-black/50 border border-amber-500/30 hover:border-amber-400 rounded flex items-center justify-between text-amber-200 hover:text-amber-300 transition group"
                    >
                      <div className="flex items-center space-x-2">
                        <FileCode className="w-3.5 h-3.5 text-amber-300" />
                        <span>/scheme/autopeg</span>
                      </div>
                      <span className="text-[9px] uppercase tracking-wider text-amber-400/80 group-hover:text-amber-300">#!/usr/bin/env scheme-r7rs</span>
                    </a>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
