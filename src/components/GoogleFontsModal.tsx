import React, { useState } from 'react';
import { Download, Search, Sparkles, X, Check, Globe, RefreshCw, Type, AlertCircle } from 'lucide-react';
import { POPULAR_GOOGLE_FONTS, fetchGoogleFontBinary, GoogleFontMetadata } from '../lib/googleFontsLoader';
import { registerFontInSystemIndex } from '../lib/fontconfigResolver';

interface GoogleFontsModalProps {
  isOpen: boolean;
  onClose: () => void;
  onFontLoaded: (buffer: ArrayBuffer, fileName: string) => void;
  currentFontName: string;
}

export const GoogleFontsModal: React.FC<GoogleFontsModalProps> = ({
  isOpen,
  onClose,
  onFontLoaded,
  currentFontName,
}) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [loadingFont, setLoadingFont] = useState<string | null>(null);
  const [statusMessage, setStatusMessage] = useState<{ type: 'success' | 'error'; msg: string } | null>(null);
  const [customFontInput, setCustomFontInput] = useState('');

  if (!isOpen) return null;

  const filteredFonts = POPULAR_GOOGLE_FONTS.filter((font) => {
    const matchesSearch =
      font.family.toLowerCase().includes(searchQuery.toLowerCase()) ||
      font.description.toLowerCase().includes(searchQuery.toLowerCase()) ||
      font.popularFor.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesCategory = selectedCategory === 'all' || font.category === selectedCategory;

    return matchesSearch && matchesCategory;
  });

  const handleFetchAndLoad = async (family: string) => {
    setLoadingFont(family);
    setStatusMessage(null);

    try {
      const result = await fetchGoogleFontBinary(family);

      // Register with fontconfig index
      registerFontInSystemIndex(
        result.info.familyName,
        result.info.styleName,
        `google-fonts://${family}`,
        result.buffer.byteLength,
        `gf_${family.toLowerCase().replace(/\s+/g, '_')}`
      );

      // Update app state
      onFontLoaded(result.buffer, `${family}.ttf`);

      setStatusMessage({
        type: 'success',
        msg: `Successfully fetched '${family}' from Google Fonts (${(result.buffer.byteLength / 1024).toFixed(1)} KB) & updated OpenType engine!`,
      });
    } catch (err: any) {
      console.error('Failed to fetch Google Font:', err);
      setStatusMessage({
        type: 'error',
        msg: err?.message || `Failed to fetch '${family}' from Google Fonts. Please check internet connection or font name.`,
      });
    } finally {
      setLoadingFont(null);
    }
  };

  const handleCustomFetch = (e: React.FormEvent) => {
    e.preventDefault();
    if (customFontInput.trim()) {
      handleFetchAndLoad(customFontInput.trim());
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm">
      <div className="bg-[#121214] border border-amber-500/30 rounded-xl w-full max-w-4xl max-h-[90vh] flex flex-col shadow-2xl overflow-hidden">
        {/* Header */}
        <div className="flex items-center justify-between p-5 border-b border-white/10 bg-black/40">
          <div className="flex items-center space-x-3">
            <div className="w-9 h-9 rounded-lg bg-amber-500/10 border border-amber-500/30 text-amber-500 flex items-center justify-center">
              <Globe className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-sm font-semibold tracking-wide text-amber-500 uppercase flex items-center gap-2">
                Google Fonts Automatic Loader
                <span className="text-[10px] bg-amber-500/20 text-amber-300 border border-amber-500/40 px-2 py-0.5 rounded-full lowercase font-mono">
                  v2.0 OTF
                </span>
              </h2>
              <p className="text-xs text-white/50">
                Directly download, parse vector metrics, and register Google Fonts into Cl(4,1,1) OpenType engine
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 rounded-lg text-white/40 hover:text-white hover:bg-white/10 transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Status Toast Notification */}
        {statusMessage && (
          <div
            className={`px-5 py-3 border-b flex items-center space-x-2 text-xs font-mono ${
              statusMessage.type === 'success'
                ? 'bg-amber-950/40 border-amber-500/40 text-amber-300'
                : 'bg-red-950/40 border-red-500/40 text-red-300'
            }`}
          >
            {statusMessage.type === 'success' ? (
              <Check className="w-4 h-4 shrink-0 text-amber-400" />
            ) : (
              <AlertCircle className="w-4 h-4 shrink-0 text-red-400" />
            )}
            <span>{statusMessage.msg}</span>
          </div>
        )}

        {/* Controls Bar: Custom Font Fetcher & Filters */}
        <div className="p-5 border-b border-white/10 bg-white/5 space-y-4">
          {/* Custom Any Google Font Direct Fetcher */}
          <form onSubmit={handleCustomFetch} className="flex gap-2">
            <div className="relative flex-1">
              <Type className="w-4 h-4 text-white/40 absolute left-3 top-1/2 -translate-y-1/2" />
              <input
                type="text"
                value={customFontInput}
                onChange={(e) => setCustomFontInput(e.target.value)}
                placeholder="Fetch ANY Google Font family by name (e.g. Montserrat, Caveat, Spectral, Oswald)..."
                className="w-full bg-black/60 border border-white/15 rounded-lg pl-9 pr-3 py-2 text-xs font-mono text-white focus:outline-none focus:border-amber-500"
              />
            </div>
            <button
              type="submit"
              disabled={!customFontInput.trim() || !!loadingFont}
              className="px-4 py-2 bg-amber-500 hover:bg-amber-400 disabled:opacity-50 text-black font-semibold text-xs tracking-wider uppercase rounded-lg transition flex items-center space-x-1.5 shrink-0"
            >
              {loadingFont === customFontInput.trim() ? (
                <RefreshCw className="w-4 h-4 animate-spin text-black" />
              ) : (
                <Download className="w-4 h-4" />
              )}
              <span>Fetch Google Font</span>
            </button>
          </form>

          {/* Search & Category Filter Buttons */}
          <div className="flex flex-col sm:flex-row gap-3 justify-between items-stretch sm:items-center">
            {/* Search filter */}
            <div className="relative flex-1 max-w-md">
              <Search className="w-4 h-4 text-white/40 absolute left-3 top-1/2 -translate-y-1/2" />
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Filter curated Google Fonts library..."
                className="w-full bg-black/40 border border-white/10 rounded-lg pl-9 pr-3 py-1.5 text-xs text-white placeholder:text-white/30 focus:outline-none focus:border-white/30"
              />
            </div>

            {/* Category pills */}
            <div className="flex flex-wrap gap-1.5 text-[10px] font-mono uppercase tracking-wider">
              {['all', 'serif', 'sans-serif', 'monospace', 'display'].map((cat) => (
                <button
                  key={cat}
                  onClick={() => setSelectedCategory(cat)}
                  className={`px-2.5 py-1 rounded border transition ${
                    selectedCategory === cat
                      ? 'bg-amber-500 text-black font-bold border-amber-500'
                      : 'bg-black/40 text-white/60 border-white/10 hover:bg-white/10 hover:text-white'
                  }`}
                >
                  {cat}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Font Cards Grid */}
        <div className="p-5 overflow-y-auto flex-1 grid grid-cols-1 md:grid-cols-2 gap-4">
          {filteredFonts.map((font) => {
            const isActive = currentFontName.toLowerCase() === font.family.toLowerCase();
            const isLoading = loadingFont === font.family;

            return (
              <div
                key={font.family}
                className={`p-4 rounded-xl border transition flex flex-col justify-between space-y-3 ${
                  isActive
                    ? 'bg-amber-950/20 border-amber-500/60 shadow-lg ring-1 ring-amber-500/30'
                    : 'bg-white/5 border-white/10 hover:border-white/20'
                }`}
              >
                <div>
                  <div className="flex items-center justify-between">
                    <h3 className="text-base font-bold text-white tracking-wide">{font.family}</h3>
                    <span className="text-[9px] uppercase tracking-wider font-mono text-amber-400 bg-amber-500/10 px-2 py-0.5 rounded border border-amber-500/20">
                      {font.category}
                    </span>
                  </div>

                  <p className="text-xs text-white/60 mt-1 leading-relaxed">{font.description}</p>
                  
                  <div className="mt-2 text-[10px] text-white/40 font-mono">
                    <span className="text-amber-500/80 font-semibold">Best for: </span>
                    {font.popularFor}
                  </div>
                </div>

                {/* Sample Typography Preview */}
                <div className="p-2.5 bg-black/60 rounded-lg border border-white/10 font-serif">
                  <div className="text-sm text-white/90 truncate font-mono">
                    {"E = m c² + \\frac{\\partial \\psi}{\\partial t}"}
                  </div>
                  <div className="text-[10px] font-sans text-white/40 mt-0.5">
                    The quick brown fox jumps over the lazy dog 0123456789
                  </div>
                </div>

                {/* Action button */}
                <div className="flex items-center justify-between pt-1">
                  <div className="text-[10px] text-white/30 font-mono">
                    Weights: {font.weights.join(', ')}
                  </div>

                  <button
                    onClick={() => handleFetchAndLoad(font.family)}
                    disabled={isLoading}
                    className={`px-3 py-1.5 rounded text-xs font-semibold uppercase tracking-wider transition flex items-center space-x-1.5 ${
                      isActive
                        ? 'bg-amber-500/20 text-amber-300 border border-amber-500/50'
                        : 'bg-amber-500 hover:bg-amber-400 text-black'
                    }`}
                  >
                    {isLoading ? (
                      <>
                        <RefreshCw className="w-3.5 h-3.5 animate-spin" />
                        <span>Fetching...</span>
                      </>
                    ) : isActive ? (
                      <>
                        <Check className="w-3.5 h-3.5 text-amber-400" />
                        <span>Active Font</span>
                      </>
                    ) : (
                      <>
                        <Download className="w-3.5 h-3.5" />
                        <span>Get & Load Font</span>
                      </>
                    )}
                  </button>
                </div>
              </div>
            );
          })}
        </div>

        {/* Footer */}
        <div className="p-4 border-t border-white/10 bg-black/60 flex items-center justify-between text-xs font-mono text-white/40">
          <span className="flex items-center gap-1.5">
            <Sparkles className="w-3.5 h-3.5 text-amber-500" />
            Automatic OpenType glyph vector extraction & webfont registration enabled.
          </span>
          <button
            onClick={onClose}
            className="px-4 py-1.5 rounded bg-white/10 hover:bg-white/20 text-white font-medium transition"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
};
