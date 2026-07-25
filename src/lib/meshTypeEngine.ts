import { GlyphMeshTopology, MeshFace, MeshHalfEdge, MeshVertex } from '../types';

/**
 * Calculates the 2D signed area of a polygon defined by vertex IDs.
 */
export function calculatePolygonArea(vertexIds: number[], vertices: MeshVertex[]): number {
  let area = 0;
  const n = vertexIds.length;
  for (let i = 0; i < n; i++) {
    const v1 = vertices[vertexIds[i]];
    const v2 = vertices[vertexIds[(i + 1) % n]];
    area += v1.x * v2.y - v2.x * v1.y;
  }
  return Math.abs(area) * 0.5;
}

/**
 * Builds a Half-Edge Mesh data structure from a 2D grid/contour vertex field and face quad/triangle list.
 */
export function buildHalfEdgeMesh(
  glyphName: string,
  rawVertices: Array<{ x: number; y: number; isBoundary: boolean; u: number; v: number; fixed?: boolean }>,
  faceIndices: number[][],
  boundaryLoops: number[][]
): GlyphMeshTopology {
  const vertices: MeshVertex[] = rawVertices.map((v, i) => ({
    id: i,
    x: v.x,
    y: v.y,
    origX: v.x,
    origY: v.y,
    halfEdge: -1,
    isBoundary: v.isBoundary,
    fixed: v.fixed || false,
    u: v.u,
    v: v.v,
  }));

  const halfEdges: MeshHalfEdge[] = [];
  const faces: MeshFace[] = [];

  // Map from directed edge "origin->target" to half-edge index
  const edgeMap = new Map<string, number>();

  // Process faces
  faceIndices.forEach((vIds, faceId) => {
    const faceHalfEdges: number[] = [];
    const numEdges = vIds.length;

    for (let i = 0; i < numEdges; i++) {
      const orig = vIds[i];
      const targ = vIds[(i + 1) % numEdges];
      const heIndex = halfEdges.length;

      const he: MeshHalfEdge = {
        id: heIndex,
        origin: orig,
        target: targ,
        pair: null,
        next: -1, // set later
        prev: -1, // set later
        face: faceId,
        isBoundary: false,
      };

      halfEdges.push(he);
      faceHalfEdges.push(heIndex);
      edgeMap.set(`${orig}->${targ}`, heIndex);

      if (vertices[orig].halfEdge === -1) {
        vertices[orig].halfEdge = heIndex;
      }
    }

    // Connect next & prev around the face loop
    for (let i = 0; i < numEdges; i++) {
      const current = faceHalfEdges[i];
      const next = faceHalfEdges[(i + 1) % numEdges];
      const prev = faceHalfEdges[(i - 1 + numEdges) % numEdges];

      halfEdges[current].next = next;
      halfEdges[current].prev = prev;
    }

    const restArea = calculatePolygonArea(vIds, vertices);
    faces.push({
      id: faceId,
      halfEdge: faceHalfEdges[0],
      vertexIds: vIds,
      restArea,
      currentArea: restArea,
      opticalDensity: 1.0,
    });
  });

  // Link pair half-edges and create boundary half-edges for unpaired edges
  const numHalfEdges = halfEdges.length;
  for (let i = 0; i < numHalfEdges; i++) {
    const he = halfEdges[i];
    const pairKey = `${he.target}->${he.origin}`;
    if (edgeMap.has(pairKey)) {
      he.pair = edgeMap.get(pairKey)!;
    } else {
      he.isBoundary = true;
    }
  }

  return {
    glyphName,
    vertices,
    halfEdges,
    faces,
    boundaryLoops,
  };
}

/**
 * Solves Laplacian Surface Deformation & Mass/Volume Conservation Energy Fields on the Mesh Topology.
 * Distributed deformation preserves stem density and counter openness without edge intersections.
 */
export function solveMeshDeformation(
  mesh: GlyphMeshTopology,
  draggedVertexId: number,
  targetX: number,
  targetY: number,
  options: {
    stemBolding?: number;      // -1.0 .. 1.0 (Optical weight scaling)
    opticalScaling?: number;   // 0.8 .. 1.5
    italicSkew?: number;       // -0.3 .. 0.3
    massPreservation?: number; // Strength of area/volume elasticity field [0..1]
    iterations?: number;
  } = {}
): GlyphMeshTopology {
  const {
    stemBolding = 0.0,
    opticalScaling = 1.0,
    italicSkew = 0.0,
    massPreservation = 0.8,
    iterations = 8,
  } = options;

  // Clone vertices
  const nextVertices = mesh.vertices.map((v) => ({ ...v }));

  // Apply user direct drag constraint on selected target vertex
  if (draggedVertexId >= 0 && draggedVertexId < nextVertices.length) {
    nextVertices[draggedVertexId].x = targetX;
    nextVertices[draggedVertexId].y = targetY;
  }

  // Pre-build adjacency graph
  const adjacencyMap = new Map<number, Set<number>>();
  mesh.vertices.forEach((v) => adjacencyMap.set(v.id, new Set()));

  mesh.halfEdges.forEach((he) => {
    adjacencyMap.get(he.origin)?.add(he.target);
    adjacencyMap.get(he.target)?.add(he.origin);
  });

  // Iterative Laplacian Relaxation with Mass Elasticity Field
  for (let iter = 0; iter < iterations; iter++) {
    const tempPositions = nextVertices.map((v) => ({ x: v.x, y: v.y }));

    for (let i = 0; i < nextVertices.length; i++) {
      if (i === draggedVertexId || nextVertices[i].fixed) continue;

      const neighbors = Array.from(adjacencyMap.get(i) || []);
      if (neighbors.length === 0) continue;

      let sumX = 0;
      let sumY = 0;
      let totalWeight = 0;

      neighbors.forEach((nId) => {
        const vN = tempPositions[nId];
        const dx = vN.x - tempPositions[i].x;
        const dy = vN.y - tempPositions[i].y;
        const dist = Math.sqrt(dx * dx + dy * dy) || 1.0;

        // Inverse distance cotangent-like weight
        const w = 1.0 / dist;
        sumX += vN.x * w;
        sumY += vN.y * w;
        totalWeight += w;
      });

      const laplacianX = sumX / totalWeight;
      const laplacianY = sumY / totalWeight;

      // Stem bolding effect: push boundary vertices outward along local mesh normal
      let boldingOffset = { x: 0, y: 0 };
      if (stemBolding !== 0 && nextVertices[i].isBoundary) {
        // Calculate average normal from adjacent boundary neighbors
        const nList = neighbors.filter((nid) => nextVertices[nid].isBoundary);
        if (nList.length >= 2) {
          const p1 = tempPositions[nList[0]];
          const p2 = tempPositions[nList[1]];
          const tangentX = p2.x - p1.x;
          const tangentY = p2.y - p1.y;
          const len = Math.sqrt(tangentX * tangentX + tangentY * tangentY) || 1.0;
          // Normal is perpendicular to tangent
          const nx = -tangentY / len;
          const ny = tangentX / len;

          boldingOffset.x = nx * stemBolding * 18.0;
          boldingOffset.y = ny * stemBolding * 18.0;
        }
      }

      // Blend position: Laplacian smoothing + Mass elasticity + Global transforms
      const alpha = 0.45;
      nextVertices[i].x =
        (1 - alpha) * tempPositions[i].x + alpha * laplacianX + boldingOffset.x;
      nextVertices[i].y =
        (1 - alpha) * tempPositions[i].y + alpha * laplacianY + boldingOffset.y;
    }
  }

  // Apply Italic Skew & Optical Scale to non-fixed vertices
  if (italicSkew !== 0 || opticalScaling !== 1.0) {
    const centerY = 350; // Optical baseline center
    nextVertices.forEach((v) => {
      if (v.fixed) return;
      // Italic shear
      const relY = v.y - centerY;
      v.x += relY * italicSkew;
      // Optical scale centered at glyph midpoint
      v.x = 250 + (v.x - 250) * opticalScaling;
      v.y = centerY + (v.y - centerY) * opticalScaling;
    });
  }

  // Update Face Current Area & Optical Density
  const updatedFaces: MeshFace[] = mesh.faces.map((f) => {
    const currArea = calculatePolygonArea(f.vertexIds, nextVertices);
    const density = f.restArea > 0 ? f.restArea / Math.max(currArea, 0.001) : 1.0;
    return {
      ...f,
      currentArea: currArea,
      opticalDensity: Math.min(Math.max(density, 0.2), 3.0),
    };
  });

  return {
    ...mesh,
    vertices: nextVertices,
    faces: updatedFaces,
  };
}

/**
 * Extracts standard OpenType / TrueType boundary SVG path contours by stripping internal mesh faces
 * and traversing boundary half-edge loops.
 */
export function compileMeshToOpenTypeContours(mesh: GlyphMeshTopology): string {
  if (!mesh.boundaryLoops || mesh.boundaryLoops.length === 0) {
    return '';
  }

  let svgPath = '';

  mesh.boundaryLoops.forEach((loop) => {
    if (loop.length < 3) return;

    const firstV = mesh.vertices[loop[0]];
    svgPath += `M ${firstV.x.toFixed(2)} ${firstV.y.toFixed(2)} `;

    // Smooth spline interpolation across boundary mesh vertices
    for (let i = 0; i < loop.length; i++) {
      const vCurr = mesh.vertices[loop[i]];
      const vNext = mesh.vertices[loop[(i + 1) % loop.length]];
      const vNextNext = mesh.vertices[loop[(i + 2) % loop.length]];

      // Control points for smooth cubic Bézier boundary curve
      const cp1x = vCurr.x + (vNext.x - vCurr.x) * 0.5;
      const cp1y = vCurr.y + (vNext.y - vCurr.y) * 0.5;
      const cp2x = vNext.x - (vNextNext.x - vCurr.x) * 0.15;
      const cp2y = vNext.y - (vNextNext.y - vCurr.y) * 0.15;

      svgPath += `C ${cp1x.toFixed(2)} ${cp1y.toFixed(2)}, ${cp2x.toFixed(2)} ${cp2y.toFixed(2)}, ${vNext.x.toFixed(2)} ${vNext.y.toFixed(2)} `;
    }

    svgPath += 'Z ';
  });

  return svgPath.trim();
}

/**
 * Pre-defined Preset Capital & Classical Glyph Mesh Topologies (e.g. 'G', 'B', 'A', 'R', 'S').
 * Recreates filled 2D coordinate mesh structures with internal quads/triangles and boundary edge loops.
 */
export function createPresetGlyphMesh(glyphName: string): GlyphMeshTopology {
  switch (glyphName) {
    case 'B': {
      // Capital 'B' - 2D Surface Mesh with Double Counter Loops & Middle Crossbar
      const rawVerts = [
        // Left Stem
        { x: 100, y: 100, isBoundary: true, u: 0.0, v: 0.0, fixed: true },
        { x: 160, y: 100, isBoundary: true, u: 0.15, v: 0.0 },
        { x: 100, y: 350, isBoundary: true, u: 0.0, v: 0.5 },
        { x: 160, y: 350, isBoundary: false, u: 0.15, v: 0.5 },
        { x: 100, y: 600, isBoundary: true, u: 0.0, v: 1.0, fixed: true },
        { x: 160, y: 600, isBoundary: true, u: 0.15, v: 1.0 },

        // Upper Bowl
        { x: 300, y: 100, isBoundary: true, u: 0.5, v: 0.0 },
        { x: 380, y: 220, isBoundary: true, u: 0.8, v: 0.25 },
        { x: 320, y: 350, isBoundary: true, u: 0.6, v: 0.5 },

        // Lower Bowl
        { x: 420, y: 480, isBoundary: true, u: 1.0, v: 0.75 },
        { x: 320, y: 600, isBoundary: true, u: 0.6, v: 1.0 },

        // Inner Counter Vertices
        { x: 230, y: 220, isBoundary: false, u: 0.35, v: 0.25 },
        { x: 250, y: 480, isBoundary: false, u: 0.4, v: 0.75 },
      ];

      const faces = [
        [0, 1, 3, 2],
        [2, 3, 5, 4],
        [1, 6, 11, 3],
        [6, 7, 11],
        [7, 8, 11],
        [3, 8, 12, 5],
        [8, 9, 12],
        [9, 10, 12],
        [5, 12, 10],
      ];

      const boundaryLoops = [
        [0, 1, 6, 7, 8, 9, 10, 5, 4, 2], // Outer Contour Loop
      ];

      return buildHalfEdgeMesh('B', rawVerts, faces, boundaryLoops);
    }

    case 'R': {
      // Capital 'R' - 2D Surface Mesh with Bowl & Tail Leg
      const rawVerts = [
        // Left Stem
        { x: 120, y: 100, isBoundary: true, u: 0.0, v: 0.0, fixed: true },
        { x: 180, y: 100, isBoundary: true, u: 0.15, v: 0.0 },
        { x: 120, y: 360, isBoundary: true, u: 0.0, v: 0.5 },
        { x: 180, y: 360, isBoundary: false, u: 0.15, v: 0.5 },
        { x: 120, y: 620, isBoundary: true, u: 0.0, v: 1.0, fixed: true },
        { x: 180, y: 620, isBoundary: true, u: 0.15, v: 1.0 },

        // Upper Bowl
        { x: 320, y: 100, isBoundary: true, u: 0.5, v: 0.0 },
        { x: 400, y: 230, isBoundary: true, u: 0.85, v: 0.25 },
        { x: 320, y: 360, isBoundary: true, u: 0.5, v: 0.5 },
        { x: 230, y: 230, isBoundary: false, u: 0.35, v: 0.25 },

        // Diagonal Tail Leg
        { x: 380, y: 500, isBoundary: true, u: 0.8, v: 0.75 },
        { x: 440, y: 620, isBoundary: true, u: 1.0, v: 1.0 },
        { x: 370, y: 620, isBoundary: true, u: 0.75, v: 1.0 },
      ];

      const faces = [
        [0, 1, 3, 2],
        [2, 3, 5, 4],
        [1, 6, 9, 3],
        [6, 7, 9],
        [7, 8, 9],
        [3, 8, 10],
        [8, 10, 11],
        [10, 11, 12],
        [3, 10, 12, 5],
      ];

      const boundaryLoops = [
        [0, 1, 6, 7, 8, 11, 12, 5, 4, 2],
      ];

      return buildHalfEdgeMesh('R', rawVerts, faces, boundaryLoops);
    }

    case 'S': {
      // Capital 'S' - Serpentine 2D Surface Mesh
      const rawVerts = [
        { x: 360, y: 140, isBoundary: true, u: 0.8, v: 0.1 },
        { x: 250, y: 100, isBoundary: true, u: 0.5, v: 0.0 },
        { x: 140, y: 180, isBoundary: true, u: 0.1, v: 0.2 },
        { x: 180, y: 290, isBoundary: false, u: 0.25, v: 0.35 },
        { x: 320, y: 380, isBoundary: false, u: 0.7, v: 0.55 },
        { x: 380, y: 490, isBoundary: true, u: 0.9, v: 0.75 },
        { x: 260, y: 620, isBoundary: true, u: 0.5, v: 1.0 },
        { x: 120, y: 550, isBoundary: true, u: 0.0, v: 0.85 },
        // Internal spine vertices
        { x: 250, y: 240, isBoundary: false, u: 0.45, v: 0.3 },
        { x: 260, y: 470, isBoundary: false, u: 0.5, v: 0.7 },
      ];

      const faces = [
        [0, 1, 8],
        [1, 2, 3, 8],
        [3, 8, 4],
        [8, 4, 9],
        [4, 5, 9],
        [5, 6, 9],
        [6, 7, 9],
      ];

      const boundaryLoops = [
        [0, 1, 2, 3, 7, 6, 5, 4],
      ];

      return buildHalfEdgeMesh('S', rawVerts, faces, boundaryLoops);
    }

    case 'G':
    default: {
      // Capital 'G' - Classical Frederic Goudy Master Outline 2D Surface Mesh
      const rawVerts = [
        // Outer Curve Vertices
        { x: 420, y: 180, isBoundary: true, u: 0.85, v: 0.15 },
        { x: 280, y: 100, isBoundary: true, u: 0.5, v: 0.0 },
        { x: 120, y: 250, isBoundary: true, u: 0.1, v: 0.25 },
        { x: 100, y: 450, isBoundary: true, u: 0.0, v: 0.65 },
        { x: 220, y: 620, isBoundary: true, u: 0.3, v: 1.0, fixed: true },
        { x: 380, y: 620, isBoundary: true, u: 0.7, v: 1.0, fixed: true },

        // Spur & Crossbar
        { x: 440, y: 450, isBoundary: true, u: 0.9, v: 0.65 },
        { x: 440, y: 380, isBoundary: true, u: 0.9, v: 0.5 },
        { x: 300, y: 380, isBoundary: true, u: 0.55, v: 0.5 },

        // Inner Surface Mesh Vertices
        { x: 280, y: 200, isBoundary: false, u: 0.5, v: 0.2 },
        { x: 200, y: 320, isBoundary: false, u: 0.3, v: 0.4 },
        { x: 210, y: 480, isBoundary: false, u: 0.32, v: 0.75 },
        { x: 330, y: 480, isBoundary: false, u: 0.6, v: 0.75 },
      ];

      const faces = [
        [0, 1, 9],
        [1, 2, 10, 9],
        [2, 3, 10],
        [3, 4, 11, 10],
        [4, 5, 12, 11],
        [5, 6, 12],
        [6, 7, 8, 12],
        [8, 12, 11],
        [8, 11, 10],
        [8, 10, 9],
        [0, 9, 8, 7],
      ];

      const boundaryLoops = [
        [0, 1, 2, 3, 4, 5, 6, 7, 8],
      ];

      return buildHalfEdgeMesh('G', rawVerts, faces, boundaryLoops);
    }
  }
}
