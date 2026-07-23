import React, { useState, useRef, useEffect } from 'react';
import {
  ZoomIn,
  ZoomOut,
  Maximize2,
  Eye,
  Grid,
  Box,
  Layers,
  Compass,
  Zap,
} from 'lucide-react';
import { LayoutBox } from '../types';
import { cl411ToSvgTransform } from '../lib/cl411Algebra';

interface TypesetCanvasProps {
  layoutBoxes: LayoutBox[];
  totalWidth: number;
  totalHeight: number;
  ascent: number;
  descent: number;
  selectedBoxId: string | null;
  onSelectBox: (box: LayoutBox | null) => void;
  showIrisGrid: boolean;
  setShowIrisGrid: (show: boolean) => void;
  showCl411Frame: boolean;
  setShowCl411Frame: (show: boolean) => void;
  showMaxEntHeatmap: boolean;
  setShowMaxEntHeatmap: (show: boolean) => void;
  showBaselineGrid: boolean;
  setShowBaselineGrid: (show: boolean) => void;
  showBoundingBoxes: boolean;
  setShowBoundingBoxes: (show: boolean) => void;
}

export const TypesetCanvas: React.FC<TypesetCanvasProps> = ({
  layoutBoxes,
  totalWidth,
  totalHeight,
  ascent,
  descent,
  selectedBoxId,
  onSelectBox,
  showIrisGrid,
  setShowIrisGrid,
  showCl411Frame,
  setShowCl411Frame,
  showMaxEntHeatmap,
  setShowMaxEntHeatmap,
  showBaselineGrid,
  setShowBaselineGrid,
  showBoundingBoxes,
  setShowBoundingBoxes,
}) => {
  const [zoom, setZoom] = useState<number>(2.5); // Default zoom level for crisp rendering
  const [pan, setPan] = useState<{ x: number; y: number }>({ x: 120, y: 160 });
  const [isDragging, setIsDragging] = useState<boolean>(false);
  const dragStartRef = useRef<{ x: number; y: number }>({ x: 0, y: 0 });

  const containerRef = useRef<HTMLDivElement>(null);

  // Mouse pan handlers
  const handleMouseDown = (e: React.MouseEvent) => {
    if (e.button === 0) {
      setIsDragging(true);
      dragStartRef.current = { x: e.clientX - pan.x, y: e.clientY - pan.y };
    }
  };

  const handleMouseMove = (e: React.MouseEvent) => {
    if (isDragging) {
      setPan({
        x: e.clientX - dragStartRef.current.x,
        y: e.clientY - dragStartRef.current.y,
      });
    }
  };

  const handleMouseUp = () => {
    setIsDragging(false);
  };

  // Wheel zoom
  const handleWheel = (e: React.WheelEvent) => {
    e.preventDefault();
    const zoomFactor = e.deltaY < 0 ? 1.15 : 0.85;
    setZoom((prev) => Math.min(Math.max(prev * zoomFactor, 0.5), 25.0));
  };

  const resetView = () => {
    setZoom(2.5);
    setPan({ x: 120, y: 160 });
  };

  return (
    <div className="flex flex-col h-full bg-[#050506] rounded-lg border border-white/10 shadow-2xl overflow-hidden relative">
      {/* Canvas Toolbar Controls */}
      <div className="bg-[#0F0F10] border-b border-white/10 p-2.5 flex flex-wrap items-center justify-between gap-2 z-10">
        <div className="flex items-center space-x-1.5 overflow-x-auto">
          <span className="text-[10px] uppercase tracking-widest text-amber-500 font-semibold px-2 py-0.5">
            Overlays:
          </span>

          <button
            onClick={() => setShowIrisGrid(!showIrisGrid)}
            className={`flex items-center space-x-1 px-2.5 py-1 rounded text-xs font-medium uppercase tracking-wider transition-all ${
              showIrisGrid
                ? 'bg-amber-500/20 text-amber-300 border border-amber-500/40'
                : 'bg-white/5 text-white/50 border border-white/10 hover:text-white/80'
            }`}
          >
            <Grid className="w-3.5 h-3.5" />
            <span>Iris Grid</span>
          </button>

          <button
            onClick={() => setShowCl411Frame(!showCl411Frame)}
            className={`flex items-center space-x-1 px-2.5 py-1 rounded text-xs font-medium uppercase tracking-wider transition-all ${
              showCl411Frame
                ? 'bg-amber-500/20 text-amber-300 border border-amber-500/40'
                : 'bg-white/5 text-white/50 border border-white/10 hover:text-white/80'
            }`}
          >
            <Compass className="w-3.5 h-3.5" />
            <span>Cl(4,1,1) Frame</span>
          </button>

          <button
            onClick={() => setShowMaxEntHeatmap(!showMaxEntHeatmap)}
            className={`flex items-center space-x-1 px-2.5 py-1 rounded text-xs font-medium uppercase tracking-wider transition-all ${
              showMaxEntHeatmap
                ? 'bg-amber-500/20 text-amber-300 border border-amber-500/40'
                : 'bg-white/5 text-white/50 border border-white/10 hover:text-white/80'
            }`}
          >
            <Zap className="w-3.5 h-3.5" />
            <span>MaxEnt Heatmap</span>
          </button>

          <button
            onClick={() => setShowBaselineGrid(!showBaselineGrid)}
            className={`flex items-center space-x-1 px-2.5 py-1 rounded text-xs font-medium uppercase tracking-wider transition-all ${
              showBaselineGrid
                ? 'bg-amber-500/20 text-amber-300 border border-amber-500/40'
                : 'bg-white/5 text-white/50 border border-white/10 hover:text-white/80'
            }`}
          >
            <Layers className="w-3.5 h-3.5" />
            <span>Baseline</span>
          </button>

          <button
            onClick={() => setShowBoundingBoxes(!showBoundingBoxes)}
            className={`flex items-center space-x-1 px-2.5 py-1 rounded text-xs font-medium uppercase tracking-wider transition-all ${
              showBoundingBoxes
                ? 'bg-amber-500/20 text-amber-300 border border-amber-500/40'
                : 'bg-white/5 text-white/50 border border-white/10 hover:text-white/80'
            }`}
          >
            <Box className="w-3.5 h-3.5" />
            <span>Glyph Box</span>
          </button>
        </div>

        {/* Zoom & Reset Controls */}
        <div className="flex items-center space-x-2 bg-white/5 px-2 py-1 rounded border border-white/10 text-xs">
          <button
            onClick={() => setZoom((z) => Math.max(z * 0.8, 0.5))}
            className="p-1 rounded hover:bg-white/10 text-white/70 transition"
            title="Zoom Out"
          >
            <ZoomOut className="w-3.5 h-3.5" />
          </button>
          <span className="font-mono text-amber-400 font-semibold w-12 text-center">
            {Math.round(zoom * 100)}%
          </span>
          <button
            onClick={() => setZoom((z) => Math.min(z * 1.25, 25.0))}
            className="p-1 rounded hover:bg-white/10 text-white/70 transition"
            title="Zoom In"
          >
            <ZoomIn className="w-3.5 h-3.5" />
          </button>
          <div className="w-px h-3 bg-white/10 mx-1" />
          <button
            onClick={resetView}
            className="p-1 rounded hover:bg-white/10 text-white/40 hover:text-white/80 transition"
            title="Reset View"
          >
            <Maximize2 className="w-3.5 h-3.5" />
          </button>
        </div>
      </div>

      {/* SVG Vector Canvas Container */}
      <div
        ref={containerRef}
        onMouseDown={handleMouseDown}
        onMouseMove={handleMouseMove}
        onMouseUp={handleMouseUp}
        onMouseLeave={handleMouseUp}
        onWheel={handleWheel}
        className="flex-1 w-full h-full cursor-grab active:cursor-grabbing select-none overflow-hidden relative bg-[#050506] [background-image:radial-gradient(#ffffff15_1px,transparent_1px)] [background-size:16px_16px]"
      >
        <svg
          className="w-full h-full absolute inset-0"
          style={{
            transformOrigin: '0 0',
          }}
        >
          <g transform={`translate(${pan.x}, ${pan.y}) scale(${zoom})`}>
            {/* Paper Document Preview Plate */}
            <rect
              x="-24"
              y={-ascent - 24}
              width={Math.max(totalWidth + 48, 200)}
              height={Math.max(ascent + descent + 48, 120)}
              fill="#FFFFFF"
              rx="2"
              className="shadow-2xl"
              style={{
                filter: 'drop-shadow(0 20px 25px rgba(0, 0, 0, 0.7))',
              }}
            />

            {/* Document Header Line on Paper */}
            <line
              x1="-16"
              y1={-ascent - 12}
              x2={Math.max(totalWidth + 32, 180)}
              y2={-ascent - 12}
              stroke="#00000015"
              strokeWidth="0.5"
            />
            <text
              x="-16"
              y={-ascent - 16}
              fontSize="3.5"
              fill="#00000040"
              fontFamily="sans-serif"
              letterSpacing="0.1em"
              fontWeight="bold"
            >
              IRIS GEOMETRIC NOTATION MANIFOLD
            </text>

            {/* 1. Counting-Iris Grid Overlay */}
            {showIrisGrid && (
              <g opacity={0.35}>
                <pattern
                  id="irisSubPixelGrid"
                  width="10"
                  height="10"
                  patternUnits="userSpaceOnUse"
                >
                  <path
                    d="M 10 0 L 0 0 0 10"
                    fill="none"
                    stroke="#D97706"
                    strokeWidth="0.2"
                    strokeDasharray="1,1"
                  />
                </pattern>
                <rect
                  x="-200"
                  y="-200"
                  width="1200"
                  height="800"
                  fill="url(#irisSubPixelGrid)"
                />
                {/* Iris Origin Node */}
                <circle cx="0" cy="0" r="1.8" fill="#D97706" />
                <text
                  x="4"
                  y="-4"
                  fontSize="4"
                  fill="#D97706"
                  fontFamily="monospace"
                >
                  Iris[0.0::0]
                </text>
              </g>
            )}

            {/* 2. Baseline Grid */}
            {showBaselineGrid && (
              <g opacity={0.6}>
                {/* Main Baseline */}
                <line
                  x1="-30"
                  y1="0"
                  x2={totalWidth + 30}
                  y2="0"
                  stroke="#D97706"
                  strokeWidth="0.6"
                />
                <text
                  x="-22"
                  y="-2"
                  fontSize="4"
                  fill="#D97706"
                  fontFamily="sans-serif"
                  fontWeight="bold"
                >
                  Baseline
                </text>

                {/* Ascent Line */}
                <line
                  x1="-30"
                  y1={-ascent}
                  x2={totalWidth + 30}
                  y2={-ascent}
                  stroke="#2563EB"
                  strokeWidth="0.3"
                  strokeDasharray="2,2"
                />
                {/* Descent Line */}
                <line
                  x1="-30"
                  y1={descent}
                  x2={totalWidth + 30}
                  y2={descent}
                  stroke="#DC2626"
                  strokeWidth="0.3"
                  strokeDasharray="2,2"
                />
              </g>
            )}

            {/* 3. Render Layout Boxes & Glyphs */}
            {layoutBoxes.map((box) => {
              const isSelected = selectedBoxId === box.id;
              const clTransformStr = cl411ToSvgTransform(box.x, box.y, box.transform);

              return (
                <g
                  key={box.id}
                  onClick={(e) => {
                    e.stopPropagation();
                    onSelectBox(box);
                  }}
                  className="cursor-pointer group"
                >
                  {/* Bounding Box Overlay */}
                  {showBoundingBoxes && (
                    <rect
                      x={box.x}
                      y={box.y - box.ascent}
                      width={box.width}
                      height={box.ascent + box.descent}
                      fill={isSelected ? 'rgba(217, 119, 6, 0.2)' : 'none'}
                      stroke={isSelected ? '#D97706' : 'rgba(0, 0, 0, 0.25)'}
                      strokeWidth={isSelected ? '0.8' : '0.3'}
                      strokeDasharray={isSelected ? 'none' : '1,1'}
                      rx="0.3"
                    />
                  )}

                  {/* Cl(4,1,1) Multivector Frame Overlay */}
                  {showCl411Frame && (
                    <g transform={`translate(${box.x}, ${box.y})`}>
                      {/* e1 spatial vector */}
                      <line
                        x1="0"
                        y1="0"
                        x2={box.width}
                        y2="0"
                        stroke="#B45309"
                        strokeWidth="0.5"
                      />
                      {/* e2 spatial vector */}
                      <line
                        x1="0"
                        y1="0"
                        x2="0"
                        y2={-box.ascent}
                        stroke="#D97706"
                        strokeWidth="0.5"
                      />
                      {/* e6 null degenerate node */}
                      <circle cx="0" cy="0" r="1.0" fill="#B45309" />
                    </g>
                  )}

                  {/* MaxEnt Energy Heatmap Overlay */}
                  {showMaxEntHeatmap && (
                    <circle
                      cx={box.x + box.width / 2}
                      cy={box.y}
                      r={Math.max(box.width * 0.6, 4)}
                      fill={box.isOperator ? 'rgba(217, 119, 6, 0.3)' : 'rgba(37, 99, 235, 0.15)'}
                      stroke={box.isOperator ? '#D97706' : '#2563EB'}
                      strokeWidth="0.3"
                    />
                  )}

                  {/* Vector Glyph Rendering */}
                  {box.glyphPath ? (
                    <path
                      d={box.glyphPath}
                      transform={clTransformStr}
                      fill={isSelected ? '#D97706' : box.isOperator ? '#B45309' : '#0F0F10'}
                      stroke={box.isOperator ? '#B45309' : 'none'}
                      strokeWidth="0.2"
                      className="transition-colors duration-150 group-hover:fill-amber-600"
                    />
                  ) : box.value ? (
                    <text
                      x={box.x}
                      y={box.y}
                      fontSize={box.fontSize}
                      fill={isSelected ? '#D97706' : box.isOperator ? '#B45309' : '#0F0F10'}
                      fontFamily="serif"
                      className="transition-colors duration-150 group-hover:fill-amber-600"
                    >
                      {box.value}
                    </text>
                  ) : null}

                  {/* Children boxes (fractions, subsup, etc) */}
                  {box.children &&
                    box.children.map((child) => (
                      <g key={child.id}>
                        {child.glyphPath ? (
                          <path
                            d={child.glyphPath}
                            fill="#0F0F10"
                          />
                        ) : (
                          <text
                            x={child.x}
                            y={child.y}
                            fontSize={child.fontSize}
                            fill="#0F0F10"
                            fontFamily="serif"
                          >
                            {child.value}
                          </text>
                        )}
                      </g>
                    ))}
                </g>
              );
            })}
          </g>
        </svg>

        {/* Canvas Corner Info Overlay */}
        <div className="absolute bottom-3 left-3 bg-[#0F0F10]/90 backdrop-blur px-3 py-1.5 rounded border border-white/10 text-[10px] font-mono text-white/50 flex items-center space-x-3 pointer-events-none uppercase tracking-wider">
          <span>
            Iris Nodes: <strong className="text-amber-400">{layoutBoxes.length}</strong>
          </span>
          <span>
            Canvas Span: <strong className="text-white/80">{totalWidth.toFixed(1)}pt × {totalHeight.toFixed(1)}pt</strong>
          </span>
        </div>
      </div>
    </div>
  );
};
