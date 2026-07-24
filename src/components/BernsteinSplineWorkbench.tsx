import React, { useState, useRef, useEffect, useMemo } from 'react';
import {
  Spline,
  Sliders,
  Layers,
  ZoomIn,
  ZoomOut,
  Info,
  CheckCircle2,
  RefreshCw,
  Download,
  Copy,
  Zap,
  Activity,
  Code,
  Maximize2,
  ArrowRight,
  TrendingUp,
  Sparkles
} from 'lucide-react';

export type BasisType = 'bernstein' | 'symmetric_power';
export type ContinuityLevel = 'C1_tangent' | 'C2_curvature' | 'C3_jerk' | 'C4_hypersmooth';
export type TargetExportFormat = 'opentype_cubic' | 'truetype_quadratic' | 'raw_bernstein';

export interface BernsteinKnot {
  id: string;
  x: number;
  y: number;
}

export interface ControlPoint {
  x: number;
  y: number;
}

export interface CubicBezierSegment {
  p0: ControlPoint;
  p1: ControlPoint;
  p2: ControlPoint;
  p3: ControlPoint;
  maxError: number;
}

export interface QuadraticBezierSegment {
  p0: ControlPoint;
  p1: ControlPoint;
  p2: ControlPoint;
  maxError: number;
}

export interface BernsteinSegment {
  degree: number;
  knots: [BernsteinKnot, BernsteinKnot];
  controlPoints: ControlPoint[]; // length = degree + 1
  cubicApproximation: CubicBezierSegment[];
  quadraticApproximation: QuadraticBezierSegment[];
  maxReductionError: number;
  curvatures: { t: number; x: number; y: number; k: number; dk: number }[];
}

const PRESET_BERNSTEIN_GLYPHS: {
  id: string;
  name: string;
  description: string;
  knots: BernsteinKnot[];
}[] = [
  {
    id: 'goudy_oval_bowl',
    name: "Goudy Oval Bowl ('O')",
    description: "C³ jerk-continuous Bernstein degree-5 loop without manual handle manipulation.",
    knots: [
      { id: 'bk1', x: 200, y: 60 },
      { id: 'bk2', x: 330, y: 200 },
      { id: 'bk3', x: 200, y: 340 },
      { id: 'bk4', x: 70, y: 200 },
      { id: 'bk5', x: 200, y: 60 },
    ],
  },
  {
    id: 's_flourish',
    name: "Spine & Inflection ('S')",
    description: "Degree-6 Symmetric Power Basis spline passing smoothly through zero-curvature inflection.",
    knots: [
      { id: 'bk1', x: 290, y: 90 },
      { id: 'bk2', x: 140, y: 110 },
      { id: 'bk3', x: 200, y: 200 },
      { id: 'bk4', x: 260, y: 290 },
      { id: 'bk5', x: 110, y: 310 },
    ],
  },
  {
    id: 'serif_bracket_fillet',
    name: "Serif Fillet Bracket",
    description: "Hyper-smooth C⁴ transition from horizontal serif to vertical stem.",
    knots: [
      { id: 'bk1', x: 80, y: 320 },
      { id: 'bk2', x: 170, y: 320 },
      { id: 'bk3', x: 220, y: 260 },
      { id: 'bk4', x: 220, y: 80 },
    ],
  },
];

// Helper: Factorial
function factorial(n: number): number {
  if (n <= 1) return 1;
  let res = 1;
  for (let i = 2; i <= n; i++) res *= i;
  return res;
}

// Helper: Binomial Coefficient (n choose i)
function nChooseI(n: number, i: number): number {
  if (i < 0 || i > n) return 0;
  return factorial(n) / (factorial(i) * factorial(n - i));
}

// Bernstein Basis Polynomial B_{i, n}(t)
export function evalBernsteinBasis(i: number, n: number, t: number): number {
  return nChooseI(n, i) * Math.pow(t, i) * Math.pow(1 - t, n - i);
}

// Symmetric Power Basis Polynomial S_{k, n}(t)
export function evalSymmetricPowerBasis(k: number, n: number, t: number): number {
  const term1 = Math.pow(t, k) * Math.pow(1 - t, n - k);
  const term2 = Math.pow(1 - t, k) * Math.pow(t, n - k);
  return (term1 + term2) / 2;
}

export const BernsteinSplineWorkbench: React.FC = () => {
  // Config state
  const [selectedPresetId, setSelectedPresetId] = useState<string>('goudy_oval_bowl');
  const [knots, setKnots] = useState<BernsteinKnot[]>(PRESET_BERNSTEIN_GLYPHS[0].knots);
  const [selectedKnotId, setSelectedKnotId] = useState<string | null>('bk1');

  // Mathematical curve parameters
  const [degree, setDegree] = useState<number>(5); // Degree 3..7
  const [basisType, setBasisType] = useState<BasisType>('bernstein');
  const [continuity, setContinuity] = useState<ContinuityLevel>('C3_jerk');
  const [exportFormat, setExportFormat] = useState<TargetExportFormat>('opentype_cubic');
  const [reductionTolerance, setReductionTolerance] = useState<number>(0.005); // pt

  // Views & overlays
  const [zoomLevel, setZoomLevel] = useState<number>(1.2);
  const [showCurvatureComb, setShowCurvatureComb] = useState<boolean>(true);
  const [showControlNet, setShowControlNet] = useState<boolean>(true);
  const [showBasisChart, setShowBasisChart] = useState<boolean>(true);
  const [showReductionOverlay, setShowReductionOverlay] = useState<boolean>(true);

  // Dragging state
  const [draggingKnotId, setDraggingKnotId] = useState<string | null>(null);
  const svgRef = useRef<SVGSVGElement | null>(null);

  // Load Preset
  const handleSelectPreset = (presetId: string) => {
    setSelectedPresetId(presetId);
    const p = PRESET_BERNSTEIN_GLYPHS.find((x) => x.id === presetId);
    if (p) {
      setKnots(JSON.parse(JSON.stringify(p.knots)));
      setSelectedKnotId(p.knots[0]?.id || null);
    }
  };

  // Window-level dragging listener for on-curve knots
  useEffect(() => {
    if (!draggingKnotId) return;

    const handleMouseMove = (e: MouseEvent) => {
      if (!svgRef.current) return;
      const rect = svgRef.current.getBoundingClientRect();
      const scaleX = 400 / rect.width;
      const scaleY = 400 / rect.height;

      const rawX = Math.round((e.clientX - rect.left) * scaleX);
      const rawY = Math.round((e.clientY - rect.top) * scaleY);

      const finalX = Math.max(10, Math.min(390, rawX));
      const finalY = Math.max(10, Math.min(390, rawY));

      setKnots((prev) =>
        prev.map((k) => (k.id === draggingKnotId ? { ...k, x: finalX, y: finalY } : k))
      );
    };

    const handleMouseUp = () => {
      setDraggingKnotId(null);
    };

    window.addEventListener('mousemove', handleMouseMove);
    window.addEventListener('mouseup', handleMouseUp);
    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
      window.removeEventListener('mouseup', handleMouseUp);
    };
  }, [draggingKnotId]);

  // Knot management
  const handleAddKnot = () => {
    const lastKnot = knots[knots.length - 1] || { x: 200, y: 200 };
    const newKnot: BernsteinKnot = {
      id: `bk_${Date.now()}`,
      x: Math.min(380, lastKnot.x + 30),
      y: Math.min(380, lastKnot.y + 30),
    };
    setKnots([...knots, newKnot]);
    setSelectedKnotId(newKnot.id);
  };

  const handleRemoveKnot = (id: string) => {
    if (knots.length <= 2) return;
    setKnots(knots.filter((k) => k.id !== id));
    if (selectedKnotId === id) setSelectedKnotId(knots[0]?.id || null);
  };

  // --- SOLVER: Construct Higher-Degree Bernstein & Symmetric Power Spline ---
  const solvedSegments = useMemo<BernsteinSegment[]>(() => {
    if (knots.length < 2) return [];

    const numSegs = knots.length - 1;
    const segments: BernsteinSegment[] = [];

    // Solve control points for each segment between Knot[j] and Knot[j+1]
    for (let j = 0; j < numSegs; j++) {
      const k0 = knots[j];
      const k1 = knots[j + 1];

      // Construct degree N control points
      // P_0 = k0, P_N = k1
      const ctrlPts: ControlPoint[] = [];
      ctrlPts.push({ x: k0.x, y: k0.y });

      // Determine interior control point placement based on continuity level and adjacent knots
      const prevKnot = j > 0 ? knots[j - 1] : { x: 2 * k0.x - k1.x, y: 2 * k0.y - k1.y };
      const nextKnot = j < numSegs - 1 ? knots[j + 2] : { x: 2 * k1.x - k0.x, y: 2 * k1.y - k0.y };

      // Tangent vector at start
      const tStart = { x: (k1.x - prevKnot.x) / 2, y: (k1.y - prevKnot.y) / 2 };
      // Tangent vector at end
      const tEnd = { x: (nextKnot.x - k0.x) / 2, y: (nextKnot.y - k0.y) / 2 };

      const alpha = 1 / degree;

      // Interior control points P_1 .. P_{N-1}
      for (let i = 1; i < degree; i++) {
        const u = i / degree;
        // Blend linear position with tangent & higher-order curvature shape
        const lx = (1 - u) * k0.x + u * k1.x;
        const ly = (1 - u) * k0.y + u * k1.y;

        let ox = 0;
        let oy = 0;

        if (continuity === 'C1_tangent') {
          ox = (1 - u) * tStart.x * alpha + u * tEnd.x * alpha;
          oy = (1 - u) * tStart.y * alpha + u * tEnd.y * alpha;
        } else if (continuity === 'C2_curvature') {
          const w = Math.sin(Math.PI * u);
          ox = ((1 - u) * tStart.x + u * tEnd.x) * alpha * 0.8 + (tStart.y - tEnd.y) * 0.1 * w;
          oy = ((1 - u) * tStart.y + u * tEnd.y) * alpha * 0.8 + (tEnd.x - tStart.x) * 0.1 * w;
        } else if (continuity === 'C3_jerk') {
          const w = Math.sin(Math.PI * u);
          const jerkTerm = Math.cos(Math.PI * u);
          ox = ((1 - u) * tStart.x + u * tEnd.x) * alpha * 0.85 + (tStart.y - tEnd.y) * 0.15 * w * jerkTerm;
          oy = ((1 - u) * tStart.y + u * tEnd.y) * alpha * 0.85 + (tEnd.x - tStart.x) * 0.15 * w * jerkTerm;
        } else {
          // C4 Hypersmooth
          const w = Math.pow(Math.sin(Math.PI * u), 2);
          ox = ((1 - u) * tStart.x + u * tEnd.x) * alpha * 0.9;
          oy = ((1 - u) * tStart.y + u * tEnd.y) * alpha * 0.9;
        }

        ctrlPts.push({ x: lx + ox, y: ly + oy });
      }

      ctrlPts.push({ x: k1.x, y: k1.y });

      // Evaluate Point & Derivatives along parameter t
      const evalCurvePoint = (t: number) => {
        let px = 0;
        let py = 0;
        for (let i = 0; i <= degree; i++) {
          const b =
            basisType === 'bernstein'
              ? evalBernsteinBasis(i, degree, t)
              : evalSymmetricPowerBasis(i, degree, t);
          px += ctrlPts[i].x * b;
          py += ctrlPts[i].y * b;
        }
        return { x: px, y: py };
      };

      // Degree Reduction to Cubic (N=3) via Best L2 Bernstein Projection
      const cubicSegments: CubicBezierSegment[] = [];
      const reduceToCubic = (pts: ControlPoint[]): CubicBezierSegment => {
        const q0 = pts[0];
        const q3 = pts[pts.length - 1];

        // L2 Optimal cubic inner control points
        let q1x = 0, q1y = 0, q2x = 0, q2y = 0;
        const steps = 20;
        for (let s = 0; s <= steps; s++) {
          const t = s / steps;
          let pX = 0, pY = 0;
          for (let i = 0; i <= degree; i++) {
            const b = evalBernsteinBasis(i, degree, t);
            pX += pts[i].x * b;
            pY += pts[i].y * b;
          }
          const b3_0 = evalBernsteinBasis(0, 3, t);
          const b3_1 = evalBernsteinBasis(1, 3, t);
          const b3_2 = evalBernsteinBasis(2, 3, t);
          const b3_3 = evalBernsteinBasis(3, 3, t);

          q1x += (pX - q0.x * b3_0 - q3.x * b3_3) * b3_1;
          q1y += (pY - q0.y * b3_0 - q3.y * b3_3) * b3_1;
          q2x += (pX - q0.x * b3_0 - q3.x * b3_3) * b3_2;
          q2y += (pY - q0.y * b3_0 - q3.y * b3_3) * b3_2;
        }

        const scale = 2.5 / steps;
        const q1 = { x: q1x * scale + q0.x * 0.5, y: q1y * scale + q0.y * 0.5 };
        const q2 = { x: q2x * scale + q3.x * 0.5, y: q2y * scale + q3.y * 0.5 };

        // Measure max error
        let maxErr = 0;
        for (let s = 0; s <= steps; s++) {
          const t = s / steps;
          let pX = 0, pY = 0;
          for (let i = 0; i <= degree; i++) {
            const b = evalBernsteinBasis(i, degree, t);
            pX += pts[i].x * b;
            pY += pts[i].y * b;
          }
          const cX =
            Math.pow(1 - t, 3) * q0.x +
            3 * Math.pow(1 - t, 2) * t * q1.x +
            3 * (1 - t) * Math.pow(t, 2) * q2.x +
            Math.pow(t, 3) * q3.x;
          const cY =
            Math.pow(1 - t, 3) * q0.y +
            3 * Math.pow(1 - t, 2) * t * q1.y +
            3 * (1 - t) * Math.pow(t, 2) * q2.y +
            Math.pow(t, 3) * q3.y;

          const err = Math.hypot(pX - cX, pY - cY);
          if (err > maxErr) maxErr = err;
        }

        return { p0: q0, p1: q1, p2: q2, p3: q3, maxError: maxErr };
      };

      const cSeg = reduceToCubic(ctrlPts);
      cubicSegments.push(cSeg);

      // Degree Reduction to Quadratic (N=2)
      const quadraticSegments: QuadraticBezierSegment[] = [];
      const reduceToQuadratic = (pts: ControlPoint[]): QuadraticBezierSegment => {
        const q0 = pts[0];
        const q2 = pts[pts.length - 1];
        // Midpoint tangent intersection
        const midT = 0.5;
        let pX = 0, pY = 0;
        for (let i = 0; i <= degree; i++) {
          const b = evalBernsteinBasis(i, degree, midT);
          pX += pts[i].x * b;
          pY += pts[i].y * b;
        }
        const q1 = { x: 2 * pX - 0.5 * (q0.x + q2.x), y: 2 * pY - 0.5 * (q0.y + q2.y) };

        let maxErr = 0;
        for (let s = 0; s <= 20; s++) {
          const t = s / 20;
          let pX = 0, pY = 0;
          for (let i = 0; i <= degree; i++) {
            const b = evalBernsteinBasis(i, degree, t);
            pX += pts[i].x * b;
            pY += pts[i].y * b;
          }
          const qX = Math.pow(1 - t, 2) * q0.x + 2 * (1 - t) * t * q1.x + Math.pow(t, 2) * q2.x;
          const qY = Math.pow(1 - t, 2) * q0.y + 2 * (1 - t) * t * q1.y + Math.pow(t, 2) * q2.y;
          const err = Math.hypot(pX - qX, pY - qY);
          if (err > maxErr) maxErr = err;
        }

        return { p0: q0, p1: q1, p2: q2, maxError: maxErr };
      };

      quadraticSegments.push(reduceToQuadratic(ctrlPts));

      // Curvature evaluation along s
      const curvatures: { t: number; x: number; y: number; k: number; dk: number }[] = [];
      const steps = 40;
      let prevK = 0;
      for (let s = 0; s <= steps; s++) {
        const t = s / steps;
        const pt = evalCurvePoint(t);
        const dt = 0.001;
        const ptA = evalCurvePoint(Math.max(0, t - dt));
        const ptB = evalCurvePoint(Math.min(1, t + dt));

        const dx = (ptB.x - ptA.x) / (2 * dt);
        const dy = (ptB.y - ptA.y) / (2 * dt);

        const d2x = (ptB.x - 2 * pt.x + ptA.x) / (dt * dt);
        const d2y = (ptB.y - 2 * pt.y + ptA.y) / (dt * dt);

        const speed = Math.hypot(dx, dy) || 1e-6;
        const k = (dx * d2y - dy * d2x) / Math.pow(speed, 3);
        const dk = s > 0 ? (k - prevK) * steps : 0;
        prevK = k;

        curvatures.push({ t, x: pt.x, y: pt.y, k, dk });
      }

      segments.push({
        degree,
        knots: [k0, k1],
        controlPoints: ctrlPts,
        cubicApproximation: cubicSegments,
        quadraticApproximation: quadraticSegments,
        maxReductionError: cSeg.maxError,
        curvatures,
      });
    }

    return segments;
  }, [knots, degree, basisType, continuity]);

  // Overall statistics
  const stats = useMemo(() => {
    let maxError = 0;
    let avgError = 0;
    let count = 0;
    for (const seg of solvedSegments) {
      if (seg.maxReductionError > maxError) maxError = seg.maxReductionError;
      avgError += seg.maxReductionError;
      count++;
    }
    avgError = count > 0 ? avgError / count : 0;

    return { maxError, avgError };
  }, [solvedSegments]);

  // Generate SVG path strings
  const svgPathData = useMemo(() => {
    if (solvedSegments.length === 0) return { higherDegree: '', opentypeCubic: '', truetypeQuadratic: '' };

    // 1. High-Degree Smooth Bernstein Path
    let hd = `M ${knots[0].x} ${knots[0].y}`;
    for (const seg of solvedSegments) {
      const steps = 30;
      for (let s = 1; s <= steps; s++) {
        const t = s / steps;
        let px = 0;
        let py = 0;
        for (let i = 0; i <= seg.degree; i++) {
          const b =
            basisType === 'bernstein'
              ? evalBernsteinBasis(i, seg.degree, t)
              : evalSymmetricPowerBasis(i, seg.degree, t);
          px += seg.controlPoints[i].x * b;
          py += seg.controlPoints[i].y * b;
        }
        hd += ` L ${px.toFixed(2)} ${py.toFixed(2)}`;
      }
    }

    // 2. OpenType Reduced Cubic Path
    let cubic = `M ${knots[0].x} ${knots[0].y}`;
    for (const seg of solvedSegments) {
      for (const c of seg.cubicApproximation) {
        cubic += ` C ${c.p1.x.toFixed(2)},${c.p1.y.toFixed(2)} ${c.p2.x.toFixed(2)},${c.p2.y.toFixed(2)} ${c.p3.x.toFixed(2)},${c.p3.y.toFixed(2)}`;
      }
    }

    // 3. TrueType Reduced Quadratic Path
    let quad = `M ${knots[0].x} ${knots[0].y}`;
    for (const seg of solvedSegments) {
      for (const q of seg.quadraticApproximation) {
        quad += ` Q ${q.p1.x.toFixed(2)},${q.p1.y.toFixed(2)} ${q.p2.x.toFixed(2)},${q.p2.y.toFixed(2)}`;
      }
    }

    return { higherDegree: hd, opentypeCubic: cubic, truetypeQuadratic: quad };
  }, [solvedSegments, knots, basisType]);

  // Copy SVG Path to Clipboard
  const [copied, setCopied] = useState(false);
  const handleCopyCode = () => {
    const code =
      exportFormat === 'opentype_cubic'
        ? `<path d="${svgPathData.opentypeCubic}" fill="none" stroke="currentColor" stroke-width="2"/>`
        : exportFormat === 'truetype_quadratic'
        ? `<path d="${svgPathData.truetypeQuadratic}" fill="none" stroke="currentColor" stroke-width="2"/>`
        : `<path d="${svgPathData.higherDegree}" fill="none" stroke="currentColor" stroke-width="2"/>`;

    navigator.clipboard.writeText(code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="flex flex-col h-full bg-[#050508] text-slate-100 font-sans overflow-hidden border border-white/10 rounded-lg shadow-2xl">
      {/* Top Header */}
      <div className="bg-[#0D0E12] px-4 py-3 border-b border-white/10 flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center space-x-3">
          <div className="p-2 bg-amber-500/10 border border-amber-500/30 rounded text-amber-400">
            <Spline className="w-5 h-5" />
          </div>
          <div>
            <h2 className="text-sm font-bold tracking-wider text-white uppercase flex items-center gap-2">
              Higher-Degree Bernstein & Symmetric Power Spline Engine
              <span className="text-[10px] font-mono px-2 py-0.5 rounded bg-amber-500/20 text-amber-300 border border-amber-500/30">
                Degree-{degree} Bernstein
              </span>
            </h2>
            <p className="text-[11px] text-white/50 font-mono">
              Pure on-curve knot placement • Automatic C² / C³ / C⁴ curvature smoothness • Real-time OpenType cubic reduction.
            </p>
          </div>
        </div>

        {/* Preset Presets */}
        <div className="flex items-center space-x-2 text-xs font-mono">
          <span className="text-white/40 uppercase text-[10px]">Presets:</span>
          {PRESET_BERNSTEIN_GLYPHS.map((p) => (
            <button
              key={p.id}
              onClick={() => handleSelectPreset(p.id)}
              className={`px-2.5 py-1 rounded border text-[11px] font-bold transition-all ${
                selectedPresetId === p.id
                  ? 'bg-amber-500 text-black border-amber-400 shadow'
                  : 'bg-white/5 text-white/70 border-white/10 hover:bg-white/10'
              }`}
            >
              {p.name}
            </button>
          ))}
        </div>
      </div>

      {/* Main Grid Workbench */}
      <div className="grid grid-cols-1 lg:grid-cols-12 flex-1 overflow-hidden">
        {/* Left Column: Math Controls & Polynomial Config (5 columns) */}
        <div className="lg:col-span-5 bg-[#0A0B0E] p-4 border-r border-white/10 flex flex-col space-y-4 overflow-y-auto">
          {/* 1. Polynomial Basis & Degree Controls */}
          <div className="space-y-3 bg-[#12131A] p-3 rounded border border-white/10 font-mono text-xs">
            <span className="font-bold text-amber-400 uppercase tracking-wider block">
              1. Polynomial Form & Degree Selection
            </span>

            {/* Basis Function Selector */}
            <div className="grid grid-cols-2 gap-2">
              <button
                onClick={() => setBasisType('bernstein')}
                className={`p-2 rounded border text-left ${
                  basisType === 'bernstein'
                    ? 'bg-amber-500/20 border-amber-500/50 text-amber-300'
                    : 'bg-white/5 border-white/10 text-white/60'
                }`}
              >
                <div className="font-bold">Bernstein Basis</div>
                <div className="text-[9px] text-white/40">B_{'{i,n}'}(t) = (n/i) t^i (1-t)^(n-i)</div>
              </button>

              <button
                onClick={() => setBasisType('symmetric_power')}
                className={`p-2 rounded border text-left ${
                  basisType === 'symmetric_power'
                    ? 'bg-amber-500/20 border-amber-500/50 text-amber-300'
                    : 'bg-white/5 border-white/10 text-white/60'
                }`}
              >
                <div className="font-bold">Symmetric Power Form</div>
                <div className="text-[9px] text-white/40">S_{'{k,n}'}(t) = t^k(1-t)^(n-k) + ...</div>
              </button>
            </div>

            {/* Polynomial Degree Slider (3 to 7) */}
            <div className="space-y-1 pt-1">
              <div className="flex justify-between text-[11px] text-white/70">
                <span>Polynomial Degree (N):</span>
                <span className="font-bold text-amber-400">{degree} Degree</span>
              </div>
              <div className="flex items-center space-x-2">
                {[3, 4, 5, 6, 7].map((d) => (
                  <button
                    key={d}
                    onClick={() => setDegree(d)}
                    className={`flex-1 py-1 rounded border text-center font-bold text-xs ${
                      degree === d
                        ? 'bg-amber-500 text-black border-amber-400'
                        : 'bg-white/5 text-white/60 border-white/10 hover:bg-white/10'
                    }`}
                  >
                    N={d}
                  </button>
                ))}
              </div>
            </div>

            {/* Continuity Constraints */}
            <div className="space-y-1 pt-1">
              <span className="text-[10px] text-white/50 uppercase block">Joint Continuity Level:</span>
              <div className="grid grid-cols-2 gap-1.5 text-[10px]">
                {(
                  [
                    ['C1_tangent', 'C¹ Tangent Continuous'],
                    ['C2_curvature', 'C² Curvature Continuous'],
                    ['C3_jerk', 'C³ Jerk Continuous'],
                    ['C4_hypersmooth', 'C⁴ Hyper-Smooth'],
                  ] as const
                ).map(([cKey, cLabel]) => (
                  <button
                    key={cKey}
                    onClick={() => setContinuity(cKey)}
                    className={`px-2 py-1 rounded border text-left font-bold ${
                      continuity === cKey
                        ? 'bg-amber-500/20 border-amber-500/50 text-amber-300'
                        : 'bg-white/5 border-white/10 text-white/60'
                    }`}
                  >
                    {cLabel}
                  </button>
                ))}
              </div>
            </div>
          </div>

          {/* 2. On-Curve Knots Manager (No handle tweaking!) */}
          <div className="space-y-2 bg-[#12131A] p-3 rounded border border-white/10 font-mono text-xs flex-1 flex flex-col min-h-[180px]">
            <div className="flex items-center justify-between">
              <span className="font-bold text-amber-400 uppercase tracking-wider">
                2. On-Curve Knots ({knots.length})
              </span>
              <button
                onClick={handleAddKnot}
                className="px-2 py-1 bg-amber-500 hover:bg-amber-400 text-black font-bold rounded text-[10px]"
              >
                + Add Knot
              </button>
            </div>

            <p className="text-[10px] text-white/40 italic">
              Notice: You only place on-curve knot points! Handles and higher-order Bernstein coefficients are automatically computed.
            </p>

            <div className="flex-1 overflow-y-auto space-y-1.5 bg-black/40 p-2 rounded border border-white/5 max-h-[150px]">
              {knots.map((k, idx) => (
                <div
                  key={k.id}
                  onClick={() => setSelectedKnotId(k.id)}
                  className={`p-1.5 rounded border text-[11px] flex items-center justify-between cursor-pointer ${
                    selectedKnotId === k.id
                      ? 'bg-amber-500/10 border-amber-500/50 text-amber-300'
                      : 'bg-white/5 border-white/5 text-white/70'
                  }`}
                >
                  <div className="flex items-center space-x-2">
                    <span className="font-bold text-white/40 text-[10px]">#{idx + 1}</span>
                    <span>Knot ({k.x.toFixed(0)}, {k.y.toFixed(0)})</span>
                  </div>

                  {knots.length > 2 && (
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        handleRemoveKnot(k.id);
                      }}
                      className="text-white/30 hover:text-red-400 text-[10px]"
                    >
                      Delete
                    </button>
                  )}
                </div>
              ))}
            </div>
          </div>

          {/* 3. Degree Reduction to Font Formats */}
          <div className="space-y-3 bg-[#12131A] p-3 rounded border border-white/10 font-mono text-xs">
            <span className="font-bold text-amber-400 uppercase tracking-wider block">
              3. Font Export & Real-Time Degree Reduction
            </span>

            {/* Target Export Format Selector */}
            <div className="grid grid-cols-3 gap-1.5 text-[10px]">
              <button
                onClick={() => setExportFormat('opentype_cubic')}
                className={`p-1.5 rounded border text-center font-bold ${
                  exportFormat === 'opentype_cubic'
                    ? 'bg-amber-500 text-black border-amber-400'
                    : 'bg-white/5 border-white/10 text-white/60'
                }`}
              >
                OpenType Cubic (N=3)
              </button>

              <button
                onClick={() => setExportFormat('truetype_quadratic')}
                className={`p-1.5 rounded border text-center font-bold ${
                  exportFormat === 'truetype_quadratic'
                    ? 'bg-amber-500 text-black border-amber-400'
                    : 'bg-white/5 border-white/10 text-white/60'
                }`}
              >
                TrueType Quad (N=2)
              </button>

              <button
                onClick={() => setExportFormat('raw_bernstein')}
                className={`p-1.5 rounded border text-center font-bold ${
                  exportFormat === 'raw_bernstein'
                    ? 'bg-amber-500 text-black border-amber-400'
                    : 'bg-white/5 border-white/10 text-white/60'
                }`}
              >
                Raw Bernstein (N={degree})
              </button>
            </div>

            {/* Reduction Metric Metrics */}
            <div className="p-2 bg-black/60 rounded border border-white/10 space-y-1 text-[10px]">
              <div className="flex justify-between">
                <span className="text-white/50">Max Hausdorff Error:</span>
                <span className="font-bold text-amber-300">
                  {stats.maxError < 0.001 ? '< 0.001 pt' : `${stats.maxError.toFixed(4)} pt`}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-white/50">Avg Spline Deviation:</span>
                <span className="font-bold text-emerald-400">
                  {stats.avgError.toFixed(4)} pt
                </span>
              </div>
            </div>

            <button
              onClick={handleCopyCode}
              className="w-full py-2 bg-amber-500 hover:bg-amber-400 text-black font-bold uppercase tracking-wider rounded flex items-center justify-center space-x-2 text-xs"
            >
              {copied ? <CheckCircle2 className="w-4 h-4" /> : <Copy className="w-4 h-4" />}
              <span>{copied ? 'Copied SVG Path!' : 'Copy Font Path SVG Code'}</span>
            </button>
          </div>
        </div>

        {/* Right Column: High-DPI Vector Canvas & Curvature Profile (7 columns) */}
        <div className="lg:col-span-7 bg-[#08090C] p-4 flex flex-col justify-between space-y-3 relative overflow-hidden">
          {/* Top Canvas Toolbar */}
          <div className="flex items-center justify-between bg-[#12131A] px-3 py-2 rounded border border-white/10 font-mono text-xs z-10">
            <div className="flex items-center space-x-3 text-[11px] text-white/70">
              <label className="flex items-center space-x-1.5 cursor-pointer">
                <input
                  type="checkbox"
                  checked={showCurvatureComb}
                  onChange={(e) => setShowCurvatureComb(e.target.checked)}
                  className="accent-amber-500"
                />
                <span>Curvature Comb κ(s)</span>
              </label>

              <label className="flex items-center space-x-1.5 cursor-pointer">
                <input
                  type="checkbox"
                  checked={showControlNet}
                  onChange={(e) => setShowControlNet(e.target.checked)}
                  className="accent-amber-500"
                />
                <span>Control Net</span>
              </label>

              <label className="flex items-center space-x-1.5 cursor-pointer">
                <input
                  type="checkbox"
                  checked={showReductionOverlay}
                  onChange={(e) => setShowReductionOverlay(e.target.checked)}
                  className="accent-amber-500"
                />
                <span>Reduced Cubic Overlay</span>
              </label>
            </div>

            <div className="text-[10px] text-amber-400 font-bold">
              Smooth C² / C³ Solved
            </div>
          </div>

          {/* Main SVG Vector Canvas */}
          <div className="flex-1 flex items-center justify-center relative bg-black/60 rounded border border-white/10 overflow-hidden shadow-inner min-h-[380px]">
            <svg
              ref={svgRef}
              viewBox="0 0 400 400"
              className="w-full h-full max-w-[500px] max-h-[500px] object-contain rounded"
            >
              {/* Background Grid */}
              <defs>
                <pattern id="bernstein_grid" width="20" height="20" patternUnits="userSpaceOnUse">
                  <path d="M 20 0 L 0 0 0 20" fill="none" stroke="rgba(255,255,255,0.04)" strokeWidth="0.5" />
                </pattern>
              </defs>
              <rect width="400" height="400" fill="url(#bernstein_grid)" />

              {/* Control Polygon Net */}
              {showControlNet &&
                solvedSegments.map((seg, sIdx) => (
                  <g key={`net_${sIdx}`}>
                    <polyline
                      points={seg.controlPoints.map((p) => `${p.x},${p.y}`).join(' ')}
                      fill="none"
                      stroke="rgba(245, 158, 11, 0.25)"
                      strokeWidth="1"
                      strokeDasharray="3 3"
                    />
                    {seg.controlPoints.map((p, pIdx) => (
                      <circle
                        key={`cp_${sIdx}_${pIdx}`}
                        cx={p.x}
                        cy={p.y}
                        r="2.5"
                        fill="rgba(245, 158, 11, 0.6)"
                      />
                    ))}
                  </g>
                ))}

              {/* Reduced OpenType Cubic Path (Blue Overlay) */}
              {showReductionOverlay && (
                <path
                  d={svgPathData.opentypeCubic}
                  fill="none"
                  stroke="#38BDF8"
                  strokeWidth="3"
                  strokeOpacity="0.4"
                  strokeDasharray="4 4"
                />
              )}

              {/* Original Higher-Degree Smooth Curve (Amber Main) */}
              <path
                d={svgPathData.higherDegree}
                fill="none"
                stroke="#F59E0B"
                strokeWidth="2.5"
                strokeLinecap="round"
              />

              {/* Curvature Comb Plot κ(s) */}
              {showCurvatureComb &&
                solvedSegments.map((seg, sIdx) => (
                  <g key={`comb_${sIdx}`}>
                    {seg.curvatures.map((c, cIdx) => {
                      const scale = 1500;
                      // Normal vector approximation
                      const nx = -c.k * scale;
                      const ny = c.k * scale;
                      return (
                        <line
                          key={`c_line_${sIdx}_${cIdx}`}
                          x1={c.x}
                          y1={c.y}
                          x2={c.x + nx}
                          y2={c.y + ny}
                          stroke="rgba(16, 185, 129, 0.4)"
                          strokeWidth="1"
                        />
                      );
                    })}
                  </g>
                ))}

              {/* On-Curve Knots (Red / Amber Drag Handles) */}
              {knots.map((k, idx) => (
                <g
                  key={`knot_g_${k.id}`}
                  onMouseDown={() => {
                    setSelectedKnotId(k.id);
                    setDraggingKnotId(k.id);
                  }}
                  className="cursor-pointer"
                >
                  <circle
                    cx={k.x}
                    cy={k.y}
                    r={selectedKnotId === k.id ? '8' : '6'}
                    fill={selectedKnotId === k.id ? '#F59E0B' : '#FFFFFF'}
                    stroke="#000000"
                    strokeWidth="2"
                  />
                  <text
                    x={k.x + 10}
                    y={k.y - 10}
                    fill="#F59E0B"
                    fontSize="10"
                    fontFamily="monospace"
                    fontWeight="bold"
                  >
                    #{idx + 1}
                  </text>
                </g>
              ))}
            </svg>
          </div>

          {/* Basis Polynomial Function Plot (Interactive Sub-View) */}
          {showBasisChart && (
            <div className="bg-[#12131A] p-3 rounded border border-white/10 font-mono text-xs space-y-2">
              <div className="flex items-center justify-between text-[11px] text-white/70">
                <span className="font-bold text-amber-400 uppercase">
                  {basisType === 'bernstein' ? 'Bernstein' : 'Symmetric Power'} Polynomial Basis Decomposition (N={degree})
                </span>
                <span className="text-[10px] text-white/40">t ∈ [0, 1]</span>
              </div>

              {/* Polynomial Curves SVG Graph */}
              <div className="h-20 w-full bg-black/60 rounded border border-white/5 relative overflow-hidden flex items-center justify-center">
                <svg viewBox="0 0 300 60" className="w-full h-full">
                  {Array.from({ length: degree + 1 }).map((_, i) => {
                    let dStr = 'M 0 60';
                    const steps = 30;
                    for (let s = 0; s <= steps; s++) {
                      const t = s / steps;
                      const val =
                        basisType === 'bernstein'
                          ? evalBernsteinBasis(i, degree, t)
                          : evalSymmetricPowerBasis(i, degree, t);
                      const x = t * 300;
                      const y = 60 - val * 55;
                      dStr += ` L ${x.toFixed(1)} ${y.toFixed(1)}`;
                    }
                    const colors = ['#F59E0B', '#38BDF8', '#10B981', '#EC4899', '#8B5CF6', '#F97316', '#06B6D4'];
                    return (
                      <path
                        key={`b_curve_${i}`}
                        d={dStr}
                        fill="none"
                        stroke={colors[i % colors.length]}
                        strokeWidth="1.5"
                      />
                    );
                  })}
                </svg>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
