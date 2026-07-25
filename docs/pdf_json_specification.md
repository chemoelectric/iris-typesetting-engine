# PDF-JSON: A Deterministic JSON Transliteration Specification for ISO 32000 / PDF 1.7

## 1. Executive Summary & Architectural Motivation
PDF (Portable Document Format) is traditionally a low-level postscript-like hybrid binary/ASCII syntax consisting of indirect object dictionaries, cross-reference byte offsets (`xref`), streams, and stack-based vector graphics operators (`BT`, `ET`, `re`, `f`, `m`, `l`, `c`, `rg`, `Tj`).

**PDF-JSON** is a deterministic, lossless 1:1 JSON transliteration of the complete PDF 1.7 object model and stream operator instruction set. It enables modular transformation tools—such as Scheme (`json2pdf.scm`) and Fortran 2008 (`json2pdf.f90`)—to compile declarative JSON document trees directly into compliant PDF 1.7 binaries without manual string concatenation or imperative PDF API bindings.

---

## 2. Top-Level Schema (`pdf-json` Document Root)

```json
{
  "$schema": "https://sortsmill.org/schemas/pdf-json-v1.json",
  "version": "1.7",
  "info": {
    "title": "Document Title",
    "author": "Sorts Mill Typography Engine",
    "creator": "Cl(4,1,1) Multivector Microtypography System"
  },
  "catalog": {
    "pageLayout": "SinglePage",
    "pageMode": "UseNone"
  },
  "resources": {
    "fonts": [
      {
        "id": "F1",
        "type": "Type1",
        "baseFont": "Helvetica",
        "encoding": "WinAnsiEncoding"
      }
    ]
  },
  "pages": [
    {
      "mediaBox": [0, 0, 612, 792],
      "cropBox": [0, 0, 612, 792],
      "rotate": 0,
      "contents": [
        { "op": "saveState" },
        { "op": "setFillColor", "rgb": [0.1, 0.1, 0.1] },
        { "op": "drawRect", "x": 50, "y": 700, "w": 512, "h": 40, "fill": true },
        {
          "op": "textBlock",
          "font": "F1",
          "size": 16.0,
          "lines": [
            { "x": 60, "y": 715, "text": "Cl(4,1,1) Microtypography Output" }
          ]
        },
        { "op": "restoreState" }
      ]
    }
  ]
}
```

---

## 3. PDF Object Primitive Mapping

| PDF Low-Level Syntax | PDF-JSON Transliteration | Example |
| :--- | :--- | :--- |
| **Boolean** | JSON Boolean | `true` / `false` |
| **Integer / Real** | JSON Number | `612.0`, `792` |
| **String Literal** | JSON String | `"Helvetica"` |
| **Name Object (`/Type`)** | JSON String / Symbol | `"/Catalog"` or `"Catalog"` |
| **Array (`[...]`)** | JSON Array | `[0, 0, 612, 792]` |
| **Dictionary (`<< ... >>`)**| JSON Object | `{"Type": "Page", ...}` |
| **Indirect Reference (`1 0 R`)**| JSON Reference Object | `{"$ref": "obj_1"}` |
| **Null Object** | JSON Null | `null` |

---

## 4. Vector Graphics & Text Operator Transliteration Table

| PDF Operator | Operands | PDF-JSON Instruction Representation |
| :--- | :--- | :--- |
| `q` / `Q` | State push/pop | `{"op": "saveState"}` / `{"op": "restoreState"}` |
| `cm` | Matrix transformation | `{"op": "transform", "matrix": [a, b, c, d, e, f]}` |
| `m` / `l` / `c` | Path construction | `{"op": "moveTo", "x": 10, "y": 20}`, `{"op": "lineTo", "x": 30, "y": 40}`, `{"op": "curveTo", "cp1": [x1,y1], "cp2": [x2,y2], "dest": [x3,y3]}` |
| `re` | Rectangle | `{"op": "rect", "x": 50, "y": 50, "w": 200, "h": 100}` |
| `f` / `S` / `B` | Fill / Stroke / Both | `{"op": "fill"}`, `{"op": "stroke"}`, `{"op": "fillAndStroke"}` |
| `rg` / `RG` | RGB fill/stroke color | `{"op": "setFillColor", "rgb": [r, g, b]}` |
| `Tf` | Select Font & Size | `{"op": "setFont", "font": "F1", "size": 12.0}` |
| `BT` ... `ET` | Text Block | `{"op": "textBlock", "font": "F1", "size": 12.0, "lines": [...]}` |
| `Tj` / `TJ` | Show text / kerning array | `{"op": "showText", "text": "Hello"}` or `{"op": "showKernedText", "array": ["H", -20, "ello"]}` |

---

## 5. Bidirectional Compiler Architecture (`json2pdf` / `pdf2json`)

```
+------------------+         +--------------------------+         +------------------+
|  PDF-JSON Tree   |  <--->  | Scheme (json-api) Parser |  <--->  | Native PDF 1.7   |
| (Structured Text)|         | Fortran 2008 AST Compiler|         | (Binary Output)  |
+------------------+         +--------------------------+         +------------------+
```

1. **Compilation (`json2pdf`)**:
   - Parses `pdf-json` document tree.
   - Computes stream object lengths dynamically (`/Length`).
   - Assigns sequential indirect object IDs (`1 0 R`, `2 0 R`, ...).
   - Generates exact byte-offset cross-reference table (`xref`) and trailer dictionary (`startxref`).

2. **Decompilation (`pdf2json`)**:
   - Reads PDF xref table and parses object dictionaries.
   - Decodes content streams into canonical PDF-JSON operator arrays.
