/**
 * Fontconfig & OpenType Naming System Resolver Engine
 *
 * Resolves font queries by file name or OpenType family / PostScript naming system.
 * If Fontconfig returns multiple non-identical candidate files, presents an informative
 * ambiguity error message and halts resolution instead of proceeding arbitrarily.
 */

export interface FontCandidate {
  path: string;
  family: string;
  style: string;
  byteSize: number;
  hash: string;
  isIdenticalToOthers?: boolean;
}

export interface FontResolutionResult {
  query: string;
  resolvedPath: string | null;
  candidates: FontCandidate[];
  isAmbiguous: boolean;
  areCandidatesIdentical: boolean;
  errorMessage?: string;
  logs: string[];
}

export class FontconfigAmbiguityError extends Error {
  query: string;
  candidates: FontCandidate[];

  constructor(query: string, candidates: FontCandidate[]) {
    const candidateList = candidates
      .map((c) => `  - ${c.path} (${c.style}) [${c.byteSize} bytes, hash:${c.hash}]`)
      .join('\n');

    const msg =
      `\n======================================================================\n` +
      `FONTCONFIG AMBIGUITY ERROR: Ambiguous OpenType font pattern\n` +
      `======================================================================\n` +
      `Font Query / Specifier: '${query}'\n` +
      `Fontconfig matched ${candidates.length} non-identical candidate font files:\n` +
      `${candidateList}\n` +
      `----------------------------------------------------------------------\n` +
      `Error: The fontconfig specification is ambiguous and resolves to multiple distinct font files.\n` +
      `Action required: Specify a unique OpenType pattern (e.g. '${query}:style=Regular') or an explicit file path.\n` +
      `Operation aborted to prevent unintended font selection.\n` +
      `======================================================================\n`;

    super(msg);
    this.name = 'FontconfigAmbiguityError';
    this.query = query;
    this.candidates = candidates;
  }
}

/**
 * Built-in font database simulating Fontconfig / OpenType naming indices
 */
const SYSTEM_FONT_INDEX: Record<string, FontCandidate[]> = {
  freeserif: [
    { path: '/usr/share/fonts/truetype/freefont/FreeSerifBoldItalic.ttf', family: 'FreeSerif', style: 'Bold Italic', byteSize: 632128, hash: 'a1f8c4e0' },
    { path: '/usr/share/fonts/truetype/freefont/FreeSerif.ttf', family: 'FreeSerif', style: 'Regular', byteSize: 1528340, hash: 'b82d91f4' },
    { path: '/usr/share/fonts/truetype/freefont/FreeSerifBold.ttf', family: 'FreeSerif', style: 'Bold', byteSize: 619100, hash: 'c94e02a1' },
    { path: '/usr/share/fonts/truetype/freefont/FreeSerifItalic.ttf', family: 'FreeSerif', style: 'Italic', byteSize: 606820, hash: 'd37f18b5' },
  ],
  'freeserif:style=regular': [
    { path: '/usr/share/fonts/truetype/freefont/FreeSerif.ttf', family: 'FreeSerif', style: 'Regular', byteSize: 1528340, hash: 'b82d91f4' },
  ],
  'nimbus sans': [
    { path: '/usr/share/fonts/opentype/urw-base35/NimbusSans-BoldItalic.otf', family: 'Nimbus Sans', style: 'Bold Italic', byteSize: 341020, hash: 'e5a109f2' },
    { path: '/usr/share/fonts/opentype/urw-base35/NimbusSansNarrow-Regular.otf', family: 'Nimbus Sans', style: 'Narrow Regular', byteSize: 298410, hash: 'f6b210a3' },
  ],
  'nimbus sans:style=regular': [
    { path: '/usr/share/fonts/opentype/urw-base35/NimbusSansNarrow-Regular.otf', family: 'Nimbus Sans', style: 'Narrow Regular', byteSize: 298410, hash: 'f6b210a3' },
  ],
  'liberation sans': [
    { path: '/usr/share/fonts/truetype/liberation/LiberationSansNarrow-BoldItalic.ttf', family: 'Liberation Sans', style: 'Narrow Bold Italic', byteSize: 248100, hash: 'g7c321b4' },
  ],
  'sorts mill goudy': [
    { path: './public/fonts/SortsMillGoudy-Regular.otf', family: 'Sorts Mill Goudy', style: 'Regular', byteSize: 184500, hash: 'h8d432c5' },
  ],
  'goudy bookletter 1911': [
    { path: './public/fonts/SortsMillGoudy-Regular.otf', family: 'Sorts Mill Goudy', style: 'Regular', byteSize: 184500, hash: 'h8d432c5' },
  ],
  'duplicate test font': [
    { path: '/fonts/primary/DuplicateFont.otf', family: 'Duplicate Test Font', style: 'Regular', byteSize: 120000, hash: 'same_hash_123' },
    { path: '/fonts/secondary/DuplicateFontCopy.otf', family: 'Duplicate Test Font', style: 'Regular', byteSize: 120000, hash: 'same_hash_123' },
  ],
};

/**
 * Resolves a font query string using Fontconfig & OpenType naming system rules.
 *
 * @param query Font file path or OpenType family / pattern name
 * @returns FontResolutionResult containing resolution details or error report
 */
export function resolveFontWithFontconfig(query: string): FontResolutionResult {
  const normalizedQuery = query.trim();
  const lowerQuery = normalizedQuery.toLowerCase();
  const logs: string[] = [];

  logs.push(`[Fontconfig] Initiating resolution for query: '${normalizedQuery}'`);

  // Direct file path match
  if (normalizedQuery.startsWith('/') || normalizedQuery.startsWith('./') || normalizedQuery.endsWith('.otf') || normalizedQuery.endsWith('.ttf')) {
    logs.push(`[Fontconfig] Direct file path pattern detected: '${normalizedQuery}'`);
    return {
      query: normalizedQuery,
      resolvedPath: normalizedQuery,
      candidates: [{
        path: normalizedQuery,
        family: normalizedQuery.replace(/^.*[\\/]/, '').replace(/\.[^/.]+$/, ''),
        style: 'Direct File',
        byteSize: 184500,
        hash: 'direct_file_hash',
      }],
      isAmbiguous: false,
      areCandidatesIdentical: true,
      logs,
    };
  }

  // Lookup in Fontconfig system index
  const candidates = SYSTEM_FONT_INDEX[lowerQuery] || [];

  if (candidates.length === 0) {
    logs.push(`[Fontconfig Error] No matching font files found for query '${normalizedQuery}'`);
    return {
      query: normalizedQuery,
      resolvedPath: null,
      candidates: [],
      isAmbiguous: false,
      areCandidatesIdentical: false,
      errorMessage: `Fontconfig Error: No font file or OpenType family matching '${normalizedQuery}' was found.`,
      logs,
    };
  }

  if (candidates.length === 1) {
    logs.push(`[Fontconfig] Unique match found: '${candidates[0].path}'`);
    return {
      query: normalizedQuery,
      resolvedPath: candidates[0].path,
      candidates,
      isAmbiguous: false,
      areCandidatesIdentical: true,
      logs,
    };
  }

  // Multiple candidate font files matched
  logs.push(`[Fontconfig] Pattern matched ${candidates.length} candidate files. Verifying byte-identity...`);

  const firstHash = candidates[0].hash;
  const areCandidatesIdentical = candidates.every((c) => c.hash === firstHash);

  if (areCandidatesIdentical) {
    logs.push(`[Fontconfig Notice] All ${candidates.length} candidate files are byte-identical. Proceeding with '${candidates[0].path}'`);
    return {
      query: normalizedQuery,
      resolvedPath: candidates[0].path,
      candidates,
      isAmbiguous: false,
      areCandidatesIdentical: true,
      logs,
    };
  }

  // Candidates are NOT byte-identical -> Ambiguity error!
  logs.push(`[Fontconfig Ambiguity Error] ${candidates.length} non-identical candidate files matched. Operation aborted.`);
  
  const err = new FontconfigAmbiguityError(normalizedQuery, candidates);

  return {
    query: normalizedQuery,
    resolvedPath: null,
    candidates,
    isAmbiguous: true,
    areCandidatesIdentical: false,
    errorMessage: err.message,
    logs,
  };
}
