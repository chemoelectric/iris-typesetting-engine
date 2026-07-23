import React from 'react';
import { Zap, Flame, BarChart3, Sliders, CheckCircle2, AlertTriangle, RefreshCw } from 'lucide-react';
import { MaxEntEnergyState, MaxEntWeights } from '../types';
import { DEFAULT_MAXENT_WEIGHTS } from '../lib/maxentSolver';

interface MaxEntPanelProps {
  weights: MaxEntWeights;
  setWeights: (w: MaxEntWeights) => void;
  energyState: MaxEntEnergyState;
}

export const MaxEntPanel: React.FC<MaxEntPanelProps> = ({
  weights,
  setWeights,
  energyState,
}) => {
  const handleReset = () => {
    setWeights(DEFAULT_MAXENT_WEIGHTS);
  };

  return (
    <div className="flex flex-col h-full bg-[#0F0F10] rounded-lg border border-white/10 p-5 space-y-6 overflow-y-auto">
      {/* Header */}
      <div className="flex items-center justify-between pb-4 border-b border-white/10">
        <div className="flex items-center space-x-3">
          <div className="w-8 h-8 rounded bg-amber-500/10 text-amber-500 border border-amber-500/30 flex items-center justify-center font-bold">
            <Zap className="w-4 h-4" />
          </div>
          <div>
            <h2 className="text-[10px] uppercase tracking-[0.15em] text-amber-500 font-semibold">
              Jaynesian MaxEnt Layout Engine
            </h2>
            <p className="text-[10px] uppercase tracking-wider text-white/40">
              Maximum Entropy Constraint Relaxation & Energy Minimization
            </p>
          </div>
        </div>
        <button
          onClick={handleReset}
          className="text-[10px] uppercase tracking-wider text-white/60 hover:text-white transition flex items-center gap-1 bg-white/5 border border-white/10 px-2.5 py-1 rounded"
        >
          <RefreshCw className="w-3 h-3" />
          <span>Defaults</span>
        </button>
      </div>

      {/* Energy & Entropy Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
        <div className="bg-white/5 p-4 rounded border border-white/10 space-y-1">
          <span className="text-[10px] uppercase tracking-wider text-white/60 font-medium block flex items-center gap-1">
            <Flame className="w-3.5 h-3.5 text-amber-500" />
            Jaynesian Layout Entropy (S)
          </span>
          <span className="text-2xl font-mono text-amber-400 font-bold block">
            {energyState.totalEntropy.toFixed(4)}
          </span>
          <span className="text-[9px] text-white/30 uppercase tracking-wider block">
            S = -∑ pᵢ ln pᵢ (Structural Diversity)
          </span>
        </div>

        <div className="bg-white/5 p-4 rounded border border-white/10 space-y-1">
          <span className="text-[10px] uppercase tracking-wider text-white/60 font-medium block flex items-center gap-1">
            <BarChart3 className="w-3.5 h-3.5 text-amber-500" />
            Total Constraint Potential (E)
          </span>
          <span className="text-2xl font-mono text-white font-bold block">
            {energyState.totalEnergy.toFixed(3)}
          </span>
          <span className="text-[9px] text-white/40 flex items-center gap-1 uppercase tracking-wider">
            {energyState.converged ? (
              <span className="text-amber-400 flex items-center gap-1 font-semibold">
                <CheckCircle2 className="w-3 h-3" /> MaxEnt Equilibrium
              </span>
            ) : (
              <span className="text-amber-500/80 flex items-center gap-1">
                <AlertTriangle className="w-3 h-3" /> Relaxing... ({energyState.iterations} steps)
              </span>
            )}
          </span>
        </div>
      </div>

      {/* Active Constraint Penalty Breakdown */}
      <div className="bg-white/5 p-4 rounded border border-white/10 space-y-3">
        <span className="text-[10px] uppercase tracking-wider font-semibold text-amber-500 block">
          Active Constraint Penalties Cₖ(x)
        </span>
        <div className="space-y-2">
          {/* Collision */}
          <div className="space-y-1">
            <div className="flex justify-between text-xs font-mono">
              <span className="text-white/60 text-[10px] uppercase tracking-wider">Glyph Collision Penalty</span>
              <span className="text-amber-400">{energyState.collisionPenalty.toFixed(2)}</span>
            </div>
            <div className="w-full bg-black/40 h-1.5 rounded overflow-hidden border border-white/5">
              <div
                className="bg-amber-500 h-full rounded transition-all duration-300"
                style={{ width: `${Math.min(energyState.collisionPenalty * 5, 100)}%` }}
              />
            </div>
          </div>

          {/* Stretch */}
          <div className="space-y-1">
            <div className="flex justify-between text-xs font-mono">
              <span className="text-white/60 text-[10px] uppercase tracking-wider">Inter-glyph Stretch Penalty</span>
              <span className="text-amber-300">{energyState.stretchPenalty.toFixed(2)}</span>
            </div>
            <div className="w-full bg-black/40 h-1.5 rounded overflow-hidden border border-white/5">
              <div
                className="bg-amber-400 h-full rounded transition-all duration-300"
                style={{ width: `${Math.min(energyState.stretchPenalty * 10, 100)}%` }}
              />
            </div>
          </div>

          {/* Baseline */}
          <div className="space-y-1">
            <div className="flex justify-between text-xs font-mono">
              <span className="text-white/60 text-[10px] uppercase tracking-wider">Baseline Alignment Penalty</span>
              <span className="text-white/80">{energyState.baselinePenalty.toFixed(2)}</span>
            </div>
            <div className="w-full bg-black/40 h-1.5 rounded overflow-hidden border border-white/5">
              <div
                className="bg-white/60 h-full rounded transition-all duration-300"
                style={{ width: `${Math.min(energyState.baselinePenalty * 10, 100)}%` }}
              />
            </div>
          </div>

          {/* Optical Weight */}
          <div className="space-y-1">
            <div className="flex justify-between text-xs font-mono">
              <span className="text-white/60 text-[10px] uppercase tracking-wider">Optical Size Harmony Penalty</span>
              <span className="text-amber-200/80">{energyState.opticalWeightPenalty.toFixed(2)}</span>
            </div>
            <div className="w-full bg-black/40 h-1.5 rounded overflow-hidden border border-white/5">
              <div
                className="bg-amber-300/80 h-full rounded transition-all duration-300"
                style={{ width: `${Math.min(energyState.opticalWeightPenalty * 10, 100)}%` }}
              />
            </div>
          </div>
        </div>
      </div>

      {/* Lagrange Multiplier Sliders */}
      <div className="space-y-4">
        <span className="text-[10px] uppercase tracking-[0.15em] font-semibold text-amber-500 block flex items-center gap-1.5">
          <Sliders className="w-3.5 h-3.5 text-amber-500" />
          Jaynesian Lagrange Multipliers (λₖ Weights)
        </span>

        {/* Collision Weight */}
        <div className="bg-white/5 p-3 rounded border border-white/10 space-y-1">
          <div className="flex justify-between text-xs text-white/80 font-medium">
            <span className="text-[10px] uppercase tracking-wider text-white/60">λ₁ Collision / Overlap Boundary:</span>
            <span className="font-mono text-amber-400 font-bold">{weights.lambdaCollision.toFixed(1)}</span>
          </div>
          <input
            type="range"
            min="0"
            max="30"
            step="0.5"
            value={weights.lambdaCollision}
            onChange={(e) => setWeights({ ...weights, lambdaCollision: Number(e.target.value) })}
            className="w-full accent-amber-500 cursor-pointer h-1 rounded bg-white/10"
          />
          <div className="text-[9px] text-white/40 italic">
            Set λ₁ = 0 to permit intentional glyph overlaps for logo design, calligraphic ligatures, or display typography interlock.
          </div>
        </div>

        {/* Stretch Weight */}
        <div className="bg-white/5 p-3 rounded border border-white/10 space-y-1">
          <div className="flex justify-between text-xs text-white/80 font-medium">
            <span className="text-[10px] uppercase tracking-wider text-white/60">λ Stretch (Kerning Tightness):</span>
            <span className="font-mono text-amber-400 font-bold">{weights.lambdaStretch.toFixed(1)}</span>
          </div>
          <input
            type="range"
            min="0.1"
            max="10"
            step="0.2"
            value={weights.lambdaStretch}
            onChange={(e) => setWeights({ ...weights, lambdaStretch: Number(e.target.value) })}
            className="w-full accent-amber-500 cursor-pointer h-1 rounded bg-white/10"
          />
        </div>

        {/* Baseline Weight */}
        <div className="bg-white/5 p-3 rounded border border-white/10 space-y-1">
          <div className="flex justify-between text-xs text-white/80 font-medium">
            <span className="text-[10px] uppercase tracking-wider text-white/60">λ Baseline (Vertical Rigidity):</span>
            <span className="font-mono text-amber-400 font-bold">{weights.lambdaBaseline.toFixed(1)}</span>
          </div>
          <input
            type="range"
            min="0.5"
            max="15"
            step="0.5"
            value={weights.lambdaBaseline}
            onChange={(e) => setWeights({ ...weights, lambdaBaseline: Number(e.target.value) })}
            className="w-full accent-amber-500 cursor-pointer h-1 rounded bg-white/10"
          />
        </div>

        {/* Jaynesian Temperature */}
        <div className="bg-white/5 p-3 rounded border border-white/10 space-y-1">
          <div className="flex justify-between text-xs text-white/80 font-medium">
            <span className="text-[10px] uppercase tracking-wider text-white/60">Jaynes Temperature T (Fluctuations):</span>
            <span className="font-mono text-amber-400 font-bold">{weights.temperature.toFixed(3)}</span>
          </div>
          <input
            type="range"
            min="0.001"
            max="0.2"
            step="0.005"
            value={weights.temperature}
            onChange={(e) => setWeights({ ...weights, temperature: Number(e.target.value) })}
            className="w-full accent-amber-500 cursor-pointer h-1 rounded bg-white/10"
          />
        </div>
      </div>
    </div>
  );
};
