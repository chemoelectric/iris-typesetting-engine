import React, { useState, useMemo } from 'react';
import { ViewTab, LayoutBox, MaxEntWeights, Cl411Transform, FontInfo } from './types';
import { DOCUMENT_TEMPLATES } from './data/templates';
import { parseMathMarkup } from './lib/mathParser';
import { layoutMathAST } from './lib/layoutEngine';
import { calculateLayoutEnergy, DEFAULT_MAXENT_WEIGHTS } from './lib/maxentSolver';
import { createDefaultTransform } from './lib/cl411Algebra';
import { loadCustomFont, getActiveFontInfo } from './lib/openTypeEngine';

import { Navbar } from './components/Navbar';
import { TypesetCanvas } from './components/TypesetCanvas';
import { DocumentEditor } from './components/DocumentEditor';
import { IrisCoordinatePanel } from './components/IrisCoordinatePanel';
import { Cl411RotorPanel } from './components/Cl411RotorPanel';
import { MaxEntPanel } from './components/MaxEntPanel';
import { FontMetricsPanel } from './components/FontMetricsPanel';
import { TextbookPanel } from './components/TextbookPanel';
import { SpiroWorkbench } from './components/SpiroWorkbench';
import { BernsteinSplineWorkbench } from './components/BernsteinSplineWorkbench';
import { PunchcutterWorkbench } from './components/PunchcutterWorkbench';
import { ExportModal } from './components/ExportModal';

export default function App() {
  const [activeTab, setActiveTab] = useState<ViewTab>('editor');
  const [selectedTemplateId, setSelectedTemplateId] = useState<string>('cl411_unified_field');
  const [markup, setMarkup] = useState<string>(DOCUMENT_TEMPLATES[0].markup);

  const [fontSize, setFontSize] = useState<number>(20);
  const [enableMaxEnt, setEnableMaxEnt] = useState<boolean>(true);
  const [maxEntWeights, setMaxEntWeights] = useState<MaxEntWeights>(DEFAULT_MAXENT_WEIGHTS);
  const [cl411Transform, setCl411Transform] = useState<Cl411Transform>(createDefaultTransform());

  const [fontInfo, setFontInfo] = useState<FontInfo>(getActiveFontInfo());
  const [selectedBox, setSelectedBox] = useState<LayoutBox | null>(null);
  const [isExportOpen, setIsExportOpen] = useState<boolean>(false);

  // Overlay Toggles
  const [showIrisGrid, setShowIrisGrid] = useState<boolean>(true);
  const [showCl411Frame, setShowCl411Frame] = useState<boolean>(false);
  const [showMaxEntHeatmap, setShowMaxEntHeatmap] = useState<boolean>(false);
  const [showBaselineGrid, setShowBaselineGrid] = useState<boolean>(true);
  const [showBoundingBoxes, setShowBoundingBoxes] = useState<boolean>(true);

  // Template change handler
  const handleSelectTemplate = (templateId: string) => {
    setSelectedTemplateId(templateId);
    const tpl = DOCUMENT_TEMPLATES.find((t) => t.id === templateId);
    if (tpl) {
      setMarkup(tpl.markup);
      setSelectedBox(null);
    }
  };

  // Custom Font Upload
  const handleFontUploaded = async (buffer: ArrayBuffer, fileName: string) => {
    try {
      const res = await loadCustomFont(buffer, fileName);
      setFontInfo(res.info);
    } catch (err) {
      alert('Failed to load font file. Please ensure it is a valid .OTF or .TTF file.');
    }
  };

  // Compute Layout AST & Boxes
  const layoutResult = useMemo(() => {
    const ast = parseMathMarkup(markup);
    return layoutMathAST(ast, {
      baseFontSize: fontSize,
      maxEntWeights,
      enableMaxEnt,
    });
  }, [markup, fontSize, maxEntWeights, enableMaxEnt, fontInfo]);

  // Compute Jaynesian MaxEnt Energy
  const energyState = useMemo(() => {
    return calculateLayoutEnergy(layoutResult.rootBoxes, maxEntWeights);
  }, [layoutResult.rootBoxes, maxEntWeights]);

  // Apply Cl(4,1,1) Rotor transform to all boxes
  const transformedBoxes = useMemo(() => {
    return layoutResult.rootBoxes.map((box) => ({
      ...box,
      transform: cl411Transform,
    }));
  }, [layoutResult.rootBoxes, cl411Transform]);

  return (
    <div className="min-h-screen bg-[#0A0A0B] text-[#E0E0E0] flex flex-col font-sans overflow-hidden selection:bg-amber-500/30 selection:text-amber-200">
      {/* Top Navigation */}
      <Navbar
        activeTab={activeTab}
        setActiveTab={setActiveTab}
        selectedTemplateId={selectedTemplateId}
        onSelectTemplate={handleSelectTemplate}
        onOpenExport={() => setIsExportOpen(true)}
        fontName={fontInfo.familyName}
        isCustomFont={fontInfo.isCustomFont}
      />

      {/* Main Interactive Workbench Layout */}
      <main className="flex-1 max-w-7xl w-full mx-auto p-3 md:p-5 h-[calc(100vh-65px)] overflow-hidden">
        {activeTab === 'textbook' ? (
          <div className="h-full overflow-hidden">
            <TextbookPanel />
          </div>
        ) : activeTab === 'spiro' ? (
          <div className="h-full overflow-hidden">
            <SpiroWorkbench />
          </div>
        ) : activeTab === 'bernstein' ? (
          <div className="h-full overflow-hidden">
            <BernsteinSplineWorkbench />
          </div>
        ) : activeTab === 'punchcutter' ? (
          <div className="h-full overflow-hidden">
            <PunchcutterWorkbench />
          </div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-4 h-full overflow-hidden">
            {/* Left Interactive Control Panel (5 columns) */}
            <div className="lg:col-span-5 h-full overflow-hidden flex flex-col">
              {activeTab === 'editor' && (
                <DocumentEditor
                  markup={markup}
                  setMarkup={setMarkup}
                  fontSize={fontSize}
                  setFontSize={setFontSize}
                  enableMaxEnt={enableMaxEnt}
                  setEnableMaxEnt={setEnableMaxEnt}
                  selectedTemplateId={selectedTemplateId}
                  onSelectTemplate={handleSelectTemplate}
                  selectedBox={selectedBox}
                />
              )}

              {activeTab === 'iris' && (
                <IrisCoordinatePanel
                  layoutBoxes={transformedBoxes}
                  selectedBox={selectedBox}
                />
              )}

              {activeTab === 'cl411' && (
                <Cl411RotorPanel
                  transform={cl411Transform}
                  setTransform={setCl411Transform}
                  selectedBox={selectedBox}
                  onApplyToAll={() => {
                    // Applied via state
                  }}
                />
              )}

              {activeTab === 'maxent' && (
                <MaxEntPanel
                  weights={maxEntWeights}
                  setWeights={setMaxEntWeights}
                  energyState={energyState}
                />
              )}

              {activeTab === 'font' && (
                <FontMetricsPanel
                  fontInfo={fontInfo}
                  onFontUploaded={handleFontUploaded}
                />
              )}
            </div>

            {/* Right High-Precision Vector Canvas Preview (7 columns) */}
            <div className="lg:col-span-7 h-full overflow-hidden flex flex-col">
              <TypesetCanvas
                layoutBoxes={transformedBoxes}
                totalWidth={layoutResult.width}
                totalHeight={layoutResult.height}
                ascent={layoutResult.ascent}
                descent={layoutResult.descent}
                selectedBoxId={selectedBox?.id || null}
                onSelectBox={setSelectedBox}
                showIrisGrid={showIrisGrid}
                setShowIrisGrid={setShowIrisGrid}
                showCl411Frame={showCl411Frame}
                setShowCl411Frame={setShowCl411Frame}
                showMaxEntHeatmap={showMaxEntHeatmap}
                setShowMaxEntHeatmap={setShowMaxEntHeatmap}
                showBaselineGrid={showBaselineGrid}
                setShowBaselineGrid={setShowBaselineGrid}
                showBoundingBoxes={showBoundingBoxes}
                setShowBoundingBoxes={setShowBoundingBoxes}
              />
            </div>
          </div>
        )}
      </main>

      {/* Export Modal */}
      <ExportModal
        isOpen={isExportOpen}
        onClose={() => setIsExportOpen(false)}
        layoutBoxes={transformedBoxes}
        totalWidth={layoutResult.width}
        totalHeight={layoutResult.height}
        markup={markup}
        energyState={energyState}
      />
    </div>
  );
}
