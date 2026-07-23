/**
 * Counting-Iris Number System Engine
 * High-precision multi-scale radial/discrete coordinate mapping.
 * 1 Physical Point = 65,536 Iris micro-units (16-bit sub-pixel precision).
 */

import { IrisCoordinate } from '../types';

export const IRIS_UNITS_PER_PT = 65536;

/**
 * Convert physical X, Y coordinates (in points) into a Counting-Iris Coordinate.
 */
export function ptToIris(x: number, y: number, iota = 4, theta = 0): IrisCoordinate {
  const radius = Math.sqrt(x * x + y * y);
  const phase = theta !== 0 ? theta : Math.atan2(y, x || 1e-9);
  
  // Discrete integer key representation
  const kX = Math.round(x * IRIS_UNITS_PER_PT);
  const kY = Math.round(y * IRIS_UNITS_PER_PT);
  const index = Math.abs(kX ^ (kY << 8));
  
  const hexX = (kX & 0xffff).toString(16).padStart(4, '0');
  const hexY = (kY & 0xffff).toString(16).padStart(4, '0');
  const formatted = `Iris[${iota}.${radius.toFixed(2)}::${index}#${hexX}${hexY}]`;

  return {
    iota,
    radius,
    theta: phase,
    index,
    normalizedX: x,
    normalizedY: y,
    formatted,
  };
}

/**
 * Convert an Iris coordinate back to precise physical points (x, y).
 */
export function irisToPt(iris: IrisCoordinate): { x: number; y: number } {
  if (iris.radius === 0) {
    return { x: iris.normalizedX, y: iris.normalizedY };
  }
  const x = iris.radius * Math.cos(iris.theta);
  const y = iris.radius * Math.sin(iris.theta);
  return { x, y };
}

/**
 * Addition of two Iris coordinates using exact micro-unit integer arithmetic
 * to prevent floating-point drift in nested subscripts/superscripts.
 */
export function addIris(a: IrisCoordinate, b: IrisCoordinate): IrisCoordinate {
  const kXa = Math.round(a.normalizedX * IRIS_UNITS_PER_PT);
  const kYa = Math.round(a.normalizedY * IRIS_UNITS_PER_PT);
  const kXb = Math.round(b.normalizedX * IRIS_UNITS_PER_PT);
  const kYb = Math.round(b.normalizedY * IRIS_UNITS_PER_PT);

  const resX = (kXa + kXb) / IRIS_UNITS_PER_PT;
  const resY = (kYa + kYb) / IRIS_UNITS_PER_PT;

  return ptToIris(resX, resY, Math.max(a.iota, b.iota));
}

/**
 * Sub-pixel distance between two Iris coordinates in points.
 */
export function irisDistance(a: IrisCoordinate, b: IrisCoordinate): number {
  const dx = a.normalizedX - b.normalizedX;
  const dy = a.normalizedY - b.normalizedY;
  return Math.sqrt(dx * dx + dy * dy);
}

/**
 * Scale an Iris coordinate by a factor (useful for optical size scaling).
 */
export function scaleIris(coord: IrisCoordinate, factor: number): IrisCoordinate {
  return ptToIris(
    coord.normalizedX * factor,
    coord.normalizedY * factor,
    coord.iota,
    coord.theta
  );
}
