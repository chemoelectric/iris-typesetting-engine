# Ada Fontconfig Binding & Module Documentation

## Overview
`fontconfig` is a high-level and low-level Ada 2022 binding package for the Keith Packard Fontconfig font configuration and customization C library (`libfontconfig`). It wraps Fontconfig primitives (`FcInit`, `FcFini`, `FcNameParse`, `FcFontMatch`, `FcFontList`, `FcPatternGetString`, etc.) into type-safe Ada subprograms with pre- and post-condition contracts.

## Architecture & Location
- **Package Spec**: `/public/iris-typesetting-suite/fontconfig.ads`
- **Package Body**: `/public/iris-typesetting-suite/fontconfig.adb`
- **Unit Test**: `/public/iris-typesetting-suite/test_fontconfig.adb`

## Features & Subprograms
1. **`init return boolean`**: Initializes the Fontconfig library environment.
2. **`fini`**: Shuts down the Fontconfig library and deallocates global tables.
3. **`parse_name (name : in string) return fc_pattern_ptr`**: Parses a font name query string (e.g. `"DejaVu Sans"`) into an `FcPattern` structure.
4. **`match_font (pat : in fc_pattern_ptr) return fc_pattern_ptr`**: Performs configuration substitutions and pattern matching to locate the best-matching installed font.
5. **`get_font_file (pat : in fc_pattern_ptr) return string`**: Extracts the absolute filesystem path from the matched font pattern.
6. **`destroy_pattern`, `destroy_font_set`, `destroy_object_set`**: Safe deallocation procedures for Fontconfig opaque handles.

## Coding Standards Compliance
1. **Ada 2022 Standard**: Modern contract aspects (`Pre => ...`, `Post => ...`).
2. **Explicit Parameter Modes**: Subprogram parameters explicitly declare `in` or `in out`.
3. **Casing & Style**: Lowercase identifiers throughout, line lengths strictly <= 72 characters.
4. **Control Structures**: Single-entry/single-exit control flow, no bare `loop` constructs.
5. **McCabe Complexity**: All functions, procedures, and main test programs have cyclomatic complexity <= 10.

## API Usage Example
```ada
with fontconfig; use fontconfig;
with ada.text_io; use ada.text_io;

procedure find_font_example is
   pat   : fc_pattern_ptr;
   match : fc_pattern_ptr;
begin
   if init then
      pat := parse_name ("DejaVu Sans");
      if pat /= null_pattern then
         match := match_font (pat);
         if match /= null_pattern then
            put_line ("Found font: " & get_font_file (match));
            destroy_pattern (match);
         end if;
         destroy_pattern (pat);
      end if;
      fini;
   end if;
end find_font_example;
```
