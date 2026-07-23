import React from 'react';
import {
  Code,
  Sliders,
  Type,
  Zap,
  BookOpen,
  Sparkles,
  RotateCcw,
} from 'lucide-react';
import { DOCUMENT_TEMPLATES } from '../data/templates';
import { LayoutBox } from '../types';

interface DocumentEditorProps {
  markup: string;
  setMarkup: (val: string) => void;
  fontSize: number;
  setFontSize: (size: number) => void;
  enableMaxEnt: boolean;
  setEnableMaxEnt: (enable: boolean) => void;
  selectedTemplateId: string;
  onSelectTemplate: (id: string) => void;
  selectedBox: LayoutBox | null;
}

export const DocumentEditor: React.FC<DocumentEditorProps> = ({
  markup,
  setMarkup,
  fontSize,
  setFontSize,
  enableMaxEnt,
  setEnableMaxEnt,
  selectedTemplateId,
  onSelectTemplate,
  selectedBox,
}) => {
  const insertSymbol = (sym: string) => {
    setMarkup(markup + (markup.endsWith(' ') || markup === '' ? '' : ' ') + sym);
  };

  return (
    <div className="flex flex-col h-full bg-[#0F0F10] rounded-lg border border-white/10 p-5 space-y-5 overflow-y-auto">
      {/* Editor Header */}
      <div className="flex items-center justify-between pb-3 border-b border-white/10">
        <div className="flex items-center space-x-2">
          <Code className="w-4 h-4 text-amber-500" />
          <h2 className="text-[10px] uppercase tracking-[0.15em] text-amber-500 font-semibold">
            Cl(4,1,1) Workspace & Markup
          </h2>
        </div>
        <button
          onClick={() => setMarkup('')}
          className="text-[10px] uppercase tracking-wider text-white/40 hover:text-amber-400 transition flex items-center gap-1"
          title="Clear markup"
        >
          <RotateCcw className="w-3 h-3" />
          <span>Clear</span>
        </button>
      </div>

      {/* Main Textarea Input */}
      <div className="space-y-1.5 flex-1 flex flex-col">
        <label className="text-[9px] uppercase tracking-wider text-white/40 flex items-center justify-between">
          <span>Markup Source (TeX / Iris Math AST)</span>
          <span className="font-mono text-white/30">
            {markup.length} chars
          </span>
        </label>
        <textarea
          value={markup}
          onChange={(e) => setMarkup(e.target.value)}
          placeholder="Enter TeX or Iris math expression, e.g. \frac{\partial \psi}{\partial t} = \hbar^2 ..."
          className="w-full flex-1 min-h-[120px] p-3 rounded bg-white/5 border border-white/10 text-white/90 font-mono text-xs leading-relaxed focus:outline-none focus:border-amber-500/60 resize-none shadow-inner"
        />
      </div>

      {/* Quick Insert Symbol Toolbar */}
      <div className="space-y-1.5">
        <span className="text-[9px] uppercase tracking-wider text-white/40">
          Quick Insert Symbols:
        </span>
        <div className="flex flex-wrap gap-1.5">
          {[
            { label: 'frac', val: '\\frac{a}{b}' },
            { label: 'sqrt', val: '\\sqrt{x}' },
            { label: 'int', val: '\\int_0^\\infty' },
            { label: 'sum', val: '\\sum_{i=1}^n' },
            { label: 'matrix', val: '\\begin{matrix} a & b \\\\ c & d \\end{matrix}' },
            { label: 'ψ', val: '\\psi' },
            { label: 'ℏ', val: '\\hbar' },
            { label: '∂', val: '\\partial' },
            { label: '∇', val: '\\nabla' },
            { label: '∞', val: '\\infty' },
            { label: 'α', val: '\\alpha' },
            { label: 'β', val: '\\beta' },
            { label: 'γ', val: '\\gamma' },
            { label: 'π', val: '\\pi' },
          ].map((sym) => (
            <button
              key={sym.label}
              onClick={() => insertSymbol(sym.val)}
              className="px-2 py-1 bg-white/5 hover:bg-white/10 text-white/80 text-xs font-mono rounded border border-white/10 transition hover:border-amber-500/40"
            >
              {sym.label}
            </button>
          ))}
        </div>
      </div>

      {/* Font & MaxEnt Controls */}
      <div className="bg-white/5 p-3.5 rounded border border-white/10 space-y-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-2 text-xs font-medium text-white/80">
            <Type className="w-3.5 h-3.5 text-amber-500" />
            <span className="text-[10px] uppercase tracking-wider text-white/60">Base Font Size:</span>
          </div>
          <span className="text-xs font-mono text-amber-400 font-bold">
            {fontSize} pt
          </span>
        </div>
        <input
          type="range"
          min="12"
          max="36"
          step="1"
          value={fontSize}
          onChange={(e) => setFontSize(Number(e.target.value))}
          className="w-full accent-amber-500 cursor-pointer h-1 rounded bg-white/10"
        />

        <div className="flex items-center justify-between pt-2 border-t border-white/10">
          <div className="flex items-center space-x-2 text-xs font-medium text-white/80">
            <Zap className="w-3.5 h-3.5 text-amber-500" />
            <span className="text-[10px] uppercase tracking-wider text-white/60">Jaynesian MaxEnt Layout Optimization</span>
          </div>
          <button
            onClick={() => setEnableMaxEnt(!enableMaxEnt)}
            className={`w-8 h-4 rounded-full transition-colors relative ${
              enableMaxEnt ? 'bg-amber-500' : 'bg-white/20'
            }`}
          >
            <span
              className={`absolute top-0.5 left-0.5 w-3 h-3 rounded-full bg-black transition-transform ${
                enableMaxEnt ? 'translate-x-4 bg-black' : 'translate-x-0 bg-white'
              }`}
            />
          </button>
        </div>
      </div>

      {/* Preset Document Templates Grid */}
      <div className="space-y-2">
        <div className="flex items-center space-x-1.5 text-[10px] uppercase tracking-[0.15em] text-amber-500">
          <BookOpen className="w-3.5 h-3.5 text-amber-500" />
          <span>Preset Formula Templates</span>
        </div>
        <div className="grid grid-cols-1 gap-2">
          {DOCUMENT_TEMPLATES.map((tpl) => (
            <div
              key={tpl.id}
              onClick={() => onSelectTemplate(tpl.id)}
              className={`p-3 rounded border cursor-pointer transition-all ${
                selectedTemplateId === tpl.id
                  ? 'bg-amber-900/20 border-amber-500/60 ring-1 ring-amber-500/30'
                  : 'bg-white/5 border-white/10 hover:border-white/20 hover:bg-white/10'
              }`}
            >
              <div className="flex items-center justify-between mb-1">
                <span className="text-xs font-medium text-white/90">
                  {tpl.title}
                </span>
                <span className="text-[9px] uppercase tracking-wider px-1.5 py-0.5 rounded bg-white/10 text-white/50 font-mono">
                  {tpl.category}
                </span>
              </div>
              <p className="text-[11px] text-white/50 leading-relaxed">
                {tpl.description}
              </p>
            </div>
          ))}
        </div>
      </div>

      {/* Selected Box Quick Metrics */}
      {selectedBox && (
        <div className="p-3 bg-amber-900/10 border border-amber-500/20 rounded space-y-1 text-xs">
          <div className="flex items-center space-x-1.5 text-amber-400 font-medium text-[11px] uppercase tracking-wider">
            <Sparkles className="w-3.5 h-3.5" />
            <span>Selected Glyph Node #{selectedBox.id}</span>
          </div>
          <div className="grid grid-cols-2 gap-x-4 gap-y-1 font-mono text-[11px] text-white/70">
            <div>Symbol: {selectedBox.value || 'Container'}</div>
            <div>Width: {selectedBox.width.toFixed(2)}pt</div>
            <div>X: {selectedBox.x.toFixed(2)}pt</div>
            <div>Y: {selectedBox.y.toFixed(2)}pt</div>
            <div className="col-span-2 text-amber-300/80 truncate">
              {selectedBox.irisPos.formatted}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
