/**
 * Google Fonts Automatic Downloader & OpenType Vector Integration Engine
 *
 * Automatically fetches fonts from Google Fonts CDN, extracts raw TTF/OTF binaries,
 * parses vector glyph metrics via opentype.js, registers DOM FontFaces, and updates
 * Fontconfig resolution indices in real time.
 */

import { loadCustomFont } from './openTypeEngine';
import { FontInfo } from '../types';

export interface GoogleFontMetadata {
  family: string;
  category: 'serif' | 'sans-serif' | 'display' | 'monospace' | 'handwriting';
  weights: string[];
  description: string;
  popularFor: string;
  ttfUrl?: string;
}

export const POPULAR_GOOGLE_FONTS: GoogleFontMetadata[] = [
  {
    family: 'Sorts Mill Goudy',
    category: 'serif',
    weights: ['400', '400i'],
    description: "Frederic Goudy's classic revival by Barry Schwartz with Sorts Mill Pegs support.",
    popularFor: 'Fine book typography & classical page layout',
    ttfUrl: 'https://raw.githubusercontent.com/google/fonts/main/ofl/sortsmillgoudy/SortsMillGoudy-Regular.ttf',
  },
  {
    family: 'EB Garamond',
    category: 'serif',
    weights: ['400', '500', '600', '700', '800'],
    description: 'Classical 16th century Claude Garamond revival by Georg Duffner.',
    popularFor: 'Academic papers, literature & classical mathematical typesetting',
    ttfUrl: 'https://raw.githubusercontent.com/google/fonts/main/ofl/ebgaramond/EBGaramond-Regular.ttf',
  },
  {
    family: 'Cormorant Garamond',
    category: 'serif',
    weights: ['300', '400', '500', '600', '700'],
    description: 'High-contrast display serif inspired by Claude Garamond by Christian Thalmann.',
    popularFor: 'Display titling, luxury headers & editorial design',
    ttfUrl: 'https://raw.githubusercontent.com/google/fonts/main/ofl/cormorantgaramond/CormorantGaramond-Regular.ttf',
  },
  {
    family: 'Cinzel',
    category: 'serif',
    weights: ['400', '600', '700', '900'],
    description: 'Classical Roman inscription proportions by Natanael Gama.',
    popularFor: 'Monumental titling & formal inscriptions',
    ttfUrl: 'https://raw.githubusercontent.com/google/fonts/main/ofl/cinzel/Cinzel-Regular.ttf',
  },
  {
    family: 'Playfair Display',
    category: 'serif',
    weights: ['400', '600', '700', '800', '900'],
    description: 'Transitional high-contrast serif inspired by John Baskerville & William Martin.',
    popularFor: 'Magazine covers, headings & elegant branding',
    ttfUrl: 'https://raw.githubusercontent.com/google/fonts/main/ofl/playfairdisplay/PlayfairDisplay-Regular.ttf',
  },
  {
    family: 'Merriweather',
    category: 'serif',
    weights: ['300', '400', '700', '900'],
    description: 'Designed for high legibility on screens with open counters and sturdy serifs.',
    popularFor: 'Long-form digital text & editorial blogs',
    ttfUrl: 'https://raw.githubusercontent.com/google/fonts/main/ofl/merriweather/Merriweather-Regular.ttf',
  },
  {
    family: 'Inter',
    category: 'sans-serif',
    weights: ['300', '400', '500', '600', '700', '800', '900'],
    description: 'Precision geometric sans-serif designed for computer screens by Rasmus Andersson.',
    popularFor: 'Modern UI interfaces, dense dashboards & digital documents',
    ttfUrl: 'https://raw.githubusercontent.com/google/fonts/main/ofl/inter/Inter-Regular.ttf',
  },
  {
    family: 'Roboto',
    category: 'sans-serif',
    weights: ['300', '400', '500', '700', '900'],
    description: 'Neo-grotesque sans-serif with friendly, open curves by Christian Robertson.',
    popularFor: 'Universal interface design & digital publishing',
    ttfUrl: 'https://raw.githubusercontent.com/google/fonts/main/ofl/roboto/Roboto-Regular.ttf',
  },
  {
    family: 'Space Grotesk',
    category: 'sans-serif',
    weights: ['300', '400', '500', '600', '700'],
    description: 'Proportional sans-serif based on Space Mono by Florian Karsten.',
    popularFor: 'Technical, scientific & speculative layout UI',
    ttfUrl: 'https://raw.githubusercontent.com/google/fonts/main/ofl/spacegrotesk/SpaceGrotesk-Regular.ttf',
  },
  {
    family: 'Fira Code',
    category: 'monospace',
    weights: ['300', '400', '500', '600', '700'],
    description: 'Monospaced font containing programming ligatures by Nikita Prokopov.',
    popularFor: 'Code editors, math markup & technical monospace blocks',
    ttfUrl: 'https://raw.githubusercontent.com/google/fonts/main/ofl/firacode/FiraCode-Regular.ttf',
  },
  {
    family: 'JetBrains Mono',
    category: 'monospace',
    weights: ['400', '500', '700', '800'],
    description: 'Monospaced typeface crafted for developer reading ease.',
    popularFor: 'IDE code display & mathematical matrix alignment',
    ttfUrl: 'https://raw.githubusercontent.com/google/fonts/main/ofl/jetbrainsmono/JetBrainsMono-Regular.ttf',
  },
  {
    family: 'Newsreader',
    category: 'serif',
    weights: ['300', '400', '500', '600', '700', '800'],
    description: 'Serif typeface optimized for continuous text reading at micro and macro scales.',
    popularFor: 'Newspapers, articles & longform publication rendering',
    ttfUrl: 'https://raw.githubusercontent.com/google/fonts/main/ofl/newsreader/Newsreader-Regular.ttf',
  },
  {
    family: 'Spectral',
    category: 'serif',
    weights: ['200', '300', '400', '500', '600', '700', '800'],
    description: 'Parametric serif font created by Production Type for screen reading.',
    popularFor: 'Rich text documents & financial reports',
    ttfUrl: 'https://raw.githubusercontent.com/google/fonts/main/ofl/spectral/Spectral-Regular.ttf',
  },
];

// In-memory cache for downloaded Google Font binaries
const downloadedFontCache = new Map<string, { buffer: ArrayBuffer; info: FontInfo }>();

/**
 * Fetch font binary from Google Fonts using direct TTF URL or CSS endpoint extraction.
 */
export async function fetchGoogleFontBinary(
  fontFamily: string,
  weight = '400'
): Promise<{ buffer: ArrayBuffer; info: FontInfo; sourceUrl: string }> {
  const cacheKey = `${fontFamily.toLowerCase()}_${weight}`;

  if (downloadedFontCache.has(cacheKey)) {
    const cached = downloadedFontCache.get(cacheKey)!;
    return {
      buffer: cached.buffer,
      info: cached.info,
      sourceUrl: 'cache',
    };
  }

  // 1. First, try Google Fonts CSS API (v2 and v1) with legacy User-Agents to retrieve gstatic TTF/OTF URL
  let targetUrl: string | undefined;

  const fontNameEncoded = encodeURIComponent(fontFamily);
  const userAgents = [
    // Old Safari/Android triggers TTF format from Google Fonts API
    'Mozilla/5.0 (Linux; U; Android 2.2; en-us; Nexus One Build/FRF91) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1',
    // IE 8 triggers EOT/TTF
    'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0)',
    // Firefox 27 triggers WOFF/TTF
    'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:27.0) Gecko/20100101 Firefox/27.0',
  ];

  const cssEndpoints = [
    `https://fonts.googleapis.com/css2?family=${fontNameEncoded}:wght@${weight}`,
    `https://fonts.googleapis.com/css2?family=${fontNameEncoded}`,
    `https://fonts.googleapis.com/css?family=${fontNameEncoded}`,
  ];

  for (const endpoint of cssEndpoints) {
    if (targetUrl) break;
    for (const ua of userAgents) {
      try {
        const cssRes = await fetch(endpoint, {
          headers: { 'User-Agent': ua },
        });
        if (cssRes.ok) {
          const cssText = await cssRes.text();
          // Match url(...) inside src:
          const matches = cssText.match(/url\((https:\/\/[^)]+)\)/gi);
          if (matches && matches.length > 0) {
            // Pick first URL and strip url() wrapper
            const rawUrl = matches[0].replace(/^url\(['"]?/, '').replace(/['"]?\)$/, '');
            if (rawUrl.startsWith('https://')) {
              targetUrl = rawUrl;
              break;
            }
          }
        }
      } catch (e) {
        // Continue to next endpoint/UA
      }
    }
  }

  // 2. If Google Fonts API didn't return a URL, check preset fallback or GitHub OFL candidate paths
  if (!targetUrl) {
    const preset = POPULAR_GOOGLE_FONTS.find(
      (f) => f.family.toLowerCase() === fontFamily.toLowerCase()
    );
    if (preset?.ttfUrl) {
      targetUrl = preset.ttfUrl;
    }
  }

  if (!targetUrl) {
    const sanitized = fontFamily.toLowerCase().replace(/[^a-z0-9]/g, '');
    const pascal = fontFamily.replace(/\s+/g, '');
    // Common GitHub OFL directory candidate structures
    const candidateUrls = [
      `https://raw.githubusercontent.com/google/fonts/main/ofl/${sanitized}/${pascal}-Regular.ttf`,
      `https://raw.githubusercontent.com/google/fonts/main/ofl/${sanitized}/static/${pascal}-Regular.ttf`,
      `https://raw.githubusercontent.com/google/fonts/main/ofl/${sanitized}/${pascal}%5Bwght%5D.ttf`,
      `https://raw.githubusercontent.com/google/fonts/main/apache/${sanitized}/${pascal}-Regular.ttf`,
      `https://raw.githubusercontent.com/google/fonts/main/uoft/${sanitized}/${pascal}-Regular.ttf`,
    ];

    for (const cand of candidateUrls) {
      try {
        const headRes = await fetch(cand, { method: 'HEAD' });
        if (headRes.ok) {
          targetUrl = cand;
          break;
        }
      } catch (e) {
        // continue
      }
    }
  }

  if (!targetUrl) {
    throw new Error(
      `Could not locate a valid font binary download URL for '${fontFamily}'. Please verify the font family name.`
    );
  }

  // Fetch binary font ArrayBuffer
  const fontRes = await fetch(targetUrl);
  if (!fontRes.ok) {
    throw new Error(
      `Could not download font '${fontFamily}' from Google Fonts (${fontRes.status} ${fontRes.statusText}).`
    );
  }

  const buffer = await fontRes.arrayBuffer();

  // Load into browser DOM FontFace
  try {
    const fontFace = new FontFace(fontFamily, buffer);
    const loadedFace = await fontFace.load();
    document.fonts.add(loadedFace);
  } catch (domErr) {
    console.warn('FontFace DOM registration warning:', domErr);
  }

  // Parse OpenType structure with opentype.js
  const parsed = await loadCustomFont(buffer, `${fontFamily}.ttf`);

  downloadedFontCache.set(cacheKey, {
    buffer,
    info: parsed.info,
  });

  return {
    buffer,
    info: parsed.info,
    sourceUrl: targetUrl,
  };
}
