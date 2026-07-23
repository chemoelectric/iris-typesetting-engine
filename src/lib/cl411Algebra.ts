/**
 * Cl(4,1,1) Clifford Geometric Algebra Engine
 * Signature: (+1, +1, +1, +1, -1, 0)
 * 4 Euclidean Spatial (e1, e2, e3, e4), 1 Timelike/Depth (e5), 1 Degenerate Null (e6).
 * Provides Rotors, Conformal Dilations, and Null Projective Bivectors for Glyphs.
 */

import { Cl411Transform, Multivector } from '../types';

/**
 * Creates an identity multivector in Cl(4,1,1).
 */
export function createIdentityMultivector(): Multivector {
  return {
    scalar: 1,
    vec: [0, 0, 0, 0, 0, 0],
    bivec: new Array(15).fill(0),
    trivec: new Array(20).fill(0),
    quadvec: new Array(15).fill(0),
    pseudoscalar: 0,
  };
}

/**
 * Default Cl(4,1,1) transform parameters for a layout box.
 */
export function createDefaultTransform(): Cl411Transform {
  return {
    translation: [0, 0, 0],
    rotationRotor: [1, 0, 0, 0], // scalar + e12, e23, e31
    conformalScale: 1.0,
    shear: [0, 0],
    nullWarp: 0,
  };
}

/**
 * Build a 2D/3D Rotor R = cos(theta/2) - sin(theta/2) * (e12 bivector)
 */
export function createRotor(angleRad: number, bivectorPlane: 'e12' | 'e23' | 'e13' = 'e12'): [number, number, number, number] {
  const half = angleRad / 2;
  const c = Math.cos(half);
  const s = Math.sin(half);

  if (bivectorPlane === 'e12') return [c, s, 0, 0];
  if (bivectorPlane === 'e23') return [c, 0, s, 0];
  return [c, 0, 0, s];
}

/**
 * Apply Cl(4,1,1) transform to a 2D point (x, y) with conformal scale & rotor.
 */
export function transformPointCl411(
  x: number,
  y: number,
  t: Cl411Transform
): { x: number; y: number; z: number; opticalScale: number } {
  // 1. Conformal Optical Scaling
  const scale = t.conformalScale;
  let sx = x * scale;
  let sy = y * scale;

  // 2. Shear distortion (e1 e2 bivector shear)
  sx += sy * t.shear[0];
  sy += sx * t.shear[1];

  // 3. Rotor Rotation (in e12 plane)
  const [c, s] = [t.rotationRotor[0], t.rotationRotor[1]];
  // R * v * R^~ in e12 plane
  const rx = sx * (c * c - s * s) - sy * (2 * c * s);
  const ry = sx * (2 * c * s) + sy * (c * c - s * s);

  // 4. Translation
  const fx = rx + t.translation[0];
  const fy = ry + t.translation[1];
  const fz = t.translation[2] + t.nullWarp * (sx * sx + sy * sy) * 0.001;

  // 5. Optical scale adjustment for micro-typography (subscripts vs display)
  // Smaller scale boosts relative stroke weight
  const opticalScale = scale < 0.85 ? scale * 1.08 : scale;

  return { x: fx, y: fy, z: fz, opticalScale };
}

/**
 * Generate SVG transform string from Cl(4,1,1) parameters.
 */
export function cl411ToSvgTransform(
  x: number,
  y: number,
  t: Cl411Transform
): string {
  const angleDeg = (Math.atan2(2 * t.rotationRotor[0] * t.rotationRotor[1], t.rotationRotor[0] * t.rotationRotor[0] - t.rotationRotor[1] * t.rotationRotor[1]) * 180) / Math.PI;
  const s = t.conformalScale;

  return `translate(${x + t.translation[0]}, ${y + t.translation[1]}) rotate(${angleDeg}) scale(${s}) skewX(${t.shear[0] * 15})`;
}

/**
 * Compose two Cl(4,1,1) transformations using geometric multivector product.
 */
export function combineTransforms(parent: Cl411Transform, child: Cl411Transform): Cl411Transform {
  return {
    translation: [
      parent.translation[0] + child.translation[0] * parent.conformalScale,
      parent.translation[1] + child.translation[1] * parent.conformalScale,
      parent.translation[2] + child.translation[2],
    ],
    rotationRotor: [
      parent.rotationRotor[0] * child.rotationRotor[0] - parent.rotationRotor[1] * child.rotationRotor[1],
      parent.rotationRotor[0] * child.rotationRotor[1] + parent.rotationRotor[1] * child.rotationRotor[0],
      0,
      0,
    ],
    conformalScale: parent.conformalScale * child.conformalScale,
    shear: [parent.shear[0] + child.shear[0], parent.shear[1] + child.shear[1]],
    nullWarp: parent.nullWarp + child.nullWarp,
  };
}
