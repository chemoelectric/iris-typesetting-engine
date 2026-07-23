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
          heading: '1.2 Unified Field Coupling in Microtypography',
          text: 'Electromagnetism and gravity are unified under a single field framework governing glyph force equilibrium. Glyph contours act as charged boundaries within a potential field, where inter-character repulsions (collisions) and attraction forces (kerning pairs) achieve static field equilibrium.',
          equation: 'F = \\nabla_{Cl(4,1,1)} A = E + i B + G + S',
          notes: [
            'E and B represent electro-optical glyph boundary potentials.',
            'G represents gravitational baseline attraction.',
            'S represents scalar optical density balance.',
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
    title: 'Native OpenType Metrical Model Optimization',
    subtitle: 'Direct Feature-Level Optimization Beyond TeX Box-and-Glue Constraints',
    icon: Type,
    content: {
      summary:
        'Rather than imposing TeX\'s rigid secondary "box and glue" abstraction upon font data, the Iris engine optimizes directly within the metrical model inherent to OpenType fonts themselves—leveraging native OpenType features (GPOS, GSUB, mark positioning, contextual alternates, optical kerning tables, and design-space axes).',
      sections: [
        {
          heading: '5.1 Direct Metrical Integration vs. TeX Box-and-Glue',
          text: 'TeX maps characters into fixed rectangular boxes with static glue and penalty metrics from TFM files. Iris bypasses this coarse model by evaluating OpenType GPOS lookup tables, contextual glyph positioning, and variable font design-space axes directly in energy potential equations.',
          equation: '\\Delta x_{\\text{GPOS}} = f_{\\text{OpenType}}(c_i, c_{i+1}, \\text{features})',
          notes: [
            'Preserves author-intended OpenType feature tables (kern, liga, mark, mkmk, calt).',
            'Eliminates artificial box boundary truncation errors.',
            'Integrates native variable font axes (wght, wdth, opsz) directly into MaxEnt optical sizing.',
          ],
        },
        {
          heading: '5.2 OpenType Feature-Space Potential Energy',
          text: 'Inter-glyph spacing incorporates both native OpenType GPOS adjustment vectors and Jaynesian density relaxation, yielding seamless microtypographic balance.',
        },
      ],
    },
  },
  {
    id: 'parallel',
    number: 'CHAPTER VI',
    title: 'Parallel Numerical Optimization & Josephson-SQUID Resonator Analogs',
    subtitle: 'Coupled Non-Linear Phase-Locked Resonator Relaxation for Multi-Core Systems',
    icon: Cpu,
    content: {
      summary:
        'Instead of restricting paragraph break optimization to traditional sequential dynamic programming, Iris embraces parallel numerical relaxation algorithms. The engine utilizes physical analogs derived from superconducting quantum interference devices (SQUIDs) and Josephson junction networks, treating layout energy states as coupled phase-locked non-linear oscillators running in parallel across multi-core processors.',
      sections: [
        {
          heading: '6.1 Non-Linear Phase-Locked Resonator Dynamics',
          text: 'Glyph baseline coordinates and line break nodes are mapped to phase variables φ_i in a system of coupled non-linear differential equations resembling Josephson junction arrays and SQUID loops. The collective system rapidly relaxes to its minimum energy state via parallel multi-grid solver iterations.',
          equation: '\\frac{d^2 \\phi_i}{dt^2} + \\gamma \\frac{d\\phi_i}{dt} + \\sin(\\phi_i - \\phi_{i-1}) = I_{\\text{MaxEnt}}(\\vec{\\lambda})',
          notes: [
            'ϕᵢ represents the spatial phase angle of glyph i in the layout stream.',
            'Coupling term sin(ϕᵢ - ϕᵢ₋₁) enforces elasticity constraints across neighboring glyphs.',
            'Enables massive multi-threaded parallel speedup across multi-core architectures (e.g. 24-core Zen 5 processors).',
          ],
        },
        {
          heading: '6.2 High-Throughput SIMD & Superconducting Circuit Analogs',
          text: 'Phase locking across thousands of text nodes converges orders of magnitude faster than serial dynamic programming, achieving global layout equilibrium simultaneously across entire documents.',
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
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
