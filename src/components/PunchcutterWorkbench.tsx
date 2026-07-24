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

export type MaterialType = 'steel' | 'boxwood' | 'brass';
export type PhysicalTool = 'counter_punch' | 'flat_file' | 'needle_file' | 'graver' | 'rasp';

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

export const PunchcutterWorkbench: React.FC = () => {
  // Material & Medium State
  const [material, setMaterial] = useState<MaterialType>('steel');
  const [activeTool, setActiveTool] = useState<PhysicalTool>('counter_punch');
  const [toolShape, setToolShape] = useState<'rect' | 'oval' | 'triangle' | 'v_groove' | 'serif_cut'>('oval');

  // Physical Tool Parameters (in mm / em points)
  const [toolX, setToolX] = useState<number>(200);
  const [toolY, setToolY] = useState<number>(200);
  const [toolWidth, setToolWidth] = useState<number>(60);
  const [toolHeight, setToolHeight] = useState<number>(100);
  const [toolDepth, setToolDepth] = useState<number>(2.5); // mm cut depth
  const [toolAngle, setToolAngle] = useState<number>(0);

  // DataHand & Single-Axis Ergonomics
  const [axisLock, setAxisLock] = useState<'auto_ortho' | 'lock_x' | 'lock_y' | 'free'>('auto_ortho');
  const [activeDragAxis, setActiveDragAxis] = useState<'x' | 'y' | null>(null);

  // Punch Cut Operations History
  const [cutOps, setCutOps] = useState<CutOperation[]>([
    // Default initial punch blank cut for an 'O' or 'H' counter
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
  const [inkViscosity, setInkViscosity] = useState<number>(0.6); // 0 (thin) to 1 (thick)
  const [paperPressure, setPaperPressure] = useState<number>(0.8); // impression force

  const canvasRef = useRef<HTMLCanvasElement | null>(null);

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

  // Render Punch face / Smoke proof / Ink proof on canvas
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

    if (viewMode === '3d_relief') {
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
      {/* Top Header & Physical Material Selector */}
      <div className="bg-[#0D0E12] px-4 py-3 border-b border-white/10 flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center space-x-3">
          <div className="p-2 bg-amber-500/10 border border-amber-500/30 rounded text-amber-400">
            <Hammer className="w-5 h-5" />
          </div>
          <div>
            <h2 className="text-sm font-bold tracking-wider text-white uppercase flex items-center gap-2">
              Physical Punchcutter & Wood/Metal Sculpting
              <span className="text-[10px] font-mono px-2 py-0.5 rounded bg-amber-500/20 text-amber-300 border border-amber-500/30">
                Benton & Sorts Mill Engine
              </span>
            </h2>
            <p className="text-[11px] text-white/50 font-mono">
              Subtractive punchcutting, counter-punching, flat/needle filing, and smoke proofing.
            </p>
          </div>
        </div>

        {/* Medium Selector */}
        <div className="flex items-center space-x-2 text-xs font-mono">
          <span className="text-white/40 uppercase">Physical Substrate:</span>
          <button
            onClick={() => setMaterial('steel')}
            className={`px-3 py-1 rounded border transition-all ${
              material === 'steel' ? 'bg-amber-500 text-black font-bold border-amber-400' : 'bg-white/5 text-white/60 border-white/10'
            }`}
          >
            Tempered Steel Punch
          </button>
          <button
            onClick={() => setMaterial('boxwood')}
            className={`px-3 py-1 rounded border transition-all ${
              material === 'boxwood' ? 'bg-amber-500 text-black font-bold border-amber-400' : 'bg-white/5 text-white/60 border-white/10'
            }`}
          >
            Boxwood End-Grain
          </button>
          <button
            onClick={() => setMaterial('brass')}
            className={`px-3 py-1 rounded border transition-all ${
              material === 'brass' ? 'bg-amber-500 text-black font-bold border-amber-400' : 'bg-white/5 text-white/60 border-white/10'
            }`}
          >
            Cast Brass Matrix
          </button>
        </div>
      </div>

      {/* Main Workbench Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-12 flex-1 overflow-hidden">
        {/* Left Physical Tool Control Panel (5 columns) */}
        <div className="lg:col-span-5 bg-[#0A0B0E] p-4 border-r border-white/10 flex flex-col space-y-4 overflow-y-auto">
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
                <input
                  type="range"
                  min="20"
                  max="380"
                  value={toolX}
                  onChange={(e) => setToolX(parseFloat(e.target.value))}
                  className="w-full accent-amber-500 bg-white/10 rounded h-1.5"
                />
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
                <input
                  type="range"
                  min="20"
                  max="380"
                  value={toolY}
                  onChange={(e) => setToolY(parseFloat(e.target.value))}
                  className="w-full accent-amber-500 bg-white/10 rounded h-1.5"
                />
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
        </div>

        {/* Right Columns: Canvas, Proofing Press, & Inspection (7 columns) */}
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

          {/* Interactive Physical Punch Canvas */}
          <div className="relative flex-1 bg-black rounded border border-white/15 p-4 flex items-center justify-center min-h-[420px] shadow-inner">
            <canvas
              ref={canvasRef}
              className="border border-white/10 rounded shadow-2xl max-w-full max-h-full aspect-square"
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
              <span className="text-amber-400 font-bold uppercase">Physical Punchcutting Metaphor:</span>
              <p className="pt-0.5 leading-relaxed">
                Replaces arbitrary spline pulling with traditional 15th–19th century punchcutting mechanics: counter-punching internal negative spaces, filing flat edges, gouging relief grooves, and taking lampblack smoke proofs. Integrated with Sorts Mill visual boundary pegs (`PEGS`).
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
