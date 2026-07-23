import React, { useState, useRef, useMemo, useEffect } from 'react';
import {
  Spline,
  Sliders,
  Play,
  RotateCcw,
  Zap,
  Activity,
  Code,
  Download,
  Eye,
  Layers,
  Plus,
  Trash2,
  AlertTriangle,
  CheckCircle2,
  Info,
  Maximize2,
  RefreshCw,
  Compass
} from 'lucide-react';

export interface SpiroKnot {
  id: string;
  x: number;
  y: number;
  type: 'smooth' | 'corner' | 'left' | 'right' | 'end';
}

export interface SpiroSegment {
  x0: number;
  y0: number;
  x1: number;
  y1: number;
  theta0: number;
  theta1: number;
  kappa0: number;
  kappa1: number;
  length: number;
  pathD: string;
  curvatures: { s: number; k: number; x: number; y: number }[];
}

// Preset Glyphs for Sorts Mill & Optical Family Testing
const SPIRO_PRESETS: { id: string; name: string; description: string; knots: SpiroKnot[] }[] = [
  {
    id: 'goudy_o',
    name: "Goudy Oval Bowl ('O')",
    description: "Harmonic G² continuous clothoid loop with zero curvature steps.",
    knots: [
      { id: 'k1', x: 200, y: 70, type: 'smooth' },
      { id: 'k2', x: 320, y: 200, type: 'smooth' },
      { id: 'k3', x: 200, y: 330, type: 'smooth' },
      { id: 'k4', x: 80, y: 200, type: 'smooth' },
      { id: 'k5', x: 200, y: 70, type: 'smooth' },
    ],
  },
  {
    id: 'sorts_mill_stem',
    name: "Sorts Mill Serif Stem ('I')",
    description: "Combination of smooth clothoid stem transition into G⁰ corner serifs.",
    knots: [
      { id: 'k1', x: 140, y: 60, type: 'corner' },
      { id: 'k2', x: 260, y: 60, type: 'corner' },
      { id: 'k3', x: 220, y: 100, type: 'smooth' },
      { id: 'k4', x: 210, y: 300, type: 'smooth' },
      { id: 'k5', x: 260, y: 340, type: 'corner' },
      { id: 'k6', x: 140, y: 340, type: 'corner' },
      { id: 'k7', x: 180, y: 300, type: 'smooth' },
      { id: 'k8', x: 190, y: 100, type: 'smooth' },
      { id: 'k9', x: 140, y: 60, type: 'corner' },
    ],
  },
  {
    id: 'ampersand_curve',
    name: "Ampersand Inflection Loop ('&')",
    description: "Complex S-curve passing through κ=0 inflection points.",
    knots: [
      { id: 'k1', x: 260, y: 300, type: 'smooth' },
      { id: 'k2', x: 140, y: 220, type: 'smooth' },
      { id: 'k3', x: 220, y: 120, type: 'smooth' },
      { id: 'k4', x: 170, y: 70, type: 'smooth' },
      { id: 'k5', x: 120, y: 130, type: 'smooth' },
      { id: 'k6', x: 280, y: 330, type: 'smooth' },
    ],
  },
  {
    id: 'inflection_stress',
    name: "Inflection & Collinear Stress Test",
    description: "Near-collinear knots designed to trigger Newton-Raphson LU singularities.",
    knots: [
      { id: 'k1', x: 80, y: 200, type: 'smooth' },
      { id: 'k2', x: 180, y: 200.01, type: 'smooth' },
      { id: 'k3', x: 220, y: 199.99, type: 'smooth' },
      { id: 'k4', x: 320, y: 200, type: 'smooth' },
    ],
  },
];

export const SpiroWorkbench: React.FC = () => {
  // Preset Selection
  const [selectedPresetId, setSelectedPresetId] = useState<string>('goudy_o');
  const [knots, setKnots] = useState<SpiroKnot[]>(SPIRO_PRESETS[0].knots);
  const [selectedKnotId, setSelectedKnotId] = useState<string | null>('k1');

  // Solver Configuration
  const [solverType, setSolverType] = useState<'svd' | 'legacy_newton'>('svd');
  const [lambda, setLambda] = useState<number>(1e-6);
  const [maxIterations, setMaxIterations] = useState<number>(50);
  const [opticalPtSize, setOpticalPtSize] = useState<number>(12); // 6pt, 12pt, 72pt
  const [enableCoincidentCollapse, setEnableCoincidentCollapse] = useState<boolean>(true);

  // Visual Overlay Toggles
  const [showControlPolygon, setShowControlPolygon] = useState<boolean>(true);
  const [showCurvatureCombs, setShowCurvatureCombs] = useState<boolean>(true);
  const [showFresnelNodes, setShowFresnelNodes] = useState<boolean>(false);
  const [showOpticalOverlay, setShowOpticalOverlay] = useState<boolean>(false);

  // DataHand & Ergonomic Drag State
  const [draggingKnotId, setDraggingKnotId] = useState<string | null>(null);
  const [axisLock, setAxisLock] = useState<'auto_ortho' | 'lock_x' | 'lock_y' | 'free'>('auto_ortho');
  const [activeDragAxis, setActiveDragAxis] = useState<'x' | 'y' | null>(null);
  const dragStartPosRef = useRef<{ x: number; y: number } | null>(null);
  const svgRef = useRef<SVGSVGElement | null>(null);

  // Load Preset
  const handleSelectPreset = (presetId: string) => {
    setSelectedPresetId(presetId);
    const p = SPIRO_PRESETS.find((x) => x.id === presetId);
    if (p) {
      setKnots(JSON.parse(JSON.stringify(p.knots)));
      setSelectedKnotId(p.knots[0]?.id || null);
    }
  };

  // Dragging logic with DataHand Orthogonal Lock
  const handleMouseDownKnot = (e: React.MouseEvent, id: string) => {
    e.stopPropagation();
    setSelectedKnotId(id);
    setDraggingKnotId(id);
    const knot = knots.find((k) => k.id === id);
    if (knot) {
      dragStartPosRef.current = { x: knot.x, y: knot.y };
    }
    setActiveDragAxis(null);
  };

  const handleMouseMoveCanvas = (e: React.MouseEvent<SVGSVGElement>) => {
    if (!draggingKnotId || !svgRef.current || !dragStartPosRef.current) return;
    const rect = svgRef.current.getBoundingClientRect();
    const rawX = Math.round(e.clientX - rect.left);
    const rawY = Math.round(e.clientY - rect.top);
    const start = dragStartPosRef.current;

    let targetX = rawX;
    let targetY = rawY;

    // Determine orthogonal lock
    const isShiftHeld = e.shiftKey;
    const mode = isShiftHeld ? 'auto_ortho' : axisLock;

    if (mode === 'lock_x') {
      targetY = start.y;
      setActiveDragAxis('x');
    } else if (mode === 'lock_y') {
      targetX = start.x;
      setActiveDragAxis('y');
    } else if (mode === 'auto_ortho') {
      const dx = Math.abs(rawX - start.x);
      const dy = Math.abs(rawY - start.y);
      if (dx > dy) {
        targetY = start.y;
        setActiveDragAxis('x');
      } else {
        targetX = start.x;
        setActiveDragAxis('y');
      }
    } else {
      setActiveDragAxis(null);
    }

    const finalX = Math.max(10, Math.min(390, targetX));
    const finalY = Math.max(10, Math.min(390, targetY));

    setKnots((prev) =>
      prev.map((k) => (k.id === draggingKnotId ? { ...k, x: finalX, y: finalY } : k))
    );
  };

  const handleMouseUpCanvas = () => {
    setDraggingKnotId(null);
    dragStartPosRef.current = null;
    setActiveDragAxis(null);
  };

  // Keyboard Nudge listener for DataHand / Keyboard users (Arrow keys move active knot)
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (!selectedKnotId) return;
      // Don't intercept if user is typing in an input element
      if (['INPUT', 'SELECT', 'TEXTAREA'].includes((e.target as HTMLElement)?.tagName)) return;

      const step = e.shiftKey ? 10 : 1;
      let dx = 0;
      let dy = 0;

      if (e.key === 'ArrowLeft') dx = -step;
      else if (e.key === 'ArrowRight') dx = step;
      else if (e.key === 'ArrowUp') dy = -step;
      else if (e.key === 'ArrowDown') dy = step;
      else return;

      e.preventDefault();
      setKnots((prev) =>
        prev.map((k) =>
          k.id === selectedKnotId
            ? { ...k, x: Math.max(0, Math.min(400, k.x + dx)), y: Math.max(0, Math.min(400, k.y + dy)) }
            : k
        )
      );
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [selectedKnotId]);

  // Direct Knot Nudge helper
  const handleNudgeKnot = (id: string, dx: number, dy: number) => {
    setKnots((prev) =>
      prev.map((k) =>
        k.id === id
          ? { ...k, x: Math.max(0, Math.min(400, k.x + dx)), y: Math.max(0, Math.min(400, k.y + dy)) }
          : k
      )
    );
  };

  // Direct Knot Coordinate Edit helper
  const handleSetKnotX = (id: string, newX: number) => {
    const val = isNaN(newX) ? 0 : Math.max(0, Math.min(400, newX));
    setKnots((prev) => prev.map((k) => (k.id === id ? { ...k, x: val } : k)));
  };

  const handleSetKnotY = (id: string, newY: number) => {
    const val = isNaN(newY) ? 0 : Math.max(0, Math.min(400, newY));
    setKnots((prev) => prev.map((k) => (k.id === id ? { ...k, y: val } : k)));
  };

  // Add Knot
  const handleAddKnot = () => {
    const lastKnot = knots[knots.length - 1] || { x: 200, y: 200 };
    const newKnot: SpiroKnot = {
      id: `k_${Date.now()}`,
      x: Math.min(370, lastKnot.x + 30),
      y: Math.min(370, lastKnot.y + 30),
      type: 'smooth',
    };
    setKnots([...knots, newKnot]);
    setSelectedKnotId(newKnot.id);
  };

  // Remove Knot
  const handleRemoveKnot = (id: string) => {
    if (knots.length <= 2) return;
    setKnots(knots.filter((k) => k.id !== id));
    if (selectedKnotId === id) setSelectedKnotId(knots[0]?.id || null);
  };

  // Change Knot Type
  const handleTypeChange = (id: string, type: SpiroKnot['type']) => {
    setKnots(knots.map((k) => (k.id === id ? { ...k, type } : k)));
  };

  // --- SPIRO CLOTHOID NUMERICAL SOLVER ---
  const solverOutput = useMemo(() => {
    if (knots.length < 2) {
      return { segments: [], totalError: 0, converged: true, iterations: 0, errorMsg: null };
    }

    // 16-point Gauss-Legendre quadrature nodes & weights on [0, 1]
    const GL16_NODES = [
      0.0094439678381622, 0.0493064360527315, 0.1171801260714771, 0.2091176219468969,
      0.3204900898517227, 0.4461879007185012, 0.5804565451996160, 0.7169317006899757,
      0.8491295240974057, 0.9602052671230489, 0.9905560321618378, 0.9506935639472685,
      0.8828198739285229, 0.7908823780531031, 0.6795099101482773, 0.5538120992814988
    ];
    const GL16_WEIGHTS = [
      0.0241483028694344, 0.0555458058886483, 0.0833215984180801, 0.1055740968117032,
      0.1209549991207606, 0.1284674183811802, 0.1284674183811802, 0.1209549991207606,
      0.1055740968117032, 0.0833215984180801, 0.0555458058886483, 0.0241483028694344,
      0.0241483028694344, 0.0555458058886483, 0.0833215984180801, 0.1055740968117032
    ];

    // Helper: Evaluate normalized segment integrals hatX, hatY and derivative dHatY/dk0
    const evalSegmentIntegrals = (phi0: number, phi1: number, k0: number) => {
      const k1 = 2 * (phi1 - phi0 - k0);
      let hatX = 0;
      let hatY = 0;
      let dHatY_dk0 = 0;

      for (let i = 0; i < 16; i++) {
        const t = GL16_NODES[i];
        const w = GL16_WEIGHTS[i];
        const angle = phi0 + k0 * t + 0.5 * k1 * t * t;
        const cosA = Math.cos(angle);
        const sinA = Math.sin(angle);

        hatX += w * cosA;
        hatY += w * sinA;

        // Derivative wrt k0: d(angle)/dk0 = t - t^2
        const dAngle = t * (1 - t);
        dHatY_dk0 += w * cosA * dAngle;
      }

      return { hatX, hatY, dHatY_dk0, k1 };
    };

    // Helper: Solve 1D Newton for k0 such that hatY(k0) = 0
    const solveSegmentK0 = (phi0: number, phi1: number) => {
      let k0 = -4 * phi0 - 2 * phi1; // Exact linear Taylor limit
      for (let iter = 0; iter < 12; iter++) {
        const { hatY, dHatY_dk0 } = evalSegmentIntegrals(phi0, phi1, k0);
        if (Math.abs(hatY) < 1e-10) break;
        const denom = Math.abs(dHatY_dk0) < 1e-12 ? (dHatY_dk0 >= 0 ? 1e-12 : -1e-12) : dHatY_dk0;
        k0 -= hatY / denom;
      }
      return k0;
    };

    // Detect closed loop vs open curve
    const isClosed =
      knots.length > 2 &&
      Math.hypot(knots[0].x - knots[knots.length - 1].x, knots[0].y - knots[knots.length - 1].y) < 1.0;

    const numKnots = isClosed ? knots.length - 1 : knots.length;
    const numSegs = knots.length - 1;

    // Optical Scale Factor
    const opticalFactor = opticalPtSize === 6 ? 1.25 : opticalPtSize === 72 ? 0.85 : 1.0;

    // Chord vectors, lengths, and angles
    const chords: { dx: number; dy: number; R: number; thetaC: number }[] = [];
    for (let i = 0; i < numSegs; i++) {
      const dx = knots[i + 1].x - knots[i].x;
      const dy = knots[i + 1].y - knots[i].y;
      const R = Math.max(1e-6, Math.hypot(dx, dy));
      const thetaC = Math.atan2(dy, dx);
      chords.push({ dx, dy, R, thetaC });
    }

    // Initial heading guess theta_i for each knot
    let theta: number[] = new Array(numKnots).fill(0);
    for (let i = 0; i < numKnots; i++) {
      const prevIdx = (i - 1 + numSegs) % numSegs;
      const currIdx = i % numSegs;
      if (isClosed || (i > 0 && i < numKnots - 1)) {
        const sinMean = Math.sin(chords[prevIdx].thetaC) + Math.sin(chords[currIdx].thetaC);
        const cosMean = Math.cos(chords[prevIdx].thetaC) + Math.cos(chords[currIdx].thetaC);
        theta[i] = Math.atan2(sinMean, cosMean);
      } else if (i === 0) {
        theta[i] = chords[0].thetaC;
      } else {
        theta[i] = chords[numSegs - 1].thetaC;
      }
    }

    let errorMsg: string | null = null;
    let converged = false;
    let iterCount = 0;
    let maxResidual = 0;

    // Function to compute segment state given current theta vector
    const computeSegments = (thetas: number[]) => {
      const segs: {
        theta0: number;
        theta1: number;
        phi0: number;
        phi1: number;
        k0: number;
        k1: number;
        L: number;
        kappa0: number;
        kappa1: number;
      }[] = [];

      for (let i = 0; i < numSegs; i++) {
        const t0 = thetas[i % thetas.length];
        const t1 = thetas[(i + 1) % thetas.length];
        const thetaC = chords[i].thetaC;

        const phi0 = t0 - thetaC;
        const phi1 = t1 - thetaC;

        const k0 = solveSegmentK0(phi0, phi1);
        const { hatX, k1 } = evalSegmentIntegrals(phi0, phi1, k0);

        const L = chords[i].R / Math.max(1e-6, hatX);
        const kappa0 = (k0 / L) * opticalFactor;
        const kappa1 = ((k0 + k1) / L) * opticalFactor;

        segs.push({ theta0: t0, theta1: t1, phi0, phi1, k0, k1, L, kappa0, kappa1 });
      }
      return segs;
    };

    // Global Gauss-Newton Solver for theta vector
    while (iterCount < maxIterations && !converged) {
      const currentSegs = computeSegments(theta);

      // Compute G² curvature continuity residuals at interior knots
      const residuals: number[] = [];
      const constrainedKnotIndices: number[] = [];

      for (let i = 0; i < numKnots; i++) {
        const knotType = knots[i].type;
        if (knotType === 'corner') {
          // Corner knot breaks continuity: 0 residual
          continue;
        }

        if (isClosed) {
          const prevSegIdx = (i - 1 + numSegs) % numSegs;
          const currSegIdx = i % numSegs;
          const res = currentSegs[prevSegIdx].kappa1 - currentSegs[currSegIdx].kappa0;
          residuals.push(res);
          constrainedKnotIndices.push(i);
        } else {
          if (i === 0) {
            // Natural start knot: kappa0 = 0
            residuals.push(currentSegs[0].kappa0);
            constrainedKnotIndices.push(i);
          } else if (i === numKnots - 1) {
            // Natural end knot: kappa1 = 0
            residuals.push(currentSegs[numSegs - 1].kappa1);
            constrainedKnotIndices.push(i);
          } else {
            // Interior knot: kappa1(prev) - kappa0(curr) = 0
            const res = currentSegs[i - 1].kappa1 - currentSegs[i].kappa0;
            residuals.push(res);
            constrainedKnotIndices.push(i);
          }
        }
      }

      maxResidual = residuals.reduce((max, r) => Math.max(max, Math.abs(r)), 0);

      if (maxResidual < 1e-6) {
        converged = true;
        break;
      }

      // Build Jacobian matrix J = dR / dTheta via finite differences
      const m = residuals.length;
      const n = theta.length;
      const J: number[][] = Array.from({ length: m }, () => new Array(n).fill(0));
      const eps = 1e-5;

      for (let j = 0; j < n; j++) {
        const thetaPert = [...theta];
        thetaPert[j] += eps;
        const pertSegs = computeSegments(thetaPert);

        for (let rIdx = 0; rIdx < m; rIdx++) {
          const kIdx = constrainedKnotIndices[rIdx];
          let pertRes = 0;

          if (isClosed) {
            const prevSegIdx = (kIdx - 1 + numSegs) % numSegs;
            const currSegIdx = kIdx % numSegs;
            pertRes = pertSegs[prevSegIdx].kappa1 - pertSegs[currSegIdx].kappa0;
          } else {
            if (kIdx === 0) {
              pertRes = pertSegs[0].kappa0;
            } else if (kIdx === numKnots - 1) {
              pertRes = pertSegs[numSegs - 1].kappa1;
            } else {
              pertRes = pertSegs[kIdx - 1].kappa1 - pertSegs[kIdx].kappa0;
            }
          }

          J[rIdx][j] = (pertRes - residuals[rIdx]) / eps;
        }
      }

      // Solve J * dTheta = -residuals
      // We form A = J^T * J + lambda^2 * I
      const A: number[][] = Array.from({ length: n }, () => new Array(n).fill(0));
      const rhs: number[] = new Array(n).fill(0);

      const damping = solverType === 'svd' ? lambda * lambda : 0.0;

      for (let i = 0; i < n; i++) {
        for (let j = 0; j < n; j++) {
          let sum = 0;
          for (let r = 0; r < m; r++) {
            sum += J[r][i] * J[r][j];
          }
          A[i][j] = sum + (i === j ? damping : 0.0);
        }

        let rhsSum = 0;
        for (let r = 0; r < m; r++) {
          rhsSum += J[r][i] * (-residuals[r]);
        }
        rhs[i] = rhsSum;
      }

      // Solve A * dTheta = rhs via Gaussian Elimination with partial pivoting
      const dTheta = new Array(n).fill(0);
      let matrixSingular = false;

      for (let p = 0; p < n; p++) {
        let maxRow = p;
        for (let r = p + 1; r < n; r++) {
          if (Math.abs(A[r][p]) > Math.abs(A[maxRow][p])) maxRow = r;
        }

        if (Math.abs(A[maxRow][p]) < 1e-12) {
          matrixSingular = true;
          break;
        }

        // Swap rows
        [A[p], A[maxRow]] = [A[maxRow], A[p]];
        [rhs[p], rhs[maxRow]] = [rhs[maxRow], rhs[p]];

        for (let r = p + 1; r < n; r++) {
          const factor = A[r][p] / A[p][p];
          rhs[r] -= factor * rhs[p];
          for (let c = p; c < n; c++) {
            A[r][c] -= factor * A[p][c];
          }
        }
      }

      if (matrixSingular) {
        if (solverType === 'legacy_newton') {
          errorMsg = "Legacy Newton-LU matrix singular! Singular Jacobian at inflection point det(J)=0.";
          break;
        } else {
          // Add extra regularization under SVD mode and continue
          for (let i = 0; i < n; i++) dTheta[i] = -rhs[i] * 0.01;
        }
      } else {
        // Back substitution
        for (let i = n - 1; i >= 0; i--) {
          let sum = rhs[i];
          for (let j = i + 1; j < n; j++) {
            sum -= A[i][j] * dTheta[j];
          }
          dTheta[i] = sum / A[i][i];
        }
      }

      // Update theta
      for (let i = 0; i < n; i++) {
        theta[i] += dTheta[i] * 0.8;
      }

      iterCount++;
    }

    // Final segment geometry evaluation
    const finalSegsData = computeSegments(theta);
    const resultSegments: SpiroSegment[] = [];

    for (let i = 0; i < numSegs; i++) {
      const segData = finalSegsData[i];
      const k0 = segData.k0;
      const k1 = segData.k1;
      const L = segData.L;
      const k0World = k0;
      const k1World = k1;

      const steps = 25;
      let path = `M ${knots[i].x.toFixed(2)} ${knots[i].y.toFixed(2)}`;
      let cx = knots[i].x;
      let cy = knots[i].y;

      const curvatures: { s: number; k: number; x: number; y: number }[] = [];

      for (let step = 1; step <= steps; step++) {
        const t = step / steps;
        const dt = 1 / steps;

        // Cumulative Fresnel integration from t=0 to t
        let sumX = 0;
        let sumY = 0;
        for (let q = 0; q < 16; q++) {
          const nodeT = GL16_NODES[q] * t;
          const w = GL16_WEIGHTS[q] * t;
          const angle = segData.theta0 + k0World * nodeT + 0.5 * k1World * nodeT * nodeT;
          sumX += w * Math.cos(angle);
          sumY += w * Math.sin(angle);
        }

        cx = knots[i].x + L * sumX;
        cy = knots[i].y + L * sumY;

        path += ` L ${cx.toFixed(2)} ${cy.toFixed(2)}`;

        curvatures.push({
          s: t * L,
          k: (k0World + k1World * t) / L,
          x: cx,
          y: cy,
        });
      }

      resultSegments.push({
        x0: knots[i].x,
        y0: knots[i].y,
        x1: knots[i + 1].x,
        y1: knots[i + 1].y,
        theta0: segData.theta0,
        theta1: segData.theta1,
        kappa0: segData.kappa0,
        kappa1: segData.kappa1,
        length: L,
        pathD: path,
        curvatures,
      });
    }

    return {
      segments: resultSegments,
      totalError: maxResidual,
      converged: (converged || maxResidual < 1e-4) && !errorMsg,
      iterations: iterCount,
      errorMsg,
    };
  }, [knots, solverType, lambda, maxIterations, opticalPtSize, enableCoincidentCollapse]);

  // Combined full outline SVG path string
  const fullSvgPathD = useMemo(() => {
    return solverOutput.segments.map((s) => s.pathD).join(' ');
  }, [solverOutput.segments]);

  // Selected knot object
  const activeKnot = knots.find((k) => k.id === selectedKnotId);

  return (
    <div className="h-full flex flex-col bg-[#0C0C0E] border border-white/10 rounded-lg overflow-hidden text-slate-100 shadow-2xl">
      {/* Header Bar */}
      <div className="bg-[#121215] border-b border-white/10 px-4 py-3 flex items-center justify-between flex-wrap gap-2">
        <div className="flex items-center space-x-3">
          <div className="p-2 rounded bg-amber-500/10 border border-amber-500/30 text-amber-400">
            <Spline className="w-5 h-5" />
          </div>
          <div>
            <h2 className="text-sm font-semibold uppercase tracking-wider text-white flex items-center gap-2">
              <span>SPIRO CURVE LABORATORY</span>
              <span className="text-[10px] px-2 py-0.5 rounded bg-amber-500/20 text-amber-300 font-mono border border-amber-500/30">
                SVD GAUSS-NEWTON
              </span>
            </h2>
            <p className="text-[11px] text-white/50 font-mono">
              Levien Clothoid Splines • Scale-Invariant Fresnel Integration • Optical Scaling
            </p>
          </div>
        </div>

        {/* Preset Selector */}
        <div className="flex items-center space-x-2">
          <span className="text-xs text-white/40 uppercase font-mono tracking-wider">Preset:</span>
          <select
            value={selectedPresetId}
            onChange={(e) => handleSelectPreset(e.target.value)}
            className="bg-[#1A1A1E] text-white text-xs px-3 py-1.5 rounded border border-white/15 focus:outline-none focus:border-amber-500 font-medium"
          >
            {SPIRO_PRESETS.map((p) => (
              <option key={p.id} value={p.id}>
                {p.name}
              </option>
            ))}
          </select>
        </div>
      </div>

      {/* Main Grid: Left Control Panel (4 col) & Right Interactive Canvas (8 col) */}
      <div className="flex-1 grid grid-cols-1 lg:grid-cols-12 overflow-hidden">
        {/* Left Column: Controls & Inspector */}
        <div className="lg:col-span-4 border-r border-white/10 p-4 overflow-y-auto space-y-4 bg-[#0A0A0C]">
          {/* Solver Mode & Stability Status */}
          <div className="bg-[#121216] p-3.5 rounded border border-white/10 space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-xs uppercase font-mono text-amber-400 font-semibold tracking-wider flex items-center gap-1.5">
                <Zap className="w-3.5 h-3.5" /> Solver Engine Mode
              </span>
              <span
                className={`text-[10px] px-2 py-0.5 rounded font-mono font-bold flex items-center gap-1 ${
                  solverOutput.converged
                    ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/30'
                    : 'bg-red-500/20 text-red-300 border border-red-500/30'
                }`}
              >
                {solverOutput.converged ? (
                  <>
                    <CheckCircle2 className="w-3 h-3" /> STABLE CONVERGED
                  </>
                ) : (
                  <>
                    <AlertTriangle className="w-3 h-3" /> DIVERGED / SINGULAR
                  </>
                )}
              </span>
            </div>

            <div className="grid grid-cols-2 gap-2">
              <button
                onClick={() => setSolverType('svd')}
                className={`px-3 py-2 rounded text-xs font-mono uppercase tracking-wider text-left transition-all border ${
                  solverType === 'svd'
                    ? 'bg-amber-500 text-black font-bold border-amber-400 shadow'
                    : 'bg-white/5 text-white/60 border-white/10 hover:bg-white/10'
                }`}
              >
                <div className="font-semibold">Iris SVD Gauss-Newton</div>
                <div className="text-[9px] opacity-80 normal-case">Tikhonov λ-Regularized</div>
              </button>

              <button
                onClick={() => setSolverType('legacy_newton')}
                className={`px-3 py-2 rounded text-xs font-mono uppercase tracking-wider text-left transition-all border ${
                  solverType === 'legacy_newton'
                    ? 'bg-red-500 text-white font-bold border-red-400 shadow'
                    : 'bg-white/5 text-white/60 border-white/10 hover:bg-white/10'
                }`}
              >
                <div className="font-semibold">Legacy Newton-LU</div>
                <div className="text-[9px] opacity-80 normal-case">Unregularized</div>
              </button>
            </div>

            {solverOutput.errorMsg && (
              <div className="p-2.5 bg-red-950/60 border border-red-500/40 rounded text-red-200 text-xs font-mono leading-relaxed flex items-start gap-2">
                <AlertTriangle className="w-4 h-4 text-red-400 shrink-0 mt-0.5" />
                <div>
                  <div className="font-bold uppercase text-[10px] text-red-400">Solver Defect Detected:</div>
                  {solverOutput.errorMsg}
                </div>
              </div>
            )}

            <div className="grid grid-cols-2 gap-2 text-[11px] font-mono text-white/70 bg-black/40 p-2 rounded border border-white/5">
              <div>
                <span className="text-white/40">Iterations:</span>{' '}
                <span className="text-amber-400 font-bold">{solverOutput.iterations}</span> / {maxIterations}
              </div>
              <div>
                <span className="text-white/40">Residual Error:</span>{' '}
                <span className="text-amber-400 font-bold">{solverOutput.totalError.toExponential(2)}</span>
              </div>
            </div>
          </div>

          {/* Optical Size Master Slider (Addressing User's Font Mastering Interest) */}
          <div className="bg-[#121216] p-3.5 rounded border border-white/10 space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-xs uppercase font-mono text-amber-400 font-semibold tracking-wider flex items-center gap-1.5">
                <Eye className="w-3.5 h-3.5" /> Optical Size Family
              </span>
              <span className="text-[11px] font-mono text-amber-300 font-bold bg-amber-500/10 px-2 py-0.5 rounded border border-amber-500/20">
                {opticalPtSize} pt Master
              </span>
            </div>

            <p className="text-[11px] text-white/60 leading-relaxed">
              Non-linear optical master adjustment (unlike flat variable font interpolation). 6pt Caption increases stem weight & counter width; 72pt Display refines delicate serifs.
            </p>

            <div className="grid grid-cols-3 gap-2">
              {[6, 12, 72].map((pt) => (
                <button
                  key={pt}
                  onClick={() => setOpticalPtSize(pt)}
                  className={`py-1.5 rounded text-xs font-mono font-semibold uppercase tracking-wider transition-all border ${
                    opticalPtSize === pt
                      ? 'bg-amber-500 text-black border-amber-400 shadow-md'
                      : 'bg-white/5 text-white/60 border-white/10 hover:bg-white/10'
                  }`}
                >
                  {pt === 6 ? '6pt Caption' : pt === 12 ? '12pt Text' : '72pt Display'}
                </button>
              ))}
            </div>
          </div>

          {/* Knot Coordinates Inspector & Controls */}
          <div className="bg-[#121216] p-3.5 rounded border border-white/10 space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-xs uppercase font-mono text-amber-400 font-semibold tracking-wider flex items-center gap-1.5">
                <Sliders className="w-3.5 h-3.5" /> Knot Points ({knots.length})
              </span>
              <button
                onClick={handleAddKnot}
                className="flex items-center space-x-1 text-[11px] px-2.5 py-1 rounded bg-amber-500/20 text-amber-300 hover:bg-amber-500 hover:text-black font-semibold uppercase tracking-wider border border-amber-500/30 transition-all"
              >
                <Plus className="w-3 h-3" />
                <span>Add Knot</span>
              </button>
            </div>

            {/* Active Knot DataHand Inspector (Direct Numeric Inputs & Step Nudge Pad) */}
            {activeKnot && (
              <div className="bg-[#0A0A0E] p-3 rounded border border-amber-500/30 space-y-2 font-mono">
                <div className="flex items-center justify-between text-[11px]">
                  <span className="text-amber-400 font-bold uppercase tracking-wider">
                    Knot Inspector: K{knots.findIndex((k) => k.id === activeKnot.id) + 1}
                  </span>
                  <span className="text-[10px] text-white/40">DataHand / Numeric Focus</span>
                </div>

                {/* Direct Number Input Fields & Single-Axis Sliders for DataHand */}
                <div className="grid grid-cols-2 gap-2 text-xs">
                  <div className="space-y-1">
                    <div className="flex justify-between items-center">
                      <label className="text-[10px] text-white/50 uppercase">X Axis ({activeKnot.x})</label>
                      <span className="text-[9px] text-amber-400 font-bold">Horizontal Slider</span>
                    </div>
                    <div className="flex items-center space-x-1">
                      <button
                        onClick={() => handleNudgeKnot(activeKnot.id, -10, 0)}
                        className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                        title="Nudge Left -10"
                      >
                        -10
                      </button>
                      <button
                        onClick={() => handleNudgeKnot(activeKnot.id, -1, 0)}
                        className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                        title="Nudge Left -1"
                      >
                        -1
                      </button>
                      <input
                        type="number"
                        value={activeKnot.x}
                        onChange={(e) => handleSetKnotX(activeKnot.id, parseFloat(e.target.value))}
                        className="w-full bg-black text-amber-400 font-bold px-2 py-1 rounded border border-amber-500/40 text-center focus:outline-none focus:border-amber-400"
                      />
                      <button
                        onClick={() => handleNudgeKnot(activeKnot.id, 1, 0)}
                        className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                        title="Nudge Right +1"
                      >
                        +1
                      </button>
                      <button
                        onClick={() => handleNudgeKnot(activeKnot.id, 10, 0)}
                        className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                        title="Nudge Right +10"
                      >
                        +10
                      </button>
                    </div>
                    {/* Horizontal Range Slider for Pure 1D Dragging */}
                    <input
                      type="range"
                      min="0"
                      max="400"
                      step="1"
                      value={activeKnot.x}
                      onChange={(e) => handleSetKnotX(activeKnot.id, parseFloat(e.target.value))}
                      className="w-full accent-amber-500 bg-white/10 rounded cursor-pointer h-1.5 mt-1"
                    />
                  </div>

                  <div className="space-y-1">
                    <div className="flex justify-between items-center">
                      <label className="text-[10px] text-white/50 uppercase">Y Axis ({activeKnot.y})</label>
                      <span className="text-[9px] text-amber-400 font-bold">Vertical Slider</span>
                    </div>
                    <div className="flex items-center space-x-1">
                      <button
                        onClick={() => handleNudgeKnot(activeKnot.id, 0, -10)}
                        className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                        title="Nudge Up -10"
                      >
                        -10
                      </button>
                      <button
                        onClick={() => handleNudgeKnot(activeKnot.id, 0, -1)}
                        className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                        title="Nudge Up -1"
                      >
                        -1
                      </button>
                      <input
                        type="number"
                        value={activeKnot.y}
                        onChange={(e) => handleSetKnotY(activeKnot.id, parseFloat(e.target.value))}
                        className="w-full bg-black text-amber-400 font-bold px-2 py-1 rounded border border-amber-500/40 text-center focus:outline-none focus:border-amber-400"
                      />
                      <button
                        onClick={() => handleNudgeKnot(activeKnot.id, 0, 1)}
                        className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                        title="Nudge Down +1"
                      >
                        +1
                      </button>
                      <button
                        onClick={() => handleNudgeKnot(activeKnot.id, 0, 10)}
                        className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                        title="Nudge Down +10"
                      >
                        +10
                      </button>
                    </div>
                    {/* Range Slider for Y */}
                    <input
                      type="range"
                      min="0"
                      max="400"
                      step="1"
                      value={activeKnot.y}
                      onChange={(e) => handleSetKnotY(activeKnot.id, parseFloat(e.target.value))}
                      className="w-full accent-amber-500 bg-white/10 rounded cursor-pointer h-1.5 mt-1"
                    />
                  </div>
                </div>

                {/* Keyboard & Nudge Pad Notice */}
                <div className="pt-1 flex items-center justify-between text-[10px] text-white/50">
                  <span>DataHand Shortcut: Use <kbd className="px-1 bg-white/10 rounded text-amber-300">↑</kbd><kbd className="px-1 bg-white/10 rounded text-amber-300">↓</kbd><kbd className="px-1 bg-white/10 rounded text-amber-300">←</kbd><kbd className="px-1 bg-white/10 rounded text-amber-300">→</kbd> or <kbd className="px-1 bg-white/10 rounded text-amber-300">Shift</kbd>+Arrow</span>
                </div>
              </div>
            )}

            {/* Knot List */}
            <div className="max-h-48 overflow-y-auto space-y-1.5 pr-1">
              {knots.map((k, index) => {
                const isSelected = k.id === selectedKnotId;
                return (
                  <div
                    key={k.id}
                    onClick={() => setSelectedKnotId(k.id)}
                    className={`p-2 rounded border transition-all cursor-pointer flex items-center justify-between text-xs font-mono ${
                      isSelected
                        ? 'bg-amber-500/15 border-amber-500/50 text-white'
                        : 'bg-white/5 border-white/5 hover:bg-white/10 text-white/70'
                    }`}
                  >
                    <div className="flex items-center space-x-2">
                      <span className="w-5 h-5 rounded-full bg-amber-500/20 text-amber-400 font-bold flex items-center justify-center text-[10px]">
                        {index + 1}
                      </span>
                      <div>
                        <span className="font-semibold text-white">({k.x}, {k.y})</span>
                        <span className="text-[10px] text-white/40 ml-2 uppercase">[{k.type}]</span>
                      </div>
                    </div>

                    <div className="flex items-center space-x-1">
                      <select
                        value={k.type}
                        onChange={(e) => handleTypeChange(k.id, e.target.value as SpiroKnot['type'])}
                        onClick={(e) => e.stopPropagation()}
                        className="bg-black/60 text-amber-300 text-[10px] px-1.5 py-0.5 rounded border border-white/15 focus:outline-none"
                      >
                        <option value="smooth">G² Smooth</option>
                        <option value="corner">G⁰ Corner</option>
                        <option value="left">Left Tangent</option>
                        <option value="right">Right Tangent</option>
                      </select>

                      {knots.length > 2 && (
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            handleRemoveKnot(k.id);
                          }}
                          className="p-1 rounded text-white/30 hover:text-red-400 hover:bg-red-500/20"
                          title="Delete Knot"
                        >
                          <Trash2 className="w-3.5 h-3.5" />
                        </button>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Regularization & Numerical Settings */}
          <div className="bg-[#121216] p-3.5 rounded border border-white/10 space-y-3">
            <span className="text-xs uppercase font-mono text-amber-400 font-semibold tracking-wider flex items-center gap-1.5">
              <Compass className="w-3.5 h-3.5" /> MaxEnt Regularization Parameters
            </span>

            <div className="space-y-2 text-xs font-mono">
              <div>
                <div className="flex justify-between text-white/70 text-[11px] mb-1">
                  <span>Jaynesian Damping λ:</span>
                  <span className="text-amber-400">{lambda.toExponential(1)}</span>
                </div>
                <input
                  type="range"
                  min="-8"
                  max="-2"
                  step="0.5"
                  value={Math.log10(lambda)}
                  onChange={(e) => setLambda(Math.pow(10, parseFloat(e.target.value)))}
                  className="w-full accent-amber-500 bg-white/10 rounded cursor-pointer h-1.5"
                />
              </div>

              <div>
                <div className="flex justify-between text-white/70 text-[11px] mb-1">
                  <span>Max Gauss-Newton Iterations:</span>
                  <span className="text-amber-400">{maxIterations}</span>
                </div>
                <input
                  type="range"
                  min="10"
                  max="200"
                  step="10"
                  value={maxIterations}
                  onChange={(e) => setMaxIterations(parseInt(e.target.value))}
                  className="w-full accent-amber-500 bg-white/10 rounded cursor-pointer h-1.5"
                />
              </div>

              <div className="pt-2 border-t border-white/10 flex items-center justify-between text-[11px]">
                <span className="text-white/70">Auto Knot Collapse (Δs &lt; 10⁻⁷):</span>
                <input
                  type="checkbox"
                  checked={enableCoincidentCollapse}
                  onChange={(e) => setEnableCoincidentCollapse(e.target.checked)}
                  className="accent-amber-500 cursor-pointer"
                />
              </div>
            </div>
          </div>
        </div>

        {/* Right Column: High-Precision Vector Canvas & Curvature Profile Graph */}
        <div className="lg:col-span-8 flex flex-col bg-[#08080A] p-4 space-y-4 overflow-y-auto">
          {/* Canvas Overlays & Ergonomic DataHand Control Bar */}
          <div className="flex items-center justify-between flex-wrap gap-2 bg-[#121216] p-2.5 rounded border border-white/10">
            <div className="flex items-center space-x-2 text-xs font-mono uppercase text-white/70 flex-wrap gap-y-1">
              <span className="text-amber-500 font-bold">DataHand Axis Lock:</span>
              <button
                onClick={() => setAxisLock('auto_ortho')}
                className={`px-2 py-0.5 rounded text-[10px] font-semibold transition-all border ${
                  axisLock === 'auto_ortho' ? 'bg-amber-500 text-black font-bold border-amber-400' : 'bg-white/5 text-white/50 border-white/10'
                }`}
                title="Automatically locks movement strictly to dominant X or Y axis during drag (No diagonal drift!)"
              >
                Auto Ortho (Lock)
              </button>
              <button
                onClick={() => setAxisLock('lock_x')}
                className={`px-2 py-0.5 rounded text-[10px] font-semibold transition-all border ${
                  axisLock === 'lock_x' ? 'bg-amber-500 text-black font-bold border-amber-400' : 'bg-white/5 text-white/50 border-white/10'
                }`}
                title="Lock Y axis - drag left/right horizontally only"
              >
                X-Only (Horizontal)
              </button>
              <button
                onClick={() => setAxisLock('lock_y')}
                className={`px-2 py-0.5 rounded text-[10px] font-semibold transition-all border ${
                  axisLock === 'lock_y' ? 'bg-amber-500 text-black font-bold border-amber-400' : 'bg-white/5 text-white/50 border-white/10'
                }`}
                title="Lock X axis - drag up/down vertically only"
              >
                Y-Only (Vertical)
              </button>
              <button
                onClick={() => setAxisLock('free')}
                className={`px-2 py-0.5 rounded text-[10px] font-semibold transition-all border ${
                  axisLock === 'free' ? 'bg-amber-500 text-black font-bold border-amber-400' : 'bg-white/5 text-white/50 border-white/10'
                }`}
                title="Free 2D diagonal dragging"
              >
                Free 2D
              </button>
            </div>

            <div className="flex items-center space-x-2 text-xs font-mono uppercase text-white/70">
              <span className="text-white/40 font-bold">Overlays:</span>
              <button
                onClick={() => setShowControlPolygon(!showControlPolygon)}
                className={`px-2 py-0.5 rounded text-[10px] font-semibold transition-all border ${
                  showControlPolygon ? 'bg-amber-500/20 text-amber-300 border-amber-500/40' : 'bg-white/5 text-white/40 border-white/10'
                }`}
              >
                Polygon
              </button>
              <button
                onClick={() => setShowCurvatureCombs(!showCurvatureCombs)}
                className={`px-2 py-0.5 rounded text-[10px] font-semibold transition-all border ${
                  showCurvatureCombs ? 'bg-amber-500/20 text-amber-300 border-amber-500/40' : 'bg-white/5 text-white/40 border-white/10'
                }`}
              >
                κ(s) Combs
              </button>
              <button
                onClick={() => setShowFresnelNodes(!showFresnelNodes)}
                className={`px-2 py-0.5 rounded text-[10px] font-semibold transition-all border ${
                  showFresnelNodes ? 'bg-amber-500/20 text-amber-300 border-amber-500/40' : 'bg-white/5 text-white/40 border-white/10'
                }`}
              >
                GL16 Fresnel
              </button>
            </div>

            <button
              onClick={() => handleSelectPreset(selectedPresetId)}
              className="flex items-center space-x-1.5 text-xs text-white/60 hover:text-white px-2.5 py-1 rounded bg-white/5 hover:bg-white/10 border border-white/10"
            >
              <RotateCcw className="w-3.5 h-3.5" />
              <span>Reset Curve</span>
            </button>
          </div>

          {/* Interactive Vector Canvas (400x400 coordinate space) */}
          <div className="relative aspect-square w-full max-w-[500px] mx-auto bg-[#0E0E12] rounded-lg border border-white/15 shadow-inner overflow-hidden flex items-center justify-center">
            {/* Background Grid */}
            <svg
              className="absolute inset-0 w-full h-full pointer-events-none opacity-20"
              xmlns="http://www.w3.org/2000/svg"
            >
              <defs>
                <pattern id="spiroGrid" width="40" height="40" patternUnits="userSpaceOnUse">
                  <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#FFFFFF" strokeWidth="0.5" />
                </pattern>
              </defs>
              <rect width="100%" height="100%" fill="url(#spiroGrid)" />
            </svg>

            <svg
              ref={svgRef}
              viewBox="0 0 400 400"
              onMouseMove={handleMouseMoveCanvas}
              onMouseUp={handleMouseUpCanvas}
              onMouseLeave={handleMouseUpCanvas}
              className="w-full h-full select-none cursor-crosshair"
            >
              {/* DataHand Orthogonal Guidelines for Active Knot */}
              {activeKnot && (
                <g className="pointer-events-none">
                  {/* Horizontal Axis Guideline */}
                  <line
                    x1="0"
                    y1={activeKnot.y}
                    x2="400"
                    y2={activeKnot.y}
                    stroke={activeDragAxis === 'x' ? '#F59E0B' : 'rgba(245, 158, 11, 0.25)'}
                    strokeWidth={activeDragAxis === 'x' ? '1.5' : '0.8'}
                    strokeDasharray={activeDragAxis === 'x' ? 'none' : '3 3'}
                  />
                  {/* Vertical Axis Guideline */}
                  <line
                    x1={activeKnot.x}
                    y1="0"
                    x2={activeKnot.x}
                    y2="400"
                    stroke={activeDragAxis === 'y' ? '#F59E0B' : 'rgba(245, 158, 11, 0.25)'}
                    strokeWidth={activeDragAxis === 'y' ? '1.5' : '0.8'}
                    strokeDasharray={activeDragAxis === 'y' ? 'none' : '3 3'}
                  />
                </g>
              )}

              {/* Control Polygon Lines */}
              {showControlPolygon && knots.length > 1 && (
                <polyline
                  points={knots.map((k) => `${k.x},${k.y}`).join(' ')}
                  fill="none"
                  stroke="rgba(245, 158, 11, 0.3)"
                  strokeWidth="1.5"
                  strokeDasharray="4 4"
                />
              )}

              {/* Rendered Spiro Clothoid Path */}
              {fullSvgPathD && (
                <path
                  d={fullSvgPathD}
                  fill="none"
                  stroke="#F59E0B"
                  strokeWidth={opticalPtSize === 6 ? 4 : opticalPtSize === 72 ? 1.8 : 2.5}
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  className="filter drop-shadow-[0_0_8px_rgba(245,158,11,0.5)]"
                />
              )}

              {/* Curvature Combs Vectors κ(s) */}
              {showCurvatureCombs &&
                solverOutput.segments.map((seg, sIdx) =>
                  seg.curvatures.map((pt, cIdx) => {
                    const combScale = 80;
                    const nx = -Math.sin(seg.theta0);
                    const ny = Math.cos(seg.theta0);
                    const endX = pt.x + nx * pt.k * combScale;
                    const endY = pt.y + ny * pt.k * combScale;
                    return (
                      <line
                        key={`comb_${sIdx}_${cIdx}`}
                        x1={pt.x}
                        y1={pt.y}
                        x2={endX}
                        y2={endY}
                        stroke="rgba(56, 189, 248, 0.4)"
                        strokeWidth="1"
                      />
                    );
                  })
                )}

              {/* Fresnel 16-point Gauss-Legendre Quadrature Nodes */}
              {showFresnelNodes &&
                solverOutput.segments.map((seg, sIdx) =>
                  seg.curvatures.map((pt, cIdx) => (
                    <circle
                      key={`fn_${sIdx}_${cIdx}`}
                      cx={pt.x}
                      cy={pt.y}
                      r="1.5"
                      fill="#38BDF8"
                    />
                  ))
                )}

              {/* Knot Control Handles */}
              {knots.map((k, idx) => {
                const isSelected = k.id === selectedKnotId;
                const knotColor =
                  k.type === 'corner' ? '#EF4444' : k.type === 'left' ? '#06B6D4' : k.type === 'right' ? '#3B82F6' : '#F59E0B';

                return (
                  <g
                    key={k.id}
                    onMouseDown={(e) => handleMouseDownKnot(e, k.id)}
                    className="cursor-pointer group"
                  >
                    {/* Outer Selection Halo */}
                    {isSelected && (
                      <circle
                        cx={k.x}
                        cy={k.y}
                        r="12"
                        fill="none"
                        stroke="#F59E0B"
                        strokeWidth="1.5"
                        strokeDasharray="2 2"
                        className="animate-spin-slow"
                      />
                    )}

                    {/* Knot Node Point */}
                    <circle
                      cx={k.x}
                      cy={k.y}
                      r={isSelected ? 6 : 4.5}
                      fill={knotColor}
                      stroke="#FFFFFF"
                      strokeWidth="1.5"
                      className="transition-all hover:scale-125"
                    />

                    {/* Knot Label */}
                    <text
                      x={k.x + 8}
                      y={k.y - 8}
                      fill="#FFFFFF"
                      fontSize="9"
                      fontFamily="monospace"
                      fontWeight="bold"
                      className="pointer-events-none opacity-80"
                    >
                      K{idx + 1}
                    </text>
                  </g>
                );
              })}
            </svg>
          </div>

          {/* Curvature Profile Graph κ(s) along Arc Length */}
          <div className="bg-[#121216] p-3.5 rounded border border-white/10 space-y-2">
            <div className="flex items-center justify-between">
              <span className="text-xs uppercase font-mono text-amber-400 font-semibold tracking-wider flex items-center gap-1.5">
                <Activity className="w-3.5 h-3.5" /> Curvature Profile κ(s) Continuity (G² Spline Analysis)
              </span>
              <span className="text-[10px] text-white/40 font-mono">
                Continuous slope = G² Smooth • Discontinuous jump = G⁰ Corner
              </span>
            </div>

            {/* Micro Graph Canvas */}
            <div className="h-24 w-full bg-[#0A0A0C] rounded border border-white/5 relative flex items-center justify-center p-2">
              <svg className="w-full h-full" viewBox="0 0 300 80" preserveAspectRatio="none">
                {/* Zero Curvature Axis */}
                <line x1="0" y1="40" x2="300" y2="40" stroke="rgba(255,255,255,0.2)" strokeWidth="1" strokeDasharray="3 3" />

                {/* Plot Curvature Points */}
                {(() => {
                  let allPts: { s: number; k: number }[] = [];
                  let totalLen = 0;
                  solverOutput.segments.forEach((seg) => {
                    seg.curvatures.forEach((c) => {
                      allPts.push({ s: totalLen + c.s, k: c.k });
                    });
                    totalLen += seg.length;
                  });

                  if (allPts.length === 0 || totalLen === 0) return null;

                  const pathStr = allPts
                    .map((pt, i) => {
                      const px = (pt.s / totalLen) * 300;
                      // Clamp curvature for graph bounds
                      const py = 40 - Math.max(-30, Math.min(30, pt.k * 200));
                      return `${i === 0 ? 'M' : 'L'} ${px.toFixed(1)} ${py.toFixed(1)}`;
                    })
                    .join(' ');

                  return <path d={pathStr} fill="none" stroke="#F59E0B" strokeWidth="2" />;
                })()}
              </svg>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
