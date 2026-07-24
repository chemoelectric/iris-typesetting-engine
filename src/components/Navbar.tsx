import React from 'react';
import {
  Layers,
  Compass,
  Zap,
  Type,
  Code,
  Download,
  BookOpen,
  Sparkles,
  RefreshCw,
  Spline,
  Hammer,
} from 'lucide-react';
import { ViewTab } from '../types';
import { DOCUMENT_TEMPLATES } from '../data/templates';

interface NavbarProps {
  activeTab: ViewTab;
  setActiveTab: (tab: ViewTab) => void;
  selectedTemplateId: string;
  onSelectTemplate: (templateId: string) => void;
  onOpenExport: () => void;
  fontName: string;
  isCustomFont: boolean;
}

export const Navbar: React.FC<NavbarProps> = ({
  activeTab,
  setActiveTab,
  selectedTemplateId,
  onSelectTemplate,
  onOpenExport,
  fontName,
  isCustomFont,
}) => {
  return (
    <header className="bg-[#0F0F10] border-b border-white/10 text-slate-100 px-6 py-3 sticky top-0 z-50 shadow-lg">
      <div className="max-w-7xl mx-auto flex flex-col md:flex-row items-center justify-between gap-3">
        {/* Logo & Brand */}
        <div className="flex items-center space-x-3 w-full md:w-auto justify-between md:justify-start">
          <div className="flex items-center space-x-2.5">
            <div className="w-8 h-8 bg-gradient-to-br from-amber-500 to-orange-700 rounded-sm flex items-center justify-center font-bold text-black text-xs shadow-md">
              CL
            </div>
            <div>
              <div className="flex items-center space-x-2">
                <h1 className="text-lg tracking-widest font-light text-white uppercase">
                  IRIS <span className="font-semibold text-amber-500">TYPESET</span>
                </h1>
                <span className="text-[10px] font-mono px-2 py-0.5 rounded bg-white/5 text-amber-400 border border-white/10 uppercase tracking-wider">
                  4.1.1.0-λ
                </span>
              </div>
              <p className="text-[10px] uppercase tracking-wider text-white/40">
                Jaynesian Precision Typesetting
              </p>
            </div>
          </div>

          {/* Preset Template Selector (Mobile) */}
          <div className="md:hidden">
            <button
              onClick={onOpenExport}
              className="p-2 rounded bg-amber-500 hover:bg-amber-400 text-black text-xs font-bold flex items-center gap-1"
            >
              <Download className="w-4 h-4" />
            </button>
          </div>
        </div>

        {/* View Navigation Tabs */}
        <div className="flex items-center bg-[#050506] p-1 rounded border border-white/10 shadow-inner overflow-x-auto max-w-full">
          <button
            onClick={() => setActiveTab('editor')}
            className={`flex items-center space-x-1.5 px-3 py-1.5 rounded text-[11px] uppercase tracking-[0.15em] font-medium transition-all whitespace-nowrap ${
              activeTab === 'editor'
                ? 'bg-amber-500 text-black font-semibold shadow-sm'
                : 'text-white/40 hover:text-white/90 hover:bg-white/5'
            }`}
          >
            <Code className="w-3.5 h-3.5" />
            <span>Framework</span>
          </button>

          <button
            onClick={() => setActiveTab('spiro')}
            className={`flex items-center space-x-1.5 px-3 py-1.5 rounded text-[11px] uppercase tracking-[0.15em] font-medium transition-all whitespace-nowrap ${
              activeTab === 'spiro'
                ? 'bg-amber-500 text-black font-semibold shadow-sm'
                : 'text-white/40 hover:text-white/90 hover:bg-white/5'
            }`}
          >
            <Spline className="w-3.5 h-3.5" />
            <span>Spiro Lab</span>
          </button>

          <button
            onClick={() => setActiveTab('bernstein')}
            className={`flex items-center space-x-1.5 px-3 py-1.5 rounded text-[11px] uppercase tracking-[0.15em] font-medium transition-all whitespace-nowrap ${
              activeTab === 'bernstein'
                ? 'bg-amber-500 text-black font-semibold shadow-sm'
                : 'text-white/40 hover:text-white/90 hover:bg-white/5'
            }`}
          >
            <Sparkles className="w-3.5 h-3.5" />
            <span>Bernstein Curves</span>
          </button>

          <button
            onClick={() => setActiveTab('punchcutter')}
            className={`flex items-center space-x-1.5 px-3 py-1.5 rounded text-[11px] uppercase tracking-[0.15em] font-medium transition-all whitespace-nowrap ${
              activeTab === 'punchcutter'
                ? 'bg-amber-500 text-black font-semibold shadow-sm'
                : 'text-white/40 hover:text-white/90 hover:bg-white/5'
            }`}
          >
            <Hammer className="w-3.5 h-3.5" />
            <span>Punchcutter</span>
          </button>

          <button
            onClick={() => setActiveTab('iris')}
            className={`flex items-center space-x-1.5 px-3 py-1.5 rounded text-[11px] uppercase tracking-[0.15em] font-medium transition-all whitespace-nowrap ${
              activeTab === 'iris'
                ? 'bg-amber-500 text-black font-semibold shadow-sm'
                : 'text-white/40 hover:text-white/90 hover:bg-white/5'
            }`}
          >
            <Layers className="w-3.5 h-3.5" />
            <span>Counting-Iris</span>
          </button>

          <button
            onClick={() => setActiveTab('cl411')}
            className={`flex items-center space-x-1.5 px-3 py-1.5 rounded text-[11px] uppercase tracking-[0.15em] font-medium transition-all whitespace-nowrap ${
              activeTab === 'cl411'
                ? 'bg-amber-500 text-black font-semibold shadow-sm'
                : 'text-white/40 hover:text-white/90 hover:bg-white/5'
            }`}
          >
            <Compass className="w-3.5 h-3.5" />
            <span>Jaynesian Engine</span>
          </button>

          <button
            onClick={() => setActiveTab('maxent')}
            className={`flex items-center space-x-1.5 px-3 py-1.5 rounded text-[11px] uppercase tracking-[0.15em] font-medium transition-all whitespace-nowrap ${
              activeTab === 'maxent'
                ? 'bg-amber-500 text-black font-semibold shadow-sm'
                : 'text-white/40 hover:text-white/90 hover:bg-white/5'
            }`}
          >
            <Zap className="w-3.5 h-3.5" />
            <span>MaxEnt Optimizer</span>
          </button>

          <button
            onClick={() => setActiveTab('font')}
            className={`flex items-center space-x-1.5 px-3 py-1.5 rounded text-[11px] uppercase tracking-[0.15em] font-medium transition-all whitespace-nowrap ${
              activeTab === 'font'
                ? 'bg-amber-500 text-black font-semibold shadow-sm'
                : 'text-white/40 hover:text-white/90 hover:bg-white/5'
            }`}
          >
            <Type className="w-3.5 h-3.5" />
            <span>OpenType Font</span>
          </button>

          <button
            onClick={() => setActiveTab('textbook')}
            className={`flex items-center space-x-1.5 px-3 py-1.5 rounded text-[11px] uppercase tracking-[0.15em] font-medium transition-all whitespace-nowrap ${
              activeTab === 'textbook'
                ? 'bg-amber-500 text-black font-semibold shadow-sm'
                : 'text-white/40 hover:text-white/90 hover:bg-white/5'
            }`}
          >
            <BookOpen className="w-3.5 h-3.5" />
            <span>Textbook</span>
          </button>
        </div>

        {/* Template Quick Select & Actions */}
        <div className="hidden md:flex items-center space-x-3">
          <div className="flex items-center space-x-2 bg-white/5 px-3 py-1.5 rounded border border-white/10 text-xs text-white/70">
            <span className="text-amber-500/80 font-mono text-[10px] uppercase tracking-wider">Template:</span>
            <select
              value={selectedTemplateId}
              onChange={(e) => onSelectTemplate(e.target.value)}
              className="bg-transparent text-white font-medium focus:outline-none cursor-pointer text-xs"
            >
              {DOCUMENT_TEMPLATES.map((tpl) => (
                <option key={tpl.id} value={tpl.id} className="bg-[#0F0F10] text-white">
                  {tpl.title}
                </option>
              ))}
            </select>
          </div>

          <div className="text-xs px-2.5 py-1 rounded bg-white/5 text-white/70 border border-white/10 flex items-center space-x-1.5">
            <Type className="w-3 h-3 text-amber-500" />
            <span className="font-mono text-[11px] truncate max-w-[120px]">{fontName}</span>
            {isCustomFont && (
              <span className="w-2 h-2 rounded-full bg-amber-500 ring-2 ring-amber-500/20" title="Custom OpenType loaded" />
            )}
          </div>

          <button
            onClick={onOpenExport}
            className="flex items-center space-x-1.5 px-3.5 py-1.5 rounded bg-amber-500 hover:bg-amber-400 text-black font-semibold text-xs tracking-wider uppercase shadow-md transition-all"
          >
            <Download className="w-3.5 h-3.5" />
            <span>Export</span>
          </button>
        </div>
      </div>
    </header>
  );
};
