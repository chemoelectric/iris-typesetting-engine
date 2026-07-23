import React, { useRef, useState } from 'react';
import { Type, Upload, CheckCircle2, FileText, Sparkles, Search } from 'lucide-react';
import { FontInfo } from '../types';
import { getGlyphPath, getKerning } from '../lib/openTypeEngine';

interface FontMetricsPanelProps {
  fontInfo: FontInfo;
  onFontUploaded: (buffer: ArrayBuffer, fileName: string) => void;
}

export const FontMetricsPanel: React.FC<FontMetricsPanelProps> = ({
  fontInfo,
  onFontUploaded,
}) => {
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [testChar1, setTestChar1] = useState<string>('F');
  const [testChar2, setTestChar2] = useState<string>('A');
  const [searchFilter, setSearchFilter] = useState<string>('');

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

        {/* Upload Custom Font Button */}
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
