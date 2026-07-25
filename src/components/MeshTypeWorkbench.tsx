import React, { useState, useMemo, useRef, useCallback } from 'react';
import {
  Layers,
  RotateCcw,
  Sparkles,
  Zap,
  Maximize2,
  Code2,
  Cpu,
  Scissors,
  Eye,
  CheckCircle2,
  Activity,
  GitBranch,
} from 'lucide-react';
import { GlyphMeshTopology } from '../types';
import {
  createPresetGlyphMesh,
  solveMeshDeformation,
  compileMeshToOpenTypeContours,
} from '../lib/meshTypeEngine';

export const MeshTypeWorkbench: React.FC = () => {
  const [selectedGlyph, setSelectedGlyph] = useState<string>('G');
  const [stemBolding, setStemBolding] = useState<number>(0.0);
  const [opticalScaling, setOpticalScaling] = useState<number>(1.0);
  const [italicSkew, setItalicSkew] = useState<number>(0.0);
  const [massPreservation, setMassPreservation] = useState<number>(0.8);

  const [showMeshFaces, setShowMeshFaces] = useState<boolean>(true);
  const [showHalfEdges, setShowHalfEdges] = useState<boolean>(true);
  const [showVertices, setShowVertices] = useState<boolean>(true);
  const [showCompiledOutline, setShowCompiledOutline] = useState<boolean>(true);
  const [showHeatmap, setShowHeatmap] = useState<boolean>(true);

  const [selectedVertexId, setSelectedVertexId] = useState<number | null>(null);
  const [isDragging, setIsDragging] = useState<boolean>(false);

  // Base raw mesh topology
  const [baseMesh, setBaseMesh] = useState<GlyphMeshTopology>(() =>
    createPresetGlyphMesh('G')
  );

  const svgRef = useRef<SVGSVGElement | null>(null);

  // Handle Glyph Change
  const handleGlyphChange = (name: string) => {
    setSelectedGlyph(name);
    setBaseMesh(createPresetGlyphMesh(name));
    setSelectedVertexId(null);
  };

  // Reset Mesh
  const handleReset = () => {
    setStemBolding(0.0);
    setOpticalScaling(1.0);
    setItalicSkew(0.0);
    setMassPreservation(0.8);
    setBaseMesh(createPresetGlyphMesh(selectedGlyph));
    setSelectedVertexId(null);
  };

  // Solve deformed mesh topology
  const activeMesh = useMemo(() => {
    return solveMeshDeformation(
      baseMesh,
      selectedVertexId !== null ? selectedVertexId : -1,
      selectedVertexId !== null ? baseMesh.vertices[selectedVertexId].x : 0,
      selectedVertexId !== null ? baseMesh.vertices[selectedVertexId].y : 0,
      {
        stemBolding,
        opticalScaling,
        italicSkew,
        massPreservation,
        iterations: 12,
      }
    );
  }, [baseMesh, selectedVertexId, stemBolding, opticalScaling, italicSkew, massPreservation]);

  // Extract compiled OpenType SVG path
  const compiledSvgPath = useMemo(() => {
    return compileMeshToOpenTypeContours(activeMesh);
  }, [activeMesh]);

  // Mouse Dragging on Canvas
  const handleMouseDown = (vId: number) => {
    setSelectedVertexId(vId);
    setIsDragging(true);
  };

  const handleMouseMove = useCallback(
    (e: React.MouseEvent<SVGSVGElement>) => {
      if (!isDragging || selectedVertexId === null || !svgRef.current) return;

      const rect = svgRef.current.getBoundingClientRect();
      const scaleX = 600 / rect.width;
      const scaleY = 700 / rect.height;

      const mouseX = (e.clientX - rect.left) * scaleX;
      const mouseY = (e.clientY - rect.top) * scaleY;

      setBaseMesh((prev) => {
        const nextVerts = [...prev.vertices];
        nextVerts[selectedVertexId] = {
          ...nextVerts[selectedVertexId],
          x: Math.max(20, Math.min(580, mouseX)),
          y: Math.max(20, Math.min(680, mouseY)),
        };
        return {
          ...prev,
          vertices: nextVerts,
        };
      });
    },
    [isDragging, selectedVertexId]
  );

  const handleMouseUp = () => {
    setIsDragging(false);
  };

  return (
    <div className="flex flex-col lg:flex-row gap-6 p-6 max-w-7xl mx-auto text-slate-100">
      {/* Sidebar Controls */}
      <div className="w-full lg:w-96 space-y-6 shrink-0">
        <div className="bg-[#121214] border border-white/10 p-5 rounded-lg shadow-xl space-y-5">
          <div className="flex items-center justify-between pb-3 border-b border-white/10">
            <div className="flex items-center space-x-2.5">
              <div className="p-2 rounded bg-amber-500/10 border border-amber-500/30 text-amber-400">
                <Cpu className="w-5 h-5" />
              </div>
              <div>
                <h2 className="text-sm font-semibold tracking-wider uppercase text-white">
                  MeshType Topology
                </h2>
                <p className="text-[10px] text-white/50 uppercase tracking-widest font-mono">
                  Continuous 2D Surface Mesh
                </p>
              </div>
            </div>
            <button
              onClick={handleReset}
              className="p-1.5 rounded hover:bg-white/10 text-white/60 hover:text-white transition cursor-pointer"
              title="Reset Topology"
            >
              <RotateCcw className="w-4 h-4" />
            </button>
          </div>

          {/* Glyph Selector */}
          <div>
            <label className="text-[11px] font-mono uppercase tracking-wider text-amber-400/90 mb-2 block">
              Select Master Glyph Topology:
            </label>
            <div className="grid grid-cols-4 gap-2">
              {['G', 'B', 'R', 'S'].map((g) => (
                <button
                  key={g}
                  onClick={() => handleGlyphChange(g)}
                  className={`py-2 text-center rounded text-xs font-bold font-mono transition cursor-pointer border ${
                    selectedGlyph === g
                      ? 'bg-amber-500 text-black border-amber-400 shadow'
                      : 'bg-white/5 text-white/70 border-white/10 hover:bg-white/10'
                  }`}
                >
                  Glyph '{g}'
                </button>
              ))}
            </div>
          </div>

          {/* Deformable Field Controls */}
          <div className="space-y-4 pt-2 border-t border-white/10">
            {/* Stem Weight / Bolding */}
            <div>
              <div className="flex justify-between items-center text-xs mb-1">
                <span className="text-white/80 font-medium">Stem Optical Bolding:</span>
                <span className="font-mono text-amber-400 font-bold">
                  {stemBolding > 0 ? `+${stemBolding.toFixed(2)}` : stemBolding.toFixed(2)}
                </span>
              </div>
              <input
                type="range"
                min="-0.8"
                max="0.8"
                step="0.05"
                value={stemBolding}
                onChange={(e) => setStemBolding(Number(e.target.value))}
                className="w-full accent-amber-500 bg-white/10 h-1.5 rounded cursor-pointer"
              />
            </div>

            {/* Optical Scale */}
            <div>
              <div className="flex justify-between items-center text-xs mb-1">
                <span className="text-white/80 font-medium">Optical Surface Scaling:</span>
                <span className="font-mono text-amber-400 font-bold">
                  {opticalScaling.toFixed(2)}×
                </span>
              </div>
              <input
                type="range"
                min="0.8"
                max="1.4"
                step="0.02"
                value={opticalScaling}
                onChange={(e) => setOpticalScaling(Number(e.target.value))}
                className="w-full accent-amber-500 bg-white/10 h-1.5 rounded cursor-pointer"
              />
            </div>

            {/* Italic Skew */}
            <div>
              <div className="flex justify-between items-center text-xs mb-1">
                <span className="text-white/80 font-medium">Italic Shear Transformation:</span>
                <span className="font-mono text-amber-400 font-bold">
                  {(italicSkew * 28).toFixed(1)}°
                </span>
              </div>
              <input
                type="range"
                min="-0.3"
                max="0.3"
                step="0.02"
                value={italicSkew}
                onChange={(e) => setItalicSkew(Number(e.target.value))}
                className="w-full accent-amber-500 bg-white/10 h-1.5 rounded cursor-pointer"
              />
            </div>

            {/* Mass Preservation Elasticity */}
            <div>
              <div className="flex justify-between items-center text-xs mb-1">
                <span className="text-white/80 font-medium">Mass / Volume Elasticity:</span>
                <span className="font-mono text-amber-400 font-bold">
                  {Math.round(massPreservation * 100)}%
                </span>
              </div>
              <input
                type="range"
                min="0.0"
                max="1.0"
                step="0.05"
                value={massPreservation}
                onChange={(e) => setMassPreservation(Number(e.target.value))}
                className="w-full accent-amber-500 bg-white/10 h-1.5 rounded cursor-pointer"
              />
            </div>
          </div>

          {/* Visualization Layer Toggles */}
          <div className="space-y-2 pt-3 border-t border-white/10">
            <span className="text-[10px] font-mono uppercase tracking-wider text-white/50 block mb-1">
              Canvas Visualization Layers:
            </span>

            <label className="flex items-center justify-between text-xs cursor-pointer hover:text-white text-white/80">
              <span className="flex items-center gap-2">
                <Layers className="w-3.5 h-3.5 text-cyan-400" />
                2D Mesh Surface Faces
              </span>
              <input
                type="checkbox"
                checked={showMeshFaces}
                onChange={(e) => setShowMeshFaces(e.target.checked)}
                className="accent-amber-500 rounded"
              />
            </label>

            <label className="flex items-center justify-between text-xs cursor-pointer hover:text-white text-white/80">
              <span className="flex items-center gap-2">
                <GitBranch className="w-3.5 h-3.5 text-amber-400" />
                Half-Edge Topology Links
              </span>
              <input
                type="checkbox"
                checked={showHalfEdges}
                onChange={(e) => setShowHalfEdges(e.target.checked)}
                className="accent-amber-500 rounded"
              />
            </label>

            <label className="flex items-center justify-between text-xs cursor-pointer hover:text-white text-white/80">
              <span className="flex items-center gap-2">
                <Activity className="w-3.5 h-3.5 text-emerald-400" />
                Optical Mass Heatmap
              </span>
              <input
                type="checkbox"
                checked={showHeatmap}
                onChange={(e) => setShowHeatmap(e.target.checked)}
                className="accent-amber-500 rounded"
              />
            </label>

            <label className="flex items-center justify-between text-xs cursor-pointer hover:text-white text-white/80">
              <span className="flex items-center gap-2">
                <Scissors className="w-3.5 h-3.5 text-orange-400" />
                Compiled OpenType Outline
              </span>
              <input
                type="checkbox"
                checked={showCompiledOutline}
                onChange={(e) => setShowCompiledOutline(e.target.checked)}
                className="accent-amber-500 rounded"
              />
            </label>
          </div>
        </div>

        {/* Mesh Metrics Summary Card */}
        <div className="bg-[#121214] border border-white/10 p-4 rounded-lg space-y-2 text-xs">
          <div className="flex items-center justify-between text-amber-400 font-mono font-bold uppercase tracking-wider text-[11px]">
            <span>Topology Inventory</span>
            <CheckCircle2 className="w-4 h-4 text-emerald-400" />
          </div>
          <div className="grid grid-cols-3 gap-2 font-mono text-[11px] pt-1">
            <div className="bg-white/5 p-2 rounded text-center">
              <div className="text-white/40 text-[9px]">VERTICES</div>
              <div className="text-white font-bold text-sm">{activeMesh.vertices.length}</div>
            </div>
            <div className="bg-white/5 p-2 rounded text-center">
              <div className="text-white/40 text-[9px]">HALF-EDGES</div>
              <div className="text-white font-bold text-sm">{activeMesh.halfEdges.length}</div>
            </div>
            <div className="bg-white/5 p-2 rounded text-center">
              <div className="text-white/40 text-[9px]">FACES</div>
              <div className="text-white font-bold text-sm">{activeMesh.faces.length}</div>
            </div>
          </div>
        </div>
      </div>

      {/* Main Interactive Mesh Canvas */}
      <div className="flex-1 space-y-6">
        <div className="bg-[#0B0B0C] border border-white/10 rounded-lg p-5 shadow-2xl relative overflow-hidden">
          {/* Header Bar */}
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between pb-4 border-b border-white/10 gap-2">
            <div>
              <div className="flex items-center space-x-2">
                <span className="text-xs font-mono px-2 py-0.5 rounded bg-amber-500/20 text-amber-400 border border-amber-500/30 uppercase font-bold">
                  2D MESH CANVAS
                </span>
                <span className="text-xs text-white/50 font-mono">
                  Interactive Vertex Deform & Mass Redistribution
                </span>
              </div>
            </div>
            <div className="flex items-center space-x-3 text-xs font-mono text-white/60">
              <span className="flex items-center gap-1">
                <span className="w-2 h-2 rounded-full bg-amber-400 inline-block" />
                Boundary Edges
              </span>
              <span className="flex items-center gap-1">
                <span className="w-2 h-2 rounded-full bg-cyan-400 inline-block" />
                Internal Mesh
              </span>
            </div>
          </div>

          {/* Interactive SVG Surface */}
          <div className="relative flex justify-center items-center my-4 bg-[#050506] rounded border border-white/5 p-4">
            <svg
              ref={svgRef}
              viewBox="0 0 600 700"
              className="w-full max-w-[540px] h-auto cursor-crosshair select-none"
              onMouseMove={handleMouseMove}
              onMouseUp={handleMouseUp}
              onMouseLeave={handleMouseUp}
            >
              {/* Grid Background */}
              <defs>
                <pattern id="meshGrid" width="30" height="30" patternUnits="userSpaceOnUse">
                  <path d="M 30 0 L 0 0 0 30" fill="none" stroke="#FFFFFF08" strokeWidth="0.5" />
                </pattern>
              </defs>
              <rect width="600" height="700" fill="url(#meshGrid)" />

              {/* Baseline & Cap-Height Guides */}
              <line x1="40" y1="620" x2="560" y2="620" stroke="#D97706" strokeWidth="1" strokeDasharray="4 4" opacity="0.6" />
              <text x="45" y="612" fill="#D97706" fontSize="11" fontFamily="monospace" opacity="0.8">
                BASELINE (0pt)
              </text>

              <line x1="40" y1="100" x2="560" y2="100" stroke="#2563EB" strokeWidth="1" strokeDasharray="4 4" opacity="0.6" />
              <text x="45" y="92" fill="#2563EB" fontSize="11" fontFamily="monospace" opacity="0.8">
                CAP-HEIGHT (700pt)
              </text>

              {/* 1. 2D Mesh Faces (Quads/Triangles with Optical Density Heatmap) */}
              {showMeshFaces &&
                activeMesh.faces.map((f) => {
                  const pathPoints = f.vertexIds
                    .map((vId) => {
                      const v = activeMesh.vertices[vId];
                      return `${v.x.toFixed(1)},${v.y.toFixed(1)}`;
                    })
                    .join(' ');

                  // Optical Density Heatmap: 1.0 = Normal (slate/cyan), >1.0 = Compressed (amber/red), <1.0 = Stretched (blue)
                  let fillColor = 'rgba(6, 182, 212, 0.15)'; // Cyan default
                  if (showHeatmap) {
                    const rho = f.opticalDensity;
                    if (rho > 1.1) {
                      fillColor = `rgba(245, 158, 11, ${Math.min((rho - 1.0) * 0.8, 0.6)})`; // Amber/gold
                    } else if (rho < 0.9) {
                      fillColor = `rgba(59, 130, 246, ${Math.min((1.0 - rho) * 0.8, 0.6)})`; // Blue
                    }
                  }

                  return (
                    <polygon
                      key={`face_${f.id}`}
                      points={pathPoints}
                      fill={fillColor}
                      stroke="#06B6D440"
                      strokeWidth="0.8"
                    />
                  );
                })}

              {/* 2. Half-Edge Topology Connections */}
              {showHalfEdges &&
                activeMesh.halfEdges.map((he) => {
                  const v1 = activeMesh.vertices[he.origin];
                  const v2 = activeMesh.vertices[he.target];
                  const isBound = he.isBoundary;

                  return (
                    <line
                      key={`he_${he.id}`}
                      x1={v1.x}
                      y1={v1.y}
                      x2={v2.x}
                      y2={v2.y}
                      stroke={isBound ? '#F59E0B' : '#06B6D4'}
                      strokeWidth={isBound ? 2.5 : 0.8}
                      strokeDasharray={isBound ? undefined : '2 2'}
                      opacity={isBound ? 0.95 : 0.4}
                    />
                  );
                })}

              {/* 3. Compiled Legacy OpenType Outline Layer */}
              {showCompiledOutline && compiledSvgPath && (
                <path
                  d={compiledSvgPath}
                  fill="rgba(245, 158, 11, 0.08)"
                  stroke="#10B981"
                  strokeWidth="2"
                  strokeLinejoin="round"
                />
              )}

              {/* 4. Mesh Vertices */}
              {showVertices &&
                activeMesh.vertices.map((v) => {
                  const isSelected = selectedVertexId === v.id;
                  const isBound = v.isBoundary;

                  return (
                    <g
                      key={`vert_${v.id}`}
                      className="group cursor-pointer"
                      onMouseDown={() => handleMouseDown(v.id)}
                    >
                      {/* Generous Invisible Hit Target to Prevent Hover Jitter */}
                      <circle
                        cx={v.x}
                        cy={v.y}
                        r={18}
                        fill="transparent"
                        className="cursor-grab active:cursor-grabbing"
                      />

                      {/* Outer Selection / Hover Halo */}
                      {(isSelected || isBound) && (
                        <circle
                          cx={v.x}
                          cy={v.y}
                          r={isSelected ? 12 : 8}
                          fill="none"
                          stroke={isSelected ? '#F59E0B' : '#06B6D4'}
                          strokeWidth="1.5"
                          strokeDasharray={isSelected ? '2 2' : undefined}
                          opacity={0.8}
                          className="transition-opacity group-hover:opacity-100"
                        />
                      )}

                      {/* Visible Vertex Point */}
                      <circle
                        cx={v.x}
                        cy={v.y}
                        r={isSelected ? 6 : isBound ? 5 : 3.5}
                        fill={isSelected ? '#F59E0B' : isBound ? '#F59E0B' : '#06B6D4'}
                        stroke="#000000"
                        strokeWidth="1.5"
                        className="transition-colors group-hover:fill-amber-400 group-hover:stroke-white"
                      />
                    </g>
                  );
                })}
            </svg>
          </div>

          <p className="text-[11px] text-white/50 text-center font-mono">
            💡 Click and drag any vertex to observe laplacian elastic deformation and mass redistribution across internal faces.
          </p>
        </div>

        {/* Compiled OpenType SVG Output Box */}
        <div className="bg-[#121214] border border-white/10 rounded-lg p-5 space-y-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-2 text-xs font-mono text-emerald-400 font-bold uppercase tracking-wider">
              <Code2 className="w-4 h-4" />
              <span>Compiled OpenType Glyph Contours (Internal Topology Stripped)</span>
            </div>
            <span className="text-[10px] font-mono px-2 py-0.5 rounded bg-emerald-500/10 text-emerald-300 border border-emerald-500/30">
              Legacy OpenType Ready
            </span>
          </div>

          <div className="bg-black/60 p-3 rounded border border-white/10 font-mono text-[11px] text-amber-300 overflow-x-auto max-h-32">
            <code>{`<path d="${compiledSvgPath}" fill="currentColor" />`}</code>
          </div>
        </div>

        {/* Mathematical Architecture Specs */}
        <div className="bg-[#121214] border border-white/10 rounded-lg p-5 space-y-4">
          <h3 className="text-xs font-mono font-bold text-amber-400 uppercase tracking-widest flex items-center gap-2">
            <Zap className="w-4 h-4" />
            MeshType Architectural Paradigm Specifications
          </h3>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-xs text-white/70">
            <div className="bg-white/5 p-3 rounded border border-white/10 space-y-1.5">
              <div className="font-semibold text-white font-mono text-[11px]">1. Half-Edge Data Structure</div>
              <p className="text-[11px] text-white/60 leading-relaxed">
                Tracks glyph geometry with pointers for <code className="text-amber-300 font-mono">origin</code>, <code className="text-amber-300 font-mono">target</code>, <code className="text-amber-300 font-mono">pair</code>, <code className="text-amber-300 font-mono">next</code>, and <code className="text-amber-300 font-mono">prev</code>, enabling instant loop traversal and face quads.
              </p>
            </div>

            <div className="bg-white/5 p-3 rounded border border-white/10 space-y-1.5">
              <div className="font-semibold text-white font-mono text-[11px]">2. Mass Elastic Conservation</div>
              <p className="text-[11px] text-white/60 leading-relaxed">
                Deformation propagates using Laplacian Laplace-Beltrami operators with mass-density field constraints (<code className="text-amber-300 font-mono">ρ = A_rest / A_curr</code>), preserving stem proportions.
              </p>
            </div>

            <div className="bg-white/5 p-3 rounded border border-white/10 space-y-1.5">
              <div className="font-semibold text-white font-mono text-[11px]">3. OpenType Compiler Pipeline</div>
              <p className="text-[11px] text-white/60 leading-relaxed">
                Automatically strips internal faces during compile, extracting outer boundary edge loops into standard cubic Bézier curves for direct OpenType export.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
