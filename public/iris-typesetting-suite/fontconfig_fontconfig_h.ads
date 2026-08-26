pragma Ada_2012;

pragma Style_Checks (Off);
pragma Warnings (Off, "-gnatwu");

with Interfaces.C; use Interfaces.C;
with Interfaces.C.Strings;
with System;
limited with bits_struct_stat_h;

package fontconfig_fontconfig_h is

   FC_MAJOR : constant := 2;  --  /usr/local/include/fontconfig/fontconfig.h:56
   FC_MINOR : constant := 17;  --  /usr/local/include/fontconfig/fontconfig.h:57
   FC_REVISION : constant := 1;  --  /usr/local/include/fontconfig/fontconfig.h:58
   --  unsupported macro: FC_VERSION ((FC_MAJOR * 10000) + (FC_MINOR * 100) + (FC_REVISION))

   FC_CACHE_VERSION_NUMBER : constant := 9;  --  /usr/local/include/fontconfig/fontconfig.h:72
   --  unsupported macro: FC_CACHE_VERSION _FC_STRINGIFY (FC_CACHE_VERSION_NUMBER)

   FcFalse : constant := 0;  --  /usr/local/include/fontconfig/fontconfig.h:77
   FcTrue : constant := 1;  --  /usr/local/include/fontconfig/fontconfig.h:78
   FcDontCare : constant := 2;  --  /usr/local/include/fontconfig/fontconfig.h:79

   FC_FAMILY : aliased constant String := "family" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:81
   FC_STYLE : aliased constant String := "style" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:82
   FC_SLANT : aliased constant String := "slant" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:83
   FC_WEIGHT : aliased constant String := "weight" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:84
   FC_SIZE : aliased constant String := "size" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:85
   FC_ASPECT : aliased constant String := "aspect" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:86
   FC_PIXEL_SIZE : aliased constant String := "pixelsize" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:87
   FC_SPACING : aliased constant String := "spacing" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:88
   FC_FOUNDRY : aliased constant String := "foundry" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:89
   FC_ANTIALIAS : aliased constant String := "antialias" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:90
   FC_HINTING : aliased constant String := "hinting" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:91
   FC_HINT_STYLE : aliased constant String := "hintstyle" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:92
   FC_VERTICAL_LAYOUT : aliased constant String := "verticallayout" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:93
   FC_AUTOHINT : aliased constant String := "autohint" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:94

   FC_GLOBAL_ADVANCE : aliased constant String := "globaladvance" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:96
   FC_WIDTH : aliased constant String := "width" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:97
   FC_FILE : aliased constant String := "file" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:98
   FC_INDEX : aliased constant String := "index" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:99
   FC_FT_FACE : aliased constant String := "ftface" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:100
   FC_RASTERIZER : aliased constant String := "rasterizer" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:101
   FC_OUTLINE : aliased constant String := "outline" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:102
   FC_SCALABLE : aliased constant String := "scalable" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:103
   FC_COLOR : aliased constant String := "color" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:104
   FC_VARIABLE : aliased constant String := "variable" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:105
   FC_SCALE : aliased constant String := "scale" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:106
   FC_SYMBOL : aliased constant String := "symbol" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:107
   FC_DPI : aliased constant String := "dpi" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:108
   FC_RGBA : aliased constant String := "rgba" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:109
   FC_MINSPACE : aliased constant String := "minspace" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:110
   FC_SOURCE : aliased constant String := "source" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:111
   FC_CHARSET : aliased constant String := "charset" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:112
   FC_LANG : aliased constant String := "lang" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:113
   FC_FONTVERSION : aliased constant String := "fontversion" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:114
   FC_FULLNAME : aliased constant String := "fullname" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:115
   FC_FAMILYLANG : aliased constant String := "familylang" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:116
   FC_STYLELANG : aliased constant String := "stylelang" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:117
   FC_FULLNAMELANG : aliased constant String := "fullnamelang" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:118
   FC_CAPABILITY : aliased constant String := "capability" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:119
   FC_FONTFORMAT : aliased constant String := "fontformat" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:120
   FC_EMBOLDEN : aliased constant String := "embolden" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:121
   FC_EMBEDDED_BITMAP : aliased constant String := "embeddedbitmap" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:122
   FC_DECORATIVE : aliased constant String := "decorative" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:123
   FC_LCD_FILTER : aliased constant String := "lcdfilter" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:124
   FC_FONT_FEATURES : aliased constant String := "fontfeatures" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:125
   FC_FONT_VARIATIONS : aliased constant String := "fontvariations" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:126
   FC_NAMELANG : aliased constant String := "namelang" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:127
   FC_PRGNAME : aliased constant String := "prgname" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:128
   FC_HASH : aliased constant String := "hash" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:129
   FC_POSTSCRIPT_NAME : aliased constant String := "postscriptname" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:130
   FC_FONT_HAS_HINT : aliased constant String := "fonthashint" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:131
   FC_ORDER : aliased constant String := "order" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:132
   FC_DESKTOP_NAME : aliased constant String := "desktop" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:133
   FC_NAMED_INSTANCE : aliased constant String := "namedinstance" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:134
   FC_FONT_WRAPPER : aliased constant String := "fontwrapper" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:135
   --  unsupported macro: FC_CACHE_SUFFIX ".cache-" FC_CACHE_VERSION
   --  unsupported macro: FC_DIR_CACHE_FILE "fonts.cache-" FC_CACHE_VERSION
   --  unsupported macro: FC_USER_CACHE_FILE ".fonts.cache-" FC_CACHE_VERSION

   FC_CHARWIDTH : aliased constant String := "charwidth" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:142
   --  unsupported macro: FC_CHAR_WIDTH FC_CHARWIDTH

   FC_CHAR_HEIGHT : aliased constant String := "charheight" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:144
   FC_MATRIX : aliased constant String := "matrix" & ASCII.NUL;  --  /usr/local/include/fontconfig/fontconfig.h:145

   FC_WEIGHT_THIN : constant := 0;  --  /usr/local/include/fontconfig/fontconfig.h:147
   FC_WEIGHT_EXTRALIGHT : constant := 40;  --  /usr/local/include/fontconfig/fontconfig.h:148
   --  unsupported macro: FC_WEIGHT_ULTRALIGHT FC_WEIGHT_EXTRALIGHT

   FC_WEIGHT_LIGHT : constant := 50;  --  /usr/local/include/fontconfig/fontconfig.h:150
   FC_WEIGHT_DEMILIGHT : constant := 55;  --  /usr/local/include/fontconfig/fontconfig.h:151
   --  unsupported macro: FC_WEIGHT_SEMILIGHT FC_WEIGHT_DEMILIGHT

   FC_WEIGHT_BOOK : constant := 75;  --  /usr/local/include/fontconfig/fontconfig.h:153
   FC_WEIGHT_REGULAR : constant := 80;  --  /usr/local/include/fontconfig/fontconfig.h:154
   --  unsupported macro: FC_WEIGHT_NORMAL FC_WEIGHT_REGULAR

   FC_WEIGHT_MEDIUM : constant := 100;  --  /usr/local/include/fontconfig/fontconfig.h:156
   FC_WEIGHT_DEMIBOLD : constant := 180;  --  /usr/local/include/fontconfig/fontconfig.h:157
   --  unsupported macro: FC_WEIGHT_SEMIBOLD FC_WEIGHT_DEMIBOLD

   FC_WEIGHT_BOLD : constant := 200;  --  /usr/local/include/fontconfig/fontconfig.h:159
   FC_WEIGHT_EXTRABOLD : constant := 205;  --  /usr/local/include/fontconfig/fontconfig.h:160
   --  unsupported macro: FC_WEIGHT_ULTRABOLD FC_WEIGHT_EXTRABOLD

   FC_WEIGHT_BLACK : constant := 210;  --  /usr/local/include/fontconfig/fontconfig.h:162
   --  unsupported macro: FC_WEIGHT_HEAVY FC_WEIGHT_BLACK

   FC_WEIGHT_EXTRABLACK : constant := 215;  --  /usr/local/include/fontconfig/fontconfig.h:164
   --  unsupported macro: FC_WEIGHT_ULTRABLACK FC_WEIGHT_EXTRABLACK

   FC_SLANT_ROMAN : constant := 0;  --  /usr/local/include/fontconfig/fontconfig.h:167
   FC_SLANT_ITALIC : constant := 100;  --  /usr/local/include/fontconfig/fontconfig.h:168
   FC_SLANT_OBLIQUE : constant := 110;  --  /usr/local/include/fontconfig/fontconfig.h:169

   FC_WIDTH_ULTRACONDENSED : constant := 50;  --  /usr/local/include/fontconfig/fontconfig.h:171
   FC_WIDTH_EXTRACONDENSED : constant := 63;  --  /usr/local/include/fontconfig/fontconfig.h:172
   FC_WIDTH_CONDENSED : constant := 75;  --  /usr/local/include/fontconfig/fontconfig.h:173
   FC_WIDTH_SEMICONDENSED : constant := 87;  --  /usr/local/include/fontconfig/fontconfig.h:174
   FC_WIDTH_NORMAL : constant := 100;  --  /usr/local/include/fontconfig/fontconfig.h:175
   FC_WIDTH_SEMIEXPANDED : constant := 113;  --  /usr/local/include/fontconfig/fontconfig.h:176
   FC_WIDTH_EXPANDED : constant := 125;  --  /usr/local/include/fontconfig/fontconfig.h:177
   FC_WIDTH_EXTRAEXPANDED : constant := 150;  --  /usr/local/include/fontconfig/fontconfig.h:178
   FC_WIDTH_ULTRAEXPANDED : constant := 200;  --  /usr/local/include/fontconfig/fontconfig.h:179

   FC_PROPORTIONAL : constant := 0;  --  /usr/local/include/fontconfig/fontconfig.h:181
   FC_DUAL : constant := 90;  --  /usr/local/include/fontconfig/fontconfig.h:182
   FC_MONO : constant := 100;  --  /usr/local/include/fontconfig/fontconfig.h:183
   FC_CHARCELL : constant := 110;  --  /usr/local/include/fontconfig/fontconfig.h:184

   FC_RGBA_UNKNOWN : constant := 0;  --  /usr/local/include/fontconfig/fontconfig.h:187
   FC_RGBA_RGB : constant := 1;  --  /usr/local/include/fontconfig/fontconfig.h:188
   FC_RGBA_BGR : constant := 2;  --  /usr/local/include/fontconfig/fontconfig.h:189
   FC_RGBA_VRGB : constant := 3;  --  /usr/local/include/fontconfig/fontconfig.h:190
   FC_RGBA_VBGR : constant := 4;  --  /usr/local/include/fontconfig/fontconfig.h:191
   FC_RGBA_NONE : constant := 5;  --  /usr/local/include/fontconfig/fontconfig.h:192

   FC_HINT_NONE : constant := 0;  --  /usr/local/include/fontconfig/fontconfig.h:195
   FC_HINT_SLIGHT : constant := 1;  --  /usr/local/include/fontconfig/fontconfig.h:196
   FC_HINT_MEDIUM : constant := 2;  --  /usr/local/include/fontconfig/fontconfig.h:197
   FC_HINT_FULL : constant := 3;  --  /usr/local/include/fontconfig/fontconfig.h:198

   FC_LCD_NONE : constant := 0;  --  /usr/local/include/fontconfig/fontconfig.h:201
   FC_LCD_DEFAULT : constant := 1;  --  /usr/local/include/fontconfig/fontconfig.h:202
   FC_LCD_LIGHT : constant := 2;  --  /usr/local/include/fontconfig/fontconfig.h:203
   FC_LCD_LEGACY : constant := 3;  --  /usr/local/include/fontconfig/fontconfig.h:204
   --  arg-macro: function FcMatrixInit (m)
   --    return (m).xx := (m).yy := 1, (m).xy := (m).yx := 0;

   FC_CHARSET_MAP_SIZE : constant := (256 / 32);  --  /usr/local/include/fontconfig/fontconfig.h:580
   --  unsupported macro: FC_CHARSET_DONE ((FcChar32) - 1)
   --  arg-macro: function FcIsUpper (c)
   --    return (8#101# <= (c)  and then  (c) <= 8#132#);
   --  arg-macro: function FcIsLower (c)
   --    return (8#141# <= (c)  and then  (c) <= 8#172#);
   --  arg-macro: function FcToLower (c)
   --    return FcIsUpper (c) ? (c) - 8#101# + 8#141# : (c);

   FC_UTF8_MAX_LEN : constant := 6;  --  /usr/local/include/fontconfig/fontconfig.h:1109
   --  unsupported macro: FcConfigGetRescanInverval FcConfigGetRescanInverval_REPLACE_BY_FcConfigGetRescanInterval
   --  unsupported macro: FcConfigSetRescanInverval FcConfigSetRescanInverval_REPLACE_BY_FcConfigSetRescanInterval

   subtype FcChar8 is unsigned_char;  -- /usr/local/include/fontconfig/fontconfig.h:45

   subtype FcChar16 is unsigned_short;  -- /usr/local/include/fontconfig/fontconfig.h:46

   subtype FcChar32 is unsigned;  -- /usr/local/include/fontconfig/fontconfig.h:47

   subtype FcBool is int;  -- /usr/local/include/fontconfig/fontconfig.h:48

   subtype u_FcType is int;
   u_FcType_FcTypeUnknown : constant u_FcType := -1;
   u_FcType_FcTypeVoid : constant u_FcType := 0;
   u_FcType_FcTypeInteger : constant u_FcType := 1;
   u_FcType_FcTypeDouble : constant u_FcType := 2;
   u_FcType_FcTypeString : constant u_FcType := 3;
   u_FcType_FcTypeBool : constant u_FcType := 4;
   u_FcType_FcTypeMatrix : constant u_FcType := 5;
   u_FcType_FcTypeCharSet : constant u_FcType := 6;
   u_FcType_FcTypeFTFace : constant u_FcType := 7;
   u_FcType_FcTypeLangSet : constant u_FcType := 8;
   u_FcType_FcTypeRange : constant u_FcType := 9;  -- /usr/local/include/fontconfig/fontconfig.h:206

   subtype FcType is u_FcType;  -- /usr/local/include/fontconfig/fontconfig.h:218

   type u_FcMatrix is record
      xx : aliased double;  -- /usr/local/include/fontconfig/fontconfig.h:221
      xy : aliased double;  -- /usr/local/include/fontconfig/fontconfig.h:221
      yx : aliased double;  -- /usr/local/include/fontconfig/fontconfig.h:221
      yy : aliased double;  -- /usr/local/include/fontconfig/fontconfig.h:221
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/fontconfig/fontconfig.h:220

   subtype FcMatrix is u_FcMatrix;  -- /usr/local/include/fontconfig/fontconfig.h:222

   type u_FcCharSet is null record;   -- incomplete struct

   subtype FcCharSet is u_FcCharSet;  -- /usr/local/include/fontconfig/fontconfig.h:232

   type u_FcObjectType is record
      object : Interfaces.C.Strings.chars_ptr;  -- /usr/local/include/fontconfig/fontconfig.h:235
      c_type : aliased FcType;  -- /usr/local/include/fontconfig/fontconfig.h:236
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/fontconfig/fontconfig.h:234

   subtype FcObjectType is u_FcObjectType;  -- /usr/local/include/fontconfig/fontconfig.h:237

   type u_FcConstant is record
      name : access FcChar8;  -- /usr/local/include/fontconfig/fontconfig.h:240
      object : Interfaces.C.Strings.chars_ptr;  -- /usr/local/include/fontconfig/fontconfig.h:241
      value : aliased int;  -- /usr/local/include/fontconfig/fontconfig.h:242
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/fontconfig/fontconfig.h:239

   subtype FcConstant is u_FcConstant;  -- /usr/local/include/fontconfig/fontconfig.h:243

   type u_FcResult is 
     (FcResultMatch,
      FcResultNoMatch,
      FcResultTypeMismatch,
      FcResultNoId,
      FcResultOutOfMemory)
   with Convention => C;  -- /usr/local/include/fontconfig/fontconfig.h:245

   subtype FcResult is u_FcResult;  -- /usr/local/include/fontconfig/fontconfig.h:251

   subtype u_FcValueBinding is unsigned;
   u_FcValueBinding_FcValueBindingWeak : constant u_FcValueBinding := 0;
   u_FcValueBinding_FcValueBindingStrong : constant u_FcValueBinding := 1;
   u_FcValueBinding_FcValueBindingSame : constant u_FcValueBinding := 2;
   u_FcValueBinding_FcValueBindingEnd : constant u_FcValueBinding := 2147483647;  -- /usr/local/include/fontconfig/fontconfig.h:253

   subtype FcValueBinding is u_FcValueBinding;  -- /usr/local/include/fontconfig/fontconfig.h:259

   type u_FcPattern is null record;   -- incomplete struct

   subtype FcPattern is u_FcPattern;  -- /usr/local/include/fontconfig/fontconfig.h:261

   type u_FcPatternIter is record
      dummy1 : System.Address;  -- /usr/local/include/fontconfig/fontconfig.h:264
      dummy2 : System.Address;  -- /usr/local/include/fontconfig/fontconfig.h:265
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/fontconfig/fontconfig.h:263

   subtype FcPatternIter is u_FcPatternIter;  -- /usr/local/include/fontconfig/fontconfig.h:266

   type u_FcLangSet is null record;   -- incomplete struct

   subtype FcLangSet is u_FcLangSet;  -- /usr/local/include/fontconfig/fontconfig.h:268

   type u_FcRange is null record;   -- incomplete struct

   subtype FcRange is u_FcRange;  -- /usr/local/include/fontconfig/fontconfig.h:270

   type anon_union1298 (discr : unsigned := 0) is record
      case discr is
         when 0 =>
            s : access FcChar8;  -- /usr/local/include/fontconfig/fontconfig.h:275
         when 1 =>
            i : aliased int;  -- /usr/local/include/fontconfig/fontconfig.h:276
         when 2 =>
            b : aliased FcBool;  -- /usr/local/include/fontconfig/fontconfig.h:277
         when 3 =>
            d : aliased double;  -- /usr/local/include/fontconfig/fontconfig.h:278
         when 4 =>
            m : access constant FcMatrix;  -- /usr/local/include/fontconfig/fontconfig.h:279
         when 5 =>
            c : access constant FcCharSet;  -- /usr/local/include/fontconfig/fontconfig.h:280
         when 6 =>
            f : System.Address;  -- /usr/local/include/fontconfig/fontconfig.h:281
         when 7 =>
            l : access constant FcLangSet;  -- /usr/local/include/fontconfig/fontconfig.h:282
         when others =>
            r : access constant FcRange;  -- /usr/local/include/fontconfig/fontconfig.h:283
      end case;
   end record
   with Convention => C_Pass_By_Copy,
        Unchecked_Union => True;
   type u_FcValue is record
      c_type : aliased FcType;  -- /usr/local/include/fontconfig/fontconfig.h:273
      u : aliased anon_union1298;  -- /usr/local/include/fontconfig/fontconfig.h:284
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/fontconfig/fontconfig.h:272

   subtype FcValue is u_FcValue;  -- /usr/local/include/fontconfig/fontconfig.h:285

   type u_FcFontSet is record
      nfont : aliased int;  -- /usr/local/include/fontconfig/fontconfig.h:288
      sfont : aliased int;  -- /usr/local/include/fontconfig/fontconfig.h:289
      fonts : System.Address;  -- /usr/local/include/fontconfig/fontconfig.h:290
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/fontconfig/fontconfig.h:287

   subtype FcFontSet is u_FcFontSet;  -- /usr/local/include/fontconfig/fontconfig.h:291

   type u_FcObjectSet is record
      nobject : aliased int;  -- /usr/local/include/fontconfig/fontconfig.h:294
      sobject : aliased int;  -- /usr/local/include/fontconfig/fontconfig.h:295
      objects : System.Address;  -- /usr/local/include/fontconfig/fontconfig.h:296
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/fontconfig/fontconfig.h:293

   subtype FcObjectSet is u_FcObjectSet;  -- /usr/local/include/fontconfig/fontconfig.h:297

   subtype u_FcMatchKind is unsigned;
   u_FcMatchKind_FcMatchPattern : constant u_FcMatchKind := 0;
   u_FcMatchKind_FcMatchFont : constant u_FcMatchKind := 1;
   u_FcMatchKind_FcMatchScan : constant u_FcMatchKind := 2;
   u_FcMatchKind_FcMatchKindEnd : constant u_FcMatchKind := 3;
   u_FcMatchKind_FcMatchKindBegin : constant u_FcMatchKind := 0;  -- /usr/local/include/fontconfig/fontconfig.h:299

   subtype FcMatchKind is u_FcMatchKind;  -- /usr/local/include/fontconfig/fontconfig.h:305

   subtype u_FcLangResult is unsigned;
   u_FcLangResult_FcLangEqual : constant u_FcLangResult := 0;
   u_FcLangResult_FcLangDifferentCountry : constant u_FcLangResult := 1;
   u_FcLangResult_FcLangDifferentTerritory : constant u_FcLangResult := 1;
   u_FcLangResult_FcLangDifferentLang : constant u_FcLangResult := 2;  -- /usr/local/include/fontconfig/fontconfig.h:307

   subtype FcLangResult is u_FcLangResult;  -- /usr/local/include/fontconfig/fontconfig.h:312

   type u_FcSetName is 
     (FcSetSystem,
      FcSetApplication)
   with Convention => C;  -- /usr/local/include/fontconfig/fontconfig.h:314

   subtype FcSetName is u_FcSetName;  -- /usr/local/include/fontconfig/fontconfig.h:317

   type u_FcConfigFileInfoIter is record
      dummy1 : System.Address;  -- /usr/local/include/fontconfig/fontconfig.h:320
      dummy2 : System.Address;  -- /usr/local/include/fontconfig/fontconfig.h:321
      dummy3 : System.Address;  -- /usr/local/include/fontconfig/fontconfig.h:322
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/fontconfig/fontconfig.h:319

   subtype FcConfigFileInfoIter is u_FcConfigFileInfoIter;  -- /usr/local/include/fontconfig/fontconfig.h:323

   type u_FcAtomic is null record;   -- incomplete struct

   subtype FcAtomic is u_FcAtomic;  -- /usr/local/include/fontconfig/fontconfig.h:325

   type FcEndian is 
     (FcEndianBig,
      FcEndianLittle)
   with Convention => C;  -- /usr/local/include/fontconfig/fontconfig.h:336

   type u_FcConfig is null record;   -- incomplete struct

   subtype FcConfig is u_FcConfig;  -- /usr/local/include/fontconfig/fontconfig.h:338

   type u_FcGlobalCache is null record;   -- incomplete struct

   subtype FcFileCache is u_FcGlobalCache;  -- /usr/local/include/fontconfig/fontconfig.h:340

   type u_FcBlanks is null record;   -- incomplete struct

   subtype FcBlanks is u_FcBlanks;  -- /usr/local/include/fontconfig/fontconfig.h:342

   type u_FcStrList is null record;   -- incomplete struct

   subtype FcStrList is u_FcStrList;  -- /usr/local/include/fontconfig/fontconfig.h:344

   type u_FcStrSet is null record;   -- incomplete struct

   subtype FcStrSet is u_FcStrSet;  -- /usr/local/include/fontconfig/fontconfig.h:346

   type u_FcCache is null record;   -- incomplete struct

   subtype FcCache is u_FcCache;  -- /usr/local/include/fontconfig/fontconfig.h:348

   type FcDestroyFunc is access procedure (arg1 : System.Address)
   with Convention => C;  -- /usr/local/include/fontconfig/fontconfig.h:350

   type FcFilterFontSetFunc is access function (arg1 : access constant FcPattern; arg2 : System.Address) return FcBool
   with Convention => C;  -- /usr/local/include/fontconfig/fontconfig.h:351

   function FcBlanksCreate return access FcBlanks  -- /usr/local/include/fontconfig/fontconfig.h:357
   with Import => True, 
        Convention => C, 
        External_Name => "FcBlanksCreate";

   procedure FcBlanksDestroy (b : access FcBlanks)  -- /usr/local/include/fontconfig/fontconfig.h:360
   with Import => True, 
        Convention => C, 
        External_Name => "FcBlanksDestroy";

   function FcBlanksAdd (b : access FcBlanks; ucs4 : FcChar32) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:363
   with Import => True, 
        Convention => C, 
        External_Name => "FcBlanksAdd";

   function FcBlanksIsMember (b : access FcBlanks; ucs4 : FcChar32) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:366
   with Import => True, 
        Convention => C, 
        External_Name => "FcBlanksIsMember";

   function FcCacheDir (c : access constant FcCache) return access FcChar8  -- /usr/local/include/fontconfig/fontconfig.h:371
   with Import => True, 
        Convention => C, 
        External_Name => "FcCacheDir";

   function FcCacheCopySet (c : access constant FcCache) return access FcFontSet  -- /usr/local/include/fontconfig/fontconfig.h:374
   with Import => True, 
        Convention => C, 
        External_Name => "FcCacheCopySet";

   function FcCacheSubdir (c : access constant FcCache; i : int) return access FcChar8  -- /usr/local/include/fontconfig/fontconfig.h:377
   with Import => True, 
        Convention => C, 
        External_Name => "FcCacheSubdir";

   function FcCacheNumSubdir (c : access constant FcCache) return int  -- /usr/local/include/fontconfig/fontconfig.h:380
   with Import => True, 
        Convention => C, 
        External_Name => "FcCacheNumSubdir";

   function FcCacheNumFont (c : access constant FcCache) return int  -- /usr/local/include/fontconfig/fontconfig.h:383
   with Import => True, 
        Convention => C, 
        External_Name => "FcCacheNumFont";

   function FcDirCacheUnlink (dir : access FcChar8; config : access FcConfig) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:386
   with Import => True, 
        Convention => C, 
        External_Name => "FcDirCacheUnlink";

   function FcDirCacheValid (cache_file : access FcChar8) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:389
   with Import => True, 
        Convention => C, 
        External_Name => "FcDirCacheValid";

   function FcDirCacheClean (cache_dir : access FcChar8; verbose : FcBool) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:392
   with Import => True, 
        Convention => C, 
        External_Name => "FcDirCacheClean";

   procedure FcCacheCreateTagFile (config : access FcConfig)  -- /usr/local/include/fontconfig/fontconfig.h:395
   with Import => True, 
        Convention => C, 
        External_Name => "FcCacheCreateTagFile";

   function FcDirCacheCreateUUID
     (dir : access FcChar8;
      force : FcBool;
      config : access FcConfig) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:398
   with Import => True, 
        Convention => C, 
        External_Name => "FcDirCacheCreateUUID";

   function FcDirCacheDeleteUUID (dir : access FcChar8; config : access FcConfig) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:403
   with Import => True, 
        Convention => C, 
        External_Name => "FcDirCacheDeleteUUID";

   function FcConfigHome return access FcChar8  -- /usr/local/include/fontconfig/fontconfig.h:408
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigHome";

   function FcConfigEnableHome (enable : FcBool) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:411
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigEnableHome";

   function FcConfigGetFilename (config : access FcConfig; url : access FcChar8) return access FcChar8  -- /usr/local/include/fontconfig/fontconfig.h:414
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigGetFilename";

   function FcConfigFilename (url : access FcChar8) return access FcChar8  -- /usr/local/include/fontconfig/fontconfig.h:418
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigFilename";

   function FcConfigCreate return access FcConfig  -- /usr/local/include/fontconfig/fontconfig.h:421
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigCreate";

   function FcConfigReference (config : access FcConfig) return access FcConfig  -- /usr/local/include/fontconfig/fontconfig.h:424
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigReference";

   procedure FcConfigDestroy (config : access FcConfig)  -- /usr/local/include/fontconfig/fontconfig.h:427
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigDestroy";

   function FcConfigSetCurrent (config : access FcConfig) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:430
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigSetCurrent";

   function FcConfigGetCurrent return access FcConfig  -- /usr/local/include/fontconfig/fontconfig.h:433
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigGetCurrent";

   function FcConfigUptoDate (config : access FcConfig) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:436
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigUptoDate";

   function FcConfigBuildFonts (config : access FcConfig) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:439
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigBuildFonts";

   function FcConfigGetFontDirs (config : access FcConfig) return access FcStrList  -- /usr/local/include/fontconfig/fontconfig.h:442
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigGetFontDirs";

   function FcConfigGetConfigDirs (config : access FcConfig) return access FcStrList  -- /usr/local/include/fontconfig/fontconfig.h:445
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigGetConfigDirs";

   function FcConfigGetConfigFiles (config : access FcConfig) return access FcStrList  -- /usr/local/include/fontconfig/fontconfig.h:448
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigGetConfigFiles";

   function FcConfigGetCache (config : access FcConfig) return access FcChar8  -- /usr/local/include/fontconfig/fontconfig.h:451
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigGetCache";

   function FcConfigGetBlanks (config : access FcConfig) return access FcBlanks  -- /usr/local/include/fontconfig/fontconfig.h:454
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigGetBlanks";

   function FcConfigGetCacheDirs (config : access FcConfig) return access FcStrList  -- /usr/local/include/fontconfig/fontconfig.h:457
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigGetCacheDirs";

   function FcConfigGetRescanInterval (config : access FcConfig) return int  -- /usr/local/include/fontconfig/fontconfig.h:460
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigGetRescanInterval";

   function FcConfigSetRescanInterval (config : access FcConfig; rescanInterval : int) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:463
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigSetRescanInterval";

   function FcConfigGetFonts (config : access FcConfig; set : FcSetName) return access FcFontSet  -- /usr/local/include/fontconfig/fontconfig.h:466
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigGetFonts";

   function FcConfigAcceptFont (config : access FcConfig; font : access constant FcPattern) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:470
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigAcceptFont";

   function FcConfigAcceptFilter (config : access FcConfig; font : access constant FcPattern) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:474
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigAcceptFilter";

   function FcConfigAppFontAddFile (config : access FcConfig; file : access FcChar8) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:478
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigAppFontAddFile";

   function FcConfigAppFontAddDir (config : access FcConfig; dir : access FcChar8) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:482
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigAppFontAddDir";

   procedure FcConfigAppFontClear (config : access FcConfig)  -- /usr/local/include/fontconfig/fontconfig.h:486
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigAppFontClear";

   procedure FcConfigPreferAppFont (config : access FcConfig; flag : FcBool)  -- /usr/local/include/fontconfig/fontconfig.h:489
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigPreferAppFont";

   function FcConfigSubstituteWithPat
     (config : access FcConfig;
      p : access FcPattern;
      p_pat : access FcPattern;
      kind : FcMatchKind) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:492
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigSubstituteWithPat";

   function FcConfigSubstitute
     (config : access FcConfig;
      p : access FcPattern;
      kind : FcMatchKind) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:498
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigSubstitute";

   function FcConfigGetSysRoot (config : access constant FcConfig) return access FcChar8  -- /usr/local/include/fontconfig/fontconfig.h:503
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigGetSysRoot";

   procedure FcConfigSetSysRoot (config : access FcConfig; sysroot : access FcChar8)  -- /usr/local/include/fontconfig/fontconfig.h:506
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigSetSysRoot";

   function FcConfigSetFontSetFilter
     (config : access FcConfig;
      filter_func : FcFilterFontSetFunc;
      destroy_data_func : FcDestroyFunc;
      user_data : System.Address) return access FcConfig  -- /usr/local/include/fontconfig/fontconfig.h:510
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigSetFontSetFilter";

   procedure FcConfigFileInfoIterInit (config : access FcConfig; iter : access FcConfigFileInfoIter)  -- /usr/local/include/fontconfig/fontconfig.h:516
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigFileInfoIterInit";

   function FcConfigFileInfoIterNext (config : access FcConfig; iter : access FcConfigFileInfoIter) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:520
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigFileInfoIterNext";

   function FcConfigFileInfoIterGet
     (config : access FcConfig;
      iter : access FcConfigFileInfoIter;
      name : System.Address;
      description : System.Address;
      enabled : access FcBool) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:524
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigFileInfoIterGet";

   function FcCharSetCreate return access FcCharSet  -- /usr/local/include/fontconfig/fontconfig.h:532
   with Import => True, 
        Convention => C, 
        External_Name => "FcCharSetCreate";

   function FcCharSetNew return access FcCharSet  -- /usr/local/include/fontconfig/fontconfig.h:536
   with Import => True, 
        Convention => C, 
        External_Name => "FcCharSetNew";

   procedure FcCharSetDestroy (fcs : access FcCharSet)  -- /usr/local/include/fontconfig/fontconfig.h:539
   with Import => True, 
        Convention => C, 
        External_Name => "FcCharSetDestroy";

   function FcCharSetAddChar (fcs : access FcCharSet; ucs4 : FcChar32) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:542
   with Import => True, 
        Convention => C, 
        External_Name => "FcCharSetAddChar";

   function FcCharSetDelChar (fcs : access FcCharSet; ucs4 : FcChar32) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:545
   with Import => True, 
        Convention => C, 
        External_Name => "FcCharSetDelChar";

   function FcCharSetCopy (src : access FcCharSet) return access FcCharSet  -- /usr/local/include/fontconfig/fontconfig.h:548
   with Import => True, 
        Convention => C, 
        External_Name => "FcCharSetCopy";

   function FcCharSetEqual (a : access constant FcCharSet; b : access constant FcCharSet) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:551
   with Import => True, 
        Convention => C, 
        External_Name => "FcCharSetEqual";

   function FcCharSetIntersect (a : access constant FcCharSet; b : access constant FcCharSet) return access FcCharSet  -- /usr/local/include/fontconfig/fontconfig.h:554
   with Import => True, 
        Convention => C, 
        External_Name => "FcCharSetIntersect";

   function FcCharSetUnion (a : access constant FcCharSet; b : access constant FcCharSet) return access FcCharSet  -- /usr/local/include/fontconfig/fontconfig.h:557
   with Import => True, 
        Convention => C, 
        External_Name => "FcCharSetUnion";

   function FcCharSetSubtract (a : access constant FcCharSet; b : access constant FcCharSet) return access FcCharSet  -- /usr/local/include/fontconfig/fontconfig.h:560
   with Import => True, 
        Convention => C, 
        External_Name => "FcCharSetSubtract";

   function FcCharSetMerge
     (a : access FcCharSet;
      b : access constant FcCharSet;
      changed : access FcBool) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:563
   with Import => True, 
        Convention => C, 
        External_Name => "FcCharSetMerge";

   function FcCharSetHasChar (fcs : access constant FcCharSet; ucs4 : FcChar32) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:566
   with Import => True, 
        Convention => C, 
        External_Name => "FcCharSetHasChar";

   function FcCharSetCount (a : access constant FcCharSet) return FcChar32  -- /usr/local/include/fontconfig/fontconfig.h:569
   with Import => True, 
        Convention => C, 
        External_Name => "FcCharSetCount";

   function FcCharSetIntersectCount (a : access constant FcCharSet; b : access constant FcCharSet) return FcChar32  -- /usr/local/include/fontconfig/fontconfig.h:572
   with Import => True, 
        Convention => C, 
        External_Name => "FcCharSetIntersectCount";

   function FcCharSetSubtractCount (a : access constant FcCharSet; b : access constant FcCharSet) return FcChar32  -- /usr/local/include/fontconfig/fontconfig.h:575
   with Import => True, 
        Convention => C, 
        External_Name => "FcCharSetSubtractCount";

   function FcCharSetIsSubset (a : access constant FcCharSet; b : access constant FcCharSet) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:578
   with Import => True, 
        Convention => C, 
        External_Name => "FcCharSetIsSubset";

   function FcCharSetFirstPage
     (a : access constant FcCharSet;
      map : access FcChar32;
      next : access FcChar32) return FcChar32  -- /usr/local/include/fontconfig/fontconfig.h:584
   with Import => True, 
        Convention => C, 
        External_Name => "FcCharSetFirstPage";

   function FcCharSetNextPage
     (a : access constant FcCharSet;
      map : access FcChar32;
      next : access FcChar32) return FcChar32  -- /usr/local/include/fontconfig/fontconfig.h:589
   with Import => True, 
        Convention => C, 
        External_Name => "FcCharSetNextPage";

   function FcCharSetCoverage
     (a : access constant FcCharSet;
      page : FcChar32;
      result : access FcChar32) return FcChar32  -- /usr/local/include/fontconfig/fontconfig.h:598
   with Import => True, 
        Convention => C, 
        External_Name => "FcCharSetCoverage";

   procedure FcValuePrint (v : FcValue)  -- /usr/local/include/fontconfig/fontconfig.h:602
   with Import => True, 
        Convention => C, 
        External_Name => "FcValuePrint";

   procedure FcPatternPrint (p : access constant FcPattern)  -- /usr/local/include/fontconfig/fontconfig.h:605
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternPrint";

   procedure FcFontSetPrint (s : access constant FcFontSet)  -- /usr/local/include/fontconfig/fontconfig.h:608
   with Import => True, 
        Convention => C, 
        External_Name => "FcFontSetPrint";

   function FcConfigGetDefaultLangs (config : access FcConfig) return access FcStrSet  -- /usr/local/include/fontconfig/fontconfig.h:612
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigGetDefaultLangs";

   function FcGetDefaultLangs return access FcStrSet  -- /usr/local/include/fontconfig/fontconfig.h:615
   with Import => True, 
        Convention => C, 
        External_Name => "FcGetDefaultLangs";

   procedure FcConfigSetDefaultSubstitute (config : access FcConfig; pattern : access FcPattern)  -- /usr/local/include/fontconfig/fontconfig.h:618
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigSetDefaultSubstitute";

   procedure FcDefaultSubstitute (pattern : access FcPattern)  -- /usr/local/include/fontconfig/fontconfig.h:622
   with Import => True, 
        Convention => C, 
        External_Name => "FcDefaultSubstitute";

   function FcFileIsDir (file : access FcChar8) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:626
   with Import => True, 
        Convention => C, 
        External_Name => "FcFileIsDir";

   function FcFileScan
     (set : access FcFontSet;
      dirs : access FcStrSet;
      cache : access FcFileCache;
      blanks : access FcBlanks;
      file : access FcChar8;
      force : FcBool) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:629
   with Import => True, 
        Convention => C, 
        External_Name => "FcFileScan";

   function FcDirScan
     (set : access FcFontSet;
      dirs : access FcStrSet;
      cache : access FcFileCache;
      blanks : access FcBlanks;
      dir : access FcChar8;
      force : FcBool) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:637
   with Import => True, 
        Convention => C, 
        External_Name => "FcDirScan";

   function FcDirSave
     (set : access FcFontSet;
      dirs : access FcStrSet;
      dir : access FcChar8) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:645
   with Import => True, 
        Convention => C, 
        External_Name => "FcDirSave";

   function FcDirCacheLoad
     (dir : access FcChar8;
      config : access FcConfig;
      cache_file : System.Address) return access FcCache  -- /usr/local/include/fontconfig/fontconfig.h:648
   with Import => True, 
        Convention => C, 
        External_Name => "FcDirCacheLoad";

   function FcDirCacheRescan (dir : access FcChar8; config : access FcConfig) return access FcCache  -- /usr/local/include/fontconfig/fontconfig.h:651
   with Import => True, 
        Convention => C, 
        External_Name => "FcDirCacheRescan";

   function FcDirCacheRead
     (dir : access FcChar8;
      force : FcBool;
      config : access FcConfig) return access FcCache  -- /usr/local/include/fontconfig/fontconfig.h:654
   with Import => True, 
        Convention => C, 
        External_Name => "FcDirCacheRead";

   function FcDirCacheLoadFile (cache_file : access FcChar8; file_stat : access bits_struct_stat_h.stat) return access FcCache  -- /usr/local/include/fontconfig/fontconfig.h:657
   with Import => True, 
        Convention => C, 
        External_Name => "FcDirCacheLoadFile";

   procedure FcDirCacheUnload (cache : access FcCache)  -- /usr/local/include/fontconfig/fontconfig.h:660
   with Import => True, 
        Convention => C, 
        External_Name => "FcDirCacheUnload";

   function FcFreeTypeQuery
     (file : access FcChar8;
      id : unsigned;
      blanks : access FcBlanks;
      count : access int) return access FcPattern  -- /usr/local/include/fontconfig/fontconfig.h:664
   with Import => True, 
        Convention => C, 
        External_Name => "FcFreeTypeQuery";

   function FcFreeTypeQueryAll
     (file : access FcChar8;
      id : unsigned;
      blanks : access FcBlanks;
      count : access int;
      set : access FcFontSet) return unsigned  -- /usr/local/include/fontconfig/fontconfig.h:667
   with Import => True, 
        Convention => C, 
        External_Name => "FcFreeTypeQueryAll";

   function FcFontSetCreate return access FcFontSet  -- /usr/local/include/fontconfig/fontconfig.h:672
   with Import => True, 
        Convention => C, 
        External_Name => "FcFontSetCreate";

   procedure FcFontSetDestroy (s : access FcFontSet)  -- /usr/local/include/fontconfig/fontconfig.h:675
   with Import => True, 
        Convention => C, 
        External_Name => "FcFontSetDestroy";

   function FcFontSetAdd (s : access FcFontSet; font : access FcPattern) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:678
   with Import => True, 
        Convention => C, 
        External_Name => "FcFontSetAdd";

   function FcInitLoadConfig return access FcConfig  -- /usr/local/include/fontconfig/fontconfig.h:682
   with Import => True, 
        Convention => C, 
        External_Name => "FcInitLoadConfig";

   function FcInitLoadConfigAndFonts return access FcConfig  -- /usr/local/include/fontconfig/fontconfig.h:685
   with Import => True, 
        Convention => C, 
        External_Name => "FcInitLoadConfigAndFonts";

   function FcInit return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:688
   with Import => True, 
        Convention => C, 
        External_Name => "FcInit";

   procedure FcFini  -- /usr/local/include/fontconfig/fontconfig.h:691
   with Import => True, 
        Convention => C, 
        External_Name => "FcFini";

   function FcGetVersion return int  -- /usr/local/include/fontconfig/fontconfig.h:694
   with Import => True, 
        Convention => C, 
        External_Name => "FcGetVersion";

   function FcInitReinitialize return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:697
   with Import => True, 
        Convention => C, 
        External_Name => "FcInitReinitialize";

   function FcInitBringUptoDate return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:700
   with Import => True, 
        Convention => C, 
        External_Name => "FcInitBringUptoDate";

   function FcGetLangs return access FcStrSet  -- /usr/local/include/fontconfig/fontconfig.h:704
   with Import => True, 
        Convention => C, 
        External_Name => "FcGetLangs";

   function FcLangNormalize (lang : access FcChar8) return access FcChar8  -- /usr/local/include/fontconfig/fontconfig.h:707
   with Import => True, 
        Convention => C, 
        External_Name => "FcLangNormalize";

   function FcLangGetCharSet (lang : access FcChar8) return access constant FcCharSet  -- /usr/local/include/fontconfig/fontconfig.h:710
   with Import => True, 
        Convention => C, 
        External_Name => "FcLangGetCharSet";

   function FcLangSetCreate return access FcLangSet  -- /usr/local/include/fontconfig/fontconfig.h:713
   with Import => True, 
        Convention => C, 
        External_Name => "FcLangSetCreate";

   procedure FcLangSetDestroy (ls : access FcLangSet)  -- /usr/local/include/fontconfig/fontconfig.h:716
   with Import => True, 
        Convention => C, 
        External_Name => "FcLangSetDestroy";

   function FcLangSetCopy (ls : access constant FcLangSet) return access FcLangSet  -- /usr/local/include/fontconfig/fontconfig.h:719
   with Import => True, 
        Convention => C, 
        External_Name => "FcLangSetCopy";

   function FcLangSetAdd (ls : access FcLangSet; lang : access FcChar8) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:722
   with Import => True, 
        Convention => C, 
        External_Name => "FcLangSetAdd";

   function FcLangSetDel (ls : access FcLangSet; lang : access FcChar8) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:725
   with Import => True, 
        Convention => C, 
        External_Name => "FcLangSetDel";

   function FcLangSetHasLang (ls : access constant FcLangSet; lang : access FcChar8) return FcLangResult  -- /usr/local/include/fontconfig/fontconfig.h:728
   with Import => True, 
        Convention => C, 
        External_Name => "FcLangSetHasLang";

   function FcLangSetCompare (lsa : access constant FcLangSet; lsb : access constant FcLangSet) return FcLangResult  -- /usr/local/include/fontconfig/fontconfig.h:731
   with Import => True, 
        Convention => C, 
        External_Name => "FcLangSetCompare";

   function FcLangSetContains (lsa : access constant FcLangSet; lsb : access constant FcLangSet) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:734
   with Import => True, 
        Convention => C, 
        External_Name => "FcLangSetContains";

   function FcLangSetEqual (lsa : access constant FcLangSet; lsb : access constant FcLangSet) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:737
   with Import => True, 
        Convention => C, 
        External_Name => "FcLangSetEqual";

   function FcLangSetHash (ls : access constant FcLangSet) return FcChar32  -- /usr/local/include/fontconfig/fontconfig.h:740
   with Import => True, 
        Convention => C, 
        External_Name => "FcLangSetHash";

   function FcLangSetGetLangs (ls : access constant FcLangSet) return access FcStrSet  -- /usr/local/include/fontconfig/fontconfig.h:743
   with Import => True, 
        Convention => C, 
        External_Name => "FcLangSetGetLangs";

   function FcLangSetUnion (a : access constant FcLangSet; b : access constant FcLangSet) return access FcLangSet  -- /usr/local/include/fontconfig/fontconfig.h:746
   with Import => True, 
        Convention => C, 
        External_Name => "FcLangSetUnion";

   function FcLangSetSubtract (a : access constant FcLangSet; b : access constant FcLangSet) return access FcLangSet  -- /usr/local/include/fontconfig/fontconfig.h:749
   with Import => True, 
        Convention => C, 
        External_Name => "FcLangSetSubtract";

   function FcObjectSetCreate return access FcObjectSet  -- /usr/local/include/fontconfig/fontconfig.h:753
   with Import => True, 
        Convention => C, 
        External_Name => "FcObjectSetCreate";

   function FcObjectSetAdd (os : access FcObjectSet; object : Interfaces.C.Strings.chars_ptr) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:756
   with Import => True, 
        Convention => C, 
        External_Name => "FcObjectSetAdd";

   procedure FcObjectSetDestroy (os : access FcObjectSet)  -- /usr/local/include/fontconfig/fontconfig.h:759
   with Import => True, 
        Convention => C, 
        External_Name => "FcObjectSetDestroy";

   function FcObjectSetVaBuild (first : Interfaces.C.Strings.chars_ptr; va : access System.Address) return access FcObjectSet  -- /usr/local/include/fontconfig/fontconfig.h:762
   with Import => True, 
        Convention => C, 
        External_Name => "FcObjectSetVaBuild";

   function FcObjectSetBuild (first : Interfaces.C.Strings.chars_ptr  -- , ...
      ) return access FcObjectSet  -- /usr/local/include/fontconfig/fontconfig.h:765
   with Import => True, 
        Convention => C, 
        External_Name => "FcObjectSetBuild";

   function FcFontSetList
     (config : access FcConfig;
      sets : System.Address;
      nsets : int;
      p : access FcPattern;
      os : access FcObjectSet) return access FcFontSet  -- /usr/local/include/fontconfig/fontconfig.h:768
   with Import => True, 
        Convention => C, 
        External_Name => "FcFontSetList";

   function FcFontList
     (config : access FcConfig;
      p : access FcPattern;
      os : access FcObjectSet) return access FcFontSet  -- /usr/local/include/fontconfig/fontconfig.h:775
   with Import => True, 
        Convention => C, 
        External_Name => "FcFontList";

   function FcAtomicCreate (file : access FcChar8) return access FcAtomic  -- /usr/local/include/fontconfig/fontconfig.h:782
   with Import => True, 
        Convention => C, 
        External_Name => "FcAtomicCreate";

   function FcAtomicLock (atomic : access FcAtomic) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:785
   with Import => True, 
        Convention => C, 
        External_Name => "FcAtomicLock";

   function FcAtomicNewFile (atomic : access FcAtomic) return access FcChar8  -- /usr/local/include/fontconfig/fontconfig.h:788
   with Import => True, 
        Convention => C, 
        External_Name => "FcAtomicNewFile";

   function FcAtomicOrigFile (atomic : access FcAtomic) return access FcChar8  -- /usr/local/include/fontconfig/fontconfig.h:791
   with Import => True, 
        Convention => C, 
        External_Name => "FcAtomicOrigFile";

   function FcAtomicReplaceOrig (atomic : access FcAtomic) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:794
   with Import => True, 
        Convention => C, 
        External_Name => "FcAtomicReplaceOrig";

   procedure FcAtomicDeleteNew (atomic : access FcAtomic)  -- /usr/local/include/fontconfig/fontconfig.h:797
   with Import => True, 
        Convention => C, 
        External_Name => "FcAtomicDeleteNew";

   procedure FcAtomicUnlock (atomic : access FcAtomic)  -- /usr/local/include/fontconfig/fontconfig.h:800
   with Import => True, 
        Convention => C, 
        External_Name => "FcAtomicUnlock";

   procedure FcAtomicDestroy (atomic : access FcAtomic)  -- /usr/local/include/fontconfig/fontconfig.h:803
   with Import => True, 
        Convention => C, 
        External_Name => "FcAtomicDestroy";

   function FcFontSetMatch
     (config : access FcConfig;
      sets : System.Address;
      nsets : int;
      p : access FcPattern;
      result : access FcResult) return access FcPattern  -- /usr/local/include/fontconfig/fontconfig.h:807
   with Import => True, 
        Convention => C, 
        External_Name => "FcFontSetMatch";

   function FcFontMatch
     (config : access FcConfig;
      p : access FcPattern;
      result : access FcResult) return access FcPattern  -- /usr/local/include/fontconfig/fontconfig.h:814
   with Import => True, 
        Convention => C, 
        External_Name => "FcFontMatch";

   function FcFontRenderPrepare
     (config : access FcConfig;
      pat : access FcPattern;
      font : access FcPattern) return access FcPattern  -- /usr/local/include/fontconfig/fontconfig.h:819
   with Import => True, 
        Convention => C, 
        External_Name => "FcFontRenderPrepare";

   function FcFontSetSort
     (config : access FcConfig;
      sets : System.Address;
      nsets : int;
      p : access FcPattern;
      trim : FcBool;
      csp : System.Address;
      result : access FcResult) return access FcFontSet  -- /usr/local/include/fontconfig/fontconfig.h:824
   with Import => True, 
        Convention => C, 
        External_Name => "FcFontSetSort";

   function FcFontSort
     (config : access FcConfig;
      p : access FcPattern;
      trim : FcBool;
      csp : System.Address;
      result : access FcResult) return access FcFontSet  -- /usr/local/include/fontconfig/fontconfig.h:833
   with Import => True, 
        Convention => C, 
        External_Name => "FcFontSort";

   procedure FcFontSetSortDestroy (fs : access FcFontSet)  -- /usr/local/include/fontconfig/fontconfig.h:840
   with Import => True, 
        Convention => C, 
        External_Name => "FcFontSetSortDestroy";

   function FcMatrixCopy (mat : access constant FcMatrix) return access FcMatrix  -- /usr/local/include/fontconfig/fontconfig.h:844
   with Import => True, 
        Convention => C, 
        External_Name => "FcMatrixCopy";

   function FcMatrixEqual (mat1 : access constant FcMatrix; mat2 : access constant FcMatrix) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:847
   with Import => True, 
        Convention => C, 
        External_Name => "FcMatrixEqual";

   procedure FcMatrixMultiply
     (result : access FcMatrix;
      a : access constant FcMatrix;
      b : access constant FcMatrix)  -- /usr/local/include/fontconfig/fontconfig.h:850
   with Import => True, 
        Convention => C, 
        External_Name => "FcMatrixMultiply";

   procedure FcMatrixRotate
     (m : access FcMatrix;
      c : double;
      s : double)  -- /usr/local/include/fontconfig/fontconfig.h:853
   with Import => True, 
        Convention => C, 
        External_Name => "FcMatrixRotate";

   procedure FcMatrixScale
     (m : access FcMatrix;
      sx : double;
      sy : double)  -- /usr/local/include/fontconfig/fontconfig.h:856
   with Import => True, 
        Convention => C, 
        External_Name => "FcMatrixScale";

   procedure FcMatrixShear
     (m : access FcMatrix;
      sh : double;
      sv : double)  -- /usr/local/include/fontconfig/fontconfig.h:859
   with Import => True, 
        Convention => C, 
        External_Name => "FcMatrixShear";

   function FcNameRegisterObjectTypes (types : access constant FcObjectType; ntype : int) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:865
   with Import => True, 
        Convention => C, 
        External_Name => "FcNameRegisterObjectTypes";

   function FcNameUnregisterObjectTypes (types : access constant FcObjectType; ntype : int) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:869
   with Import => True, 
        Convention => C, 
        External_Name => "FcNameUnregisterObjectTypes";

   function FcNameGetObjectType (object : Interfaces.C.Strings.chars_ptr) return access constant FcObjectType  -- /usr/local/include/fontconfig/fontconfig.h:872
   with Import => True, 
        Convention => C, 
        External_Name => "FcNameGetObjectType";

   function FcNameRegisterConstants (consts : access constant FcConstant; nconsts : int) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:876
   with Import => True, 
        Convention => C, 
        External_Name => "FcNameRegisterConstants";

   function FcNameUnregisterConstants (consts : access constant FcConstant; nconsts : int) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:880
   with Import => True, 
        Convention => C, 
        External_Name => "FcNameUnregisterConstants";

   function FcNameGetConstant (string : access FcChar8) return access constant FcConstant  -- /usr/local/include/fontconfig/fontconfig.h:883
   with Import => True, 
        Convention => C, 
        External_Name => "FcNameGetConstant";

   function FcNameGetConstantFor (string : access FcChar8; object : Interfaces.C.Strings.chars_ptr) return access constant FcConstant  -- /usr/local/include/fontconfig/fontconfig.h:886
   with Import => True, 
        Convention => C, 
        External_Name => "FcNameGetConstantFor";

   function FcNameConstant (string : access FcChar8; result : access int) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:889
   with Import => True, 
        Convention => C, 
        External_Name => "FcNameConstant";

   function FcNameParse (name : access FcChar8) return access FcPattern  -- /usr/local/include/fontconfig/fontconfig.h:892
   with Import => True, 
        Convention => C, 
        External_Name => "FcNameParse";

   function FcNameUnparse (pat : access FcPattern) return access FcChar8  -- /usr/local/include/fontconfig/fontconfig.h:895
   with Import => True, 
        Convention => C, 
        External_Name => "FcNameUnparse";

   function FcPatternCreate return access FcPattern  -- /usr/local/include/fontconfig/fontconfig.h:899
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternCreate";

   function FcPatternDuplicate (p : access constant FcPattern) return access FcPattern  -- /usr/local/include/fontconfig/fontconfig.h:902
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternDuplicate";

   procedure FcPatternReference (p : access FcPattern)  -- /usr/local/include/fontconfig/fontconfig.h:905
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternReference";

   function FcPatternFilter (p : access FcPattern; os : access constant FcObjectSet) return access FcPattern  -- /usr/local/include/fontconfig/fontconfig.h:908
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternFilter";

   procedure FcValueDestroy (v : FcValue)  -- /usr/local/include/fontconfig/fontconfig.h:911
   with Import => True, 
        Convention => C, 
        External_Name => "FcValueDestroy";

   function FcValueEqual (va : FcValue; vb : FcValue) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:914
   with Import => True, 
        Convention => C, 
        External_Name => "FcValueEqual";

   function FcValueSave (v : FcValue) return FcValue  -- /usr/local/include/fontconfig/fontconfig.h:917
   with Import => True, 
        Convention => C, 
        External_Name => "FcValueSave";

   procedure FcPatternDestroy (p : access FcPattern)  -- /usr/local/include/fontconfig/fontconfig.h:920
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternDestroy";

   function FcPatternObjectCount (pat : access constant FcPattern) return int  -- /usr/local/include/fontconfig/fontconfig.h:923
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternObjectCount";

   function FcPatternEqual (pa : access constant FcPattern; pb : access constant FcPattern) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:926
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternEqual";

   function FcPatternEqualSubset
     (pa : access constant FcPattern;
      pb : access constant FcPattern;
      os : access constant FcObjectSet) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:929
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternEqualSubset";

   function FcPatternHash (p : access constant FcPattern) return FcChar32  -- /usr/local/include/fontconfig/fontconfig.h:932
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternHash";

   function FcPatternAdd
     (p : access FcPattern;
      object : Interfaces.C.Strings.chars_ptr;
      value : FcValue;
      append : FcBool) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:935
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternAdd";

   function FcPatternAddWeak
     (p : access FcPattern;
      object : Interfaces.C.Strings.chars_ptr;
      value : FcValue;
      append : FcBool) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:938
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternAddWeak";

   function FcPatternGet
     (p : access constant FcPattern;
      object : Interfaces.C.Strings.chars_ptr;
      id : int;
      v : access FcValue) return FcResult  -- /usr/local/include/fontconfig/fontconfig.h:941
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternGet";

   function FcPatternGetWithBinding
     (p : access constant FcPattern;
      object : Interfaces.C.Strings.chars_ptr;
      id : int;
      v : access FcValue;
      b : access FcValueBinding) return FcResult  -- /usr/local/include/fontconfig/fontconfig.h:944
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternGetWithBinding";

   function FcPatternDel (p : access FcPattern; object : Interfaces.C.Strings.chars_ptr) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:947
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternDel";

   function FcPatternRemove
     (p : access FcPattern;
      object : Interfaces.C.Strings.chars_ptr;
      id : int) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:950
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternRemove";

   function FcPatternAddInteger
     (p : access FcPattern;
      object : Interfaces.C.Strings.chars_ptr;
      i : int) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:953
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternAddInteger";

   function FcPatternAddDouble
     (p : access FcPattern;
      object : Interfaces.C.Strings.chars_ptr;
      d : double) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:956
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternAddDouble";

   function FcPatternAddString
     (p : access FcPattern;
      object : Interfaces.C.Strings.chars_ptr;
      s : access FcChar8) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:959
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternAddString";

   function FcPatternAddMatrix
     (p : access FcPattern;
      object : Interfaces.C.Strings.chars_ptr;
      s : access constant FcMatrix) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:962
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternAddMatrix";

   function FcPatternAddCharSet
     (p : access FcPattern;
      object : Interfaces.C.Strings.chars_ptr;
      c : access constant FcCharSet) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:965
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternAddCharSet";

   function FcPatternAddBool
     (p : access FcPattern;
      object : Interfaces.C.Strings.chars_ptr;
      b : FcBool) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:968
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternAddBool";

   function FcPatternAddLangSet
     (p : access FcPattern;
      object : Interfaces.C.Strings.chars_ptr;
      ls : access constant FcLangSet) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:971
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternAddLangSet";

   function FcPatternAddRange
     (p : access FcPattern;
      object : Interfaces.C.Strings.chars_ptr;
      r : access constant FcRange) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:974
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternAddRange";

   function FcPatternGetInteger
     (p : access constant FcPattern;
      object : Interfaces.C.Strings.chars_ptr;
      n : int;
      i : access int) return FcResult  -- /usr/local/include/fontconfig/fontconfig.h:977
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternGetInteger";

   function FcPatternGetDouble
     (p : access constant FcPattern;
      object : Interfaces.C.Strings.chars_ptr;
      n : int;
      d : access double) return FcResult  -- /usr/local/include/fontconfig/fontconfig.h:980
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternGetDouble";

   function FcPatternGetString
     (p : access constant FcPattern;
      object : Interfaces.C.Strings.chars_ptr;
      n : int;
      s : System.Address) return FcResult  -- /usr/local/include/fontconfig/fontconfig.h:983
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternGetString";

   function FcPatternGetMatrix
     (p : access constant FcPattern;
      object : Interfaces.C.Strings.chars_ptr;
      n : int;
      s : System.Address) return FcResult  -- /usr/local/include/fontconfig/fontconfig.h:986
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternGetMatrix";

   function FcPatternGetCharSet
     (p : access constant FcPattern;
      object : Interfaces.C.Strings.chars_ptr;
      n : int;
      c : System.Address) return FcResult  -- /usr/local/include/fontconfig/fontconfig.h:989
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternGetCharSet";

   function FcPatternGetBool
     (p : access constant FcPattern;
      object : Interfaces.C.Strings.chars_ptr;
      n : int;
      b : access FcBool) return FcResult  -- /usr/local/include/fontconfig/fontconfig.h:992
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternGetBool";

   function FcPatternGetLangSet
     (p : access constant FcPattern;
      object : Interfaces.C.Strings.chars_ptr;
      n : int;
      ls : System.Address) return FcResult  -- /usr/local/include/fontconfig/fontconfig.h:995
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternGetLangSet";

   function FcPatternGetRange
     (p : access constant FcPattern;
      object : Interfaces.C.Strings.chars_ptr;
      id : int;
      r : System.Address) return FcResult  -- /usr/local/include/fontconfig/fontconfig.h:998
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternGetRange";

   function FcPatternVaBuild (p : access FcPattern; va : access System.Address) return access FcPattern  -- /usr/local/include/fontconfig/fontconfig.h:1001
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternVaBuild";

   function FcPatternBuild (p : access FcPattern  -- , ...
      ) return access FcPattern  -- /usr/local/include/fontconfig/fontconfig.h:1004
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternBuild";

   function FcPatternFormat (pat : access FcPattern; format : access FcChar8) return access FcChar8  -- /usr/local/include/fontconfig/fontconfig.h:1007
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternFormat";

   function FcRangeCreateDouble (c_begin : double; c_end : double) return access FcRange  -- /usr/local/include/fontconfig/fontconfig.h:1011
   with Import => True, 
        Convention => C, 
        External_Name => "FcRangeCreateDouble";

   function FcRangeCreateInteger (c_begin : FcChar32; c_end : FcChar32) return access FcRange  -- /usr/local/include/fontconfig/fontconfig.h:1014
   with Import => True, 
        Convention => C, 
        External_Name => "FcRangeCreateInteger";

   procedure FcRangeDestroy (c_range : access FcRange)  -- /usr/local/include/fontconfig/fontconfig.h:1017
   with Import => True, 
        Convention => C, 
        External_Name => "FcRangeDestroy";

   function FcRangeCopy (r : access constant FcRange) return access FcRange  -- /usr/local/include/fontconfig/fontconfig.h:1020
   with Import => True, 
        Convention => C, 
        External_Name => "FcRangeCopy";

   function FcRangeGetDouble
     (c_range : access constant FcRange;
      c_begin : access double;
      c_end : access double) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:1023
   with Import => True, 
        Convention => C, 
        External_Name => "FcRangeGetDouble";

   procedure FcPatternIterStart (pat : access constant FcPattern; iter : access FcPatternIter)  -- /usr/local/include/fontconfig/fontconfig.h:1026
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternIterStart";

   function FcPatternIterNext (pat : access constant FcPattern; iter : access FcPatternIter) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:1029
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternIterNext";

   function FcPatternIterEqual
     (p1 : access constant FcPattern;
      i1 : access FcPatternIter;
      p2 : access constant FcPattern;
      i2 : access FcPatternIter) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:1032
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternIterEqual";

   function FcPatternFindIter
     (pat : access constant FcPattern;
      iter : access FcPatternIter;
      object : Interfaces.C.Strings.chars_ptr) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:1036
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternFindIter";

   function FcPatternIterIsValid (pat : access constant FcPattern; iter : access FcPatternIter) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:1039
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternIterIsValid";

   function FcPatternIterGetObject (pat : access constant FcPattern; iter : access FcPatternIter) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/fontconfig/fontconfig.h:1042
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternIterGetObject";

   function FcPatternIterValueCount (pat : access constant FcPattern; iter : access FcPatternIter) return int  -- /usr/local/include/fontconfig/fontconfig.h:1045
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternIterValueCount";

   function FcPatternIterGetValue
     (pat : access constant FcPattern;
      iter : access FcPatternIter;
      id : int;
      v : access FcValue;
      b : access FcValueBinding) return FcResult  -- /usr/local/include/fontconfig/fontconfig.h:1048
   with Import => True, 
        Convention => C, 
        External_Name => "FcPatternIterGetValue";

   function FcWeightFromOpenType (ot_weight : int) return int  -- /usr/local/include/fontconfig/fontconfig.h:1053
   with Import => True, 
        Convention => C, 
        External_Name => "FcWeightFromOpenType";

   function FcWeightFromOpenTypeDouble (ot_weight : double) return double  -- /usr/local/include/fontconfig/fontconfig.h:1056
   with Import => True, 
        Convention => C, 
        External_Name => "FcWeightFromOpenTypeDouble";

   function FcWeightToOpenType (fc_weight : int) return int  -- /usr/local/include/fontconfig/fontconfig.h:1059
   with Import => True, 
        Convention => C, 
        External_Name => "FcWeightToOpenType";

   function FcWeightToOpenTypeDouble (fc_weight : double) return double  -- /usr/local/include/fontconfig/fontconfig.h:1062
   with Import => True, 
        Convention => C, 
        External_Name => "FcWeightToOpenTypeDouble";

   function FcStrCopy (s : access FcChar8) return access FcChar8  -- /usr/local/include/fontconfig/fontconfig.h:1067
   with Import => True, 
        Convention => C, 
        External_Name => "FcStrCopy";

   function FcStrCopyFilename (s : access FcChar8) return access FcChar8  -- /usr/local/include/fontconfig/fontconfig.h:1070
   with Import => True, 
        Convention => C, 
        External_Name => "FcStrCopyFilename";

   function FcStrPlus (s1 : access FcChar8; s2 : access FcChar8) return access FcChar8  -- /usr/local/include/fontconfig/fontconfig.h:1073
   with Import => True, 
        Convention => C, 
        External_Name => "FcStrPlus";

   procedure FcStrFree (s : access FcChar8)  -- /usr/local/include/fontconfig/fontconfig.h:1076
   with Import => True, 
        Convention => C, 
        External_Name => "FcStrFree";

   function FcStrDowncase (s : access FcChar8) return access FcChar8  -- /usr/local/include/fontconfig/fontconfig.h:1084
   with Import => True, 
        Convention => C, 
        External_Name => "FcStrDowncase";

   function FcStrCmpIgnoreCase (s1 : access FcChar8; s2 : access FcChar8) return int  -- /usr/local/include/fontconfig/fontconfig.h:1087
   with Import => True, 
        Convention => C, 
        External_Name => "FcStrCmpIgnoreCase";

   function FcStrCmp (s1 : access FcChar8; s2 : access FcChar8) return int  -- /usr/local/include/fontconfig/fontconfig.h:1090
   with Import => True, 
        Convention => C, 
        External_Name => "FcStrCmp";

   function FcStrStrIgnoreCase (s1 : access FcChar8; s2 : access FcChar8) return access FcChar8  -- /usr/local/include/fontconfig/fontconfig.h:1093
   with Import => True, 
        Convention => C, 
        External_Name => "FcStrStrIgnoreCase";

   function FcStrStr (s1 : access FcChar8; s2 : access FcChar8) return access FcChar8  -- /usr/local/include/fontconfig/fontconfig.h:1096
   with Import => True, 
        Convention => C, 
        External_Name => "FcStrStr";

   function FcUtf8ToUcs4
     (src_orig : access FcChar8;
      dst : access FcChar32;
      len : int) return int  -- /usr/local/include/fontconfig/fontconfig.h:1099
   with Import => True, 
        Convention => C, 
        External_Name => "FcUtf8ToUcs4";

   function FcUtf8Len
     (string : access FcChar8;
      len : int;
      nchar : access int;
      wchar : access int) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:1104
   with Import => True, 
        Convention => C, 
        External_Name => "FcUtf8Len";

   function FcUcs4ToUtf8 (ucs4 : FcChar32; dest : access FcChar8) return int  -- /usr/local/include/fontconfig/fontconfig.h:1112
   with Import => True, 
        Convention => C, 
        External_Name => "FcUcs4ToUtf8";

   function FcUtf16ToUcs4
     (src_orig : access FcChar8;
      endian : FcEndian;
      dst : access FcChar32;
      len : int) return int  -- /usr/local/include/fontconfig/fontconfig.h:1116
   with Import => True, 
        Convention => C, 
        External_Name => "FcUtf16ToUcs4";

   function FcUtf16Len
     (string : access FcChar8;
      endian : FcEndian;
      len : int;
      nchar : access int;
      wchar : access int) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:1122
   with Import => True, 
        Convention => C, 
        External_Name => "FcUtf16Len";

   function FcStrBuildFilename (path : access FcChar8  -- , ...
      ) return access FcChar8  -- /usr/local/include/fontconfig/fontconfig.h:1129
   with Import => True, 
        Convention => C, 
        External_Name => "FcStrBuildFilename";

   function FcStrDirname (file : access FcChar8) return access FcChar8  -- /usr/local/include/fontconfig/fontconfig.h:1133
   with Import => True, 
        Convention => C, 
        External_Name => "FcStrDirname";

   function FcStrBasename (file : access FcChar8) return access FcChar8  -- /usr/local/include/fontconfig/fontconfig.h:1136
   with Import => True, 
        Convention => C, 
        External_Name => "FcStrBasename";

   function FcStrSetCreate return access FcStrSet  -- /usr/local/include/fontconfig/fontconfig.h:1139
   with Import => True, 
        Convention => C, 
        External_Name => "FcStrSetCreate";

   function FcStrSetMember (set : access FcStrSet; s : access FcChar8) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:1142
   with Import => True, 
        Convention => C, 
        External_Name => "FcStrSetMember";

   function FcStrSetEqual (sa : access FcStrSet; sb : access FcStrSet) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:1145
   with Import => True, 
        Convention => C, 
        External_Name => "FcStrSetEqual";

   function FcStrSetAdd (set : access FcStrSet; s : access FcChar8) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:1148
   with Import => True, 
        Convention => C, 
        External_Name => "FcStrSetAdd";

   function FcStrSetAddFilename (set : access FcStrSet; s : access FcChar8) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:1151
   with Import => True, 
        Convention => C, 
        External_Name => "FcStrSetAddFilename";

   function FcStrSetDel (set : access FcStrSet; s : access FcChar8) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:1154
   with Import => True, 
        Convention => C, 
        External_Name => "FcStrSetDel";

   procedure FcStrSetDestroy (set : access FcStrSet)  -- /usr/local/include/fontconfig/fontconfig.h:1157
   with Import => True, 
        Convention => C, 
        External_Name => "FcStrSetDestroy";

   function FcStrListCreate (set : access FcStrSet) return access FcStrList  -- /usr/local/include/fontconfig/fontconfig.h:1160
   with Import => True, 
        Convention => C, 
        External_Name => "FcStrListCreate";

   procedure FcStrListFirst (list : access FcStrList)  -- /usr/local/include/fontconfig/fontconfig.h:1163
   with Import => True, 
        Convention => C, 
        External_Name => "FcStrListFirst";

   function FcStrListNext (list : access FcStrList) return access FcChar8  -- /usr/local/include/fontconfig/fontconfig.h:1166
   with Import => True, 
        Convention => C, 
        External_Name => "FcStrListNext";

   procedure FcStrListDone (list : access FcStrList)  -- /usr/local/include/fontconfig/fontconfig.h:1169
   with Import => True, 
        Convention => C, 
        External_Name => "FcStrListDone";

   function FcConfigParseAndLoad
     (config : access FcConfig;
      file : access FcChar8;
      complain : FcBool) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:1173
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigParseAndLoad";

   function FcConfigParseAndLoadFromMemory
     (config : access FcConfig;
      buffer : access FcChar8;
      complain : FcBool) return FcBool  -- /usr/local/include/fontconfig/fontconfig.h:1176
   with Import => True, 
        Convention => C, 
        External_Name => "FcConfigParseAndLoadFromMemory";

end fontconfig_fontconfig_h;

pragma Style_Checks (On);
pragma Warnings (On, "-gnatwu");
