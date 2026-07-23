import React from 'react';
import { Compass, RotateCw, Scaling, Shield, Sparkles, RefreshCw } from 'lucide-react';
import { Cl411Transform, LayoutBox } from '../types';
import { createDefaultTransform, createRotor } from '../lib/cl411Algebra';

interface Cl411RotorPanelProps {
  transform: Cl411Transform;
  setTransform: (t: Cl411Transform) => void;
  selectedBox: LayoutBox | null;
  onApplyToAll: () => void;
}

export const Cl411RotorPanel: React.FC<Cl411RotorPanelProps> = ({
  transform,
  setTransform,
  selectedBox,
  onApplyToAll,
}) => {
  // Current rotor angle in degrees
  const rotorAngleDeg = Math.round(
    (Math.atan2(
      2 * transform.rotationRotor[0] * transform.rotationRotor[1],
      transform.rotationRotor[0] * transform.rotationRotor[0] -
        transform.rotationRotor[1] * transform.rotationRotor[1]
    ) *
      180) /
      Math.PI
  );

  const handleAngleChange = (deg: number) => {
    const rad = (deg * Math.PI) / 180;
    const rotor = createRotor(rad, 'e12');
    setTransform({
      ...transform,
      rotationRotor: rotor,
    });
  };

  const handleReset = () => {
    setTransform(createDefaultTransform());
  };

  return (
    <div className="flex flex-col h-full bg-[#0F0F10] rounded-lg border border-white/10 p-5 space-y-6 overflow-y-auto">
      {/* Header */}
      <div className="flex items-center justify-between pb-4 border-b border-white/10">
        <div className="flex items-center space-x-3">
          <div className="w-8 h-8 rounded bg-amber-500/10 text-amber-500 border border-amber-500/30 flex items-center justify-center font-bold">
            <Compass className="w-4 h-4" />
          </div>
          <div>
            <h2 className="text-[10px] uppercase tracking-[0.15em] text-amber-500 font-semibold">
              Cl(4,1,1) Clifford Framework
            </h2>
            <p className="text-[10px] uppercase tracking-wider text-white/40">
              Conformal Absolute 3D Space Geometric Algebra Glyph Operators
            </p>
          </div>
        </div>
        <button
          onClick={handleReset}
          className="text-[10px] uppercase tracking-wider text-white/60 hover:text-white transition flex items-center gap-1 bg-white/5 border border-white/10 px-2.5 py-1 rounded"
        >
          <RefreshCw className="w-3 h-3" />
          <span>Reset</span>
        </button>
      </div>

      {/* Multivector Status */}
      <div className="bg-white/5 p-4 rounded border border-white/10 space-y-2">
        <span className="text-[10px] uppercase tracking-wider font-semibold text-amber-500 block">
          Current Cl(4,1,1) Multivector State
        </span>
        <div className="p-3 bg-black/40 rounded border border-white/10 font-mono text-xs text-white/80 space-y-1">
          <div>
            Scalar: <span className="text-amber-400">{transform.rotationRotor[0].toFixed(3)} e₀</span>
          </div>
          <div>
            Bivector e₁₂: <span className="text-amber-300">{transform.rotationRotor[1].toFixed(3)} e₁₂</span>
          </div>
          <div>
            Conformal Dilation: <span className="text-white">σ = {transform.conformalScale.toFixed(3)}</span>
          </div>
          <div>
            Null Degenerate e₆: <span className="text-amber-500">w = {transform.nullWarp.toFixed(3)} e₆</span>
          </div>
        </div>
      </div>

      {/* Interactive Controls */}
      <div className="space-y-4">
        {/* 1. Rotor Angle */}
        <div className="bg-white/5 p-4 rounded border border-white/10 space-y-2">
          <div className="flex items-center justify-between text-xs font-medium text-white/80">
            <span className="flex items-center gap-1.5 text-[10px] uppercase tracking-wider text-white/60">
              <RotateCw className="w-3.5 h-3.5 text-amber-500" />
              e₁₂ Bivector Rotor Angle:
            </span>
            <span className="font-mono text-amber-400 font-bold">{rotorAngleDeg}°</span>
          </div>
          <input
            type="range"
            min="-180"
            max="180"
            value={rotorAngleDeg}
            onChange={(e) => handleAngleChange(Number(e.target.value))}
            className="w-full accent-amber-500 cursor-pointer h-1 rounded bg-white/10"
          />
          <div className="flex justify-between text-[9px] text-white/30 font-mono uppercase">
            <span>-180°</span>
            <span>0°</span>
            <span>+180°</span>
          </div>
        </div>

        {/* 2. Conformal Optical Scale */}
        <div className="bg-white/5 p-4 rounded border border-white/10 space-y-2">
          <div className="flex items-center justify-between text-xs font-medium text-white/80">
            <span className="flex items-center gap-1.5 text-[10px] uppercase tracking-wider text-white/60">
              <Scaling className="w-3.5 h-3.5 text-amber-500" />
              Conformal Optical Scale (σ):
            </span>
            <span className="font-mono text-amber-400 font-bold">
              {transform.conformalScale.toFixed(2)}x
            </span>
          </div>
          <input
            type="range"
            min="0.5"
            max="2.5"
            step="0.05"
            value={transform.conformalScale}
            onChange={(e) =>
              setTransform({
                ...transform,
                conformalScale: Number(e.target.value),
              })
            }
            className="w-full accent-amber-500 cursor-pointer h-1 rounded bg-white/10"
          />
        </div>

        {/* 3. e12 Shear Distortion */}
        <div className="bg-white/5 p-4 rounded border border-white/10 space-y-2">
          <div className="flex items-center justify-between text-xs font-medium text-white/80">
            <span className="text-[10px] uppercase tracking-wider text-white/60">e₁₂ Plane Shear (Slant):</span>
            <span className="font-mono text-amber-400 font-bold">
              {transform.shear[0].toFixed(2)}
            </span>
          </div>
          <input
            type="range"
            min="-0.8"
            max="0.8"
            step="0.05"
            value={transform.shear[0]}
            onChange={(e) =>
              setTransform({
                ...transform,
                shear: [Number(e.target.value), transform.shear[1]],
              })
            }
            className="w-full accent-amber-500 cursor-pointer h-1 rounded bg-white/10"
          />
        </div>

        {/* 4. e6 Null Degenerate Warp */}
        <div className="bg-white/5 p-4 rounded border border-white/10 space-y-2">
          <div className="flex items-center justify-between text-xs font-medium text-white/80">
            <span className="text-[10px] uppercase tracking-wider text-white/60">e₆ Null Degenerate Depth Warp:</span>
            <span className="font-mono text-amber-400 font-bold">
              {transform.nullWarp.toFixed(2)}
            </span>
          </div>
          <input
            type="range"
            min="-5"
            max="5"
            step="0.2"
            value={transform.nullWarp}
            onChange={(e) =>
              setTransform({
                ...transform,
                nullWarp: Number(e.target.value),
              })
            }
            className="w-full accent-amber-500 cursor-pointer h-1 rounded bg-white/10"
          />
        </div>
      </div>

      {/* Target Application Trigger */}
      <div className="p-3 bg-amber-900/10 border border-amber-500/20 rounded space-y-2">
        <span className="text-[10px] text-amber-200/80 uppercase tracking-wider block font-medium">
          Transform Scope Target:
        </span>
        <div className="flex gap-2">
          <button
            onClick={onApplyToAll}
            className="flex-1 py-2 bg-amber-500 hover:bg-amber-400 text-black font-semibold text-xs tracking-wider uppercase rounded transition"
          >
            Apply Rotor to All Document Glyphs
          </button>
        </div>
      </div>
    </div>
  );
};
