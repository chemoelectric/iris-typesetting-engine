/**
 * Types for Iris Typesetting System
 * Powered by Counting-Iris, Cl(4,1,1), Jaynesian MaxEnt & OpenType
 */

// --- Counting-Iris Number System ---
export interface IrisCoordinate {
  iota: number;       // Base epoch / scale level
  radius: number;     // Radial / logarithmic distance
  theta: number;      // Phase angle (orientation / baseline inclination)
  index: number;      // Discrete micro-unit index (65536 sub-units = 1 pt)
  normalizedX: number; // Evaluated physical X (pt)
  normalizedY: number; // Evaluated physical Y (pt)
  formatted: string;   // e.g. "Iris[4.1::196608#3a]"
}

// --- Cl(4,1,1) Multivector ---
// Signature: 4 Euclidean spatial (e1, e2, e3, e4), 1 Timelike (e5), 1 Degenerate (e6)
export interface Multivector {
  scalar: number;          // e0 component
  vec: [number, number, number, number, number, number]; // e1..e6
  bivec: number[];         // 15 bivector components (e_ij)
  trivec: number[];        // 20 trivector components
  quadvec: number[];       // 15 quadvector components
  pseudoscalar: number;    // e123456
}

export interface Cl411Transform {
  translation: [number, number, number];
  rotationRotor: [number, number, number, number]; // [scalar, e12, e23, e31]
  conformalScale: number; // Optical scale modifier
  shear: [number, number];
  nullWarp: number; // e6 degenerate space warp
}

// --- Jaynesian MaxEnt Layout ---
export interface MaxEntEnergyState {
  stretchPenalty: number;
  shrinkPenalty: number;
  collisionPenalty: number;
  baselinePenalty: number;
  opticalWeightPenalty: number;
  totalEntropy: number; // S = -sum p_i ln p_i
  totalEnergy: number;  // E = sum lambda_k * C_k
  converged: boolean;
  iterations: number;
}

export interface MaxEntWeights {
  lambdaStretch: number;
  lambdaShrink: number;
  lambdaCollision: number;
  lambdaBaseline: number;
  lambdaOpticalWeight: number;
  temperature: number;
}

// --- OpenType & Glyph Metrics ---
export interface GlyphMetrics {
  glyphId: number;
  name: string;
  unicode?: number;
  advanceWidth: number;
  leftSideBearing: number;
  xMin: number;
  yMin: number;
  xMax: number;
  yMax: number;
  pathSvg: string;
}

export interface FontInfo {
  familyName: string;
  styleName: string;
  unitsPerEm: number;
  ascender: number;
  descender: number;
  xHeight: number;
  capHeight: number;
  isCustomFont: boolean;
  glyphCount: number;
}

// --- Math AST & Layout Box ---
export type MathNodeType =
  | 'text'
  | 'symbol'
  | 'fraction'
  | 'subsup'
  | 'integral'
  | 'summation'
  | 'matrix'
  | 'root'
  | 'group'
  | 'accent';

export interface MathASTNode {
  id: string;
  type: MathNodeType;
  value?: string;
  children?: MathASTNode[];
  nucleus?: MathASTNode;
  subscript?: MathASTNode;
  superscript?: MathASTNode;
  numerator?: MathASTNode;
  denominator?: MathASTNode;
  lowerLimit?: MathASTNode;
  upperLimit?: MathASTNode;
  matrixRows?: MathASTNode[][];
  accentSymbol?: string;
}

export interface LayoutBox {
  id: string;
  nodeId: string;
  type: MathNodeType;
  value?: string;
  x: number; // Physical pt
  y: number; // Physical pt
  width: number;
  height: number;
  ascent: number;
  descent: number;
  fontSize: number;
  irisPos: IrisCoordinate;
  transform: Cl411Transform;
  children: LayoutBox[];
  glyphPath?: string;
  color?: string;
  isOperator?: boolean;
}

// --- Document & Templates ---
export interface DocumentTemplate {
  id: string;
  title: string;
  category: 'Unified Field Theory' | 'Cl(4,1,1) Dynamics' | 'Jaynesian MaxEnt' | 'Microtypography' | 'Tensor & Matrices';
  description: string;
  markup: string;
}

export type ViewTab = 'editor' | 'spiro' | 'iris' | 'cl411' | 'maxent' | 'font' | 'textbook';
