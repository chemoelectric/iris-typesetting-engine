import React, { useState, useRef, useEffect } from 'react';
import {
  Hammer,
  RotateCcw,
  Sparkles,
  Scissors,
  Layers,
  Flame,
  Eye,
  Sliders,
  Maximize2,
  ChevronUp,
  ChevronDown,
  Info,
  Type,
  FileText
} from 'lucide-react';

export type MaterialType = 'steel' | 'boxwood' | 'brass' | 'terracotta' | 'polymer_wax' | 'dark_bronze';
export type SculptEngineMode = 'clay_sculptor' | 'punchcutter_metal';
export type PhysicalTool = 'counter_punch' | 'flat_file' | 'needle_file' | 'graver' | 'rasp';
export type ClaySculptTool = 'push_pull_thumb' | 'clay_pinch' | 'clay_smooth_sponge' | 'clay_flat_rasp' | 'clay_gouge_add';

export interface Point2D {
  x: number;
  y: number;
}

export interface CutOperation {
  id: string;
  tool: PhysicalTool;
  x: number;
  y: number;
  width: number;
  height: number;
  depth: number;
  angle: number;
  shape?: 'rect' | 'oval' | 'triangle' | 'v_groove' | 'serif_cut';
}

// Generate smooth ellipse contour points for initial clay glyphs
const generateEllipseContour = (cx: number, cy: number, rx: number, ry: number, numPoints: number = 120): Point2D[] => {
  const pts: Point2D[] = [];
  for (let i = 0; i < numPoints; i += 1) {
    const angle = (i / numPoints) * Math.PI * 2;
    pts.push({
      x: cx + Math.cos(angle) * rx,
      y: cy + Math.sin(angle) * ry,
    });
  }
  return pts;
};

// Generate 'A' shape contour points
const generateLetterAContour = (): { outer: Point2D[]; inner: Point2D[] } => {
  const outer: Point2D[] = [];
  // Triangular apex, left stem, serif, right stem, serif
  const keyNodes: Point2D[] = [
    { x: 200, y: 70 },   // Apex top
    { x: 220, y: 70 },   // Apex right
    { x: 310, y: 320 },  // Right leg bottom
    { x: 340, y: 330 },  // Right serif outer
    { x: 270, y: 330 },  // Right serif inner
    { x: 250, y: 260 },  // Right inner waist
    { x: 150, y: 260 },  // Left inner waist
    { x: 130, y: 330 },  // Left serif inner
    { x: 60, y: 330 },   // Left serif outer
    { x: 90, y: 320 },   // Left leg bottom
    { x: 180, y: 70 },   // Apex left
  ];

  // Subdivide key nodes smoothly
  for (let i = 0; i < keyNodes.length; i += 1) {
    const curr = keyNodes[i];
    const next = keyNodes[(i + 1) % keyNodes.length];
    const steps = 12;
    for (let s = 0; s < steps; s += 1) {
      const t = s / steps;
      outer.push({
        x: curr.x + (next.x - curr.x) * t,
        y: curr.y + (next.y - curr.y) * t,
      });
    }
  }

  // Counter triangle
  const innerTriangle = generateEllipseContour(200, 180, 25, 35, 60);

  return { outer, inner: innerTriangle };
};

// Generate 'S' spine contour
const generateLetterSContour = (): Point2D[] => {
  const pts: Point2D[] = [];
  const num = 120;
  for (let i = 0; i < num; i += 1) {
    const t = (i / num) * Math.PI * 2;
    // S-curve parametric function
    const x = 200 + Math.sin(t) * 75 + Math.cos(t * 2) * 15;
    const y = 200 - Math.cos(t) * 115;
    pts.push({ x, y });
  }
  return pts;
};

export const PunchcutterWorkbench: React.FC = () => {
  // Engine Mode: Clay Outline Sculptor vs Steel Punchcutter
  const [engineMode, setEngineMode] = useState<SculptEngineMode>('clay_sculptor');

  // Material & Medium State
  const [material, setMaterial] = useState<MaterialType>('terracotta');
  const [activeTool, setActiveTool] = useState<PhysicalTool>('counter_punch');
  const [toolShape, setToolShape] = useState<'rect' | 'oval' | 'triangle' | 'v_groove' | 'serif_cut'>('oval');

  // Clay Sculpting State
  const [clayTool, setClayTool] = useState<ClaySculptTool>('push_pull_thumb');
  const [brushRadius, setBrushRadius] = useState<number>(45); // px
  const [brushStrength, setBrushStrength] = useState<number>(0.6); // 0.1 to 1.0
  const [showCurvatureComb, setShowCurvatureComb] = useState<boolean>(true);
  const [showClayWireframe, setShowClayWireframe] = useState<boolean>(true);

  // Clay Outlines (Outer & Inner Counter)
  const [outerContour, setOuterContour] = useState<Point2D[]>(() =>
    generateEllipseContour(200, 200, 110, 130, 120)
  );
  const [innerContour, setInnerContour] = useState<Point2D[]>(() =>
    generateEllipseContour(200, 200, 55, 75, 80)
  );
  const [contourHistory, setContourHistory] = useState<Array<{ outer: Point2D[]; inner: Point2D[] }>>([]);

  // Physical Tool Parameters (in mm / em points)
  const [toolX, setToolX] = useState<number>(200);
  const [toolY, setToolY] = useState<number>(200);
  const [toolWidth, setToolWidth] = useState<number>(60);
  const [toolHeight, setToolHeight] = useState<number>(100);
  const [toolDepth, setToolDepth] = useState<number>(2.5); // mm cut depth
  const [toolAngle, setToolAngle] = useState<number>(0);

  // Active Mouse/Touch Drag for Clay Sculpting
  const [isSculptingCanvas, setIsSculptingCanvas] = useState<boolean>(false);
  const [lastSculptPos, setLastSculptPos] = useState<Point2D | null>(null);

  // Punch Cut Operations History
  const [cutOps, setCutOps] = useState<CutOperation[]>([
    {
      id: 'cut_init_1',
      tool: 'counter_punch',
      x: 200,
      y: 200,
      width: 80,
      height: 120,
      depth: 3.0,
      angle: 0,
      shape: 'oval',
    },
  ]);

  // Proofing & Inspection Mode
  const [viewMode, setViewMode] = useState<'3d_relief' | 'smoke_proof' | 'ink_press' | 'peg_metrics'>('3d_relief');
  const [inkViscosity, setInkViscosity] = useState<number>(0.6);
  const [paperPressure, setPaperPressure] = useState<number>(0.8);

  const canvasRef = useRef<HTMLCanvasElement | null>(null);

  // Push current state to undo history before sculpting action
  const pushHistory = () => {
    setContourHistory((prev) => [
      ...prev.slice(-15),
      { outer: [...outerContour], inner: [...innerContour] },
    ]);
  };

  const handleUndoClay = () => {
    if (contourHistory.length === 0) return;
    const last = contourHistory[contourHistory.length - 1];
    setOuterContour(last.outer);
    setInnerContour(last.inner);
    setContourHistory((prev) => prev.slice(0, -1));
  };

  // Perform Clay Sculpting deformation at point (cx, cy) with direction (dx, dy)
  const applyClaySculptDeform = (cx: number, cy: number, dx: number, dy: number) => {
    const radius = brushRadius;
    const strength = brushStrength;

    const deformLoop = (pts: Point2D[]): Point2D[] => {
      return pts.map((pt, i, arr) => {
        const dist = Math.hypot(pt.x - cx, pt.y - cy);
        if (dist >= radius) return pt;

        // Gaussian smooth falloff
        const falloff = Math.pow(1 - dist / radius, 2) * strength;

        if (clayTool === 'push_pull_thumb') {
          // Push along movement vector (dx, dy)
          return {
            x: pt.x + dx * falloff * 0.8,
            y: pt.y + dy * falloff * 0.8,
          };
        } else if (clayTool === 'clay_pinch') {
          // Squeeze towards brush center (cx, cy)
          const dirX = (cx - pt.x) / (dist || 1);
          const dirY = (cy - pt.y) / (dist || 1);
          return {
            x: pt.x + dirX * falloff * 8,
            y: pt.y + dirY * falloff * 8,
          };
        } else if (clayTool === 'clay_smooth_sponge') {
          // Water smoothing - blend with neighbors
          const prevPt = arr[(i - 1 + arr.length) % arr.length];
          const nextPt = arr[(i + 1) % arr.length];
          const avgX = (prevPt.x + nextPt.x) / 2;
          const avgY = (prevPt.y + nextPt.y) / 2;
          return {
            x: pt.x + (avgX - pt.x) * falloff * 0.5,
            y: pt.y + (avgY - pt.y) * falloff * 0.5,
          };
        } else if (clayTool === 'clay_gouge_add') {
          // Add/subtract clay mass radially from brush center
          const dirX = (pt.x - cx) / (dist || 1);
          const dirY = (pt.y - cy) / (dist || 1);
          return {
            x: pt.x + dirX * falloff * 6,
            y: pt.y + dirY * falloff * 6,
          };
        } else if (clayTool === 'clay_flat_rasp') {
          // Flatten contour along tangent plane
          const planeDirX = -dy / (Math.hypot(dx, dy) || 1);
          const planeDirY = dx / (Math.hypot(dx, dy) || 1);
          const proj = (pt.x - cx) * planeDirX + (pt.y - cy) * planeDirY;
          return {
            x: pt.x + (cx + planeDirX * proj - pt.x) * falloff * 0.7,
            y: pt.y + (cy + planeDirY * proj - pt.y) * falloff * 0.7,
          };
        }

        return pt;
      });
    };

    setOuterContour((prev) => deformLoop(prev));
    if (innerContour.length > 0) {
      setInnerContour((prev) => deformLoop(prev));
    }
  };

  // 1D Accessible Directional Push for DataHand Users
  const handleDataHandClayPush = (direction: 'left' | 'right' | 'up' | 'down' | 'inward' | 'outward' | 'smooth', amount: number) => {
    pushHistory();
    let dx = 0;
    let dy = 0;
    if (direction === 'left') dx = -amount;
    if (direction === 'right') dx = amount;
    if (direction === 'up') dy = -amount;
    if (direction === 'down') dy = amount;

    if (direction === 'inward' || direction === 'outward') {
      const sign = direction === 'inward' ? -1 : 1;
      const radius = brushRadius;
      const strength = brushStrength;

      const scaleLoop = (pts: Point2D[]): Point2D[] => {
        return pts.map((pt) => {
          const dist = Math.hypot(pt.x - toolX, pt.y - toolY);
          if (dist >= radius) return pt;
          const falloff = Math.pow(1 - dist / radius, 2) * strength;
          const dirX = (pt.x - toolX) / (dist || 1);
          const dirY = (pt.y - toolY) / (dist || 1);
          return {
            x: pt.x + dirX * sign * amount * falloff,
            y: pt.y + dirY * sign * amount * falloff,
          };
        });
      };

      setOuterContour((prev) => scaleLoop(prev));
      if (innerContour.length > 0) setInnerContour((prev) => scaleLoop(prev));
      return;
    }

    if (direction === 'smooth') {
      const radius = brushRadius;
      const smoothLoop = (pts: Point2D[]): Point2D[] => {
        return pts.map((pt, i, arr) => {
          const dist = Math.hypot(pt.x - toolX, pt.y - toolY);
          if (dist >= radius) return pt;
          const prevPt = arr[(i - 1 + arr.length) % arr.length];
          const nextPt = arr[(i + 1) % arr.length];
          return {
            x: pt.x + ((prevPt.x + nextPt.x) / 2 - pt.x) * 0.4,
            y: pt.y + ((prevPt.y + nextPt.y) / 2 - pt.y) * 0.4,
          };
        });
      };
      setOuterContour((prev) => smoothLoop(prev));
      if (innerContour.length > 0) setInnerContour((prev) => smoothLoop(prev));
      return;
    }

    applyClaySculptDeform(toolX, toolY, dx, dy);
  };

  // Preset Clay Glyphs
  const handleLoadClayPreset = (preset: 'letter_O' | 'letter_A' | 'letter_S' | 'letter_g' | 'disk') => {
    pushHistory();
    if (preset === 'disk') {
      setOuterContour(generateEllipseContour(200, 200, 110, 110, 120));
      setInnerContour([]);
    } else if (preset === 'letter_O') {
      setOuterContour(generateEllipseContour(200, 200, 110, 130, 120));
      setInnerContour(generateEllipseContour(200, 200, 55, 75, 80));
    } else if (preset === 'letter_A') {
      const a = generateLetterAContour();
      setOuterContour(a.outer);
      setInnerContour(a.inner);
    } else if (preset === 'letter_S') {
      setOuterContour(generateLetterSContour());
      setInnerContour([]);
    } else if (preset === 'letter_g') {
      // Lowercase g double loop
      const topLoop = generateEllipseContour(200, 150, 70, 60, 80);
      const innerTop = generateEllipseContour(200, 150, 35, 30, 50);
      setOuterContour(topLoop);
      setInnerContour(innerTop);
    }
  };

  // Apply Current Cut Operation to Punch
  const handleApplyCut = () => {
    const newCut: CutOperation = {
      id: `cut_${Date.now()}`,
      tool: activeTool,
      x: toolX,
      y: toolY,
      width: toolWidth,
      height: toolHeight,
      depth: toolDepth,
      angle: toolAngle,
      shape: toolShape,
    };
    setCutOps((prev) => [...prev, newCut]);
  };

  const handleUndoCut = () => {
    setCutOps((prev) => prev.slice(0, -1));
  };

  const handleResetPunch = () => {
    setCutOps([]);
  };

  // Nudge Helpers for DataHand Users
  const handleNudgeToolX = (dx: number) => {
    setToolX((prev) => Math.max(20, Math.min(380, prev + dx)));
  };

  const handleNudgeToolY = (dy: number) => {
    setToolY((prev) => Math.max(20, Math.min(380, prev + dy)));
  };

  const handleNudgeWidth = (dw: number) => {
    setToolWidth((prev) => Math.max(5, Math.min(300, prev + dw)));
  };

  const handleNudgeHeight = (dh: number) => {
    setToolHeight((prev) => Math.max(5, Math.min(300, prev + dh)));
  };

  // Preset Punch Blanks
  const handleLoadPreset = (type: 'letter_O' | 'letter_H' | 'letter_R' | 'blank') => {
    if (type === 'blank') {
      setCutOps([]);
    } else if (type === 'letter_O') {
      setCutOps([
        // Counter punch inside
        { id: '1', tool: 'counter_punch', x: 200, y: 200, width: 80, height: 130, depth: 3, angle: 0, shape: 'oval' },
        // Outer filing chamfers
        { id: '2', tool: 'flat_file', x: 120, y: 120, width: 60, height: 60, depth: 2, angle: 45, shape: 'rect' },
        { id: '3', tool: 'flat_file', x: 280, y: 120, width: 60, height: 60, depth: 2, angle: -45, shape: 'rect' },
        { id: '4', tool: 'flat_file', x: 120, y: 280, width: 60, height: 60, depth: 2, angle: -45, shape: 'rect' },
        { id: '5', tool: 'flat_file', x: 280, y: 280, width: 60, height: 60, depth: 2, angle: 45, shape: 'rect' },
      ]);
    } else if (type === 'letter_H') {
      setCutOps([
        // Top counter cut out
        { id: '1', tool: 'graver', x: 200, y: 120, width: 90, height: 100, depth: 3, angle: 0, shape: 'rect' },
        // Bottom counter cut out
        { id: '2', tool: 'graver', x: 200, y: 280, width: 90, height: 100, depth: 3, angle: 0, shape: 'rect' },
      ]);
    } else if (type === 'letter_R') {
      setCutOps([
        // Counter bowl
        { id: '1', tool: 'counter_punch', x: 200, y: 150, width: 60, height: 60, depth: 3, angle: 0, shape: 'oval' },
        // Right bowl outer cut
        { id: '2', tool: 'graver', x: 260, y: 280, width: 80, height: 140, depth: 3, angle: 0, shape: 'v_groove' },
      ]);
    }
  };

  // Render Punch face / Clay Sculpt / Smoke proof / Ink proof on canvas
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const width = 400;
    const height = 400;
    canvas.width = width;
    canvas.height = height;

    // Clear background
    ctx.clearRect(0, 0, width, height);

    if (engineMode === 'clay_sculptor') {
      // ----------------------------------------------------
      // CLAY OUTLINE SCULPTOR RENDERING
      // ----------------------------------------------------
      // Slate Worktable Background
      const bgGrad = ctx.createRadialGradient(200, 200, 50, 200, 200, 250);
      bgGrad.addColorStop(0, '#12141C');
      bgGrad.addColorStop(1, '#08090D');
      ctx.fillStyle = bgGrad;
      ctx.fillRect(0, 0, width, height);

      // Grid guidelines & baseline / cap height
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.08)';
      ctx.lineWidth = 1;
      ctx.setLineDash([2, 4]);

      // Baseline y=300, Cap Height y=100, LSB x=80, RSB x=320
      ctx.beginPath();
      ctx.moveTo(0, 300); ctx.lineTo(400, 300);
      ctx.moveTo(0, 100); ctx.lineTo(400, 100);
      ctx.moveTo(80, 0); ctx.lineTo(80, 400);
      ctx.moveTo(320, 0); ctx.lineTo(320, 400);
      ctx.stroke();
      ctx.setLineDash([]);

      // Draw Sculpted Clay Body with 3D Shading
      if (outerContour.length > 2) {
        ctx.save();

        // Material Color Palette
        let clayFill: CanvasGradient | string = '#C86D43'; // Terracotta default
        let shadowColor = 'rgba(0, 0, 0, 0.6)';

        if (material === 'terracotta') {
          const g = ctx.createLinearGradient(100, 70, 300, 330);
          g.addColorStop(0, '#E08052');
          g.addColorStop(0.5, '#C86D43');
          g.addColorStop(1, '#944723');
          clayFill = g;
        } else if (material === 'polymer_wax') {
          const g = ctx.createLinearGradient(100, 70, 300, 330);
          g.addColorStop(0, '#FCD34D');
          g.addColorStop(0.5, '#F59E0B');
          g.addColorStop(1, '#B45309');
          clayFill = g;
        } else if (material === 'dark_bronze') {
          const g = ctx.createLinearGradient(100, 70, 300, 330);
          g.addColorStop(0, '#78716C');
          g.addColorStop(0.5, '#44403C');
          g.addColorStop(1, '#1C1917');
          clayFill = g;
        } else {
          // Steel / Boxwood fallback
          const g = ctx.createLinearGradient(100, 70, 300, 330);
          g.addColorStop(0, '#38BDF8');
          g.addColorStop(0.5, '#0284C7');
          g.addColorStop(1, '#075985');
          clayFill = g;
        }

        // Soft Clay Drop Shadow
        ctx.shadowColor = shadowColor;
        ctx.shadowBlur = 12;
        ctx.shadowOffsetX = 4;
        ctx.shadowOffsetY = 6;

        // Path for outer contour - inner contour (Even-Odd Fill)
        ctx.beginPath();
        ctx.moveTo(outerContour[0].x, outerContour[0].y);
        for (let i = 1; i < outerContour.length; i += 1) {
          ctx.lineTo(outerContour[i].x, outerContour[i].y);
        }
        ctx.closePath();

        if (innerContour.length > 2) {
          ctx.moveTo(innerContour[0].x, innerContour[0].y);
          for (let i = 1; i < innerContour.length; i += 1) {
            ctx.lineTo(innerContour[i].x, innerContour[i].y);
          }
          ctx.closePath();
        }

        ctx.fillStyle = clayFill;
        ctx.fill('evenodd');

        // Reset Shadow for Bevel / Wireframe
        ctx.shadowColor = 'transparent';

        // Sculpted Edge Bevel / Ambient Occlusion Line
        ctx.strokeStyle = 'rgba(255, 255, 255, 0.4)';
        ctx.lineWidth = 2;
        ctx.stroke();

        ctx.restore();

        // Draw Curvature Combs if enabled
        if (showCurvatureComb) {
          ctx.strokeStyle = 'rgba(245, 158, 11, 0.6)';
          ctx.lineWidth = 1;

          const drawComb = (pts: Point2D[]) => {
            for (let i = 0; i < pts.length; i += 2) {
              const prev = pts[(i - 1 + pts.length) % pts.length];
              const curr = pts[i];
              const next = pts[(i + 1) % pts.length];

              // Tangent vector
              const tx = next.x - prev.x;
              const ty = next.y - prev.y;
              const len = Math.hypot(tx, ty) || 1;
              const nx = -ty / len; // Normal
              const ny = tx / len;

              // Curvature estimation (angle change)
              const a1 = Math.atan2(curr.y - prev.y, curr.x - prev.x);
              const a2 = Math.atan2(next.y - curr.y, next.x - curr.x);
              let diff = a2 - a1;
              while (diff > Math.PI) diff -= Math.PI * 2;
              while (diff < -Math.PI) diff += Math.PI * 2;

              const combLen = Math.min(25, Math.abs(diff) * 120);

              ctx.beginPath();
              ctx.moveTo(curr.x, curr.y);
              ctx.lineTo(curr.x + nx * combLen, curr.y + ny * combLen);
              ctx.stroke();
            }
          };

          drawComb(outerContour);
          if (innerContour.length > 0) drawComb(innerContour);
        }

        // Draw Wireframe Vertex Points if enabled
        if (showClayWireframe) {
          ctx.fillStyle = '#FCD34D';
          for (let i = 0; i < outerContour.length; i += 4) {
            ctx.beginPath();
            ctx.arc(outerContour[i].x, outerContour[i].y, 2, 0, Math.PI * 2);
            ctx.fill();
          }
          for (let i = 0; i < innerContour.length; i += 4) {
            ctx.beginPath();
            ctx.arc(innerContour[i].x, innerContour[i].y, 2, 0, Math.PI * 2);
            ctx.fill();
          }
        }
      }

      // Render Active Sculpting Brush Overlay
      ctx.save();
      ctx.translate(toolX, toolY);

      // Brush radius ring
      ctx.strokeStyle = '#F59E0B';
      ctx.lineWidth = 1.5;
      ctx.setLineDash([4, 4]);
      ctx.beginPath();
      ctx.arc(0, 0, brushRadius, 0, Math.PI * 2);
      ctx.stroke();

      // Brush Center Reticle
      ctx.setLineDash([]);
      ctx.fillStyle = '#F59E0B';
      ctx.beginPath();
      ctx.arc(0, 0, 4, 0, Math.PI * 2);
      ctx.fill();

      // Tool Icon / Name label
      ctx.fillStyle = '#FCD34D';
      ctx.font = '10px monospace';
      ctx.textAlign = 'center';
      ctx.fillText(clayTool.replace('clay_', '').replace('_', ' ').toUpperCase(), 0, -brushRadius - 6);

      ctx.restore();
    } else if (viewMode === '3d_relief') {
      // Physical Metallic/Wood Steel Punch Relief Rendering
      // Base block
      if (material === 'steel') {
        const grad = ctx.createLinearGradient(0, 0, width, height);
        grad.addColorStop(0, '#1E2028');
        grad.addColorStop(0.5, '#2A2D38');
        grad.addColorStop(1, '#14151B');
        ctx.fillStyle = grad;
      } else if (material === 'boxwood') {
        const grad = ctx.createLinearGradient(0, 0, width, height);
        grad.addColorStop(0, '#5C3A21');
        grad.addColorStop(0.5, '#7A4D2C');
        grad.addColorStop(1, '#422815');
        ctx.fillStyle = grad;
      } else {
        // Brass
        const grad = ctx.createLinearGradient(0, 0, width, height);
        grad.addColorStop(0, '#B38B38');
        grad.addColorStop(0.5, '#D4AF37');
        grad.addColorStop(1, '#8C6820');
        ctx.fillStyle = grad;
      }

      ctx.fillRect(40, 40, 320, 320);

      // Block bezel & physical texture lines
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.15)';
      ctx.lineWidth = 2;
      ctx.strokeRect(40, 40, 320, 320);

      // Create physical punch face boundary (Base raised glyph face before cuts)
      // We start with a solid face rectangle, then subtract cutOps
      ctx.save();
      // Draw outer raised face bounds
      ctx.beginPath();
      ctx.rect(80, 80, 240, 240);

      // Subtract cuts via composite or clipping
      // Render cut operations as carved relief grooves
      cutOps.forEach((op) => {
        ctx.save();
        ctx.translate(op.x, op.y);
        ctx.rotate((op.angle * Math.PI) / 180);

        if (op.shape === 'oval') {
          ctx.beginPath();
          ctx.ellipse(0, 0, op.width / 2, op.height / 2, 0, 0, Math.PI * 2);
        } else if (op.shape === 'triangle') {
          ctx.beginPath();
          ctx.moveTo(0, -op.height / 2);
          ctx.lineTo(op.width / 2, op.height / 2);
          ctx.lineTo(-op.width / 2, op.height / 2);
          ctx.closePath();
        } else {
          ctx.beginPath();
          ctx.rect(-op.width / 2, -op.height / 2, op.width, op.height);
        }

        // Inner shadow representing carved depth in metal/wood
        ctx.fillStyle = material === 'steel' ? '#090A0C' : material === 'boxwood' ? '#221208' : '#3D2A08';
        ctx.fill();

        ctx.strokeStyle = material === 'steel' ? '#3B3F50' : '#8C5A35';
        ctx.lineWidth = 1.5;
        ctx.stroke();

        ctx.restore();
      });

      ctx.restore();

      // Render Active Tool Overlay Wireframe
      ctx.save();
      ctx.translate(toolX, toolY);
      ctx.rotate((toolAngle * Math.PI) / 180);

      ctx.strokeStyle = '#F59E0B'; // Amber tool outline
      ctx.lineWidth = 2;
      ctx.setLineDash([4, 4]);

      if (toolShape === 'oval') {
        ctx.beginPath();
        ctx.ellipse(0, 0, toolWidth / 2, toolHeight / 2, 0, 0, Math.PI * 2);
        ctx.stroke();
      } else if (toolShape === 'triangle') {
        ctx.beginPath();
        ctx.moveTo(0, -toolHeight / 2);
        ctx.lineTo(toolWidth / 2, toolHeight / 2);
        ctx.lineTo(-toolWidth / 2, toolHeight / 2);
        ctx.closePath();
        ctx.stroke();
      } else {
        ctx.strokeRect(-toolWidth / 2, -toolHeight / 2, toolWidth, toolHeight);
      }

      // Tool Center reticle
      ctx.beginPath();
      ctx.moveTo(-8, 0);
      ctx.lineTo(8, 0);
      ctx.moveTo(0, -8);
      ctx.lineTo(0, 8);
      ctx.strokeStyle = '#F59E0B';
      ctx.lineWidth = 1;
      ctx.setLineDash([]);
      ctx.stroke();

      ctx.restore();
    } else if (viewMode === 'smoke_proof') {
      // Lampblack Candle Smoke Proof on Paper Simulation
      // White/Cream rag paper texture background
      ctx.fillStyle = '#F4F0EA';
      ctx.fillRect(0, 0, width, height);

      // Paper grain noise grid
      ctx.fillStyle = 'rgba(0, 0, 0, 0.03)';
      for (let px = 0; px < width; px += 4) {
        for (let py = 0; py < height; py += 4) {
          if ((px + py) % 7 === 0) ctx.fillRect(px, py, 2, 2);
        }
      }

      // Render Soot Stamping: Solid Face minus cutOps with soot edge feathering
      ctx.save();
      ctx.fillStyle = 'rgba(15, 15, 18, 0.92)';

      // Raised face region
      ctx.beginPath();
      ctx.rect(80, 80, 240, 240);

      // Cut out counter spaces
      cutOps.forEach((op) => {
        ctx.save();
        ctx.translate(op.x, op.y);
        ctx.rotate((op.angle * Math.PI) / 180);
        if (op.shape === 'oval') {
          ctx.ellipse(0, 0, op.width / 2, op.height / 2, 0, 0, Math.PI * 2);
        } else {
          ctx.rect(-op.width / 2, -op.height / 2, op.width, op.height);
        }
        ctx.restore();
      });

      ctx.fill('evenodd');

      // Smoke Soot feathering aura around edges
      ctx.strokeStyle = 'rgba(15, 15, 18, 0.3)';
      ctx.lineWidth = 3;
      ctx.stroke();

      ctx.restore();
    } else if (viewMode === 'ink_press') {
      // Physical Oil Ink Press on Damp Rag Paper
      ctx.fillStyle = '#EAE5D9';
      ctx.fillRect(0, 0, width, height);

      ctx.save();
      // Physical Ink Viscosity & Paper Impression Bleed
      const alpha = Math.min(1.0, 0.7 + paperPressure * 0.25);
      ctx.fillStyle = `rgba(10, 12, 16, ${alpha})`;

      ctx.beginPath();
      ctx.rect(80, 80, 240, 240);

      cutOps.forEach((op) => {
        ctx.save();
        ctx.translate(op.x, op.y);
        ctx.rotate((op.angle * Math.PI) / 180);
        if (op.shape === 'oval') {
          ctx.ellipse(0, 0, op.width / 2, op.height / 2, 0, 0, Math.PI * 2);
        } else {
          ctx.rect(-op.width / 2, -op.height / 2, op.width, op.height);
        }
        ctx.restore();
      });

      ctx.fill('evenodd');

      // Ink capillary squeeze edge
      if (inkViscosity > 0.3) {
        ctx.strokeStyle = `rgba(10, 12, 16, ${inkViscosity * 0.4})`;
        ctx.lineWidth = 1 + inkViscosity * 2;
        ctx.stroke();
      }

      ctx.restore();
    } else if (viewMode === 'peg_metrics') {
      // Sorts Mill Pegs & Optical Center Metrics Overlay
      ctx.fillStyle = '#0B0C10';
      ctx.fillRect(0, 0, width, height);

      // Baseline, X-Height, Cap-Height, Side-Bearings
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.15)';
      ctx.lineWidth = 1;
      ctx.setLineDash([3, 3]);

      // Baseline (y=320)
      ctx.beginPath();
      ctx.moveTo(0, 320);
      ctx.lineTo(400, 320);
      ctx.stroke();

      // Cap Height (y=80)
      ctx.beginPath();
      ctx.moveTo(0, 80);
      ctx.lineTo(400, 80);
      ctx.stroke();

      // Left Side Bearing (x=80)
      ctx.beginPath();
      ctx.moveTo(80, 0);
      ctx.lineTo(80, 400);
      ctx.stroke();

      // Right Side Bearing (x=320)
      ctx.beginPath();
      ctx.moveTo(320, 0);
      ctx.lineTo(320, 400);
      ctx.stroke();

      ctx.setLineDash([]);

      // Draw raised face
      ctx.fillStyle = '#1F2937';
      ctx.beginPath();
      ctx.rect(80, 80, 240, 240);

      cutOps.forEach((op) => {
        ctx.save();
        ctx.translate(op.x, op.y);
        ctx.rotate((op.angle * Math.PI) / 180);
        if (op.shape === 'oval') {
          ctx.ellipse(0, 0, op.width / 2, op.height / 2, 0, 0, Math.PI * 2);
        } else {
          ctx.rect(-op.width / 2, -op.height / 2, op.width, op.height);
        }
        ctx.restore();
      });

      ctx.fill('evenodd');

      // Calculate optical center of mass from cut ops
      let totalArea = 240 * 240;
      let cx = 200;
      let cy = 200;

      cutOps.forEach((op) => {
        const area = op.shape === 'oval' ? Math.PI * (op.width / 2) * (op.height / 2) : op.width * op.height;
        totalArea -= area;
      });

      // Draw Sorts Mill Peg Markers (Primary boundary pegs)
      const pegs = [
        { x: 80, y: 200, label: 'Peg-LSB' },
        { x: 320, y: 200, label: 'Peg-RSB' },
        { x: 200, y: 80, label: 'Peg-Top' },
        { x: 200, y: 320, label: 'Peg-Base' },
        { x: cx, y: cy, label: 'Peg-OpticalCenter' },
      ];

      pegs.forEach((peg) => {
        ctx.fillStyle = '#F59E0B';
        ctx.beginPath();
        ctx.arc(peg.x, peg.y, 4, 0, Math.PI * 2);
        ctx.fill();

        ctx.strokeStyle = '#F59E0B';
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.arc(peg.x, peg.y, 8, 0, Math.PI * 2);
        ctx.stroke();

        ctx.fillStyle = '#FCD34D';
        ctx.font = '10px monospace';
        ctx.fillText(peg.label, peg.x + 10, peg.y + 3);
      });
    }
  }, [material, activeTool, toolShape, toolX, toolY, toolWidth, toolHeight, toolDepth, toolAngle, cutOps, viewMode, inkViscosity, paperPressure]);

  return (
    <div className="flex flex-col h-full bg-[#050508] text-slate-100 font-sans overflow-hidden border border-white/10 rounded-lg shadow-2xl">
      {/* Top Header & Engine Mode Switcher */}
      <div className="bg-[#0D0E12] px-4 py-3 border-b border-white/10 flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center space-x-3">
          <div className="p-2 bg-amber-500/10 border border-amber-500/30 rounded text-amber-400">
            <Hammer className="w-5 h-5" />
          </div>
          <div>
            <h2 className="text-sm font-bold tracking-wider text-white uppercase flex items-center gap-2">
              Physical Clay Sculptor & Punchcutter Workbench
              <span className="text-[10px] font-mono px-2 py-0.5 rounded bg-amber-500/20 text-amber-300 border border-amber-500/30">
                Continuous Contour Engine
              </span>
            </h2>
            <p className="text-[11px] text-white/50 font-mono">
              Manipulate outlines as continuous physical clay/wax with push, pinch, smoothing, and filing tools.
            </p>
          </div>
        </div>

        {/* Engine Mode Toggle */}
        <div className="flex items-center space-x-2 text-xs font-mono">
          <button
            onClick={() => {
              setEngineMode('clay_sculptor');
              setMaterial('terracotta');
            }}
            className={`px-3 py-1.5 rounded border transition-all flex items-center space-x-1.5 ${
              engineMode === 'clay_sculptor' ? 'bg-amber-500 text-black font-bold border-amber-400 shadow' : 'bg-white/5 text-white/60 border-white/10'
            }`}
          >
            <Sparkles className="w-3.5 h-3.5" />
            <span>Clay & Wax Outline Sculptor</span>
          </button>
          <button
            onClick={() => {
              setEngineMode('punchcutter_metal');
              setMaterial('steel');
            }}
            className={`px-3 py-1.5 rounded border transition-all flex items-center space-x-1.5 ${
              engineMode === 'punchcutter_metal' ? 'bg-amber-500 text-black font-bold border-amber-400 shadow' : 'bg-white/5 text-white/60 border-white/10'
            }`}
          >
            <Hammer className="w-3.5 h-3.5" />
            <span>Metal/Wood Punchcutter</span>
          </button>
        </div>
      </div>

      {/* Main Workbench Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-12 flex-1 overflow-hidden">
        {/* Left Physical Tool Control Panel (5 columns) */}
        <div className="lg:col-span-5 bg-[#0A0B0E] p-4 border-r border-white/10 flex flex-col space-y-4 overflow-y-auto">
          {engineMode === 'clay_sculptor' ? (
            /* CLAY OUTLINE SCULPTOR CONTROL PANEL */
            <>
              {/* Material Substrate */}
              <div className="space-y-2 bg-[#12131A] p-3 rounded border border-white/10 font-mono text-xs">
                <span className="font-bold text-amber-400 uppercase tracking-wider block">
                  1. Clay / Wax Physical Substrate
                </span>
                <div className="grid grid-cols-3 gap-2">
                  <button
                    onClick={() => setMaterial('terracotta')}
                    className={`py-1.5 px-2 rounded border text-center font-bold text-[11px] ${
                      material === 'terracotta' ? 'bg-amber-500 text-black border-amber-400' : 'bg-white/5 text-white/70 border-white/10'
                    }`}
                  >
                    Terracotta Clay
                  </button>
                  <button
                    onClick={() => setMaterial('polymer_wax')}
                    className={`py-1.5 px-2 rounded border text-center font-bold text-[11px] ${
                      material === 'polymer_wax' ? 'bg-amber-500 text-black border-amber-400' : 'bg-white/5 text-white/70 border-white/10'
                    }`}
                  >
                    Polymer Wax
                  </button>
                  <button
                    onClick={() => setMaterial('dark_bronze')}
                    className={`py-1.5 px-2 rounded border text-center font-bold text-[11px] ${
                      material === 'dark_bronze' ? 'bg-amber-500 text-black border-amber-400' : 'bg-white/5 text-white/70 border-white/10'
                    }`}
                  >
                    Dark Bronze
                  </button>
                </div>
              </div>

              {/* Clay Sculpting Tools */}
              <div className="space-y-2 bg-[#12131A] p-3 rounded border border-white/10 font-mono">
                <span className="text-xs font-bold text-amber-400 uppercase tracking-wider block">
                  2. Clay Sculpting Tools
                </span>
                <div className="grid grid-cols-2 gap-2 text-xs">
                  <button
                    onClick={() => setClayTool('push_pull_thumb')}
                    className={`p-2 rounded border text-left flex items-center space-x-2 ${
                      clayTool === 'push_pull_thumb' ? 'bg-amber-500/20 border-amber-500/50 text-amber-300' : 'bg-white/5 border-white/10 text-white/70'
                    }`}
                  >
                    <Hammer className="w-4 h-4 text-amber-400" />
                    <div>
                      <div className="font-bold">Thumb Push / Indent</div>
                      <div className="text-[9px] text-white/40">Push & deform contour</div>
                    </div>
                  </button>

                  <button
                    onClick={() => setClayTool('clay_pinch')}
                    className={`p-2 rounded border text-left flex items-center space-x-2 ${
                      clayTool === 'clay_pinch' ? 'bg-amber-500/20 border-amber-500/50 text-amber-300' : 'bg-white/5 border-white/10 text-white/70'
                    }`}
                  >
                    <Scissors className="w-4 h-4 text-amber-400" />
                    <div>
                      <div className="font-bold">Clay Pinch / Nippers</div>
                      <div className="text-[9px] text-white/40">Squeeze stems & serifs</div>
                    </div>
                  </button>

                  <button
                    onClick={() => setClayTool('clay_smooth_sponge')}
                    className={`p-2 rounded border text-left flex items-center space-x-2 ${
                      clayTool === 'clay_smooth_sponge' ? 'bg-amber-500/20 border-amber-500/50 text-amber-300' : 'bg-white/5 border-white/10 text-white/70'
                    }`}
                  >
                    <Sparkles className="w-4 h-4 text-amber-400" />
                    <div>
                      <div className="font-bold">Water Sponge Smooth</div>
                      <div className="text-[9px] text-white/40">Smooth ripples & edges</div>
                    </div>
                  </button>

                  <button
                    onClick={() => setClayTool('clay_flat_rasp')}
                    className={`p-2 rounded border text-left flex items-center space-x-2 ${
                      clayTool === 'clay_flat_rasp' ? 'bg-amber-500/20 border-amber-500/50 text-amber-300' : 'bg-white/5 border-white/10 text-white/70'
                    }`}
                  >
                    <Sliders className="w-4 h-4 text-amber-400" />
                    <div>
                      <div className="font-bold">Flat Rasp / Plane</div>
                      <div className="text-[9px] text-white/40">Flatten straight stems</div>
                    </div>
                  </button>
                </div>

                {/* Brush Parameters Slider */}
                <div className="pt-2 grid grid-cols-2 gap-3 text-xs">
                  <div className="space-y-1">
                    <div className="flex justify-between text-[10px] text-white/60">
                      <span>Brush Radius ({brushRadius}px)</span>
                    </div>
                    <input
                      type="range"
                      min="10"
                      max="100"
                      value={brushRadius}
                      onChange={(e) => setBrushRadius(parseFloat(e.target.value))}
                      className="w-full accent-amber-500 bg-white/10 rounded h-1.5"
                    />
                  </div>

                  <div className="space-y-1">
                    <div className="flex justify-between text-[10px] text-white/60">
                      <span>Strength ({Math.round(brushStrength * 100)}%)</span>
                    </div>
                    <input
                      type="range"
                      min="0.1"
                      max="1.0"
                      step="0.05"
                      value={brushStrength}
                      onChange={(e) => setBrushStrength(parseFloat(e.target.value))}
                      className="w-full accent-amber-500 bg-white/10 rounded h-1.5"
                    />
                  </div>
                </div>

                {/* Overlays Toggle */}
                <div className="pt-2 flex items-center justify-between text-xs text-white/70">
                  <label className="flex items-center space-x-2 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={showCurvatureComb}
                      onChange={(e) => setShowCurvatureComb(e.target.checked)}
                      className="accent-amber-500"
                    />
                    <span>Curvature Comb</span>
                  </label>

                  <label className="flex items-center space-x-2 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={showClayWireframe}
                      onChange={(e) => setShowClayWireframe(e.target.checked)}
                      className="accent-amber-500"
                    />
                    <span>Contour Dots</span>
                  </label>
                </div>
              </div>

              {/* DataHand Ergonomic 1D Directional Push Controls */}
              <div className="space-y-3 bg-[#12131A] p-3 rounded border border-white/10 font-mono">
                <div className="flex items-center justify-between text-xs">
                  <span className="font-bold text-amber-400 uppercase tracking-wider">
                    3. DataHand 1D Push Sculpting
                  </span>
                  <span className="text-[9px] text-amber-300 bg-amber-500/10 px-1.5 py-0.5 rounded border border-amber-500/30">
                    Single-Axis Accessible
                  </span>
                </div>

                {/* Tool Coordinates */}
                <div className="grid grid-cols-2 gap-2 text-xs">
                  <div className="space-y-1">
                    <div className="flex justify-between text-[10px] text-white/60">
                      <span>Center X ({toolX}px)</span>
                    </div>
                    <div className="flex items-center space-x-1">
                      <button
                        onClick={() => handleNudgeToolX(-10)}
                        className="px-1.5 py-1 bg-white/5 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                      >
                        -10
                      </button>
                      <button
                        onClick={() => handleNudgeToolX(-1)}
                        className="px-1.5 py-1 bg-white/5 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                      >
                        -1
                      </button>
                      <input
                        type="number"
                        value={toolX}
                        onChange={(e) => setToolX(parseFloat(e.target.value) || 0)}
                        className="w-full bg-black text-amber-400 font-bold px-1.5 py-1 rounded border border-amber-500/40 text-center focus:outline-none"
                      />
                      <button
                        onClick={() => handleNudgeToolX(1)}
                        className="px-1.5 py-1 bg-white/5 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                      >
                        +1
                      </button>
                      <button
                        onClick={() => handleNudgeToolX(10)}
                        className="px-1.5 py-1 bg-white/5 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                      >
                        +10
                      </button>
                    </div>
                  </div>

                  <div className="space-y-1">
                    <div className="flex justify-between text-[10px] text-white/60">
                      <span>Center Y ({toolY}px)</span>
                    </div>
                    <div className="flex items-center space-x-1">
                      <button
                        onClick={() => handleNudgeToolY(-10)}
                        className="px-1.5 py-1 bg-white/5 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                      >
                        -10
                      </button>
                      <button
                        onClick={() => handleNudgeToolY(-1)}
                        className="px-1.5 py-1 bg-white/5 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                      >
                        -1
                      </button>
                      <input
                        type="number"
                        value={toolY}
                        onChange={(e) => setToolY(parseFloat(e.target.value) || 0)}
                        className="w-full bg-black text-amber-400 font-bold px-1.5 py-1 rounded border border-amber-500/40 text-center focus:outline-none"
                      />
                      <button
                        onClick={() => handleNudgeToolY(1)}
                        className="px-1.5 py-1 bg-white/5 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                      >
                        +1
                      </button>
                      <button
                        onClick={() => handleNudgeToolY(10)}
                        className="px-1.5 py-1 bg-white/5 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                      >
                        +10
                      </button>
                    </div>
                  </div>
                </div>

                {/* Directional Push Actions */}
                <div className="grid grid-cols-3 gap-1.5 text-xs pt-1">
                  <button
                    onClick={() => handleDataHandClayPush('up', 8)}
                    className="col-span-3 py-1.5 bg-amber-500/10 hover:bg-amber-500/20 border border-amber-500/30 rounded text-amber-300 font-bold uppercase"
                  >
                    ↑ Push Clay Up
                  </button>
                  <button
                    onClick={() => handleDataHandClayPush('left', 8)}
                    className="py-1.5 bg-amber-500/10 hover:bg-amber-500/20 border border-amber-500/30 rounded text-amber-300 font-bold uppercase"
                  >
                    ← Push Left
                  </button>
                  <button
                    onClick={() => handleDataHandClayPush('smooth', 0)}
                    className="py-1.5 bg-blue-500/20 hover:bg-blue-500/30 border border-blue-500/40 rounded text-blue-300 font-bold uppercase text-[10px]"
                  >
                    Water Smooth
                  </button>
                  <button
                    onClick={() => handleDataHandClayPush('right', 8)}
                    className="py-1.5 bg-amber-500/10 hover:bg-amber-500/20 border border-amber-500/30 rounded text-amber-300 font-bold uppercase"
                  >
                    Push Right →
                  </button>
                  <button
                    onClick={() => handleDataHandClayPush('down', 8)}
                    className="col-span-3 py-1.5 bg-amber-500/10 hover:bg-amber-500/20 border border-amber-500/30 rounded text-amber-300 font-bold uppercase"
                  >
                    ↓ Push Clay Down
                  </button>
                  <button
                    onClick={() => handleDataHandClayPush('inward', 6)}
                    className="py-1.5 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-amber-300 font-bold uppercase text-[10px]"
                  >
                    Pinch Inward
                  </button>
                  <button
                    onClick={() => handleDataHandClayPush('outward', 6)}
                    className="col-span-2 py-1.5 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-amber-300 font-bold uppercase text-[10px]"
                  >
                    Expand Outward
                  </button>
                </div>
              </div>

              {/* Clay Glyph Presets */}
              <div className="space-y-2 bg-[#12131A] p-3 rounded border border-white/10 font-mono">
                <span className="text-xs font-bold text-amber-400 uppercase tracking-wider block">
                  4. Preset Clay Glyphs
                </span>
                <div className="grid grid-cols-5 gap-1 text-[11px]">
                  <button
                    onClick={() => handleLoadClayPreset('letter_O')}
                    className="py-1 px-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-amber-300 font-bold text-center"
                  >
                    'O'
                  </button>
                  <button
                    onClick={() => handleLoadClayPreset('letter_A')}
                    className="py-1 px-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-amber-300 font-bold text-center"
                  >
                    'A'
                  </button>
                  <button
                    onClick={() => handleLoadClayPreset('letter_S')}
                    className="py-1 px-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-amber-300 font-bold text-center"
                  >
                    'S'
                  </button>
                  <button
                    onClick={() => handleLoadClayPreset('letter_g')}
                    className="py-1 px-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-amber-300 font-bold text-center"
                  >
                    'g'
                  </button>
                  <button
                    onClick={() => handleLoadClayPreset('disk')}
                    className="py-1 px-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-white/60 font-bold text-center"
                  >
                    Disk
                  </button>
                </div>

                <div className="pt-2 flex items-center justify-between text-xs">
                  <span className="text-white/50 text-[10px]">Contour Vertices: {outerContour.length + innerContour.length}</span>
                  <button
                    onClick={handleUndoClay}
                    disabled={contourHistory.length === 0}
                    className="px-2 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-[10px] text-amber-300 disabled:opacity-30"
                  >
                    Undo Clay Action ({contourHistory.length})
                  </button>
                </div>
              </div>
            </>
          ) : (
            /* STEEL/WOOD PUNCHCUTTER CONTROL PANEL */
            <>
              {/* Tool Selection */}
              <div className="space-y-2 bg-[#12131A] p-3 rounded border border-white/10 font-mono">
                <span className="text-xs font-bold text-amber-400 uppercase tracking-wider block">
                  1. Select Physical Tool & Action
                </span>
                <div className="grid grid-cols-2 gap-2 text-xs">
                  <button
                    onClick={() => {
                      setActiveTool('counter_punch');
                      setToolShape('oval');
                    }}
                    className={`p-2 rounded border text-left flex items-center space-x-2 ${
                      activeTool === 'counter_punch' ? 'bg-amber-500/20 border-amber-500/50 text-amber-300' : 'bg-white/5 border-white/10 text-white/70'
                    }`}
                  >
                    <Hammer className="w-4 h-4 text-amber-400" />
                    <div>
                      <div className="font-bold">Counter-Punch</div>
                      <div className="text-[9px] text-white/40">Press interior counter-spaces</div>
                    </div>
                  </button>

                  <button
                    onClick={() => {
                      setActiveTool('flat_file');
                      setToolShape('rect');
                    }}
                    className={`p-2 rounded border text-left flex items-center space-x-2 ${
                      activeTool === 'flat_file' ? 'bg-amber-500/20 border-amber-500/50 text-amber-300' : 'bg-white/5 border-white/10 text-white/70'
                    }`}
                  >
                    <Scissors className="w-4 h-4 text-amber-400" />
                    <div>
                      <div className="font-bold">Flat File (Bastard)</div>
                      <div className="text-[9px] text-white/40">File outer stems & shoulders</div>
                    </div>
                  </button>

                  <button
                    onClick={() => {
                      setActiveTool('needle_file');
                      setToolShape('triangle');
                    }}
                    className={`p-2 rounded border text-left flex items-center space-x-2 ${
                      activeTool === 'needle_file' ? 'bg-amber-500/20 border-amber-500/50 text-amber-300' : 'bg-white/5 border-white/10 text-white/70'
                    }`}
                  >
                    <Sliders className="w-4 h-4 text-amber-400" />
                    <div>
                      <div className="font-bold">Needle File</div>
                      <div className="text-[9px] text-white/40">Serifs, crotches & ink traps</div>
                    </div>
                  </button>

                  <button
                    onClick={() => {
                      setActiveTool('graver');
                      setToolShape('v_groove');
                    }}
                    className={`p-2 rounded border text-left flex items-center space-x-2 ${
                      activeTool === 'graver' ? 'bg-amber-500/20 border-amber-500/50 text-amber-300' : 'bg-white/5 border-white/10 text-white/70'
                    }`}
                  >
                    <Sparkles className="w-4 h-4 text-amber-400" />
                    <div>
                      <div className="font-bold">Steel Graver / Chisel</div>
                      <div className="text-[9px] text-white/40">Carve V-channels & relief</div>
                    </div>
                  </button>
                </div>

                {/* Shape selection */}
                <div className="pt-2 flex items-center space-x-2 text-xs">
                  <span className="text-white/50 text-[10px] uppercase">Punch Profile:</span>
                  {(['oval', 'rect', 'triangle'] as const).map((sh) => (
                    <button
                      key={sh}
                      onClick={() => setToolShape(sh)}
                      className={`px-2 py-0.5 rounded text-[10px] uppercase border ${
                        toolShape === sh ? 'bg-amber-500 text-black font-bold border-amber-400' : 'bg-white/5 text-white/60 border-white/10'
                      }`}
                    >
                      {sh}
                    </button>
                  ))}
                </div>
              </div>

              {/* DataHand Ergonomic Tool Coordinates Inspector */}
              <div className="space-y-3 bg-[#12131A] p-3 rounded border border-white/10 font-mono">
                <div className="flex items-center justify-between text-xs">
                  <span className="font-bold text-amber-400 uppercase tracking-wider">
                    2. Physical Tool Coordinates & Sliders
                  </span>
                  <span className="text-[9px] text-amber-300 bg-amber-500/10 px-1.5 py-0.5 rounded border border-amber-500/30">
                    DataHand 1D Accessible
                  </span>
                </div>

                {/* Tool Position X / Y */}
                <div className="grid grid-cols-2 gap-2 text-xs">
                  {/* X Axis */}
                  <div className="space-y-1">
                    <div className="flex justify-between text-[10px] text-white/60">
                      <span>Tool Center X ({toolX} mm)</span>
                    </div>
                    <div className="flex items-center space-x-1">
                      <button
                        onClick={() => handleNudgeToolX(-10)}
                        className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                      >
                        -10
                      </button>
                      <button
                        onClick={() => handleNudgeToolX(-1)}
                        className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                      >
                        -1
                      </button>
                      <input
                        type="number"
                        value={toolX}
                        onChange={(e) => setToolX(parseFloat(e.target.value) || 0)}
                        className="w-full bg-black text-amber-400 font-bold px-1.5 py-1 rounded border border-amber-500/40 text-center focus:outline-none"
                      />
                      <button
                        onClick={() => handleNudgeToolX(1)}
                        className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                      >
                        +1
                      </button>
                      <button
                        onClick={() => handleNudgeToolX(10)}
                        className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                      >
                        +10
                      </button>
                    </div>
                  </div>

                  {/* Y Axis */}
                  <div className="space-y-1">
                    <div className="flex justify-between text-[10px] text-white/60">
                      <span>Tool Center Y ({toolY} mm)</span>
                    </div>
                    <div className="flex items-center space-x-1">
                      <button
                        onClick={() => handleNudgeToolY(-10)}
                        className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                      >
                        -10
                      </button>
                      <button
                        onClick={() => handleNudgeToolY(-1)}
                        className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                      >
                        -1
                      </button>
                      <input
                        type="number"
                        value={toolY}
                        onChange={(e) => setToolY(parseFloat(e.target.value) || 0)}
                        className="w-full bg-black text-amber-400 font-bold px-1.5 py-1 rounded border border-amber-500/40 text-center focus:outline-none"
                      />
                      <button
                        onClick={() => handleNudgeToolY(1)}
                        className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                      >
                        +1
                      </button>
                      <button
                        onClick={() => handleNudgeToolY(10)}
                        className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                      >
                        +10
                      </button>
                    </div>
                  </div>
                </div>

                {/* Tool Size Width / Height */}
                <div className="grid grid-cols-2 gap-2 text-xs pt-1">
                  <div className="space-y-1">
                    <div className="flex justify-between text-[10px] text-white/60">
                      <span>Width ({toolWidth} mm)</span>
                    </div>
                    <input
                      type="range"
                      min="5"
                      max="200"
                      value={toolWidth}
                      onChange={(e) => setToolWidth(parseFloat(e.target.value))}
                      className="w-full accent-amber-500 bg-white/10 rounded h-1.5"
                    />
                  </div>

                  <div className="space-y-1">
                    <div className="flex justify-between text-[10px] text-white/60">
                      <span>Height ({toolHeight} mm)</span>
                    </div>
                    <input
                      type="range"
                      min="5"
                      max="200"
                      value={toolHeight}
                      onChange={(e) => setToolHeight(parseFloat(e.target.value))}
                      className="w-full accent-amber-500 bg-white/10 rounded h-1.5"
                    />
                  </div>
                </div>

                {/* Cut Action Button */}
                <button
                  onClick={handleApplyCut}
                  className="w-full py-2.5 bg-amber-500 hover:bg-amber-400 text-black font-bold uppercase tracking-wider rounded flex items-center justify-center space-x-2 shadow-lg transition-all"
                >
                  <Hammer className="w-4 h-4" />
                  <span>Drive Punch / Cut Stroke into Block</span>
                </button>
              </div>

              {/* Preset Punch Blanks & Action History */}
              <div className="space-y-2 bg-[#12131A] p-3 rounded border border-white/10 font-mono">
                <span className="text-xs font-bold text-amber-400 uppercase tracking-wider block">
                  3. Preset Glyph Blanks & Cut History
                </span>
                <div className="grid grid-cols-4 gap-1 text-[11px]">
                  <button
                    onClick={() => handleLoadPreset('letter_O')}
                    className="py-1 px-2 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-amber-300 font-bold"
                  >
                    Capital 'O'
                  </button>
                  <button
                    onClick={() => handleLoadPreset('letter_H')}
                    className="py-1 px-2 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-amber-300 font-bold"
                  >
                    Capital 'H'
                  </button>
                  <button
                    onClick={() => handleLoadPreset('letter_R')}
                    className="py-1 px-2 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-amber-300 font-bold"
                  >
                    Capital 'R'
                  </button>
                  <button
                    onClick={() => handleLoadPreset('blank')}
                    className="py-1 px-2 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-white/60 font-bold"
                  >
                    Raw Blank
                  </button>
                </div>

                <div className="pt-2 flex items-center justify-between text-xs">
                  <span className="text-white/50">Cuts Applied: {cutOps.length}</span>
                  <div className="flex items-center space-x-2">
                    <button
                      onClick={handleUndoCut}
                      disabled={cutOps.length === 0}
                      className="px-2 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-[10px] text-amber-300 disabled:opacity-30"
                    >
                      Undo Cut
                    </button>
                    <button
                      onClick={handleResetPunch}
                      className="px-2 py-1 bg-red-500/20 hover:bg-red-500/30 border border-red-500/40 rounded text-[10px] text-red-300"
                    >
                      Reset Punch
                    </button>
                  </div>
                </div>
              </div>
            </>
          )}
        </div>

        {/* Right Columns: Interactive Canvas & Proofing Press (7 columns) */}
        <div className="lg:col-span-7 bg-[#08090C] p-4 flex flex-col space-y-4 overflow-y-auto">
          {/* Mode Selector */}
          <div className="flex items-center justify-between flex-wrap gap-2 bg-[#12131A] p-2.5 rounded border border-white/10 font-mono text-xs">
            <span className="text-amber-400 font-bold uppercase tracking-wider">Proofing Mode:</span>
            <div className="flex items-center space-x-2">
              <button
                onClick={() => setViewMode('3d_relief')}
                className={`px-3 py-1 rounded border flex items-center space-x-1.5 ${
                  viewMode === '3d_relief' ? 'bg-amber-500 text-black font-bold border-amber-400' : 'bg-white/5 text-white/60 border-white/10'
                }`}
              >
                <Eye className="w-3.5 h-3.5" />
                <span>3D Physical Relief</span>
              </button>

              <button
                onClick={() => setViewMode('smoke_proof')}
                className={`px-3 py-1 rounded border flex items-center space-x-1.5 ${
                  viewMode === 'smoke_proof' ? 'bg-amber-500 text-black font-bold border-amber-400' : 'bg-white/5 text-white/60 border-white/10'
                }`}
              >
                <Flame className="w-3.5 h-3.5" />
                <span>Lampblack Smoke Proof</span>
              </button>

              <button
                onClick={() => setViewMode('ink_press')}
                className={`px-3 py-1 rounded border flex items-center space-x-1.5 ${
                  viewMode === 'ink_press' ? 'bg-amber-500 text-black font-bold border-amber-400' : 'bg-white/5 text-white/60 border-white/10'
                }`}
              >
                <FileText className="w-3.5 h-3.5" />
                <span>Oil Ink Press</span>
              </button>

              <button
                onClick={() => setViewMode('peg_metrics')}
                className={`px-3 py-1 rounded border flex items-center space-x-1.5 ${
                  viewMode === 'peg_metrics' ? 'bg-amber-500 text-black font-bold border-amber-400' : 'bg-white/5 text-white/60 border-white/10'
                }`}
              >
                <Sliders className="w-3.5 h-3.5" />
                <span>Sorts Mill Pegs</span>
              </button>
            </div>
          </div>

          {/* Interactive Physical Punch / Clay Canvas */}
          <div className="relative flex-1 bg-black rounded border border-white/15 p-4 flex items-center justify-center min-h-[420px] shadow-inner select-none">
            <canvas
              ref={canvasRef}
              onMouseDown={(e) => {
                const rect = e.currentTarget.getBoundingClientRect();
                const x = e.clientX - rect.left;
                const y = e.clientY - rect.top;
                setToolX(x);
                setToolY(y);
                if (engineMode === 'clay_sculptor') {
                  pushHistory();
                  setIsSculptingCanvas(true);
                  setLastSculptPos({ x, y });
                }
              }}
              onMouseMove={(e) => {
                const rect = e.currentTarget.getBoundingClientRect();
                const x = e.clientX - rect.left;
                const y = e.clientY - rect.top;
                setToolX(x);
                setToolY(y);
                if (engineMode === 'clay_sculptor' && isSculptingCanvas && lastSculptPos) {
                  const dx = x - lastSculptPos.x;
                  const dy = y - lastSculptPos.y;
                  if (Math.hypot(dx, dy) > 1.5) {
                    applyClaySculptDeform(x, y, dx, dy);
                    setLastSculptPos({ x, y });
                  }
                }
              }}
              onMouseUp={() => {
                setIsSculptingCanvas(false);
                setLastSculptPos(null);
              }}
              onMouseLeave={() => {
                setIsSculptingCanvas(false);
                setLastSculptPos(null);
              }}
              onTouchStart={(e) => {
                const touch = e.touches[0];
                const rect = e.currentTarget.getBoundingClientRect();
                const x = touch.clientX - rect.left;
                const y = touch.clientY - rect.top;
                setToolX(x);
                setToolY(y);
                if (engineMode === 'clay_sculptor') {
                  pushHistory();
                  setIsSculptingCanvas(true);
                  setLastSculptPos({ x, y });
                }
              }}
              onTouchMove={(e) => {
                const touch = e.touches[0];
                const rect = e.currentTarget.getBoundingClientRect();
                const x = touch.clientX - rect.left;
                const y = touch.clientY - rect.top;
                setToolX(x);
                setToolY(y);
                if (engineMode === 'clay_sculptor' && isSculptingCanvas && lastSculptPos) {
                  const dx = x - lastSculptPos.x;
                  const dy = y - lastSculptPos.y;
                  if (Math.hypot(dx, dy) > 1.5) {
                    applyClaySculptDeform(x, y, dx, dy);
                    setLastSculptPos({ x, y });
                  }
                }
              }}
              onTouchEnd={() => {
                setIsSculptingCanvas(false);
                setLastSculptPos(null);
              }}
              className="border border-white/10 rounded shadow-2xl max-w-full max-h-full aspect-square cursor-crosshair"
            />
          </div>

          {/* Proofing Press Parameters (when in Ink Press mode) */}
          {viewMode === 'ink_press' && (
            <div className="bg-[#12131A] p-3 rounded border border-white/10 font-mono text-xs grid grid-cols-2 gap-4">
              <div className="space-y-1">
                <span className="text-white/60 text-[10px] uppercase">Oil Ink Viscosity (Capillary Bleed)</span>
                <input
                  type="range"
                  min="0"
                  max="1"
                  step="0.05"
                  value={inkViscosity}
                  onChange={(e) => setInkViscosity(parseFloat(e.target.value))}
                  className="w-full accent-amber-500 bg-white/10 rounded h-1.5"
                />
              </div>

              <div className="space-y-1">
                <span className="text-white/60 text-[10px] uppercase">Proof Press Impression Force</span>
                <input
                  type="range"
                  min="0.1"
                  max="1"
                  step="0.05"
                  value={paperPressure}
                  onChange={(e) => setPaperPressure(parseFloat(e.target.value))}
                  className="w-full accent-amber-500 bg-white/10 rounded h-1.5"
                />
              </div>
            </div>
          )}

          {/* Theoretical Note footer */}
          <div className="bg-[#0B0C10] p-3 rounded border border-white/10 text-[11px] font-mono text-white/50 flex items-start space-x-2">
            <Info className="w-4 h-4 text-amber-500 flex-shrink-0 mt-0.5" />
            <div>
              <span className="text-amber-400 font-bold uppercase">Clay & Outline Sculpting Mechanics:</span>
              <p className="pt-0.5 leading-relaxed">
                Direct physical outline deformation replacing spline knot/handle manipulation. Indent, pinch, file, and smooth continuous letterform contours as if working with physical clay/wax. Fully accessible via DataHand single-axis push controls and Sorts Mill boundary pegs (`PEGS`).
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
