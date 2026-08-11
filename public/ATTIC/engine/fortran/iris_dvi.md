# Module: `iris_dvi`

## Overview
The `iris_dvi` Fortran 2008 module implements a high-performance, modular binary writer for TeX Device Independent (DVI v2) files. It serves as the primary macro-typographic output driver for the TeX-style backend engine, generating standard big-endian DVI opcodes for document pagination, character positioning, rules, font definitions, and stack state transformations.

## Data Structures

### `dvi_font_type`
Encapsulates TeX font metadata required for font definition opcodes (`fnt_def1`).
- `font_num`: Unique integer font handle.
- `checksum`: TeX font metric checksum.
- `scale_sp`: Font scale size in scaled points (`sp`).
- `design_sp`: Font design size in scaled points (`sp`).
- `font_name`: Font metric identifier string (e.g. `cmr10`, `cmbx10`, `cmtt10`).

### `dvi_document_type`
Maintains the runtime state of an active DVI binary output stream.
- `file_unit`: Fortran stream I/O logical unit.
- `byte_offset`: Cumulative output byte counter.
- `page_count`: Total paginated pages generated.
- `last_bop_offset`: Byte offset of the most recent `bop` command (for back-linked page pointers).
- `max_stack_depth`: High-water mark for state stack depth.
- `active_font_num`: Currently selected font index.
- `fonts`: Array of registered `dvi_font_type` descriptors.

## Public API Procedures

| Procedure | Purpose |
| :--- | :--- |
| `dvi_init(doc, filename, status)` | Opens binary stream and writes DVI preamble (`pre`). |
| `dvi_begin_page(doc, count0, status)` | Emits beginning-of-page (`bop`) with page counters and back-link pointer. |
| `dvi_end_page(doc, status)` | Emits end-of-page (`eop`) command. |
| `dvi_write_char(doc, char_code, status)` | Emits single character code opcode. |
| `dvi_write_rule(doc, height_sp, width_sp, status)` | Emits set rule (`set_rule`) opcode for box/line rendering. |
| `dvi_define_font(doc, font_num, checksum, scale_sp, design_sp, font_name, status)` | Registers font and emits `fnt_def1` opcode. |
| `dvi_select_font(doc, font_num, status)` | Emits font selection opcode (`fnt_num_0`..`fnt_num_63` or `fnt1`). |
| `dvi_move_right(doc, distance_sp, status)` | Emits horizontal displacement opcode (`right4`). |
| `dvi_move_down(doc, distance_sp, status)` | Emits vertical displacement opcode (`down4`). |
| `dvi_push(doc, status)` | Pushes graphics/coordinate state stack (`push`). |
| `dvi_pop(doc, status)` | Pops graphics/coordinate state stack (`pop`). |
| `dvi_close(doc, status)` | Emits postamble (`post`), font definitions table, `post_post`, trailer padding, and closes file. |

## Theoretical & Standards Compliance
- **ISO Fortran 2008**: Uses standard stream I/O (`access='stream'`, `form='unformatted'`) and ISO C/Fortran integer types (`int8`, `int16`, `int32`).
- **Structured Control Flow**: Single-entry / single-exit routines with McCabe cyclomatic complexity strictly constrained ($\le 10$).
- **Absolute Continuum**: Space coordinates are measured in absolute TeX scaled points ($1\text{ sp} = 2^{-16}\text{ pt}$).
