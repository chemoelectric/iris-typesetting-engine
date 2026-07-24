import React, { useState, useRef, useEffect } from 'react';
import {
  Scissors,
  Hammer,
  RotateCcw,
  Sparkles,
  Sliders,
  ZoomIn,
  ZoomOut,
  Info,
  Type,
  Square,
  Triangle,
  Circle,
  PenTool,
  Grid,
  Check,
  RefreshCw,
  Download,
  Trash2,
  Move,
  Target,
  Layers,
  Eye,
  Maximize2
} from 'lucide-react';

export type ChippingToolType =
  | 'flat_file_plane'  // Straight filing plane at angle theta
  | 'v_chisel_wedge'   // Triangular V-notch chisel
  | 'rect_file'        // Rectangular precision file
  | 'circular_burr'    // Round burr cutter
  | 'serif_bracket'    // Curved serif fillet cutter
  | 'custom_polygon';  // User defined polygon outline

export interface Point2D {
  x: number;
  y: number;
}

export interface ChippingStep {
  id: string;
  timestamp: string;
  toolType: ChippingToolType;
  mode: 'subtract' | 'add' | 'intersect';
  x: number;
  y: number;
  width: number;
  height: number;
  angle: number;
  customVertices?: Point2D[];
}

export type BaseGlyphPreset = 'letter_E' | 'letter_R' | 'letter_O' | 'letter_S' | 'letter_A' | 'letter_g' | 'solid_block';

export const PunchcutterWorkbench: React.FC = () => {
  // Preset & Glyph Selection (Forward Right-Reading)
  const [selectedPreset, setSelectedPreset] = useState<BaseGlyphPreset>('letter_E');

  // Tool Outline State
  const [toolType, setToolType] = useState<ChippingToolType>('flat_file_plane');
  const [chipMode, setChipMode] = useState<'subtract' | 'add' | 'intersect'>('subtract');

  // Tool Sub-Point Position & Dimensions
  const [toolX, setToolX] = useState<number>(400); // Center relative to 800x800 canvas
  const [toolY, setToolY] = useState<number>(400);
  const [toolWidth, setToolWidth] = useState<number>(40); // pt
  const [toolHeight, setToolHeight] = useState<number>(120); // pt
  const [toolAngle, setToolAngle] = useState<number>(0); // degrees
  const [stepPrecision, setStepPrecision] = useState<number>(0.5); // 0.1, 0.5, 1.0, 5.0 pt

  // Custom Tool Polygon Vertices (relative offset from center)
  const [customVertices, setCustomVertices] = useState<Point2D[]>([
    { x: -20, y: -40 },
    { x: 20, y: -40 },
    { x: 40, y: 0 },
    { x: 20, y: 40 },
    { x: -20, y: 40 },
    { x: -40, y: 0 },
  ]);

  // History of Chipping Actions (Bit-by-Bit CSG Subtractions)
  const [chippingSteps, setChippingSteps] = useState<ChippingStep[]>([]);
  const [stepHistoryIndex, setStepHistoryIndex] = useState<number>(-1); // For undo/redo

  // View & Zoom State
  const [zoomLevel, setZoomLevel] = useState<number>(2.0); // 1.0x to 15.0x
  const [panX, setPanX] = useState<number>(0);
  const [panY, setPanY] = useState<number>(0);
  const [showSubpixelGrid, setShowSubpixelGrid] = useState<boolean>(true);
  const [showTypographyGuides, setShowTypographyGuides] = useState<boolean>(true);
  const [showPegMetrics, setShowPegMetrics] = useState<boolean>(true);

  // Canvas Refs
  const displayCanvasRef = useRef<HTMLCanvasElement | null>(null);
  const offscreenCanvasRef = useRef<HTMLCanvasElement | null>(null);

  // Initialize Offscreen Canvas for High-DPI CSG
  useEffect(() => {
    if (!offscreenCanvasRef.current) {
      const off = document.createElement('canvas');
      off.width = 800;
      off.height = 800;
      offscreenCanvasRef.current = off;
    }
  }, []);

  // Draw Base Preset Glyph onto Context
  const renderBaseGlyph = (ctx: CanvasRenderingContext2D) => {
    ctx.clearRect(0, 0, 800, 800);
    ctx.fillStyle = '#000000';

    const cx = 400;
    const cy = 400;

    if (selectedPreset === 'solid_block') {
      ctx.fillRect(cx - 150, cy - 200, 300, 400);
    } else if (selectedPreset === 'letter_E') {
      ctx.beginPath();
      // Right-reading Capital 'E'
      // Stem
      ctx.rect(cx - 120, cy - 180, 50, 360);
      // Top Arm
      ctx.rect(cx - 120, cy - 180, 220, 45);
      // Middle Arm
      ctx.rect(cx - 120, cy - 20, 180, 40);
      // Bottom Arm
      ctx.rect(cx - 120, cy + 135, 230, 45);
      ctx.fill();
    } else if (selectedPreset === 'letter_R') {
      ctx.beginPath();
      // Right-reading Capital 'R'
      // Stem
      ctx.rect(cx - 120, cy - 180, 50, 360);
      // Top Arm & Bowl
      ctx.arc(cx - 20, cy - 90, 90, -Math.PI / 2, Math.PI / 2, false);
      ctx.rect(cx - 120, cy - 180, 100, 45);
      ctx.rect(cx - 120, cy - 45, 100, 45);
      // Diagonal Leg
      ctx.moveTo(cx - 20, cy - 10);
      ctx.lineTo(cx + 110, cy + 180);
      ctx.lineTo(cx + 55, cy + 180);
      ctx.lineTo(cx - 70, cy - 10);
      ctx.fill();

      // Punch out bowl counter space
      ctx.globalCompositeOperation = 'destination-out';
      ctx.beginPath();
      ctx.arc(cx - 20, cy - 90, 45, -Math.PI / 2, Math.PI / 2, false);
      ctx.rect(cx - 120, cy - 135, 100, 45);
      ctx.fill();
      ctx.globalCompositeOperation = 'source-over';
    } else if (selectedPreset === 'letter_O') {
      // Outer Ellipse
      ctx.beginPath();
      ctx.ellipse(cx, cy, 140, 180, 0, 0, Math.PI * 2);
      ctx.fill();

      // Inner Counter Space Subtraction
      ctx.globalCompositeOperation = 'destination-out';
      ctx.beginPath();
      ctx.ellipse(cx, cy, 75, 120, 0, 0, Math.PI * 2);
      ctx.fill();
      ctx.globalCompositeOperation = 'source-over';
    } else if (selectedPreset === 'letter_S') {
      ctx.save();
      ctx.lineWidth = 52;
      ctx.strokeStyle = '#000000';
      ctx.lineCap = 'square';
      ctx.beginPath();
      // S-curve spine
      ctx.moveTo(cx + 80, cy - 130);
      ctx.bezierCurveTo(cx - 120, cy - 200, cx - 140, cy - 20, cx, cy);
      ctx.bezierCurveTo(cx + 140, cy + 20, cx + 120, cy + 200, cx - 80, cy + 130);
      ctx.stroke();
      ctx.restore();
    } else if (selectedPreset === 'letter_A') {
      ctx.beginPath();
      // Apex & Legs
      ctx.moveTo(cx, cy - 180);
      ctx.lineTo(cx + 130, cy + 180);
      ctx.lineTo(cx + 70, cy + 180);
      ctx.lineTo(cx + 35, cy + 90);
      ctx.lineTo(cx - 35, cy + 90);
      ctx.lineTo(cx - 70, cy + 180);
      ctx.lineTo(cx - 130, cy + 180);
      ctx.closePath();
      ctx.fill();

      // Triangle Counter
      ctx.globalCompositeOperation = 'destination-out';
      ctx.beginPath();
      ctx.moveTo(cx, cy - 100);
      ctx.lineTo(cx + 25, cy + 40);
      ctx.lineTo(cx - 25, cy + 40);
      ctx.closePath();
      ctx.fill();
      ctx.globalCompositeOperation = 'source-over';
    } else if (selectedPreset === 'letter_g') {
      // Lowercase g double loop
      ctx.beginPath();
      ctx.ellipse(cx, cy - 80, 90, 80, 0, 0, Math.PI * 2);
      ctx.ellipse(cx + 10, cy + 90, 100, 85, 0, 0, Math.PI * 2);
      ctx.fill();

      // Counter holes
      ctx.globalCompositeOperation = 'destination-out';
      ctx.beginPath();
      ctx.ellipse(cx, cy - 80, 45, 40, 0, 0, Math.PI * 2);
      ctx.ellipse(cx + 10, cy + 90, 55, 45, 0, 0, Math.PI * 2);
      ctx.fill();
      ctx.globalCompositeOperation = 'source-over';
    }
  };

  // Helper: Draw Tool Path onto a Canvas Context at (tx, ty) with rotation angle
  const drawToolShapePath = (
    ctx: CanvasRenderingContext2D,
    tType: ChippingToolType,
    tx: number,
    ty: number,
    w: number,
    h: number,
    angDeg: number
  ) => {
    ctx.save();
    ctx.translate(tx, ty);
    ctx.rotate((angDeg * Math.PI) / 180);

    ctx.beginPath();
    if (tType === 'flat_file_plane') {
      // Half-plane file mask: line at y=0, cuts away everything above y=0
      ctx.rect(-w * 4, -h * 4, w * 8, h * 4);
    } else if (tType === 'v_chisel_wedge') {
      // Triangular V-notch chisel
      ctx.moveTo(0, 0);
      ctx.lineTo(-w / 2, -h);
      ctx.lineTo(w / 2, -h);
      ctx.closePath();
    } else if (tType === 'rect_file') {
      // Centered rectangular file
      ctx.rect(-w / 2, -h / 2, w, h);
    } else if (tType === 'circular_burr') {
      // Circular burr cutter
      ctx.arc(0, 0, w / 2, 0, Math.PI * 2);
    } else if (tType === 'serif_bracket') {
      // Curved serif fillet cutter
      ctx.moveTo(-w / 2, -h / 2);
      ctx.lineTo(w / 2, -h / 2);
      ctx.quadraticCurveTo(0, 0, w / 2, h / 2);
      ctx.lineTo(-w / 2, h / 2);
      ctx.closePath();
    } else if (tType === 'custom_polygon') {
      // Custom user polygon
      if (customVertices.length > 0) {
        ctx.moveTo(customVertices[0].x, customVertices[0].y);
        for (let i = 1; i < customVertices.length; i += 1) {
          ctx.lineTo(customVertices[i].x, customVertices[i].y);
        }
        ctx.closePath();
      }
    }

    ctx.restore();
  };

  // Execute Chipping Operations onto Offscreen CSG Canvas
  const processCSGBuffer = () => {
    const offCanvas = offscreenCanvasRef.current;
    if (!offCanvas) return;
    const offCtx = offCanvas.getContext('2d');
    if (!offCtx) return;

    // 1. Render Base Glyph
    renderBaseGlyph(offCtx);

    // 2. Replay Active History Chipping Steps
    const activeSteps = chippingSteps.slice(0, stepHistoryIndex + 1);
    for (const step of activeSteps) {
      if (step.mode === 'subtract') {
        offCtx.globalCompositeOperation = 'destination-out';
        offCtx.fillStyle = '#000000';
        drawToolShapePath(
          offCtx,
          step.toolType,
          step.x,
          step.y,
          step.width,
          step.height,
          step.angle
        );
        offCtx.fill();
        offCtx.globalCompositeOperation = 'source-over';
      } else if (step.mode === 'add') {
        offCtx.globalCompositeOperation = 'source-over';
        offCtx.fillStyle = '#000000';
        drawToolShapePath(
          offCtx,
          step.toolType,
          step.x,
          step.y,
          step.width,
          step.height,
          step.angle
        );
        offCtx.fill();
      } else if (step.mode === 'intersect') {
        offCtx.globalCompositeOperation = 'destination-in';
        offCtx.fillStyle = '#000000';
        drawToolShapePath(
          offCtx,
          step.toolType,
          step.x,
          step.y,
          step.width,
          step.height,
          step.angle
        );
        offCtx.fill();
        offCtx.globalCompositeOperation = 'source-over';
      }
    }
  };

  // Main Render Loop (Renders Offscreen CSG + Viewport Grid + Active Tool Overlay)
  useEffect(() => {
    processCSGBuffer();

    const canvas = displayCanvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const width = canvas.width;
    const height = canvas.height;

    // Clear main display
    ctx.clearRect(0, 0, width, height);

    // Studio Dark Background
    const bgGrad = ctx.createRadialGradient(width / 2, height / 2, 50, width / 2, height / 2, width);
    bgGrad.addColorStop(0, '#0F1016');
    bgGrad.addColorStop(1, '#07080B');
    ctx.fillStyle = bgGrad;
    ctx.fillRect(0, 0, width, height);

    ctx.save();
    // Apply Viewport Pan & Zoom Transform around Canvas Center (400, 400)
    ctx.translate(width / 2 + panX, height / 2 + panY);
    ctx.scale(zoomLevel, zoomLevel);
    ctx.translate(-400, -400);

    // 1. Sub-pixel Metric Grid
    if (showSubpixelGrid) {
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.05)';
      ctx.lineWidth = 0.5 / zoomLevel;

      const gridSize = 20; // 20pt sub-pixel grid
      for (let x = 0; x <= 800; x += gridSize) {
        ctx.beginPath();
        ctx.moveTo(x, 0);
        ctx.lineTo(x, 800);
        ctx.stroke();
      }
      for (let y = 0; y <= 800; y += gridSize) {
        ctx.beginPath();
        ctx.moveTo(0, y);
        ctx.lineTo(800, y);
        ctx.stroke();
      }
    }

    // 2. Typography Guidelines (Baseline y=580, Cap Height y=220, X-Height y=360, LSB x=250, RSB x=550)
    if (showTypographyGuides) {
      ctx.lineWidth = 1.0 / zoomLevel;

      // Baseline
      ctx.strokeStyle = '#F59E0B'; // Amber
      ctx.setLineDash([4, 4]);
      ctx.beginPath();
      ctx.moveTo(0, 580); ctx.lineTo(800, 580);
      ctx.stroke();

      // Cap Height
      ctx.strokeStyle = '#38BDF8'; // Sky Blue
      ctx.beginPath();
      ctx.moveTo(0, 220); ctx.lineTo(800, 220);
      ctx.stroke();

      // Mean Line / X-Height
      ctx.strokeStyle = '#10B981'; // Emerald
      ctx.beginPath();
      ctx.moveTo(0, 360); ctx.lineTo(800, 360);
      ctx.stroke();

      // Sidebearings LSB / RSB
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.2)';
      ctx.beginPath();
      ctx.moveTo(250, 0); ctx.lineTo(250, 800);
      ctx.moveTo(550, 0); ctx.lineTo(550, 800);
      ctx.stroke();

      ctx.setLineDash([]);
    }

    // 3. Render CSG Chipped Glyph Output from Offscreen Canvas
    if (offscreenCanvasRef.current) {
      ctx.shadowColor = 'rgba(0, 0, 0, 0.8)';
      ctx.shadowBlur = 12 / zoomLevel;
      ctx.shadowOffsetX = 2 / zoomLevel;
      ctx.shadowOffsetY = 4 / zoomLevel;

      ctx.drawImage(offscreenCanvasRef.current, 0, 0);

      ctx.shadowColor = 'transparent';
    }

    // 4. Sorts Mill Visual Boundary Pegs
    if (showPegMetrics) {
      ctx.fillStyle = '#F59E0B';
      const pegs = [
        { x: 280, y: 220, label: 'Peg #1 Cap' },
        { x: 280, y: 580, label: 'Peg #2 Base' },
        { x: 520, y: 220, label: 'Peg #3 Cap-R' },
        { x: 520, y: 580, label: 'Peg #4 Base-R' },
      ];
      for (const p of pegs) {
        ctx.beginPath();
        ctx.arc(p.x, p.y, 3 / zoomLevel, 0, Math.PI * 2);
        ctx.fill();

        ctx.font = `${9 / zoomLevel}px monospace`;
        ctx.fillStyle = 'rgba(245, 158, 11, 0.7)';
        ctx.fillText(p.label, p.x + 6 / zoomLevel, p.y - 4 / zoomLevel);
      }
    }

    // 5. Active Overlay: Tool Outline & Cutting Reticle
    ctx.save();
    ctx.lineWidth = 1.5 / zoomLevel;

    // Tool Outline Path
    drawToolShapePath(ctx, toolType, toolX, toolY, toolWidth, toolHeight, toolAngle);

    // Color code based on chip mode
    if (chipMode === 'subtract') {
      ctx.strokeStyle = '#F59E0B'; // Amber
      ctx.fillStyle = 'rgba(245, 158, 11, 0.15)';
    } else if (chipMode === 'add') {
      ctx.strokeStyle = '#10B981'; // Emerald
      ctx.fillStyle = 'rgba(16, 185, 129, 0.15)';
    } else {
      ctx.strokeStyle = '#38BDF8'; // Blue
      ctx.fillStyle = 'rgba(56, 189, 248, 0.15)';
    }

    ctx.fill();
    ctx.stroke();

    // Cutting Reticle Center Point
    ctx.fillStyle = '#F59E0B';
    ctx.beginPath();
    ctx.arc(toolX, toolY, 3 / zoomLevel, 0, Math.PI * 2);
    ctx.fill();

    // Crosshairs
    ctx.strokeStyle = 'rgba(245, 158, 11, 0.6)';
    ctx.setLineDash([2 / zoomLevel, 2 / zoomLevel]);
    ctx.beginPath();
    ctx.moveTo(toolX - 15 / zoomLevel, toolY); ctx.lineTo(toolX + 15 / zoomLevel, toolY);
    ctx.moveTo(toolX, toolY - 15 / zoomLevel); ctx.lineTo(toolX, toolY + 15 / zoomLevel);
    ctx.stroke();

    ctx.restore();

    ctx.restore();
  }, [
    selectedPreset,
    chippingSteps,
    stepHistoryIndex,
    toolType,
    chipMode,
    toolX,
    toolY,
    toolWidth,
    toolHeight,
    toolAngle,
    zoomLevel,
    panX,
    panY,
    showSubpixelGrid,
    showTypographyGuides,
    showPegMetrics,
    customVertices,
  ]);

  // Execute a Bit-by-Bit Chipping Action
  const handleApplyChipStep = () => {
    const newStep: ChippingStep = {
      id: `chip_${Date.now()}`,
      timestamp: new Date().toLocaleTimeString([], { hour12: false, minute: '2-digit', second: '2-digit' }),
      toolType,
      mode: chipMode,
      x: toolX,
      y: toolY,
      width: toolWidth,
      height: toolHeight,
      angle: toolAngle,
      customVertices: toolType === 'custom_polygon' ? [...customVertices] : undefined,
    };

    // Trim history if we were in undo state
    const truncated = chippingSteps.slice(0, stepHistoryIndex + 1);
    const updated = [...truncated, newStep];
    setChippingSteps(updated);
    setStepHistoryIndex(updated.length - 1);
  };

  // Undo / Redo Handlers
  const handleUndo = () => {
    if (stepHistoryIndex >= 0) {
      setStepHistoryIndex((prev) => prev - 1);
    }
  };

  const handleRedo = () => {
    if (stepHistoryIndex < chippingSteps.length - 1) {
      setStepHistoryIndex((prev) => prev + 1);
    }
  };

  const handleResetGlyph = () => {
    setChippingSteps([]);
    setStepHistoryIndex(-1);
  };

  // Precision Nudge Handlers (1D DataHand / Keyboard Compatible)
  const nudgeToolX = (delta: number) => setToolX((prev) => Math.round((prev + delta * stepPrecision) * 10) / 10);
  const nudgeToolY = (delta: number) => setToolY((prev) => Math.round((prev + delta * stepPrecision) * 10) / 10);
  const nudgeWidth = (delta: number) => setToolWidth((prev) => Math.max(1, Math.round((prev + delta * stepPrecision) * 10) / 10));
  const nudgeHeight = (delta: number) => setToolHeight((prev) => Math.max(1, Math.round((prev + delta * stepPrecision) * 10) / 10));
  const nudgeAngle = (delta: number) => setToolAngle((prev) => (prev + delta * (stepPrecision >= 1 ? 5 : 1) + 360) % 360);

  // Mouse Interaction on Canvas (Positioning Tool)
  const handleCanvasClick = (e: React.MouseEvent<HTMLCanvasElement>) => {
    const canvas = displayCanvasRef.current;
    if (!canvas) return;
    const rect = canvas.getBoundingClientRect();
    const clickX = e.clientX - rect.left;
    const clickY = e.clientY - rect.top;

    // Convert screen coordinates back to 800x800 canvas space accounting for zoom & pan
    const scaleX = canvas.width / rect.width;
    const scaleY = canvas.height / rect.height;

    const canvasScreenX = clickX * scaleX;
    const canvasScreenY = clickY * scaleY;

    const unpannedX = canvasScreenX - (canvas.width / 2 + panX);
    const unpannedY = canvasScreenY - (canvas.height / 2 + panY);

    const targetX = unpannedX / zoomLevel + 400;
    const targetY = unpannedY / zoomLevel + 400;

    setToolX(Math.round(targetX * 10) / 10);
    setToolY(Math.round(targetY * 10) / 10);
  };

  return (
    <div className="flex flex-col h-full bg-[#050508] text-slate-100 font-sans overflow-hidden border border-white/10 rounded-lg shadow-2xl">
      {/* Header Bar */}
      <div className="bg-[#0D0E12] px-4 py-3 border-b border-white/10 flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center space-x-3">
          <div className="p-2 bg-amber-500/10 border border-amber-500/30 rounded text-amber-400">
            <Scissors className="w-5 h-5" />
          </div>
          <div>
            <h2 className="text-sm font-bold tracking-wider text-white uppercase flex items-center gap-2">
              Forward Outline Chipping Engine
              <span className="text-[10px] font-mono px-2 py-0.5 rounded bg-amber-500/20 text-amber-300 border border-amber-500/30">
                Bit-by-Bit CSG Precision
              </span>
            </h2>
            <p className="text-[11px] text-white/50 font-mono">
              Subtract or fuse exact tool outlines onto right-reading forward letterforms at sub-point scale.
            </p>
          </div>
        </div>

        {/* Preset Glyph Selector */}
        <div className="flex items-center space-x-2 text-xs font-mono">
          <span className="text-white/40 uppercase text-[10px]">Base Outline:</span>
          {(['letter_E', 'letter_R', 'letter_O', 'letter_S', 'letter_A', 'letter_g', 'solid_block'] as const).map((pr) => (
            <button
              key={pr}
              onClick={() => {
                setSelectedPreset(pr);
                handleResetGlyph();
              }}
              className={`px-2.5 py-1 rounded border text-[11px] font-bold transition-all ${
                selectedPreset === pr
                  ? 'bg-amber-500 text-black border-amber-400 shadow'
                  : 'bg-white/5 text-white/70 border-white/10 hover:bg-white/10'
              }`}
            >
              {pr === 'solid_block' ? 'Solid Block' : pr.replace('letter_', '')}
            </button>
          ))}
        </div>
      </div>

      {/* Main Grid Workbench */}
      <div className="grid grid-cols-1 lg:grid-cols-12 flex-1 overflow-hidden">
        {/* Left Column: Chipping Tools & Sub-Point Control (5 columns) */}
        <div className="lg:col-span-5 bg-[#0A0B0E] p-4 border-r border-white/10 flex flex-col space-y-4 overflow-y-auto">
          {/* 1. Tool Selection */}
          <div className="space-y-2 bg-[#12131A] p-3 rounded border border-white/10 font-mono text-xs">
            <span className="font-bold text-amber-400 uppercase tracking-wider block">
              1. Chipping Tool Outline
            </span>
            <div className="grid grid-cols-2 gap-2">
              <button
                onClick={() => setToolType('flat_file_plane')}
                className={`p-2 rounded border text-left flex items-center space-x-2 ${
                  toolType === 'flat_file_plane'
                    ? 'bg-amber-500/20 border-amber-500/50 text-amber-300'
                    : 'bg-white/5 border-white/10 text-white/70'
                }`}
              >
                <Sliders className="w-4 h-4 text-amber-400" />
                <div>
                  <div className="font-bold">Flat Filing Plane</div>
                  <div className="text-[9px] text-white/40">Linear angle slice</div>
                </div>
              </button>

              <button
                onClick={() => setToolType('v_chisel_wedge')}
                className={`p-2 rounded border text-left flex items-center space-x-2 ${
                  toolType === 'v_chisel_wedge'
                    ? 'bg-amber-500/20 border-amber-500/50 text-amber-300'
                    : 'bg-white/5 border-white/10 text-white/70'
                }`}
              >
                <Triangle className="w-4 h-4 text-amber-400" />
                <div>
                  <div className="font-bold">V-Chisel Wedge</div>
                  <div className="text-[9px] text-white/40">Crotches & ink traps</div>
                </div>
              </button>

              <button
                onClick={() => setToolType('rect_file')}
                className={`p-2 rounded border text-left flex items-center space-x-2 ${
                  toolType === 'rect_file'
                    ? 'bg-amber-500/20 border-amber-500/50 text-amber-300'
                    : 'bg-white/5 border-white/10 text-white/70'
                }`}
              >
                <Square className="w-4 h-4 text-amber-400" />
                <div>
                  <div className="font-bold">Rectangular File</div>
                  <div className="text-[9px] text-white/40">Stem milling block</div>
                </div>
              </button>

              <button
                onClick={() => setToolType('circular_burr')}
                className={`p-2 rounded border text-left flex items-center space-x-2 ${
                  toolType === 'circular_burr'
                    ? 'bg-amber-500/20 border-amber-500/50 text-amber-300'
                    : 'bg-white/5 border-white/10 text-white/70'
                }`}
              >
                <Circle className="w-4 h-4 text-amber-400" />
                <div>
                  <div className="font-bold">Circular Burr</div>
                  <div className="text-[9px] text-white/40">Inner curve drill</div>
                </div>
              </button>

              <button
                onClick={() => setToolType('serif_bracket')}
                className={`p-2 rounded border text-left flex items-center space-x-2 ${
                  toolType === 'serif_bracket'
                    ? 'bg-amber-500/20 border-amber-500/50 text-amber-300'
                    : 'bg-white/5 border-white/10 text-white/70'
                }`}
              >
                <PenTool className="w-4 h-4 text-amber-400" />
                <div>
                  <div className="font-bold">Serif Fillet Bracket</div>
                  <div className="text-[9px] text-white/40">Curved transition</div>
                </div>
              </button>

              <button
                onClick={() => setToolType('custom_polygon')}
                className={`p-2 rounded border text-left flex items-center space-x-2 ${
                  toolType === 'custom_polygon'
                    ? 'bg-amber-500/20 border-amber-500/50 text-amber-300'
                    : 'bg-white/5 border-white/10 text-white/70'
                }`}
              >
                <PenTool className="w-4 h-4 text-amber-400" />
                <div>
                  <div className="font-bold">Custom Polygon</div>
                  <div className="text-[9px] text-white/40">User custom outline</div>
                </div>
              </button>
            </div>

            {/* Chip Action Mode Switcher */}
            <div className="pt-2 flex items-center space-x-2 text-xs">
              <span className="text-white/50 text-[10px] uppercase">Operation Mode:</span>
              <button
                onClick={() => setChipMode('subtract')}
                className={`px-2.5 py-1 rounded text-[10px] font-bold border uppercase ${
                  chipMode === 'subtract'
                    ? 'bg-amber-500 text-black border-amber-400'
                    : 'bg-white/5 text-white/60 border-white/10'
                }`}
              >
                Subtract (Difference)
              </button>
              <button
                onClick={() => setChipMode('add')}
                className={`px-2.5 py-1 rounded text-[10px] font-bold border uppercase ${
                  chipMode === 'add'
                    ? 'bg-emerald-500 text-black border-emerald-400'
                    : 'bg-white/5 text-white/60 border-white/10'
                }`}
              >
                Fuse (Union)
              </button>
            </div>
          </div>

          {/* 2. Sub-Point Coordinates & Step Precision */}
          <div className="space-y-3 bg-[#12131A] p-3 rounded border border-white/10 font-mono text-xs">
            <div className="flex items-center justify-between">
              <span className="font-bold text-amber-400 uppercase tracking-wider">
                2. Sub-Point Precision Nudge Controls
              </span>
              <div className="flex items-center space-x-1 text-[10px]">
                <span className="text-white/50">Step:</span>
                {[0.1, 0.5, 1.0, 5.0].map((step) => (
                  <button
                    key={step}
                    onClick={() => setStepPrecision(step)}
                    className={`px-1.5 py-0.5 rounded border ${
                      stepPrecision === step
                        ? 'bg-amber-500 text-black font-bold border-amber-400'
                        : 'bg-white/5 text-white/60 border-white/10'
                    }`}
                  >
                    {step}pt
                  </button>
                ))}
              </div>
            </div>

            {/* Position X / Y */}
            <div className="grid grid-cols-2 gap-3 text-xs">
              {/* X Axis */}
              <div className="space-y-1">
                <div className="flex justify-between text-[10px] text-white/60">
                  <span>Center X ({toolX} pt)</span>
                </div>
                <div className="flex items-center space-x-1">
                  <button
                    onClick={() => nudgeToolX(-5)}
                    className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-amber-300 font-bold"
                  >
                    -5
                  </button>
                  <button
                    onClick={() => nudgeToolX(-1)}
                    className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-amber-300 font-bold"
                  >
                    -1
                  </button>
                  <input
                    type="number"
                    step={stepPrecision}
                    value={toolX}
                    onChange={(e) => setToolX(parseFloat(e.target.value) || 0)}
                    className="w-full bg-black text-amber-400 font-bold px-1.5 py-1 rounded border border-amber-500/40 text-center focus:outline-none"
                  />
                  <button
                    onClick={() => nudgeToolX(1)}
                    className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-amber-300 font-bold"
                  >
                    +1
                  </button>
                  <button
                    onClick={() => nudgeToolX(5)}
                    className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-amber-300 font-bold"
                  >
                    +5
                  </button>
                </div>
              </div>

              {/* Y Axis */}
              <div className="space-y-1">
                <div className="flex justify-between text-[10px] text-white/60">
                  <span>Center Y ({toolY} pt)</span>
                </div>
                <div className="flex items-center space-x-1">
                  <button
                    onClick={() => nudgeToolY(-5)}
                    className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-amber-300 font-bold"
                  >
                    -5
                  </button>
                  <button
                    onClick={() => nudgeToolY(-1)}
                    className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-amber-300 font-bold"
                  >
                    -1
                  </button>
                  <input
                    type="number"
                    step={stepPrecision}
                    value={toolY}
                    onChange={(e) => setToolY(parseFloat(e.target.value) || 0)}
                    className="w-full bg-black text-amber-400 font-bold px-1.5 py-1 rounded border border-amber-500/40 text-center focus:outline-none"
                  />
                  <button
                    onClick={() => nudgeToolY(1)}
                    className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-amber-300 font-bold"
                  >
                    +1
                  </button>
                  <button
                    onClick={() => nudgeToolY(5)}
                    className="px-1.5 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-amber-300 font-bold"
                  >
                    +5
                  </button>
                </div>
              </div>
            </div>

            {/* Width, Height, Angle */}
            <div className="grid grid-cols-3 gap-2 text-xs pt-1">
              <div className="space-y-1">
                <div className="flex justify-between text-[10px] text-white/60">
                  <span>Width ({toolWidth}pt)</span>
                </div>
                <div className="flex items-center space-x-1">
                  <button
                    onClick={() => nudgeWidth(-1)}
                    className="px-1 py-0.5 bg-white/5 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                  >
                    -
                  </button>
                  <input
                    type="number"
                    value={toolWidth}
                    onChange={(e) => setToolWidth(parseFloat(e.target.value) || 1)}
                    className="w-full bg-black text-amber-400 font-bold px-1 py-0.5 rounded border border-amber-500/30 text-center text-[10px] focus:outline-none"
                  />
                  <button
                    onClick={() => nudgeWidth(1)}
                    className="px-1 py-0.5 bg-white/5 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                  >
                    +
                  </button>
                </div>
              </div>

              <div className="space-y-1">
                <div className="flex justify-between text-[10px] text-white/60">
                  <span>Height ({toolHeight}pt)</span>
                </div>
                <div className="flex items-center space-x-1">
                  <button
                    onClick={() => nudgeHeight(-1)}
                    className="px-1 py-0.5 bg-white/5 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                  >
                    -
                  </button>
                  <input
                    type="number"
                    value={toolHeight}
                    onChange={(e) => setToolHeight(parseFloat(e.target.value) || 1)}
                    className="w-full bg-black text-amber-400 font-bold px-1 py-0.5 rounded border border-amber-500/30 text-center text-[10px] focus:outline-none"
                  />
                  <button
                    onClick={() => nudgeHeight(1)}
                    className="px-1 py-0.5 bg-white/5 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                  >
                    +
                  </button>
                </div>
              </div>

              <div className="space-y-1">
                <div className="flex justify-between text-[10px] text-white/60">
                  <span>Angle ({toolAngle}°)</span>
                </div>
                <div className="flex items-center space-x-1">
                  <button
                    onClick={() => nudgeAngle(-1)}
                    className="px-1 py-0.5 bg-white/5 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                  >
                    -
                  </button>
                  <input
                    type="number"
                    value={toolAngle}
                    onChange={(e) => setToolAngle(parseFloat(e.target.value) || 0)}
                    className="w-full bg-black text-amber-400 font-bold px-1 py-0.5 rounded border border-amber-500/30 text-center text-[10px] focus:outline-none"
                  />
                  <button
                    onClick={() => nudgeAngle(1)}
                    className="px-1 py-0.5 bg-white/5 border border-white/10 rounded text-[10px] text-amber-300 font-bold"
                  >
                    +
                  </button>
                </div>
              </div>
            </div>

            {/* Execute Bit-by-Bit Action Button */}
            <button
              onClick={handleApplyChipStep}
              className={`w-full py-2.5 font-bold uppercase tracking-wider rounded flex items-center justify-center space-x-2 shadow-lg transition-all ${
                chipMode === 'subtract'
                  ? 'bg-amber-500 hover:bg-amber-400 text-black'
                  : 'bg-emerald-500 hover:bg-emerald-400 text-black'
              }`}
            >
              <Scissors className="w-4 h-4" />
              <span>Chip Away Bit-by-Bit ({chipMode.toUpperCase()})</span>
            </button>
          </div>

          {/* 3. History Log & Undo / Redo */}
          <div className="space-y-2 bg-[#12131A] p-3 rounded border border-white/10 font-mono text-xs flex-1 flex flex-col min-h-[160px]">
            <div className="flex items-center justify-between">
              <span className="font-bold text-amber-400 uppercase tracking-wider">
                3. Sequential Chipping History
              </span>
              <div className="flex items-center space-x-1">
                <button
                  onClick={handleUndo}
                  disabled={stepHistoryIndex < 0}
                  className="px-2 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-[10px] text-amber-300 disabled:opacity-30"
                >
                  Undo
                </button>
                <button
                  onClick={handleRedo}
                  disabled={stepHistoryIndex >= chippingSteps.length - 1}
                  className="px-2 py-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-[10px] text-amber-300 disabled:opacity-30"
                >
                  Redo
                </button>
                <button
                  onClick={handleResetGlyph}
                  className="px-2 py-1 bg-red-500/20 hover:bg-red-500/30 border border-red-500/40 rounded text-[10px] text-red-300"
                >
                  Reset
                </button>
              </div>
            </div>

            <div className="flex-1 overflow-y-auto space-y-1 bg-black/40 p-2 rounded border border-white/5 max-h-[140px]">
              {chippingSteps.length === 0 ? (
                <div className="text-[10px] text-white/30 italic text-center py-4">
                  No chipping steps applied yet. Position tool & click 'Chip Away Bit-by-Bit'.
                </div>
              ) : (
                chippingSteps.map((step, idx) => {
                  const isActive = idx <= stepHistoryIndex;
                  return (
                    <div
                      key={step.id}
                      onClick={() => setStepHistoryIndex(idx)}
                      className={`p-1.5 rounded border text-[10px] cursor-pointer flex items-center justify-between ${
                        isActive
                          ? 'bg-amber-500/10 border-amber-500/40 text-amber-300'
                          : 'bg-white/5 border-white/5 text-white/40 line-through'
                      }`}
                    >
                      <div className="flex items-center space-x-1.5">
                        <span className="font-bold text-white/50">#{idx + 1}</span>
                        <span className="uppercase text-amber-400 font-bold">{step.toolType.replace('_', ' ')}</span>
                      </div>
                      <div className="text-[9px] text-white/60 font-mono">
                        ({step.x.toFixed(1)}, {step.y.toFixed(1)}) @ {step.angle}°
                      </div>
                    </div>
                  );
                })
              )}
            </div>
          </div>
        </div>

        {/* Right Column: High-DPI Precision Display & Micro Viewport (7 columns) */}
        <div className="lg:col-span-7 bg-[#08090C] p-4 flex flex-col justify-between space-y-3 relative overflow-hidden">
          {/* Top Viewport Toolbar */}
          <div className="flex items-center justify-between bg-[#12131A] px-3 py-2 rounded border border-white/10 font-mono text-xs z-10">
            {/* Zoom Controls */}
            <div className="flex items-center space-x-2">
              <span className="text-white/40 uppercase text-[10px]">Magnification:</span>
              <button
                onClick={() => setZoomLevel((z) => Math.max(1.0, z - 0.5))}
                className="p-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-amber-300"
              >
                <ZoomOut className="w-3.5 h-3.5" />
              </button>
              <span className="font-bold text-amber-400 w-12 text-center text-[11px]">
                {zoomLevel.toFixed(1)}x
              </span>
              <button
                onClick={() => setZoomLevel((z) => Math.min(15.0, z + 0.5))}
                className="p-1 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-amber-300"
              >
                <ZoomIn className="w-3.5 h-3.5" />
              </button>

              <button
                onClick={() => {
                  setZoomLevel(2.0);
                  setPanX(0);
                  setPanY(0);
                }}
                className="px-2 py-0.5 bg-white/5 hover:bg-white/10 border border-white/10 rounded text-[10px] text-white/60"
              >
                Reset Pan/Zoom
              </button>
            </div>

            {/* Overlays Toggles */}
            <div className="flex items-center space-x-3 text-[11px] text-white/70">
              <label className="flex items-center space-x-1.5 cursor-pointer">
                <input
                  type="checkbox"
                  checked={showSubpixelGrid}
                  onChange={(e) => setShowSubpixelGrid(e.target.checked)}
                  className="accent-amber-500"
                />
                <span>Sub-Pixel Grid</span>
              </label>

              <label className="flex items-center space-x-1.5 cursor-pointer">
                <input
                  type="checkbox"
                  checked={showTypographyGuides}
                  onChange={(e) => setShowTypographyGuides(e.target.checked)}
                  className="accent-amber-500"
                />
                <span>Typography Guides</span>
              </label>

              <label className="flex items-center space-x-1.5 cursor-pointer">
                <input
                  type="checkbox"
                  checked={showPegMetrics}
                  onChange={(e) => setShowPegMetrics(e.target.checked)}
                  className="accent-amber-500"
                />
                <span>Pegs</span>
              </label>
            </div>
          </div>

          {/* Interactive Canvas Stage */}
          <div className="flex-1 flex items-center justify-center relative bg-black/60 rounded border border-white/10 overflow-hidden shadow-inner min-h-[440px]">
            <canvas
              ref={displayCanvasRef}
              width={800}
              height={800}
              onClick={handleCanvasClick}
              className="w-full h-full max-w-[560px] max-h-[560px] object-contain cursor-crosshair rounded"
            />

            {/* Scale HUD Badge */}
            <div className="absolute bottom-3 left-3 bg-black/80 backdrop-blur px-2.5 py-1 rounded border border-white/10 font-mono text-[10px] text-amber-400 space-y-0.5">
              <div>Scale: Sub-Point Fine Chipping</div>
              <div className="text-white/40">Position: ({toolX.toFixed(1)}, {toolY.toFixed(1)}) pt</div>
            </div>
          </div>

          {/* Bottom Theoretical Metrology & Sorts Mill Pegs Inspector */}
          <div className="bg-[#12131A] p-3 rounded border border-white/10 font-mono text-xs flex items-center justify-between text-white/60">
            <div className="flex items-center space-x-2">
              <Info className="w-4 h-4 text-amber-400" />
              <span>
                Sorts Mill Boundary Pegs & Cl(4,1,1) Multivector Coordinate Frame Active.
              </span>
            </div>

            <div className="text-[10px] text-amber-300 bg-amber-500/10 px-2 py-0.5 rounded border border-amber-500/30 font-bold">
              No Distortion • Exact Outline CSG Subtraction
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
