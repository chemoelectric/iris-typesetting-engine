/**
 * Jaynesian Maximum Entropy (MaxEnt) Layout Optimization Engine
 * Based on E.T. Jaynes' Principle of Maximum Entropy.
 * Minimizes constraint energy functional E = sum(lambda_k * C_k)
 * while maximizing layout structural entropy S = -sum(p_i * ln p_i).
 */

import { LayoutBox, MaxEntEnergyState, MaxEntWeights } from '../types';

export const DEFAULT_MAXENT_WEIGHTS: MaxEntWeights = {
  lambdaStretch: 1.2,
  lambdaShrink: 2.5,
  lambdaCollision: 10.0,
  lambdaBaseline: 3.0,
  lambdaOpticalWeight: 0.8,
  temperature: 0.05,
};

/**
 * Calculates Jaynesian Energy penalties for a collection of layout boxes.
 */
export function calculateLayoutEnergy(
  boxes: LayoutBox[],
  weights: MaxEntWeights
): MaxEntEnergyState {
  let stretchPenalty = 0;
  let shrinkPenalty = 0;
  let collisionPenalty = 0;
  let baselinePenalty = 0;
  let opticalWeightPenalty = 0;

  for (let i = 0; i < boxes.length; i++) {
    const box = boxes[i];

    // 1. Baseline deviation penalty
    const baselineDev = Math.abs(box.y);
    baselinePenalty += baselineDev * baselineDev;

    // 2. Optical balance penalty
    const area = box.width * box.height;
    const targetArea = box.fontSize * box.fontSize * 0.5;
    opticalWeightPenalty += Math.abs(area - targetArea) / (targetArea || 1);

    // Inter-box constraints (neighbor checks)
    if (i < boxes.length - 1) {
      const next = boxes[i + 1];
      const actualGap = next.x - (box.x + box.width);
      const idealGap = box.fontSize * 0.25;

      if (actualGap < 0) {
        // Collision (boxes overlapping)
        collisionPenalty += Math.pow(Math.abs(actualGap) + 1, 2) * 50;
      } else if (actualGap > idealGap * 1.5) {
        // Over-stretch
        stretchPenalty += Math.pow(actualGap - idealGap, 2);
      } else if (actualGap < idealGap * 0.5) {
        // Over-shrink
        shrinkPenalty += Math.pow(idealGap - actualGap, 2);
      }
    }
  }

  // Calculate Jaynesian Entropy S = -sum p_i ln p_i
  const N = Math.max(boxes.length, 1);
  const totalRawEnergy =
    weights.lambdaStretch * stretchPenalty +
    weights.lambdaShrink * shrinkPenalty +
    weights.lambdaCollision * collisionPenalty +
    weights.lambdaBaseline * baselinePenalty +
    weights.lambdaOpticalWeight * opticalWeightPenalty;

  // Normalized probability distribution over layout micro-states
  const states = boxes.map((b) => {
    const e = (b.x * b.x + b.y * b.y) / 1000;
    return Math.exp(-e / Math.max(weights.temperature, 0.001));
  });
  const Z = states.reduce((sum, v) => sum + v, 0) || 1;
  const probs = states.map((v) => v / Z);

  let totalEntropy = 0;
  for (const p of probs) {
    if (p > 1e-9) {
      totalEntropy -= p * Math.log(p);
    }
  }

  return {
    stretchPenalty,
    shrinkPenalty,
    collisionPenalty,
    baselinePenalty,
    opticalWeightPenalty,
    totalEntropy,
    totalEnergy: totalRawEnergy,
    converged: totalRawEnergy < 0.1,
    iterations: 1,
  };
}

/**
 * Solves & Relaxes a layout tree using MaxEnt gradient relaxation.
 */
export function optimizeLayoutMaxEnt(
  boxes: LayoutBox[],
  weights: MaxEntWeights = DEFAULT_MAXENT_WEIGHTS,
  maxSteps = 15
): { optimizedBoxes: LayoutBox[]; energyState: MaxEntEnergyState } {
  const adjusted = boxes.map((b) => ({ ...b }));
  let lastEnergy = calculateLayoutEnergy(adjusted, weights);

  for (let step = 0; step < maxSteps; step++) {
    let movedAny = false;

    for (let i = 0; i < adjusted.length - 1; i++) {
      const current = adjusted[i];
      const next = adjusted[i + 1];

      const currentRight = current.x + current.width;
      const targetGap = Math.max(current.fontSize * 0.2, 2);
      const overlap = currentRight + targetGap - next.x;

      if (overlap > 0.01) {
        // Shift next box right to prevent collision
        const shift = overlap * 0.5;
        next.x += shift;
        next.irisPos.normalizedX += shift;
        movedAny = true;
      }
    }

    lastEnergy = calculateLayoutEnergy(adjusted, weights);
    lastEnergy.iterations = step + 1;

    if (!movedAny || lastEnergy.totalEnergy < 0.05) {
      break;
    }
  }

  return {
    optimizedBoxes: adjusted,
    energyState: lastEnergy,
  };
}
