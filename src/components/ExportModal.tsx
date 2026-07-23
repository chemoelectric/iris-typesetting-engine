import React, { useState } from 'react';
import { Download, X, Copy, Check, FileCode, Image, FileText } from 'lucide-react';
import { LayoutBox, MaxEntEnergyState } from '../types';

interface ExportModalProps {
  isOpen: boolean;
  onClose: () => void;
  layoutBoxes: LayoutBox[];
  totalWidth: number;
  totalHeight: number;
  markup: string;
  energyState: MaxEntEnergyState;
}

export const ExportModal: React.FC<ExportModalProps> = ({
  isOpen,
  onClose,
  layoutBoxes,
  totalWidth,
  totalHeight,
  markup,
  energyState,
}) => {
  const [copied, setCopied] = useState<boolean>(false);
  const [exportType, setExportType] = useState<'svg' | 'png' | 'tex' | 'json'>('svg');

  if (!isOpen) return null;

  // Generate SVG String
  const svgContent = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${Math.ceil(totalWidth + 40)} ${Math.ceil(totalHeight + 40)}" width="${Math.ceil(totalWidth + 40)}pt" height="${Math.ceil(totalHeight + 40)}pt">
  <style>
    .iris-glyph { fill: #0f172a; font-family: serif; }
  </style>
  <g transform="translate(20, ${Math.ceil(totalHeight * 0.7)})">
    ${layoutBoxes
      .map((b) =>
        b.glyphPath
          ? `<path d="${b.glyphPath}" fill="#0f172a" />`
          : `<text x="${b.x}" y="${b.y}" font-size="${b.fontSize}" class="iris-glyph">${b.value || ''}</text>`
      )
      .join('\n    ')}
  </g>
</svg>`;

  // Generate Manifest JSON
  const jsonManifest = JSON.stringify(
    {
      system: 'Iris Typeset Engine',
      version: '1.0.0',
      markup,
      boundingDimensions: { width: totalWidth, height: totalHeight },
      energyState,
      irisNodes: layoutBoxes.map((b) => ({
        id: b.id,
        value: b.value,
        irisCoordinate: b.irisPos.formatted,
        xPt: b.x,
        yPt: b.y,
        widthPt: b.width,
        heightPt: b.height,
        transform: b.transform,
      })),
    },
    null,
    2
  );

  const handleCopy = () => {
    const textToCopy = exportType === 'svg' ? svgContent : exportType === 'tex' ? markup : jsonManifest;
    navigator.clipboard.writeText(textToCopy);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleDownload = () => {
    let content = '';
    let fileName = `iris_typeset_${Date.now()}`;
    let mime = 'text/plain';

    if (exportType === 'svg') {
      content = svgContent;
      fileName += '.svg';
      mime = 'image/svg+xml';
    } else if (exportType === 'tex') {
      content = markup;
      fileName += '.tex';
      mime = 'text/x-tex';
    } else if (exportType === 'json') {
      content = jsonManifest;
      fileName += '.json';
      mime = 'application/json';
    }

    const blob = new Blob([content], { type: mime });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = fileName;
    a.click();
    URL.revokeObjectURL(url);
  };

  return (
    <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
      <div className="bg-[#0F0F10] border border-white/10 rounded-lg w-full max-w-2xl overflow-hidden shadow-2xl flex flex-col max-h-[90vh]">
        {/* Modal Header */}
        <div className="p-4 border-b border-white/10 flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <Download className="w-4 h-4 text-amber-500" />
            <h3 className="text-[10px] uppercase tracking-[0.15em] text-amber-500 font-semibold">
              Export Typeset Artifacts
            </h3>
          </div>
          <button
            onClick={onClose}
            className="p-1 rounded text-white/40 hover:text-white hover:bg-white/10 transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Modal Body */}
        <div className="p-5 space-y-4 overflow-y-auto flex-1">
          {/* Format Tabs */}
          <div className="flex bg-black/40 p-1 rounded border border-white/10">
            <button
              onClick={() => setExportType('svg')}
              className={`flex-1 py-1.5 rounded text-[10px] uppercase tracking-wider font-semibold transition flex items-center justify-center gap-1.5 ${
                exportType === 'svg'
                  ? 'bg-amber-500 text-black shadow'
                  : 'text-white/40 hover:text-white'
              }`}
            >
              <Image className="w-3.5 h-3.5" />
              <span>SVG Vector</span>
            </button>

            <button
              onClick={() => setExportType('tex')}
              className={`flex-1 py-1.5 rounded text-[10px] uppercase tracking-wider font-semibold transition flex items-center justify-center gap-1.5 ${
                exportType === 'tex'
                  ? 'bg-amber-500 text-black shadow'
                  : 'text-white/40 hover:text-white'
              }`}
            >
              <FileCode className="w-3.5 h-3.5" />
              <span>TeX Markup</span>
            </button>

            <button
              onClick={() => setExportType('json')}
              className={`flex-1 py-1.5 rounded text-[10px] uppercase tracking-wider font-semibold transition flex items-center justify-center gap-1.5 ${
                exportType === 'json'
                  ? 'bg-amber-500 text-black shadow'
                  : 'text-white/40 hover:text-white'
              }`}
            >
              <FileText className="w-3.5 h-3.5" />
              <span>Iris Manifest (JSON)</span>
            </button>
          </div>

          {/* Preview Code Box */}
          <div className="space-y-1.5">
            <div className="flex items-center justify-between text-[10px] uppercase tracking-wider text-white/40 font-medium">
              <span>Artifact Output Code:</span>
              <button
                onClick={handleCopy}
                className="flex items-center space-x-1 text-amber-500 hover:text-amber-400 transition"
              >
                {copied ? <Check className="w-3.5 h-3.5 text-amber-400" /> : <Copy className="w-3.5 h-3.5" />}
                <span>{copied ? 'Copied!' : 'Copy to Clipboard'}</span>
              </button>
            </div>
            <textarea
              readOnly
              value={exportType === 'svg' ? svgContent : exportType === 'tex' ? markup : jsonManifest}
              className="w-full h-64 p-3 bg-black/60 border border-white/10 rounded font-mono text-xs text-amber-200/90 focus:outline-none resize-none shadow-inner"
            />
          </div>
        </div>

        {/* Modal Footer */}
        <div className="p-4 bg-black/40 border-t border-white/10 flex items-center justify-between">
          <span className="text-[10px] uppercase tracking-wider text-white/40 font-mono">
            Sub-pixel Iris Vector Precision
          </span>
          <div className="flex items-center space-x-2">
            <button
              onClick={onClose}
              className="px-4 py-2 rounded text-xs font-semibold uppercase tracking-wider text-white/40 hover:text-white hover:bg-white/10 transition"
            >
              Close
            </button>
            <button
              onClick={handleDownload}
              className="flex items-center space-x-1.5 px-4 py-2 rounded bg-amber-500 hover:bg-amber-400 text-black font-semibold text-xs uppercase tracking-wider transition"
            >
              <Download className="w-4 h-4" />
              <span>Download File</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
