import React, { useState } from 'react';
import { Layers, Plus, ArrowRight, Activity, HelpCircle, CheckCircle2 } from 'lucide-react';
import { LayoutBox } from '../types';
import { addIris, ptToIris, irisToPt, IRIS_UNITS_PER_PT } from '../lib/irisCoordinates';

interface IrisCoordinatePanelProps {
  layoutBoxes: LayoutBox[];
  selectedBox: LayoutBox | null;
}

export const IrisCoordinatePanel: React.FC<IrisCoordinatePanelProps> = ({
  layoutBoxes,
  selectedBox,
}) => {
  // Iris Sandbox state
  const [x1, setX1] = useState<number>(12.5);
  const [y1, setY1] = useState<number>(4.25);
  const [x2, setX2] = useState<number>(8.75);
  const [y2, setY2] = useState<number>(-2.1);

  const iris1 = ptToIris(x1, y1);
  const iris2 = ptToIris(x2, y2);
  const irisSum = addIris(iris1, iris2);
  const evaluatedSumPt = irisToPt(irisSum);

  return (
    <div className="flex flex-col h-full bg-[#0F0F10] rounded-lg border border-white/10 p-5 space-y-6 overflow-y-auto">
      {/* Header */}
      <div className="flex items-center justify-between pb-4 border-b border-white/10">
        <div className="flex items-center space-x-3">
          <div className="w-8 h-8 rounded bg-amber-500/10 text-amber-500 border border-amber-500/30 flex items-center justify-center font-bold">
            <Layers className="w-4 h-4" />
          </div>
          <div>
            <h2 className="text-[10px] uppercase tracking-[0.15em] text-amber-500 font-semibold">
              Counting-Iris Coordinate Engine
            </h2>
            <p className="text-[10px] uppercase tracking-wider text-white/40">
              Multi-scale Logarithmic & Sub-pixel Discrete Manifold
            </p>
          </div>
        </div>
        <div className="text-[9px] font-mono px-2.5 py-1 bg-white/5 text-amber-400 rounded border border-white/10 uppercase tracking-wider">
          1 pt = 65,536 µ
        </div>
      </div>

      {/* Selected Glyph Iris Inspector */}
      <div className="bg-white/5 p-4 rounded border border-white/10 space-y-3">
        <div className="flex items-center justify-between">
          <span className="text-[10px] uppercase tracking-wider text-white/70 font-medium flex items-center gap-1.5">
            <Activity className="w-3.5 h-3.5 text-amber-500" />
            Active Glyph Coordinate Breakdown
          </span>
          <span className="text-[9px] uppercase tracking-wider text-white/30 font-mono">
            {selectedBox ? `Node: #${selectedBox.id}` : 'Select a glyph on canvas'}
          </span>
        </div>

        {selectedBox ? (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3 pt-1">
            <div className="p-3 bg-black/40 rounded border border-white/10 space-y-1">
              <span className="text-[9px] uppercase tracking-wider text-white/40 block">
                Canonical Iris String
              </span>
              <span className="text-xs font-mono text-amber-300 font-bold block truncate">
                {selectedBox.irisPos.formatted}
              </span>
            </div>

            <div className="p-3 bg-black/40 rounded border border-white/10 space-y-1">
              <span className="text-[9px] uppercase tracking-wider text-white/40 block">
                Radial Magnitude (r) & Phase (θ)
              </span>
              <span className="text-xs font-mono text-white/80 font-bold block">
                r: {selectedBox.irisPos.radius.toFixed(4)} pt | θ: {(selectedBox.irisPos.theta * (180 / Math.PI)).toFixed(1)}°
              </span>
            </div>

            <div className="p-3 bg-black/40 rounded border border-white/10 space-y-1">
              <span className="text-[9px] uppercase tracking-wider text-white/40 block">
                Sub-pixel Integer Key (Index)
              </span>
              <span className="text-xs font-mono text-amber-400 font-bold block">
                k = {selectedBox.irisPos.index} (0x{selectedBox.irisPos.index.toString(16)})
              </span>
            </div>

            <div className="p-3 bg-black/40 rounded border border-white/10 space-y-1">
              <span className="text-[9px] uppercase tracking-wider text-white/40 block">
                Scale Tier (ι / Iota)
              </span>
              <span className="text-xs font-mono text-amber-200/80 font-bold block">
                ι = {selectedBox.irisPos.iota}
              </span>
            </div>
          </div>
        ) : (
          <div className="p-5 text-center text-white/40 text-xs italic bg-black/20 rounded border border-dashed border-white/10">
            Click any glyph node on the document canvas to view its exact Counting-Iris coordinate breakdown.
          </div>
        )}
      </div>

      {/* Iris Arithmetic Sandbox */}
      <div className="bg-white/5 p-4 rounded border border-white/10 space-y-4">
        <div className="flex items-center justify-between">
          <span className="text-[10px] uppercase tracking-wider text-white/70 font-medium flex items-center gap-1.5">
            <Plus className="w-3.5 h-3.5 text-amber-500" />
            Exact Iris Vector Addition Sandbox
          </span>
          <span className="text-[9px] uppercase tracking-wider text-white/30 font-mono">
            Zero Floating-Point Drift
          </span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
          {/* Vector A */}
          <div className="p-3 bg-black/40 rounded border border-white/10 space-y-2">
            <span className="text-[10px] uppercase tracking-wider font-bold text-amber-500">Vector A</span>
            <div className="flex gap-2">
              <div className="flex-1">
                <label className="text-[9px] uppercase tracking-wider text-white/40">X1 (pt)</label>
                <input
                  type="number"
                  step="0.01"
                  value={x1}
                  onChange={(e) => setX1(Number(e.target.value))}
                  className="w-full bg-white/5 border border-white/10 rounded px-2 py-1 text-xs font-mono text-white/90 focus:border-amber-500"
                />
              </div>
              <div className="flex-1">
                <label className="text-[9px] uppercase tracking-wider text-white/40">Y1 (pt)</label>
                <input
                  type="number"
                  step="0.01"
                  value={y1}
                  onChange={(e) => setY1(Number(e.target.value))}
                  className="w-full bg-white/5 border border-white/10 rounded px-2 py-1 text-xs font-mono text-white/90 focus:border-amber-500"
                />
              </div>
            </div>
            <div className="text-[10px] font-mono text-white/40 truncate">
              {iris1.formatted}
            </div>
          </div>

          {/* Vector B */}
          <div className="p-3 bg-black/40 rounded border border-white/10 space-y-2">
            <span className="text-[10px] uppercase tracking-wider font-bold text-amber-500">Vector B</span>
            <div className="flex gap-2">
              <div className="flex-1">
                <label className="text-[9px] uppercase tracking-wider text-white/40">X2 (pt)</label>
                <input
                  type="number"
                  step="0.01"
                  value={x2}
                  onChange={(e) => setX2(Number(e.target.value))}
                  className="w-full bg-white/5 border border-white/10 rounded px-2 py-1 text-xs font-mono text-white/90 focus:border-amber-500"
                />
              </div>
              <div className="flex-1">
                <label className="text-[9px] uppercase tracking-wider text-white/40">Y2 (pt)</label>
                <input
                  type="number"
                  step="0.01"
                  value={y2}
                  onChange={(e) => setY2(Number(e.target.value))}
                  className="w-full bg-white/5 border border-white/10 rounded px-2 py-1 text-xs font-mono text-white/90 focus:border-amber-500"
                />
              </div>
            </div>
            <div className="text-[10px] font-mono text-white/40 truncate">
              {iris2.formatted}
            </div>
          </div>
        </div>

        {/* Evaluated Sum */}
        <div className="p-3 bg-amber-900/10 border border-amber-500/30 rounded flex items-center justify-between">
          <div className="space-y-0.5">
            <span className="text-[10px] uppercase tracking-wider font-bold text-amber-400 block">
              Result (A + B in Counting-Iris)
            </span>
            <span className="text-xs font-mono text-white/80 block">
              X = {evaluatedSumPt.x.toFixed(4)} pt | Y = {evaluatedSumPt.y.toFixed(4)} pt
            </span>
            <span className="text-[11px] font-mono text-amber-200/80 block">
              {irisSum.formatted}
            </span>
          </div>
          <CheckCircle2 className="w-5 h-5 text-amber-500 shrink-0" />
        </div>
      </div>

      {/* All Document Iris Nodes List */}
      <div className="space-y-2">
        <h3 className="text-[10px] uppercase tracking-[0.15em] text-amber-500">
          Document Iris Nodes ({layoutBoxes.length} nodes):
        </h3>
        <div className="max-h-48 overflow-y-auto space-y-1.5 pr-1">
          {layoutBoxes.map((box) => (
            <div
              key={box.id}
              className={`p-2 rounded border text-xs font-mono flex items-center justify-between ${
                selectedBox?.id === box.id
                  ? 'bg-amber-900/20 border-amber-500/80 text-amber-200'
                  : 'bg-white/5 border-white/10 text-white/70 hover:border-white/20'
              }`}
            >
              <div className="flex items-center space-x-2 truncate">
                <span className="w-5 font-bold text-amber-400">{box.value || '□'}</span>
                <span className="truncate text-[11px]">{box.irisPos.formatted}</span>
              </div>
              <span className="text-[10px] text-white/40 shrink-0">
                ({box.x.toFixed(1)}, {box.y.toFixed(1)})
              </span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
