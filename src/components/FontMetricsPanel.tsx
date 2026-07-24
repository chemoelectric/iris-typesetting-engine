import React, { useRef, useState } from 'react';
import { Type, Upload, CheckCircle2, FileText, Sparkles, Search, AlertTriangle, ShieldCheck, Terminal, Globe, Download, RefreshCw } from 'lucide-react';
import { FontInfo } from '../types';
import { getGlyphPath, getKerning } from '../lib/openTypeEngine';
import { resolveFontWithFontconfig, FontResolutionResult, registerFontInSystemIndex } from '../lib/fontconfigResolver';
import { POPULAR_GOOGLE_FONTS, fetchGoogleFontBinary } from '../lib/googleFontsLoader';

interface FontMetricsPanelProps {
  fontInfo: FontInfo;
  onFontUploaded: (buffer: ArrayBuffer, fileName: string) => void;
  onOpenGoogleFonts?: () => void;
}

export const FontMetricsPanel: React.FC<FontMetricsPanelProps> = ({
  fontInfo,
  onFontUploaded,
  onOpenGoogleFonts,
}) => {
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [testChar1, setTestChar1] = useState<string>('F');
  const [testChar2, setTestChar2] = useState<string>('A');
  const [searchFilter, setSearchFilter] = useState<string>('');

  // Quick Google Fonts state inside panel
  const [gfInput, setGfInput] = useState<string>('');
  const [isFetchingGf, setIsFetchingGf] = useState<boolean>(false);
  const [gfMessage, setGfMessage] = useState<string | null>(null);

  // Fontconfig resolution state
  const [fcQuery, setFcQuery] = useState<string>('FreeSerif');
  const [fcResult, setFcResult] = useState<FontResolutionResult>(() => resolveFontWithFontconfig('FreeSerif'));

  const handleFcQueryChange = (q: string) => {
    setFcQuery(q);
    setFcResult(resolveFontWithFontconfig(q));
  };

  const handleQuickGfFetch = async (fontFamily: string) => {
    setIsFetchingGf(true);
    setGfMessage(null);
    try {
      const res = await fetchGoogleFontBinary(fontFamily);
      registerFontInSystemIndex(
        res.info.familyName,
        res.info.styleName,
        `google-fonts://${fontFamily}`,
        res.buffer.byteLength,
        `gf_${fontFamily.toLowerCase().replace(/\s+/g, '_')}`
      );
      onFontUploaded(res.buffer, `${fontFamily}.ttf`);
      setGfMessage(`Loaded Google Font '${fontFamily}' successfully!`);
    } catch (err: any) {
      setGfMessage(`Failed to fetch Google Font '${fontFamily}'. ${err?.message || ''}`);
    } finally {
      setIsFetchingGf(false);
    }
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (evt) => {
        if (evt.target?.result instanceof ArrayBuffer) {
          onFontUploaded(evt.target.result, file.name);
        }
      };
      reader.readAsArrayBuffer(file);
    }
  };

  const currentKern = getKerning(testChar1, testChar2, 24);

  // Common math & typography glyph set
  const sampleGlyphs = [
    'A', 'B', 'C', 'f', 'x', 'y', 'z', '0', '1', '2', '=', '+', '-',
    '∫', '∑', '√', '∞', '∂', 'π', 'ψ', 'ϕ', 'α', 'β', 'γ', 'ℏ', '∇', '±', '≈', '∈', '→'
  ].filter(g => searchFilter ? g.toLowerCase().includes(searchFilter.toLowerCase()) : true);

  return (
    <div className="flex flex-col h-full bg-[#0F0F10] rounded-lg border border-white/10 p-5 space-y-6 overflow-y-auto">
      {/* Header */}
      <div className="flex items-center justify-between pb-4 border-b border-white/10">
        <div className="flex items-center space-x-3">
          <div className="w-8 h-8 rounded bg-amber-500/10 text-amber-500 border border-amber-500/30 flex items-center justify-center font-bold">
            <Type className="w-4 h-4" />
          </div>
          <div>
            <h2 className="text-[10px] uppercase tracking-[0.15em] text-amber-500 font-semibold">
              OpenType Font & Glyph Inspector
            </h2>
            <p className="text-[10px] uppercase tracking-wider text-white/40">
              Direct OTF/TTF Font File Parsing & MATH Metrics Table
            </p>
          </div>
        </div>

        {/* Actions: Google Fonts & Upload */}
        <div className="flex items-center space-x-2">
          {onOpenGoogleFonts && (
            <button
              onClick={onOpenGoogleFonts}
              className="flex items-center space-x-1.5 px-3 py-1.5 rounded bg-amber-500/20 hover:bg-amber-500/30 text-amber-300 border border-amber-500/40 font-semibold text-xs tracking-wider uppercase transition cursor-pointer"
            >
              <Globe className="w-3.5 h-3.5 text-amber-400" />
              <span>Google Fonts</span>
            </button>
          )}

          <button
            onClick={() => fileInputRef.current?.click()}
            className="flex items-center space-x-1.5 px-3 py-1.5 rounded bg-amber-500 hover:bg-amber-400 text-black font-semibold text-xs tracking-wider uppercase transition"
          >
            <Upload className="w-3.5 h-3.5" />
            <span>Upload Font</span>
          </button>
          <input
            ref={fileInputRef}
            type="file"
            accept=".otf,.ttf,.woff,.woff2"
            onChange={handleFileChange}
            className="hidden"
          />
        </div>
      </div>

      {/* Google Fonts Quick Fetcher Bar */}
      <div className="bg-amber-950/20 border border-amber-500/30 p-4 rounded-lg space-y-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-2 text-amber-400">
            <Globe className="w-4 h-4 text-amber-400" />
            <span className="text-[10px] uppercase tracking-wider font-semibold">
              Automatic Google Fonts Fetcher & Vector Engine
            </span>
          </div>
          <span className="text-[9px] uppercase tracking-wider text-amber-400/80 font-mono">
            Direct TTF Download & OpenType Integration
          </span>
        </div>

        <p className="text-xs text-white/70 leading-relaxed">
          Type any Google Font family name below or click a quick preset to automatically fetch, extract vector glyph metrics, and load it into the Cl(4,1,1) engine.
        </p>

        <form
          onSubmit={(e) => {
            e.preventDefault();
            if (gfInput.trim()) handleQuickGfFetch(gfInput.trim());
          }}
          className="flex gap-2"
        >
          <input
            type="text"
            value={gfInput}
            onChange={(e) => setGfInput(e.target.value)}
            placeholder="Type any Google Font name (e.g. Sorts Mill Goudy, EB Garamond, Cinzel, Inter, Fira Code)..."
            className="flex-1 bg-black/60 border border-amber-500/30 rounded px-3 py-1.5 text-xs font-mono text-white focus:outline-none focus:border-amber-400"
          />
          <button
            type="submit"
            disabled={!gfInput.trim() || isFetchingGf}
            className="px-3.5 py-1.5 rounded bg-amber-500 hover:bg-amber-400 disabled:opacity-50 text-black font-semibold text-xs uppercase tracking-wider transition flex items-center space-x-1.5"
          >
            {isFetchingGf ? (
              <RefreshCw className="w-3.5 h-3.5 animate-spin" />
            ) : (
              <Download className="w-3.5 h-3.5" />
            )}
            <span>Fetch Font</span>
          </button>
        </form>

        {/* Preset Quick Badges */}
        <div className="flex flex-wrap gap-1.5 pt-1">
          <span className="text-[9px] uppercase tracking-wider text-white/40 self-center font-mono mr-1">Presets:</span>
          {['Sorts Mill Goudy', 'EB Garamond', 'Cormorant Garamond', 'Cinzel', 'Playfair Display', 'Inter', 'Fira Code', 'Space Grotesk'].map((f) => (
            <button
              key={f}
              onClick={() => handleQuickGfFetch(f)}
              disabled={isFetchingGf}
              className="text-[10px] px-2 py-0.5 rounded bg-white/5 hover:bg-amber-500/20 text-white/80 hover:text-amber-300 border border-white/10 hover:border-amber-500/40 transition font-mono"
            >
              + {f}
            </button>
          ))}
        </div>

        {gfMessage && (
          <div className="p-2 bg-black/60 rounded border border-amber-500/40 text-xs font-mono text-amber-300">
            {gfMessage}
          </div>
        )}
      </div>

      {/* Font Metadata Grid */}
      <div className="bg-white/5 p-4 rounded border border-white/10 space-y-3">
        <div className="flex items-center justify-between">
          <span className="text-[10px] uppercase tracking-wider text-white/70 font-medium flex items-center gap-1.5">
            <FileText className="w-3.5 h-3.5 text-amber-500" />
            Active Font Metadata
          </span>
          {fontInfo.isCustomFont ? (
            <span className="text-[9px] uppercase tracking-wider text-amber-400 flex items-center gap-1 font-medium bg-amber-950/40 px-2 py-0.5 rounded border border-amber-500/30">
              <CheckCircle2 className="w-3 h-3" /> Custom OTF Active
            </span>
          ) : (
            <span className="text-[9px] uppercase tracking-wider text-white/30 font-mono">
              Built-in OpenType Engine
            </span>
          )}
        </div>

        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 pt-1">
          <div className="p-2.5 bg-black/40 rounded border border-white/10">
            <span className="text-[9px] uppercase tracking-wider text-white/40 block font-medium">Font Family</span>
            <span className="text-xs font-mono text-white/90 font-bold block truncate">
              {fontInfo.familyName}
            </span>
          </div>

          <div className="p-2.5 bg-black/40 rounded border border-white/10">
            <span className="text-[9px] uppercase tracking-wider text-white/40 block font-medium">unitsPerEm</span>
            <span className="text-xs font-mono text-amber-400 font-bold block">
              {fontInfo.unitsPerEm}
            </span>
          </div>

          <div className="p-2.5 bg-black/40 rounded border border-white/10">
            <span className="text-[9px] uppercase tracking-wider text-white/40 block font-medium">Ascender / Descender</span>
            <span className="text-xs font-mono text-white/80 font-bold block">
              +{fontInfo.ascender} / {fontInfo.descender}
            </span>
          </div>

          <div className="p-2.5 bg-black/40 rounded border border-white/10">
            <span className="text-[9px] uppercase tracking-wider text-white/40 block font-medium">xHeight / capHeight</span>
            <span className="text-xs font-mono text-amber-300 font-bold block">
              {fontInfo.xHeight} / {fontInfo.capHeight}
            </span>
          </div>
        </div>
      </div>

      {/* Fontconfig & OpenType Naming System Resolver Inspector */}
      <div className="bg-white/5 p-4 rounded border border-white/10 space-y-4">
        <div className="flex items-center justify-between pb-2 border-b border-white/10">
          <div className="flex items-center space-x-2">
            <Terminal className="w-4 h-4 text-amber-500" />
            <span className="text-[10px] uppercase tracking-wider font-semibold text-amber-500">
              Fontconfig & OpenType Naming Resolver (Ambiguity Verification)
            </span>
          </div>
          <span className="text-[9px] uppercase tracking-wider text-white/40 font-mono">
            R⁷RS / C23 / Fontconfig Protocol
          </span>
        </div>

        <p className="text-xs text-white/70 leading-relaxed">
          Resolves fonts by file name or OpenType naming system via Fontconfig. If Fontconfig returns multiple matching candidate files, the engine verifies byte-identity. If candidate files are <strong>not byte-identical</strong>, an informative ambiguity error is issued and resolution is halted to prevent unintended font selection.
        </p>

        {/* Query Input & Presets */}
        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-wider text-white/40 font-mono block">
            Font Query / Pattern Specifier:
          </label>
          <div className="flex gap-2">
            <input
              type="text"
              value={fcQuery}
              onChange={(e) => handleFcQueryChange(e.target.value)}
              placeholder="e.g. FreeSerif, FreeSerif:style=Regular, Sorts Mill Goudy..."
              className="flex-1 bg-black/50 border border-white/15 rounded px-3 py-1.5 text-xs font-mono text-white focus:outline-none focus:border-amber-500"
            />
            <button
              onClick={() => handleFcQueryChange('FreeSerif')}
              className={`px-2.5 py-1 text-[10px] uppercase tracking-wider font-mono rounded border transition ${
                fcQuery === 'FreeSerif' ? 'bg-amber-500 text-black font-bold border-amber-500' : 'bg-white/5 text-white/70 border-white/10 hover:bg-white/10'
              }`}
            >
              FreeSerif
            </button>
            <button
              onClick={() => handleFcQueryChange('FreeSerif:style=Regular')}
              className={`px-2.5 py-1 text-[10px] uppercase tracking-wider font-mono rounded border transition ${
                fcQuery === 'FreeSerif:style=Regular' ? 'bg-amber-500 text-black font-bold border-amber-500' : 'bg-white/5 text-white/70 border-white/10 hover:bg-white/10'
              }`}
            >
              FreeSerif:style=Regular
            </button>
            <button
              onClick={() => handleFcQueryChange('Mokka')}
              className={`px-2.5 py-1 text-[10px] uppercase tracking-wider font-mono rounded border transition ${
                fcQuery === 'Mokka' ? 'bg-amber-500 text-black font-bold border-amber-500' : 'bg-white/5 text-white/70 border-white/10 hover:bg-white/10'
              }`}
            >
              Mokka (Ambiguous)
            </button>
            <button
              onClick={() => handleFcQueryChange('Mokka:style=Small Caps')}
              className={`px-2.5 py-1 text-[10px] uppercase tracking-wider font-mono rounded border transition ${
                fcQuery === 'Mokka:style=Small Caps' ? 'bg-amber-500 text-black font-bold border-amber-500' : 'bg-white/5 text-white/10 hover:bg-white/10'
              }`}
            >
              Mokka:style=Small Caps
            </button>
            <button
              onClick={() => handleFcQueryChange('Sorts Mill Goudy')}
              className={`px-2.5 py-1 text-[10px] uppercase tracking-wider font-mono rounded border transition ${
                fcQuery === 'Sorts Mill Goudy' ? 'bg-amber-500 text-black font-bold border-amber-500' : 'bg-white/5 text-white/70 border-white/10 hover:bg-white/10'
              }`}
            >
              Sorts Mill Goudy
            </button>
          </div>
        </div>

        {/* Resolution Output Status */}
        {fcResult.isAmbiguous ? (
          <div className="p-3.5 bg-red-950/40 border border-red-500/50 rounded-lg space-y-2">
            <div className="flex items-center space-x-2 text-red-400 font-bold text-xs">
              <AlertTriangle className="w-4 h-4 shrink-0 text-red-400" />
              <span>FONTCONFIG AMBIGUITY ERROR DETECTED</span>
            </div>
            <pre className="p-3 bg-black/80 rounded border border-red-900/50 text-[11px] font-mono text-red-200/90 whitespace-pre-wrap leading-relaxed overflow-x-auto">
              {fcResult.errorMessage}
            </pre>
            <div className="text-[10px] text-red-300/80 font-mono">
              ★ Ambiguity Prevention Guard Active: Operation halted. To proceed, qualify the query with a specific style (e.g. <code>:style=Regular</code>) or file path.
            </div>
          </div>
        ) : fcResult.resolvedPath ? (
          <div className="p-3.5 bg-amber-950/30 border border-amber-500/40 rounded-lg space-y-2">
            <div className="flex items-center space-x-2 text-amber-400 font-bold text-xs">
              <ShieldCheck className="w-4 h-4 text-amber-400 shrink-0" />
              <span>Fontconfig Query Successfully Resolved</span>
            </div>
            <div className="text-xs font-mono text-white/90">
              Resolved File Path: <span className="text-amber-300 font-bold">{fcResult.resolvedPath}</span>
            </div>
            {fcResult.candidates.length > 1 && (
              <div className="text-[10px] text-amber-300/80 font-mono">
                Matched {fcResult.candidates.length} candidate files; verified 100% byte-identity across all candidates.
              </div>
            )}
            <div className="p-2 bg-black/50 rounded border border-white/10 font-mono text-[10px] text-white/60 space-y-1">
              {fcResult.candidates.map((c, i) => (
                <div key={i} className="flex justify-between">
                  <span>- {c.path} ({c.style})</span>
                  <span>{c.byteSize} bytes | hash:{c.hash}</span>
                </div>
              ))}
            </div>
          </div>
        ) : (
          <div className="p-3 bg-black/40 border border-white/10 rounded text-xs font-mono text-white/50">
            {fcResult.errorMessage || 'No font matched query.'}
          </div>
        )}
      </div>

      {/* Kerning Debugger Sandbox */}
      <div className="bg-white/5 p-4 rounded border border-white/10 space-y-3">
        <span className="text-[10px] uppercase tracking-wider font-semibold text-amber-500 block">
          OpenType Kerning Pair Inspector
        </span>

        <div className="flex flex-wrap items-center gap-3">
          <div className="flex items-center space-x-2">
            <span className="text-[10px] uppercase tracking-wider text-white/40 font-mono">Char 1:</span>
            <input
              type="text"
              maxLength={1}
              value={testChar1}
              onChange={(e) => setTestChar1(e.target.value)}
              className="w-10 h-8 bg-black/40 border border-white/10 rounded text-center text-sm font-mono text-white font-bold focus:outline-none focus:border-amber-500"
            />
          </div>

          <div className="flex items-center space-x-2">
            <span className="text-[10px] uppercase tracking-wider text-white/40 font-mono">Char 2:</span>
            <input
              type="text"
              maxLength={1}
              value={testChar2}
              onChange={(e) => setTestChar2(e.target.value)}
              className="w-10 h-8 bg-black/40 border border-white/10 rounded text-center text-sm font-mono text-white font-bold focus:outline-none focus:border-amber-500"
            />
          </div>

          <div className="p-2 bg-black/40 rounded border border-white/10 text-xs font-mono text-amber-300">
            Kerning Offset (at 24pt): <strong className="text-white">{currentKern.toFixed(3)} pt</strong>
          </div>
        </div>
      </div>

      {/* Vector Glyph Grid Explorer */}
      <div className="space-y-3">
        <div className="flex items-center justify-between">
          <span className="text-[10px] uppercase tracking-[0.15em] font-semibold text-amber-500">
            Vector Glyph Outline Explorer:
          </span>
          <div className="relative">
            <Search className="w-3.5 h-3.5 text-white/40 absolute left-2.5 top-2" />
            <input
              type="text"
              placeholder="Search symbol..."
              value={searchFilter}
              onChange={(e) => setSearchFilter(e.target.value)}
              className="pl-8 pr-3 py-1 bg-black/40 border border-white/10 rounded text-xs font-mono text-white focus:outline-none focus:border-amber-500"
            />
          </div>
        </div>

        <div className="grid grid-cols-5 md:grid-cols-10 gap-2">
          {sampleGlyphs.map((glyph) => {
            const metrics = getGlyphPath(glyph, 24, 0, 0);
            return (
              <div
                key={glyph}
                className="p-3 bg-white/5 hover:bg-white/10 border border-white/10 hover:border-amber-500/50 rounded flex flex-col items-center justify-center space-y-1 transition group cursor-pointer"
                title={`Advance width: ${metrics.width.toFixed(2)}pt`}
              >
                <div className="w-8 h-8 flex items-center justify-center">
                  {metrics.pathSvg ? (
                    <svg viewBox={`0 ${-metrics.ascent} ${metrics.width || 24} ${metrics.height || 24}`} className="w-6 h-6 fill-white/80 group-hover:fill-amber-400">
                      <path d={metrics.pathSvg} />
                    </svg>
                  ) : (
                    <span className="text-base font-serif text-white/80 group-hover:text-amber-400">
                      {glyph}
                    </span>
                  )}
                </div>
                <span className="text-[10px] font-mono text-white/40 group-hover:text-white/60">
                  {glyph}
                </span>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};
