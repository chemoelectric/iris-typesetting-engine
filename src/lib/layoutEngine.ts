/**
 * Iris Typesetting Layout Engine
 * Converts MathASTNode -> LayoutBox hierarchy with Cl(4,1,1) transforms,
 * OpenType vector glyph metrics, MaxEnt optimization, and Iris coordinates.
 */

import { createDefaultTransform } from './cl411Algebra';

import { ptToIris } from './irisCoordinates';

import { optimizeLayoutMaxEnt } from './maxentSolver';
import { getGlyphPath, getKerning } from './openTypeEngine';
import { LayoutBox, MathASTNode, MaxEntWeights } from '../types';

let layoutBoxIdSeq = 0;
function genBoxId(): string {
  return `box_${++layoutBoxIdSeq}`;
}

export interface LayoutEngineOptions {
  baseFontSize: number; // in pt (e.g. 18pt)
  maxEntWeights?: MaxEntWeights;
  enableMaxEnt?: boolean;
  colorScheme?: 'default' | 'unified' | 'classic';
}

export function layoutMathAST(
  ast: MathASTNode,
  options: LayoutEngineOptions
): { rootBoxes: LayoutBox[]; width: number; height: number; ascent: number; descent: number } {
  layoutBoxIdSeq = 0;

  const baseFontSize = options.baseFontSize || 18;
  const rawBoxes = buildBoxesFromAST(ast, 0, 0, baseFontSize, options);

  // Apply MaxEnt layout optimization if enabled
  let finalBoxes = rawBoxes;
  if (options.enableMaxEnt !== false) {
    const maxEntRes = optimizeLayoutMaxEnt(rawBoxes, options.maxEntWeights);
    finalBoxes = maxEntRes.optimizedBoxes;
  }

  // Calculate overall layout bounding dimensions
  let maxX = 0;
  let maxAscent = baseFontSize * 0.8;
  let maxDescent = baseFontSize * 0.2;

  for (const b of finalBoxes) {
    const right = b.x + b.width;
    if (right > maxX) maxX = right;
    if (b.ascent > maxAscent) maxAscent = b.ascent;
    if (b.descent > maxDescent) maxDescent = b.descent;
  }

  return {
    rootBoxes: finalBoxes,
    width: Math.max(maxX, 10),
    height: maxAscent + maxDescent,
    ascent: maxAscent,
    descent: maxDescent,
  };
}

function buildBoxesFromAST(
  node: MathASTNode,
  startX: number,
  baselineY: number,
  fontSize: number,
  options: LayoutEngineOptions
): LayoutBox[] {
  const boxes: LayoutBox[] = [];
  let currX = startX;

  if (node.type === 'group' && node.children) {
    for (let i = 0; i < node.children.length; i++) {
      const child = node.children[i];

      // Optical Kerning
      if (i > 0 && node.children[i - 1].value && child.value) {
        const kern = getKerning(node.children[i - 1].value!, child.value!, fontSize);
        currX += kern;
      }

      const childBoxes = buildBoxesFromAST(child, currX, baselineY, fontSize, options);
      for (const cb of childBoxes) {
        boxes.push(cb);
        currX = Math.max(currX, cb.x + cb.width);
      }
    }
    return boxes;
  }

  if (node.type === 'text' || node.type === 'symbol') {
    const val = node.value || '';
    const metrics = getGlyphPath(val, fontSize, 0, 0);

    const box: LayoutBox = {
      id: genBoxId(),
      nodeId: node.id,
      type: node.type,
      value: val,
      x: currX,
      y: baselineY,
      width: metrics.width,
      height: metrics.height,
      ascent: metrics.ascent,
      descent: metrics.descent,
      fontSize,
      irisPos: ptToIris(currX, baselineY),
      transform: createDefaultTransform(),
      children: [],
      glyphPath: metrics.pathSvg,
      isOperator: ['=', '+', '-', '×', '÷', '≈', '≠', '≤', '≥', '→', '∈'].includes(val),
    };

    boxes.push(box);
    return boxes;
  }

  if (node.type === 'fraction' && node.numerator && node.denominator) {
    const scriptSize = fontSize * 0.85;
    const numBoxes = buildBoxesFromAST(node.numerator, 0, 0, scriptSize, options);
    const denBoxes = buildBoxesFromAST(node.denominator, 0, 0, scriptSize, options);

    const numWidth = numBoxes.reduce((max, b) => Math.max(max, b.x + b.width), 10);
    const denWidth = denBoxes.reduce((max, b) => Math.max(max, b.x + b.width), 10);
    const fracWidth = Math.max(numWidth, denWidth) + fontSize * 0.4;

    const barThickness = Math.max(fontSize * 0.06, 1.2);
    const numY = baselineY - fontSize * 0.45;
    const denY = baselineY + fontSize * 0.45;

    // Center numerator & denominator
    const numOffsetX = currX + (fracWidth - numWidth) / 2;
    const denOffsetX = currX + (fracWidth - denWidth) / 2;

    const shiftedNum = numBoxes.map((b) => ({
      ...b,
      x: b.x + numOffsetX,
      y: b.y + numY,
      irisPos: ptToIris(b.x + numOffsetX, b.y + numY),
    }));

    const shiftedDen = denBoxes.map((b) => ({
      ...b,
      x: b.x + denOffsetX,
      y: b.y + denY,
      irisPos: ptToIris(b.x + denOffsetX, b.y + denY),
    }));

    // Fraction Bar
    const fracBarBox: LayoutBox = {
      id: genBoxId(),
      nodeId: node.id,
      type: 'symbol',
      value: '—',
      x: currX,
      y: baselineY - barThickness / 2,
      width: fracWidth,
      height: barThickness,
      ascent: barThickness / 2,
      descent: barThickness / 2,
      fontSize,
      irisPos: ptToIris(currX, baselineY),
      transform: createDefaultTransform(),
      children: [],
      glyphPath: `M ${currX} ${baselineY - barThickness / 2} L ${currX + fracWidth} ${baselineY - barThickness / 2}`,
    };

    const fracContainer: LayoutBox = {
      id: genBoxId(),
      nodeId: node.id,
      type: 'fraction',
      x: currX,
      y: baselineY,
      width: fracWidth,
      height: fontSize * 1.6,
      ascent: fontSize * 0.9,
      descent: fontSize * 0.7,
      fontSize,
      irisPos: ptToIris(currX, baselineY),
      transform: createDefaultTransform(),
      children: [fracBarBox, ...shiftedNum, ...shiftedDen],
    };

    boxes.push(fracContainer);
    return boxes;
  }

  if (node.type === 'subsup' && node.nucleus) {
    const nucBoxes = buildBoxesFromAST(node.nucleus, currX, baselineY, fontSize, options);
    const nucWidth = nucBoxes.reduce((max, b) => Math.max(max, b.x + b.width), 10);

    const scriptSize = fontSize * 0.68;
    let subBoxes: LayoutBox[] = [];
    let supBoxes: LayoutBox[] = [];

    const scriptX = currX + nucWidth + fontSize * 0.05;

    if (node.superscript) {
      supBoxes = buildBoxesFromAST(node.superscript, scriptX, baselineY - fontSize * 0.4, scriptSize, options);
    }
    if (node.subscript) {
      subBoxes = buildBoxesFromAST(node.subscript, scriptX, baselineY + fontSize * 0.25, scriptSize, options);
    }

    const scriptWidth = Math.max(
      supBoxes.reduce((max, b) => Math.max(max, b.x + b.width - scriptX), 0),
      subBoxes.reduce((max, b) => Math.max(max, b.x + b.width - scriptX), 0)
    );

    const totalWidth = nucWidth + scriptWidth + fontSize * 0.1;

    boxes.push(...nucBoxes, ...supBoxes, ...subBoxes);
    return boxes;
  }

  if ((node.type === 'integral' || node.type === 'summation') && node.value) {
    const opMetrics = getGlyphPath(node.value, fontSize * 1.5, currX, baselineY);
    const opWidth = opMetrics.width;

    const opBox: LayoutBox = {
      id: genBoxId(),
      nodeId: node.id,
      type: node.type,
      value: node.value,
      x: currX,
      y: baselineY,
      width: opWidth,
      height: opMetrics.height,
      ascent: opMetrics.ascent,
      descent: opMetrics.descent,
      fontSize: fontSize * 1.5,
      irisPos: ptToIris(currX, baselineY),
      transform: createDefaultTransform(),
      children: [],
      glyphPath: opMetrics.pathSvg,
      isOperator: true,
    };

    const scriptSize = fontSize * 0.65;
    let lowerBoxes: LayoutBox[] = [];
    let upperBoxes: LayoutBox[] = [];

    if (node.lowerLimit) {
      lowerBoxes = buildBoxesFromAST(node.lowerLimit, currX, baselineY + fontSize * 0.55, scriptSize, options);
    }
    if (node.upperLimit) {
      upperBoxes = buildBoxesFromAST(node.upperLimit, currX + opWidth * 0.2, baselineY - fontSize * 0.6, scriptSize, options);
    }

    boxes.push(opBox, ...lowerBoxes, ...upperBoxes);
    return boxes;
  }

  if (node.type === 'root' && node.nucleus) {
    const innerBoxes = buildBoxesFromAST(node.nucleus, currX + fontSize * 0.6, baselineY, fontSize, options);
    const innerWidth = innerBoxes.reduce((max, b) => Math.max(max, b.x + b.width - (currX + fontSize * 0.6)), 10);

    const rootSymbolMetrics = getGlyphPath('√', fontSize, currX, baselineY);

    const barY = baselineY - fontSize * 0.75;
    const overbarPath = `M ${currX + fontSize * 0.55} ${barY} L ${currX + fontSize * 0.6 + innerWidth + 2} ${barY}`;

    const rootSymbolBox: LayoutBox = {
      id: genBoxId(),
      nodeId: node.id,
      type: 'symbol',
      value: '√',
      x: currX,
      y: baselineY,
      width: fontSize * 0.6 + innerWidth + 2,
      height: fontSize * 1.2,
      ascent: fontSize * 0.8,
      descent: fontSize * 0.2,
      fontSize,
      irisPos: ptToIris(currX, baselineY),
      transform: createDefaultTransform(),
      children: [],
      glyphPath: `${rootSymbolMetrics.pathSvg} ${overbarPath}`,
    };

    boxes.push(rootSymbolBox, ...innerBoxes);
    return boxes;
  }

  if (node.type === 'matrix' && node.matrixRows) {
    const rowGap = fontSize * 0.8;
    const colGap = fontSize * 0.8;

    let maxCols = 0;
    node.matrixRows.forEach((r) => {
      if (r.length > maxCols) maxCols = r.length;
    });

    const colWidths = new Array(maxCols).fill(0);
    const rowHeights = new Array(node.matrixRows.length).fill(fontSize);

    // Calculate matrix cell dimensions
    const cellBoxesGrid: LayoutBox[][][] = [];

    node.matrixRows.forEach((row, rIdx) => {
      cellBoxesGrid[rIdx] = [];
      row.forEach((cellNode, cIdx) => {
        const cBoxes = buildBoxesFromAST(cellNode, 0, 0, fontSize, options);
        cellBoxesGrid[rIdx][cIdx] = cBoxes;
        const cellW = cBoxes.reduce((m, b) => Math.max(m, b.x + b.width), fontSize * 0.5);
        if (cellW > colWidths[cIdx]) colWidths[cIdx] = cellW;
      });
    });

    const totalMatrixW = colWidths.reduce((sum, w) => sum + w + colGap, 0) - colGap;
    let matrixY = baselineY - (node.matrixRows.length * rowGap) / 2;

    const matrixChildBoxes: LayoutBox[] = [];

    node.matrixRows.forEach((row, rIdx) => {
      let matrixX = currX + fontSize * 0.4;
      row.forEach((_, cIdx) => {
        const cellBoxes = cellBoxesGrid[rIdx][cIdx] || [];
        const colW = colWidths[cIdx];
        const cellW = cellBoxes.reduce((m, b) => Math.max(m, b.x + b.width), 0);
        const cellOffsetX = matrixX + (colW - cellW) / 2; // Center in matrix cell

        cellBoxes.forEach((b) => {
          matrixChildBoxes.push({
            ...b,
            x: b.x + cellOffsetX,
            y: b.y + matrixY,
            irisPos: ptToIris(b.x + cellOffsetX, b.y + matrixY),
          });
        });

        matrixX += colW + colGap;
      });
      matrixY += rowGap;
    });

    // Parentheses/Brackets around matrix
    const bracketMetricsLeft = getGlyphPath('(', fontSize * 1.8, currX, baselineY);
    const bracketMetricsRight = getGlyphPath(')', fontSize * 1.8, currX + totalMatrixW + fontSize * 0.5, baselineY);

    const leftBracketBox: LayoutBox = {
      id: genBoxId(),
      nodeId: node.id,
      type: 'symbol',
      value: '(',
      x: currX,
      y: baselineY,
      width: fontSize * 0.35,
      height: fontSize * 1.8,
      ascent: fontSize * 1.2,
      descent: fontSize * 0.6,
      fontSize: fontSize * 1.8,
      irisPos: ptToIris(currX, baselineY),
      transform: createDefaultTransform(),
      children: [],
      glyphPath: bracketMetricsLeft.pathSvg || `M ${currX + fontSize * 0.25} ${baselineY - fontSize * 1.1} C ${currX} ${baselineY - fontSize * 0.5} ${currX} ${baselineY + fontSize * 0.3} ${currX + fontSize * 0.25} ${baselineY + fontSize * 0.7}`,
    };

    const rightBracketBox: LayoutBox = {
      id: genBoxId(),
      nodeId: node.id,
      type: 'symbol',
      value: ')',
      x: currX + totalMatrixW + fontSize * 0.5,
      y: baselineY,
      width: fontSize * 0.35,
      height: fontSize * 1.8,
      ascent: fontSize * 1.2,
      descent: fontSize * 0.6,
      fontSize: fontSize * 1.8,
      irisPos: ptToIris(currX + totalMatrixW + fontSize * 0.5, baselineY),
      transform: createDefaultTransform(),
      children: [],
      glyphPath: bracketMetricsRight.pathSvg || `M ${currX + totalMatrixW + fontSize * 0.55} ${baselineY - fontSize * 1.1} C ${currX + totalMatrixW + fontSize * 0.8} ${baselineY - fontSize * 0.5} ${currX + totalMatrixW + fontSize * 0.8} ${baselineY + fontSize * 0.3} ${currX + totalMatrixW + fontSize * 0.55} ${baselineY + fontSize * 0.7}`,
    };

    boxes.push(leftBracketBox, ...matrixChildBoxes, rightBracketBox);
    return boxes;
  }

  return boxes;
}
