pragma Ada_2012;

pragma Style_Checks (Off);
pragma Warnings (Off, "-gnatwu");

with Interfaces.C; use Interfaces.C;
with bits_stdint_intn_h;
with System;
with Interfaces.C.Strings;
with bits_stdint_uintn_h;

package capypdf_0_capypdf_h is

   CAPYPDF_VERSION_STR : aliased constant String := "0.21.0" & ASCII.NUL;  --  /usr/local/include/capypdf-0/capypdf.h:8
   CAPYPDF_VERSION_MAJOR : constant := 0;  --  /usr/local/include/capypdf-0/capypdf.h:9
   CAPYPDF_VERSION_MINOR : constant := 21;  --  /usr/local/include/capypdf-0/capypdf.h:10
   CAPYPDF_VERSION_MICRO : constant := 0;  --  /usr/local/include/capypdf-0/capypdf.h:11
   --  unsupported macro: CAPYPDF_NONNULL_ARGS __attribute__((nonnull))
   --  unsupported macro: CAPYPDF_NONNULL_ARGS_AT(...) __attribute__((nonnull(__VA_ARGS__)))
   --  unsupported macro: CAPYPDF_DEFAULT_FUNCTION_PROPS CAPYPDF_NOEXCEPT CAPYPDF_NONNULL_ARGS

   type CapyPDF_Builtin_Fonts is 
     (CAPY_FONT_TIMES_ROMAN,
      CAPY_FONT_HELVETICA,
      CAPY_FONT_COURIER,
      CAPY_FONT_SYMBOL,
      CAPY_FONT_TIMES_ROMAN_BOLD,
      CAPY_FONT_HELVETICA_BOLD,
      CAPY_FONT_COURIER_BOLD,
      CAPY_FONT_ZAPF_DINGBATS,
      CAPY_FONT_TIMES_ROMAN_ITALIC,
      CAPY_FONT_HELVETICA_OBLIQUE,
      CAPY_FONT_COURIER_OBLIQUE,
      CAPY_FONT_TIMES_ROMAN_BOLDITALIC,
      CAPY_FONT_HELVETICA_BOLDOBLIQUE,
      CAPY_FONT_COURIER_BOLDOBLIQUE)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:64

   type CapyPDF_Device_Colorspace is 
     (CAPY_DEVICE_CS_RGB,
      CAPY_DEVICE_CS_GRAY,
      CAPY_DEVICE_CS_CMYK)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:70

   type CapyPDF_Image_Colorspace is 
     (CAPY_IMAGE_CS_RGB,
      CAPY_IMAGE_CS_GRAY,
      CAPY_IMAGE_CS_CMYK)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:77

   type CapyPDF_Rendering_Intent is 
     (CAPY_RI_RELATIVE_COLORIMETRIC,
      CAPY_RI_ABSOLUTE_COLORIMETRIC,
      CAPY_RI_SATURATION,
      CAPY_RI_PERCEPTUAL)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:84

   type CapyPDF_Text_Mode is 
     (CAPY_TEXT_FILL,
      CAPY_TEXT_STROKE,
      CAPY_TEXT_FILL_STROKE,
      CAPY_TEXT_INVISIBLE,
      CAPY_TEXT_FILL_CLIP,
      CAPY_TEXT_STROKE_CLIP,
      CAPY_TEXT_FILL_STROKE_CLIP,
      CAPY_TEXT_CLIP)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:95

   type CapyPDF_Blend_Mode is 
     (CAPY_BM_NORMAL,
      CAPY_BM_MULTIPLY,
      CAPY_BM_SCREEN,
      CAPY_BM_OVERLAY,
      CAPY_BM_DARKEN,
      CAPY_BM_LIGHTEN,
      CAPY_BM_COLORDODGE,
      CAPY_BM_COLORBURN,
      CAPY_BM_HARDLIGHT,
      CAPY_BM_SOFTLIGHT,
      CAPY_BM_DIFFERENCE,
      CAPY_BM_EXCLUSION,
      CAPY_BM_HUE,
      CAPY_BM_SATURATION,
      CAPY_BM_COLOR,
      CAPY_BM_LUMINOSITY)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:114

   type CapyPDF_Line_Cap is 
     (CAPY_LC_BUTT,
      CAPY_LC_ROUND,
      CAPY_LC_PROJECTION)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:116

   type CapyPDF_Line_Annotation_End_Style is 
     (CAPY_LINE_ANNOTATION_END_SQUARE,
      CAPY_LINE_ANNOTATION_END_CIRCLE,
      CAPY_LINE_ANNOTATION_END_DIAMOND,
      CAPY_LINE_ANNOTATION_END_OPEN_ARROW,
      CAPY_LINE_ANNOTATION_END_CLOSED_ARROW,
      CAPY_LINE_ANNOTATION_END_NONE,
      CAPY_LINE_ANNOTATION_END_BUTT,
      CAPY_LINE_ANNOTATION_END_R_OPEN_ARROW,
      CAPY_LINE_ANNOTATION_END_R_CLOSED_ARROW,
      CAPY_LINE_ANNOTATION_END_SLASH)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:129

   type CapyPDF_Line_Join is 
     (CAPY_LJ_MITER,
      CAPY_LJ_ROUND,
      CAPY_LJ_BEVEL)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:135

   type CapyPDF_Draw_Context_Type is 
     (CAPY_DC_PAGE,
      CAPY_DC_COLOR_TILING,
      CAPY_DC_UCOLORED_TILING,
      CAPY_DC_FORM_XOBJECT,
      CAPY_DC_TRANSPARENCY_GROUP)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:143

   type CapyPDF_Transition_Type is 
     (CAPY_TR_SPLIT,
      CAPY_TR_BLINDS,
      CAPY_TR_BOX,
      CAPY_TR_WIPE,
      CAPY_TR_DISSOLVE,
      CAPY_TR_GLITTER,
      CAPY_TR_R,
      CAPY_TR_FLY,
      CAPY_TR_PUSH,
      CAPY_TR_COVER,
      CAPY_TR_UNCOVER,
      CAPY_TR_FADE)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:158

   type CapyPDF_Transition_Dimension is 
     (CAPY_TR_DIM_H,
      CAPY_TR_DIM_V)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:160

   type CapyPDF_Transition_Motion is 
     (CAPY_TR_M_I,
      CAPY_TR_M_O)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:162

   type CapyPDF_Page_Box is 
     (CAPY_BOX_MEDIA,
      CAPY_BOX_CROP,
      CAPY_BOX_BLEED,
      CAPY_BOX_TRIM,
      CAPY_BOX_ART)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:170

   type CapyPDF_PDFX_Type is 
     (CAPY_PDFX_1_2001,
      CAPY_PDFX_1A_2001,
      CAPY_PDFX_1A_2003,
      CAPY_PDFX_3_2002,
      CAPY_PDFX_3_2003,
      CAPY_PDFX_4,
      CAPY_PDFX_4P,
      CAPY_PDFX_5G,
      CAPY_PDFX_5PG,
      CAPY_PDFX_6,
      CAPY_PDFX_6p,
      CAPY_PDFX_6n)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:185

   type CapyPDF_PDFA_Type is 
     (CAPY_PDFA_1a,
      CAPY_PDFA_1b,
      CAPY_PDFA_2a,
      CAPY_PDFA_2b,
      CAPY_PDFA_2u,
      CAPY_PDFA_3a,
      CAPY_PDFA_3b,
      CAPY_PDFA_3u,
      CAPY_PDFA_4f,
      CAPY_PDFA_4e)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:198

   type CapyPDF_Image_Interpolation is 
     (CAPY_INTERPOLATION_AUTO,
      CAPY_INTERPOLATION_PIXELATED,
      CAPY_INTERPOLATION_SMOOTH)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:204

   type CapyPDF_Compression is 
     (CAPY_COMPRESSION_NONE,
      CAPY_COMPRESSION_DEFLATE)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:210

   subtype CapyPDF_Annotation_Flags is unsigned;
   CapyPDF_Annotation_Flags_CAPY_ANNOTATION_FLAG_NONE : constant CapyPDF_Annotation_Flags := 0;
   CapyPDF_Annotation_Flags_CAPY_ANNOTATION_FLAG_INVISIBLE : constant CapyPDF_Annotation_Flags := 1;
   CapyPDF_Annotation_Flags_CAPY_ANNOTATION_FLAG_HIDDEN : constant CapyPDF_Annotation_Flags := 2;
   CapyPDF_Annotation_Flags_CAPY_ANNOTATION_FLAG_PRINT : constant CapyPDF_Annotation_Flags := 4;
   CapyPDF_Annotation_Flags_CAPY_ANNOTATION_FLAG_NOZOOM : constant CapyPDF_Annotation_Flags := 8;
   CapyPDF_Annotation_Flags_CAPY_ANNOTATION_FLAG_NOROTATE : constant CapyPDF_Annotation_Flags := 16;
   CapyPDF_Annotation_Flags_CAPY_ANNOTATION_FLAG_NOVIEW : constant CapyPDF_Annotation_Flags := 32;
   CapyPDF_Annotation_Flags_CAPY_ANNOTATION_FLAG_READONLY : constant CapyPDF_Annotation_Flags := 64;
   CapyPDF_Annotation_Flags_CAPY_ANNOTATION_FLAG_LOCKED : constant CapyPDF_Annotation_Flags := 128;
   CapyPDF_Annotation_Flags_CAPY_ANNOTATION_FLAG_TOGGLENOVIEW : constant CapyPDF_Annotation_Flags := 256;
   CapyPDF_Annotation_Flags_CAPY_ANNOTATION_FLAG_LOCKEDCONTENTS : constant CapyPDF_Annotation_Flags := 512;  -- /usr/local/include/capypdf-0/capypdf.h:224

   type CapyPDF_Structure_Type is 
     (CAPY_STRUCTURE_TYPE_DOCUMENT,
      CAPY_STRUCTURE_TYPE_DOCUMENT_FRAGMENT,
      CAPY_STRUCTURE_TYPE_PART,
      CAPY_STRUCTURE_TYPE_SECT,
      CAPY_STRUCTURE_TYPE_DIV,
      CAPY_STRUCTURE_TYPE_ASIDE,
      CAPY_STRUCTURE_TYPE_NONSTRUCT,
      CAPY_STRUCTURE_TYPE_P,
      CAPY_STRUCTURE_TYPE_H,
      CAPY_STRUCTURE_TYPE_H1,
      CAPY_STRUCTURE_TYPE_H2,
      CAPY_STRUCTURE_TYPE_H3,
      CAPY_STRUCTURE_TYPE_H4,
      CAPY_STRUCTURE_TYPE_H5,
      CAPY_STRUCTURE_TYPE_H6,
      CAPY_STRUCTURE_TYPE_H7,
      CAPY_STRUCTURE_TYPE_TITLE,
      CAPY_STRUCTURE_TYPE_FENOTE,
      CAPY_STRUCTURE_TYPE_SUB,
      CAPY_STRUCTURE_TYPE_LBL,
      CAPY_STRUCTURE_TYPE_SPAN,
      CAPY_STRUCTURE_TYPE_EM,
      CAPY_STRUCTURE_TYPE_STRONG,
      CAPY_STRUCTURE_TYPE_LINK,
      CAPY_STRUCTURE_TYPE_ANNOT,
      CAPY_STRUCTURE_TYPE_FORM,
      CAPY_STRUCTURE_TYPE_RUBY,
      CAPY_STRUCTURE_TYPE_RB,
      CAPY_STRUCTURE_TYPE_RT,
      CAPY_STRUCTURE_TYPE_RP,
      CAPY_STRUCTURE_TYPE_WARICHU,
      CAPY_STRUCTURE_TYPE_WT,
      CAPY_STRUCTURE_TYPE_WP,
      CAPY_STRUCTURE_TYPE_L,
      CAPY_STRUCTURE_TYPE_LI,
      CAPY_STRUCTURE_TYPE_LBODY,
      CAPY_STRUCTURE_TYPE_TABLE,
      CAPY_STRUCTURE_TYPE_TR,
      CAPY_STRUCTURE_TYPE_TH,
      CAPY_STRUCTURE_TYPE_TD,
      CAPY_STRUCTURE_TYPE_THEAD,
      CAPY_STRUCTURE_TYPE_TBODY,
      CAPY_STRUCTURE_TYPE_TFOOT,
      CAPY_STRUCTURE_TYPE_CAPTION,
      CAPY_STRUCTURE_TYPE_FIGURE,
      CAPY_STRUCTURE_TYPE_FORMULA,
      CAPY_STRUCTURE_TYPE_ARTIFACT,
      CAPY_STRUCTURE_TYPE_NUM_ITEMS)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:286

   type CapyPDF_Structure_Placement is 
     (CAPY_STRUCTURE_PLACEMENT_BLOCK,
      CAPY_STRUCTURE_PLACEMENT_INLINE,
      CAPY_STRUCTURE_PLACEMENT_BEFORE,
      CAPY_STRUCTURE_PLACEMENT_START,
      CAPY_STRUCTURE_PLACEMENT_END)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:295

   type CapyPDF_Structure_Writing_Mode is 
     (CAPY_STRUCTURE_WRITING_MODE_LRTB,
      CAPY_STRUCTURE_WRITING_MODE_RLTB,
      CAPY_STRUCTURE_WRITING_MODE_TBRL,
      CAPY_STRUCTURE_WRITING_MODE_TBLR,
      CAPY_STRUCTURE_WRITING_MODE_LRBT,
      CAPY_STRUCTURE_WRITING_MODE_RLBT,
      CAPY_STRUCTURE_WRITING_MODE_BTRL,
      CAPY_STRUCTURE_WRITING_MODE_BTLR)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:307

   type CapyPDF_Form_Field_Type is 
     (CAPY_FORM_FIELD_TYPE_BTN,
      CAPY_FORM_FIELD_TYPE_TX,
      CAPY_FORM_FIELD_TYPE_CH)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:315

   subtype CapyPDF_Form_Field_Flags is unsigned;
   CapyPDF_Form_Field_Flags_CAPY_FFIELD_NONE : constant CapyPDF_Form_Field_Flags := 0;
   CapyPDF_Form_Field_Flags_CAPY_FFIELD_READONLY : constant CapyPDF_Form_Field_Flags := 1;
   CapyPDF_Form_Field_Flags_CAPY_FFIELD_REQUIRED : constant CapyPDF_Form_Field_Flags := 2;
   CapyPDF_Form_Field_Flags_CAPY_FFIELD_NOEXPORT : constant CapyPDF_Form_Field_Flags := 4;
   CapyPDF_Form_Field_Flags_CAPY_FFIELD_MULTILINE : constant CapyPDF_Form_Field_Flags := 4096;
   CapyPDF_Form_Field_Flags_CAPY_FFIELD_PASSWORD : constant CapyPDF_Form_Field_Flags := 8192;
   CapyPDF_Form_Field_Flags_CAPY_FFIELD_NOTOGGLETOOFF : constant CapyPDF_Form_Field_Flags := 16384;
   CapyPDF_Form_Field_Flags_CAPY_FFIELD_RADIO : constant CapyPDF_Form_Field_Flags := 32768;
   CapyPDF_Form_Field_Flags_CAPY_FFIELD_PUSHBUTTON : constant CapyPDF_Form_Field_Flags := 65536;
   CapyPDF_Form_Field_Flags_CAPY_FFIELD_COMBO : constant CapyPDF_Form_Field_Flags := 131072;
   CapyPDF_Form_Field_Flags_CAPY_FFIELD_EDIT : constant CapyPDF_Form_Field_Flags := 262144;
   CapyPDF_Form_Field_Flags_CAPY_FFIELD_SORT : constant CapyPDF_Form_Field_Flags := 524288;
   CapyPDF_Form_Field_Flags_CAPY_FFIELD_FILESELECT : constant CapyPDF_Form_Field_Flags := 1048576;
   CapyPDF_Form_Field_Flags_CAPY_FFIELD_MULTISELECT : constant CapyPDF_Form_Field_Flags := 2097152;
   CapyPDF_Form_Field_Flags_CAPY_FFIELD_DONOTSPELLCHECK : constant CapyPDF_Form_Field_Flags := 4194304;
   CapyPDF_Form_Field_Flags_CAPY_FFIELD_DONOTSCROLL : constant CapyPDF_Form_Field_Flags := 8388608;
   CapyPDF_Form_Field_Flags_CAPY_FFIELD_COMB : constant CapyPDF_Form_Field_Flags := 16777216;
   CapyPDF_Form_Field_Flags_CAPY_FFIELD_RICHTEXT : constant CapyPDF_Form_Field_Flags := 33554432;
   CapyPDF_Form_Field_Flags_CAPY_FFIELD_RADIOSINUNISON : constant CapyPDF_Form_Field_Flags := 33554432;
   CapyPDF_Form_Field_Flags_CAPY_FFIELD_COMMITONSELCHANGE : constant CapyPDF_Form_Field_Flags := 67108864;  -- /usr/local/include/capypdf-0/capypdf.h:340

   subtype CapyPDF_Form_Submit_Action_Flags is unsigned;
   CapyPDF_Form_Submit_Action_Flags_CAPY_FORM_ACTION_NONE : constant CapyPDF_Form_Submit_Action_Flags := 0;
   CapyPDF_Form_Submit_Action_Flags_CAPY_FORM_ACTION_INCLUEEXCLUDE : constant CapyPDF_Form_Submit_Action_Flags := 1;
   CapyPDF_Form_Submit_Action_Flags_CAPY_FORM_ACTION_INCLUDENOVALUEFIELDS : constant CapyPDF_Form_Submit_Action_Flags := 2;
   CapyPDF_Form_Submit_Action_Flags_CAPY_FORM_ACTION_EXPORTFORMAT : constant CapyPDF_Form_Submit_Action_Flags := 4;
   CapyPDF_Form_Submit_Action_Flags_CAPY_FORM_ACTION_GETMETHOD : constant CapyPDF_Form_Submit_Action_Flags := 8;
   CapyPDF_Form_Submit_Action_Flags_CAPY_FORM_ACTION_SUBMITCOORDINATES : constant CapyPDF_Form_Submit_Action_Flags := 16;
   CapyPDF_Form_Submit_Action_Flags_CAPY_FORM_ACTION_XFDF : constant CapyPDF_Form_Submit_Action_Flags := 32;
   CapyPDF_Form_Submit_Action_Flags_CAPY_FORM_ACTION_INCLUDEAPPENDSAVES : constant CapyPDF_Form_Submit_Action_Flags := 64;
   CapyPDF_Form_Submit_Action_Flags_CAPY_FORM_ACTION_INCLUDEANNOTATIONS : constant CapyPDF_Form_Submit_Action_Flags := 128;
   CapyPDF_Form_Submit_Action_Flags_CAPY_FORM_ACTION_SUBMITPDF : constant CapyPDF_Form_Submit_Action_Flags := 256;
   CapyPDF_Form_Submit_Action_Flags_CAPY_FORM_ACTION_CANONICALFORMAT : constant CapyPDF_Form_Submit_Action_Flags := 512;
   CapyPDF_Form_Submit_Action_Flags_CAPY_FORM_ACTION_EXCLNONUSERANNOTS : constant CapyPDF_Form_Submit_Action_Flags := 1024;
   CapyPDF_Form_Submit_Action_Flags_CAPY_FORM_ACTION_EXCLFKEY : constant CapyPDF_Form_Submit_Action_Flags := 2048;
   CapyPDF_Form_Submit_Action_Flags_CAPY_FORM_ACTION_EMBEDFORM : constant CapyPDF_Form_Submit_Action_Flags := 4096;  -- /usr/local/include/capypdf-0/capypdf.h:357

   type CapyPDF_Page_Label_Number_Style is 
     (CAPY_PAGE_LABEL_NUMBER_STYLE_DECIMAL,
      CAPY_PAGE_LABEL_NUMBER_STYLE_ROMAN_UPPER,
      CAPY_PAGE_LABEL_NUMBER_STYLE_ROMAN_LOWER,
      CAPY_PAGE_LABEL_NUMBER_STYLE_LETTER_UPPER,
      CAPY_PAGE_LABEL_NUMBER_STYLE_LETTER_LOWER)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:365

   type CapyPDF_Page_Layout is 
     (CAPY_PAGE_LAYOUT_SINGLE_PAGE,
      CAPY_PAGE_LAYOUT_ONE_COLUMN,
      CAPY_PAGE_LAYOUT_TWO_COLUMN_LEFT,
      CAPY_PAGE_LAYOUT_TWO_COLUMN_RIGHT,
      CAPY_PAGE_LAYOUT_TWO_PAGE_LEFT,
      CAPY_PAGE_LAYOUT_TWO_PAGE_RIGHT)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:374

   type CapyPDF_Page_Mode is 
     (CAPY_PAGE_MODE_USE_NONE,
      CAPY_PAGE_MODE_OUTLINES,
      CAPY_PAGE_MODE_THUMBS,
      CAPY_PAGE_MODE_FULL_SCREEN,
      CAPY_PAGE_MODE_OC,
      CAPY_PAGE_MODE_ATTACHMENTS)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:383

   type CapyPDF_Soft_Mask_Subtype is 
     (CAPY_SOFT_MASK_ALPHA,
      CAPY_SOFT_MASK_LUMINOSITY)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:388

   type CapyPDF_Halftone_Spot_Function is 
     (CAPY_HT_FUNC_SIMPLEDOT,
      CAPY_HT_FUNC_INVERTED_SIMPLEDOT,
      CAPY_HT_FUNC_DOUBLEDOT,
      CAPY_HT_FUNC_INVERTED_DOUBLEDOT,
      CAPY_HT_FUNC_COSINEDOT,
      CAPY_HT_FUNC_DOUBLE,
      CAPY_HT_FUNC_INVERTED_DOUBLE,
      CAPY_HT_FUNC_LINE,
      CAPY_HT_FUNC_LINEX,
      CAPY_HT_FUNC_LINEY,
      CAPY_HT_FUNC_ROUND,
      CAPY_HT_FUNC_ELLIPSE,
      CAPY_HT_FUNC_ELLIPSEA,
      CAPY_HT_FUNC_INVERTED_ELLIPSEA,
      CAPY_HT_FUNC_ELLIPSEB,
      CAPY_HT_FUNC_ELLIPSEC,
      CAPY_HT_FUNC_INVERTED_ELLIPSEC,
      CAPY_HT_FUNC_SQUARE,
      CAPY_HT_FUNC_CROSS,
      CAPY_HT_FUNC_RHOMBOID,
      CAPY_HT_FUNC_DIAMOND)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:412

   type CapyPDF_3D_File_Format is 
     (CAPY_3D_UDF,
      CAPY_3D_PRC)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:417

   type CapyPDF_Black_Point_Compensation is 
     (CAPY_BLACK_POINT_COMPENSATION_OFF,
      CAPY_BLACK_POINT_COMPENSATION_ON,
      CAPY_BLACK_POINT_COMPENSATION_DEFAULT)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:423

   type CapyPDF_Border_Style is 
     (CAPY_BORDER_STYLE_SOLID,
      CAPY_BORDER_STYLE_DASHED,
      CAPY_BORDER_STYLE_BEVELED,
      CAPY_BORDER_STYLE_INSET,
      CAPY_BORDER_STYLE_UNDERLINE)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:431

   type CapyPDF_Border_Effect is 
     (CAPY_BORDER_EFFECT_CLOUDY,
      CAPY_BORDER_EFFECT_SOLID)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:436

   type CapyPDF_Widget_Caption_Position is 
     (CAPY_WIDGET_CAPTION_NO_ICON,
      CAPY_WIDGET_CAPTION_NO_CAPTION,
      CAPY_WIDGET_CAPTION_BELOW_ICON,
      CAPY_WIDGET_CAPTION_ABOVE_ICON,
      CAPY_WIDGET_CAPTION_RIGHT_OF_ICON,
      CAPY_WIDGET_CAPTION_LEFT_OF_ICON,
      CAPY_WIDGET_CAPTION_OVERLAID)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:446

   type CapyPDF_AF_Relationship is 
     (CAPY_AF_RELATIONSHIP_SOURCE,
      CAPY_AF_RELATIONSHIP_DATA,
      CAPY_AF_RELATIONSHIP_ALTERNATIVE,
      CAPY_AF_RELATIONSHIP_SUPPLEMENT,
      CAPY_AF_RELATIONSHIP_ENCRYPTED_PAYLOAD,
      CAPY_AF_RELATIONSHIP_FORM_DATA,
      CAPY_AF_RELATIONSHIP_SCHEMA,
      CAPY_AF_RELATIONSHIP_UNSPECIFIED)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:457

   type CapyPDF_Collection_View is 
     (CAPY_COLLECTION_D,
      CAPY_COLLECTION_T,
      CAPY_COLLECTION_H,
      CAPY_COLLECTION_C)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:464

   type CapyPDF_Collection_Subtype is 
     (CAPY_COLLECTION_SUB_S,
      CAPY_COLLECTION_SUB_D,
      CAPY_COLLECTION_SUB_N,
      CAPY_COLLECTION_SUB_F,
      CAPY_COLLECTION_SUB_DESC,
      CAPY_COLLECTION_SUB_MOD_DATE,
      CAPY_COLLECTION_SUB_CREATION_DATE,
      CAPY_COLLECTION_SUB_SIZE,
      CAPY_COLLECTION_SUB_COMPRESSED_SIZE)
   with Convention => C;  -- /usr/local/include/capypdf-0/capypdf.h:476

   type u_capyPDF_DocumentProperties is null record;   -- incomplete struct

   subtype CapyPDF_DocumentProperties is u_capyPDF_DocumentProperties;  -- /usr/local/include/capypdf-0/capypdf.h:481

   type u_capyPDF_PageProperties is null record;   -- incomplete struct

   subtype CapyPDF_PageProperties is u_capyPDF_PageProperties;  -- /usr/local/include/capypdf-0/capypdf.h:482

   type u_capyPDF_TransparencyGroupProperties is null record;   -- incomplete struct

   subtype CapyPDF_TransparencyGroupProperties is u_capyPDF_TransparencyGroupProperties;  -- /usr/local/include/capypdf-0/capypdf.h:483

   type u_capyPDF_ImagePdfProperties is null record;   -- incomplete struct

   subtype CapyPDF_ImagePdfProperties is u_capyPDF_ImagePdfProperties;  -- /usr/local/include/capypdf-0/capypdf.h:484

   type u_capyPDF_FontProperties is null record;   -- incomplete struct

   subtype CapyPDF_FontProperties is u_capyPDF_FontProperties;  -- /usr/local/include/capypdf-0/capypdf.h:485

   type u_capyPDF_Color is null record;   -- incomplete struct

   subtype CapyPDF_Color is u_capyPDF_Color;  -- /usr/local/include/capypdf-0/capypdf.h:487

   type u_capyPDF_DrawContext is null record;   -- incomplete struct

   subtype CapyPDF_DrawContext is u_capyPDF_DrawContext;  -- /usr/local/include/capypdf-0/capypdf.h:488

   type u_capyPDF_Generator is null record;   -- incomplete struct

   subtype CapyPDF_Generator is u_capyPDF_Generator;  -- /usr/local/include/capypdf-0/capypdf.h:489

   type u_capyPDF_GraphicsState is null record;   -- incomplete struct

   subtype CapyPDF_GraphicsState is u_capyPDF_GraphicsState;  -- /usr/local/include/capypdf-0/capypdf.h:490

   type u_capyPDF_OptionalContentGroup is null record;   -- incomplete struct

   subtype CapyPDF_OptionalContentGroup is u_capyPDF_OptionalContentGroup;  -- /usr/local/include/capypdf-0/capypdf.h:491

   type u_capyPDF_Text is null record;   -- incomplete struct

   subtype CapyPDF_Text is u_capyPDF_Text;  -- /usr/local/include/capypdf-0/capypdf.h:492

   type u_capyPDF_TextSequence is null record;   -- incomplete struct

   subtype CapyPDF_TextSequence is u_capyPDF_TextSequence;  -- /usr/local/include/capypdf-0/capypdf.h:493

   type u_capyPDF_Transition is null record;   -- incomplete struct

   subtype CapyPDF_Transition is u_capyPDF_Transition;  -- /usr/local/include/capypdf-0/capypdf.h:494

   type u_capyPDF_RasterImage is null record;   -- incomplete struct

   subtype CapyPDF_RasterImage is u_capyPDF_RasterImage;  -- /usr/local/include/capypdf-0/capypdf.h:495

   type u_capyPDF_RasterImageBuilder is null record;   -- incomplete struct

   subtype CapyPDF_RasterImageBuilder is u_capyPDF_RasterImageBuilder;  -- /usr/local/include/capypdf-0/capypdf.h:496

   type u_capyPDF_Function is null record;   -- incomplete struct

   subtype CapyPDF_Function is u_capyPDF_Function;  -- /usr/local/include/capypdf-0/capypdf.h:497

   type u_capyPDF_Shading is null record;   -- incomplete struct

   subtype CapyPDF_Shading is u_capyPDF_Shading;  -- /usr/local/include/capypdf-0/capypdf.h:498

   type u_capyPDF_Annotation is null record;   -- incomplete struct

   subtype CapyPDF_Annotation is u_capyPDF_Annotation;  -- /usr/local/include/capypdf-0/capypdf.h:499

   type u_capyPDF_StructItemExtraData is null record;   -- incomplete struct

   subtype CapyPDF_StructItemExtraData is u_capyPDF_StructItemExtraData;  -- /usr/local/include/capypdf-0/capypdf.h:500

   type u_capyPDF_Destination is null record;   -- incomplete struct

   subtype CapyPDF_Destination is u_capyPDF_Destination;  -- /usr/local/include/capypdf-0/capypdf.h:501

   type u_capyPDF_Outline is null record;   -- incomplete struct

   subtype CapyPDF_Outline is u_capyPDF_Outline;  -- /usr/local/include/capypdf-0/capypdf.h:502

   type u_capyPDF_ShadingPattern is null record;   -- incomplete struct

   subtype CapyPDF_ShadingPattern is u_capyPDF_ShadingPattern;  -- /usr/local/include/capypdf-0/capypdf.h:503

   type u_capyPDF_SoftMask is null record;   -- incomplete struct

   subtype CapyPDF_SoftMask is u_capyPDF_SoftMask;  -- /usr/local/include/capypdf-0/capypdf.h:504

   type u_capyPDF_EmbeddedFile is null record;   -- incomplete struct

   subtype CapyPDF_EmbeddedFile is u_capyPDF_EmbeddedFile;  -- /usr/local/include/capypdf-0/capypdf.h:505

   type u_capyPDF_BDCTags is null record;   -- incomplete struct

   subtype CapyPDF_BDCTags is u_capyPDF_BDCTags;  -- /usr/local/include/capypdf-0/capypdf.h:506

   type u_capyPDF_Halftone is null record;   -- incomplete struct

   subtype CapyPDF_Halftone is u_capyPDF_Halftone;  -- /usr/local/include/capypdf-0/capypdf.h:507

   type u_capyPDF_3DStream is null record;   -- incomplete struct

   subtype CapyPDF_3DStream is u_capyPDF_3DStream;  -- /usr/local/include/capypdf-0/capypdf.h:508

   type u_capyPDF_FormField is null record;   -- incomplete struct

   subtype CapyPDF_FormField is u_capyPDF_FormField;  -- /usr/local/include/capypdf-0/capypdf.h:509

   type u_capyPDF_NumberFormat is null record;   -- incomplete struct

   subtype CapyPDF_NumberFormat is u_capyPDF_NumberFormat;  -- /usr/local/include/capypdf-0/capypdf.h:510

   type u_capyPDF_Measure is null record;   -- incomplete struct

   subtype CapyPDF_Measure is u_capyPDF_Measure;  -- /usr/local/include/capypdf-0/capypdf.h:511

   type u_capyPDF_Viewport is null record;   -- incomplete struct

   subtype CapyPDF_Viewport is u_capyPDF_Viewport;  -- /usr/local/include/capypdf-0/capypdf.h:512

   type u_capyPDF_Collection is null record;   -- incomplete struct

   subtype CapyPDF_Collection is u_capyPDF_Collection;  -- /usr/local/include/capypdf-0/capypdf.h:513

   type u_capyPDF_CollectionSchema is null record;   -- incomplete struct

   subtype CapyPDF_CollectionSchema is u_capyPDF_CollectionSchema;  -- /usr/local/include/capypdf-0/capypdf.h:514

   type u_capyPDF_CollectionField is null record;   -- incomplete struct

   subtype CapyPDF_CollectionField is u_capyPDF_CollectionField;  -- /usr/local/include/capypdf-0/capypdf.h:515

   subtype CapyPDF_EC is bits_stdint_intn_h.int32_t;  -- /usr/local/include/capypdf-0/capypdf.h:517

   type CapyPDF_AnnotationId is record
      id : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/capypdf-0/capypdf.h:520
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/capypdf-0/capypdf.h:521

   type CapyPDF_EmbeddedFileId is record
      id : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/capypdf-0/capypdf.h:524
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/capypdf-0/capypdf.h:525

   type CapyPDF_FontId is record
      id : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/capypdf-0/capypdf.h:528
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/capypdf-0/capypdf.h:529

   type CapyPDF_FormFieldId is record
      id : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/capypdf-0/capypdf.h:532
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/capypdf-0/capypdf.h:533

   type CapyPDF_FormXObjectId is record
      id : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/capypdf-0/capypdf.h:536
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/capypdf-0/capypdf.h:537

   type CapyPDF_GraphicsStateId is record
      id : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/capypdf-0/capypdf.h:540
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/capypdf-0/capypdf.h:541

   type CapyPDF_IccColorSpaceId is record
      id : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/capypdf-0/capypdf.h:544
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/capypdf-0/capypdf.h:545

   type CapyPDF_LabColorSpaceId is record
      id : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/capypdf-0/capypdf.h:548
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/capypdf-0/capypdf.h:549

   type CapyPDF_ImageId is record
      id : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/capypdf-0/capypdf.h:552
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/capypdf-0/capypdf.h:553

   type CapyPDF_OptionalContentGroupId is record
      id : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/capypdf-0/capypdf.h:556
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/capypdf-0/capypdf.h:557

   type CapyPDF_StructureItemId is record
      id : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/capypdf-0/capypdf.h:560
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/capypdf-0/capypdf.h:561

   type CapyPDF_TransparencyGroupId is record
      id : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/capypdf-0/capypdf.h:564
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/capypdf-0/capypdf.h:565

   type CapyPDF_SoftMaskId is record
      id : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/capypdf-0/capypdf.h:568
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/capypdf-0/capypdf.h:569

   type CapyPDF_FunctionId is record
      id : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/capypdf-0/capypdf.h:572
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/capypdf-0/capypdf.h:573

   type CapyPDF_ShadingId is record
      id : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/capypdf-0/capypdf.h:576
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/capypdf-0/capypdf.h:577

   type CapyPDF_OutlineId is record
      id : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/capypdf-0/capypdf.h:580
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/capypdf-0/capypdf.h:581

   type CapyPDF_SeparationId is record
      id : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/capypdf-0/capypdf.h:584
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/capypdf-0/capypdf.h:585

   type CapyPDF_PatternId is record
      id : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/capypdf-0/capypdf.h:588
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/capypdf-0/capypdf.h:589

   type CapyPDF_RoleId is record
      id : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/capypdf-0/capypdf.h:592
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/capypdf-0/capypdf.h:593

   type CapyPDF_3DStreamId is record
      id : aliased bits_stdint_intn_h.int32_t;  -- /usr/local/include/capypdf-0/capypdf.h:596
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/capypdf-0/capypdf.h:597

   function capy_document_properties_new (out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:601
   with Import => True, 
        Convention => C, 
        External_Name => "capy_document_properties_new";

   function capy_document_properties_destroy (docprops : access CapyPDF_DocumentProperties) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:603
   with Import => True, 
        Convention => C, 
        External_Name => "capy_document_properties_destroy";

   function capy_document_properties_set_title
     (docprops : access CapyPDF_DocumentProperties;
      utf8_title : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:605
   with Import => True, 
        Convention => C, 
        External_Name => "capy_document_properties_set_title";

   function capy_document_properties_set_author
     (docprops : access CapyPDF_DocumentProperties;
      utf8_author : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:609
   with Import => True, 
        Convention => C, 
        External_Name => "capy_document_properties_set_author";

   function capy_document_properties_set_creator
     (docprops : access CapyPDF_DocumentProperties;
      utf8_creator : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:613
   with Import => True, 
        Convention => C, 
        External_Name => "capy_document_properties_set_creator";

   function capy_document_properties_set_language
     (docprops : access CapyPDF_DocumentProperties;
      lang : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:618
   with Import => True, 
        Convention => C, 
        External_Name => "capy_document_properties_set_language";

   function capy_document_properties_set_device_profile
     (docprops : access CapyPDF_DocumentProperties;
      cs : CapyPDF_Device_Colorspace;
      profile_path : Interfaces.C.Strings.chars_ptr) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:621
   with Import => True, 
        Convention => C, 
        External_Name => "capy_document_properties_set_device_profile";

   function capy_document_properties_set_colorspace (docprops : access CapyPDF_DocumentProperties; cs : CapyPDF_Device_Colorspace) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:625
   with Import => True, 
        Convention => C, 
        External_Name => "capy_document_properties_set_colorspace";

   function capy_document_properties_set_output_intent
     (docprops : access CapyPDF_DocumentProperties;
      identifier : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:629
   with Import => True, 
        Convention => C, 
        External_Name => "capy_document_properties_set_output_intent";

   function capy_document_properties_set_pdfx (docprops : access CapyPDF_DocumentProperties; xtype : CapyPDF_PDFX_Type) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:632
   with Import => True, 
        Convention => C, 
        External_Name => "capy_document_properties_set_pdfx";

   function capy_document_properties_set_pdfa (docprops : access CapyPDF_DocumentProperties; atype : CapyPDF_PDFA_Type) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:634
   with Import => True, 
        Convention => C, 
        External_Name => "capy_document_properties_set_pdfa";

   function capy_document_properties_set_default_page_properties (docprops : access CapyPDF_DocumentProperties; prop : access constant CapyPDF_PageProperties) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:636
   with Import => True, 
        Convention => C, 
        External_Name => "capy_document_properties_set_default_page_properties";

   function capy_document_properties_set_tagged (docprops : access CapyPDF_DocumentProperties; is_tagged : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:639
   with Import => True, 
        Convention => C, 
        External_Name => "capy_document_properties_set_tagged";

   function capy_document_properties_set_page_layout (docprops : access CapyPDF_DocumentProperties; layout : CapyPDF_Page_Layout) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:642
   with Import => True, 
        Convention => C, 
        External_Name => "capy_document_properties_set_page_layout";

   function capy_document_properties_set_page_mode (docprops : access CapyPDF_DocumentProperties; mode : CapyPDF_Page_Mode) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:644
   with Import => True, 
        Convention => C, 
        External_Name => "capy_document_properties_set_page_mode";

   function capy_document_properties_set_metadata_xml
     (docprops : access CapyPDF_DocumentProperties;
      rdf_xml : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:647
   with Import => True, 
        Convention => C, 
        External_Name => "capy_document_properties_set_metadata_xml";

   function capy_page_properties_new (out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:652
   with Import => True, 
        Convention => C, 
        External_Name => "capy_page_properties_new";

   function capy_page_properties_destroy (pageprops : access CapyPDF_PageProperties) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:654
   with Import => True, 
        Convention => C, 
        External_Name => "capy_page_properties_destroy";

   function capy_page_properties_set_pagebox
     (pageprops : access CapyPDF_PageProperties;
      boxtype : CapyPDF_Page_Box;
      x1 : double;
      y1 : double;
      x2 : double;
      y2 : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:656
   with Import => True, 
        Convention => C, 
        External_Name => "capy_page_properties_set_pagebox";

   function capy_page_properties_set_transparency_group_properties (pageprops : access CapyPDF_PageProperties; trprop : access CapyPDF_TransparencyGroupProperties) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:663
   with Import => True, 
        Convention => C, 
        External_Name => "capy_page_properties_set_transparency_group_properties";

   function capy_generator_new
     (filename : Interfaces.C.Strings.chars_ptr;
      docprops : access constant CapyPDF_DocumentProperties;
      out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:669
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_new";

   function capy_generator_add_page (g : access CapyPDF_Generator; ctx : access CapyPDF_DrawContext) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:673
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_add_page";

   function capy_generator_add_page_labeling
     (gen : access CapyPDF_Generator;
      start_page : bits_stdint_uintn_h.uint32_t;
      style : access CapyPDF_Page_Label_Number_Style;
      prefix : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t;
      start_num : access bits_stdint_uintn_h.uint32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:675
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_add_page_labeling";

   function capy_generator_add_form_xobject
     (gen : access CapyPDF_Generator;
      ctx : access CapyPDF_DrawContext;
      out_ptr : access CapyPDF_FormXObjectId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:682
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_add_form_xobject";

   function capy_generator_add_transparency_group
     (gen : access CapyPDF_Generator;
      ctx : access CapyPDF_DrawContext;
      out_ptr : access CapyPDF_TransparencyGroupId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:686
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_add_transparency_group";

   function capy_generator_add_soft_mask
     (gen : access CapyPDF_Generator;
      sm : access constant CapyPDF_SoftMask;
      out_ptr : access CapyPDF_SoftMaskId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:690
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_add_soft_mask";

   function capy_generator_add_shading_pattern
     (g : access CapyPDF_Generator;
      shp : access CapyPDF_ShadingPattern;
      out_ptr : access CapyPDF_PatternId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:694
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_add_shading_pattern";

   function capy_generator_add_tiling_pattern
     (g : access CapyPDF_Generator;
      ctx : access CapyPDF_DrawContext;
      out_ptr : access CapyPDF_PatternId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:698
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_add_tiling_pattern";

   function capy_generator_embed_file
     (g : access CapyPDF_Generator;
      efile : access CapyPDF_EmbeddedFile;
      out_ptr : access CapyPDF_EmbeddedFileId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:702
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_embed_file";

   function capy_generator_load_font
     (gen : access CapyPDF_Generator;
      fname : Interfaces.C.Strings.chars_ptr;
      fprop : access CapyPDF_FontProperties;
      out_ptr : access CapyPDF_FontId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:706
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_load_font";

   function capy_generator_load_image
     (gen : access CapyPDF_Generator;
      fname : Interfaces.C.Strings.chars_ptr;
      out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:711
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_load_image";

   function capy_generator_load_image_from_memory
     (gen : access CapyPDF_Generator;
      buf : Interfaces.C.Strings.chars_ptr;
      bufsize : bits_stdint_intn_h.int64_t;
      out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:715
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_load_image_from_memory";

   function capy_generator_convert_image
     (gen : access CapyPDF_Generator;
      source : access constant CapyPDF_RasterImage;
      output_cs : CapyPDF_Device_Colorspace;
      ri : CapyPDF_Rendering_Intent;
      out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:721
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_convert_image";

   function capy_generator_add_image
     (gen : access CapyPDF_Generator;
      image : access CapyPDF_RasterImage;
      params : access constant CapyPDF_ImagePdfProperties;
      out_ptr : access CapyPDF_ImageId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:727
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_add_image";

   function capy_generator_add_function
     (gen : access CapyPDF_Generator;
      func : access CapyPDF_Function;
      out_ptr : access CapyPDF_FunctionId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:732
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_add_function";

   function capy_generator_add_shading
     (gen : access CapyPDF_Generator;
      shade : access CapyPDF_Shading;
      out_ptr : access CapyPDF_ShadingId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:736
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_add_shading";

   function capy_generator_add_graphics_state
     (gen : access CapyPDF_Generator;
      state : access constant CapyPDF_GraphicsState;
      out_ptr : access CapyPDF_GraphicsStateId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:740
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_add_graphics_state";

   function capy_generator_add_structure_item
     (gen : access CapyPDF_Generator;
      stype : CapyPDF_Structure_Type;
      parent : access constant CapyPDF_StructureItemId;
      extra : access CapyPDF_StructItemExtraData;
      out_ptr : access CapyPDF_StructureItemId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:744
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_add_structure_item";

   function capy_generator_add_custom_structure_item
     (gen : access CapyPDF_Generator;
      role : CapyPDF_RoleId;
      parent : access constant CapyPDF_StructureItemId;
      extra : access CapyPDF_StructItemExtraData;
      out_ptr : access CapyPDF_StructureItemId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:750
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_add_custom_structure_item";

   function capy_generator_add_3d_stream
     (gen : access CapyPDF_Generator;
      stream : access CapyPDF_3DStream;
      out_ptr : access CapyPDF_3DStreamId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:756
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_add_3d_stream";

   function capy_generator_load_icc_profile
     (gen : access CapyPDF_Generator;
      fname : Interfaces.C.Strings.chars_ptr;
      out_ptr : access CapyPDF_IccColorSpaceId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:761
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_load_icc_profile";

   function capy_generator_add_icc_profile
     (gen : access CapyPDF_Generator;
      buf : Interfaces.C.Strings.chars_ptr;
      bufsize : bits_stdint_uintn_h.uint64_t;
      num_channels : bits_stdint_uintn_h.uint32_t;
      out_ptr : access CapyPDF_IccColorSpaceId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:765
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_add_icc_profile";

   function capy_generator_add_lab_colorspace
     (gen : access CapyPDF_Generator;
      xw : double;
      yw : double;
      zw : double;
      amin : double;
      amax : double;
      bmin : double;
      bmax : double;
      out_ptr : access CapyPDF_LabColorSpaceId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:771
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_add_lab_colorspace";

   function capy_generator_add_separation
     (gen : access CapyPDF_Generator;
      separation_name : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t;
      cs : CapyPDF_Device_Colorspace;
      fid : CapyPDF_FunctionId;
      out_ptr : access CapyPDF_SeparationId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:781
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_add_separation";

   function capy_generator_write (gen : access CapyPDF_Generator) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:788
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_write";

   function capy_generator_add_optional_content_group
     (gen : access CapyPDF_Generator;
      ocg : access constant CapyPDF_OptionalContentGroup;
      out_ptr : access CapyPDF_OptionalContentGroupId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:790
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_add_optional_content_group";

   function capy_generator_add_annotation
     (gen : access CapyPDF_Generator;
      annotation : access CapyPDF_Annotation;
      out_ptr : access CapyPDF_AnnotationId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:794
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_add_annotation";

   function capy_generator_add_form_field
     (gen : access CapyPDF_Generator;
      field : access CapyPDF_FormField;
      out_ptr : access CapyPDF_FormFieldId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:798
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_add_form_field";

   function capy_generator_add_rolemap_entry
     (gen : access CapyPDF_Generator;
      name : Interfaces.C.Strings.chars_ptr;
      namesize : bits_stdint_intn_h.int32_t;
      builtin : CapyPDF_Structure_Type;
      out_ptr : access CapyPDF_RoleId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:802
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_add_rolemap_entry";

   function capy_generator_set_collection (gen : access CapyPDF_Generator; coll : access CapyPDF_Collection) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:808
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_set_collection";

   function capy_generator_add_outline
     (gen : access CapyPDF_Generator;
      outline : access constant CapyPDF_Outline;
      out_ptr : access CapyPDF_OutlineId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:811
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_add_outline";

   function capy_generator_destroy (gen : access CapyPDF_Generator) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:816
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_destroy";

   function capy_generator_text_width
     (gen : access CapyPDF_Generator;
      utf8_text : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t;
      font : CapyPDF_FontId;
      pointsize : double;
      out_ptr : access double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:820
   with Import => True, 
        Convention => C, 
        External_Name => "capy_generator_text_width";

   function capy_page_draw_context_new (gen : access CapyPDF_Generator; out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:829
   with Import => True, 
        Convention => C, 
        External_Name => "capy_page_draw_context_new";

   function capy_dc_cmd_b (ctx : access CapyPDF_DrawContext) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:831
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_b";

   function capy_dc_cmd_xB (ctx : access CapyPDF_DrawContext) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:832
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_B";

   function capy_dc_cmd_bstar (ctx : access CapyPDF_DrawContext) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:833
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_bstar";

   function capy_dc_cmd_xBstar (ctx : access CapyPDF_DrawContext) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:835
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_Bstar";

   function capy_dc_cmd_BDC_builtin
     (ctx : access CapyPDF_DrawContext;
      structid : CapyPDF_StructureItemId;
      tags : access constant CapyPDF_BDCTags) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:837
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_BDC_builtin";

   function capy_dc_cmd_BDC_testing
     (ctx : access CapyPDF_DrawContext;
      name : Interfaces.C.Strings.chars_ptr;
      namelen : bits_stdint_intn_h.int32_t;
      tags : access constant CapyPDF_BDCTags) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:841
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_BDC_testing";

   function capy_dc_cmd_BDC_ocg (ctx : access CapyPDF_DrawContext; ocgid : CapyPDF_OptionalContentGroupId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:846
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_BDC_ocg";

   function capy_dc_cmd_BMC (ctx : access CapyPDF_DrawContext; tag : Interfaces.C.Strings.chars_ptr) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:848
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_BMC";

   function capy_dc_cmd_c
     (ctx : access CapyPDF_DrawContext;
      x1 : double;
      y1 : double;
      x2 : double;
      y2 : double;
      x3 : double;
      y3 : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:850
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_c";

   function capy_dc_cmd_cm
     (ctx : access CapyPDF_DrawContext;
      m1 : double;
      m2 : double;
      m3 : double;
      m4 : double;
      m5 : double;
      m6 : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:857
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_cm";

   function capy_dc_cmd_d
     (ctx : access CapyPDF_DrawContext;
      dash_array : access double;
      array_size : bits_stdint_intn_h.int32_t;
      phase : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:864
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_d";

   function capy_dc_cmd_Do_trgroup (ctx : access CapyPDF_DrawContext; tgid : CapyPDF_TransparencyGroupId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:868
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_Do_trgroup";

   function capy_dc_cmd_Do_image (ctx : access CapyPDF_DrawContext; iid : CapyPDF_ImageId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:870
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_Do_image";

   function capy_dc_cmd_EMC (ctx : access CapyPDF_DrawContext) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:872
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_EMC";

   function capy_dc_cmd_f (ctx : access CapyPDF_DrawContext) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:873
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_f";

   function capy_dc_cmd_fstar (ctx : access CapyPDF_DrawContext) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:874
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_fstar";

   function capy_dc_cmd_xG (ctx : access CapyPDF_DrawContext; gray : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:876
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_G";

   function capy_dc_cmd_g (ctx : access CapyPDF_DrawContext; gray : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:878
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_g";

   function capy_dc_cmd_gs (ctx : access CapyPDF_DrawContext; gsid : CapyPDF_GraphicsStateId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:880
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_gs";

   function capy_dc_cmd_h (ctx : access CapyPDF_DrawContext) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:882
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_h";

   function capy_dc_cmd_i (ctx : access CapyPDF_DrawContext; flatness : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:883
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_i";

   function capy_dc_cmd_j (ctx : access CapyPDF_DrawContext; join_style : CapyPDF_Line_Join) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:885
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_j";

   function capy_dc_cmd_J (ctx : access CapyPDF_DrawContext; cap_style : CapyPDF_Line_Cap) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:887
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_J";

   function capy_dc_cmd_k
     (ctx : access CapyPDF_DrawContext;
      c : double;
      m : double;
      y : double;
      k : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:889
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_k";

   function capy_dc_cmd_xK
     (ctx : access CapyPDF_DrawContext;
      c : double;
      m : double;
      y : double;
      k : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:894
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_K";

   function capy_dc_cmd_l
     (ctx : access CapyPDF_DrawContext;
      x : double;
      y : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:899
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_l";

   function capy_dc_cmd_m
     (ctx : access CapyPDF_DrawContext;
      x : double;
      y : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:902
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_m";

   function capy_dc_cmd_M (ctx : access CapyPDF_DrawContext; miterlimit : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:905
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_M";

   function capy_dc_cmd_n (ctx : access CapyPDF_DrawContext) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:907
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_n";

   function capy_dc_cmd_q (ctx : access CapyPDF_DrawContext) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:908
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_q";

   function capy_dc_cmd_xQ (ctx : access CapyPDF_DrawContext) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:909
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_Q";

   function capy_dc_cmd_re
     (ctx : access CapyPDF_DrawContext;
      x : double;
      y : double;
      w : double;
      h : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:910
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_re";

   function capy_dc_cmd_xRG
     (ctx : access CapyPDF_DrawContext;
      r : double;
      g : double;
      b : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:915
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_RG";

   function capy_dc_cmd_rg
     (ctx : access CapyPDF_DrawContext;
      r : double;
      g : double;
      b : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:917
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_rg";

   function capy_dc_cmd_ri (ctx : access CapyPDF_DrawContext; ri : CapyPDF_Rendering_Intent) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:919
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_ri";

   function capy_dc_cmd_s (ctx : access CapyPDF_DrawContext) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:921
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_s";

   function capy_dc_cmd_xS (ctx : access CapyPDF_DrawContext) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:922
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_S";

   function capy_dc_cmd_sh (ctx : access CapyPDF_DrawContext; shid : CapyPDF_ShadingId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:923
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_sh";

   function capy_dc_cmd_v
     (ctx : access CapyPDF_DrawContext;
      x2 : double;
      y2 : double;
      x3 : double;
      y3 : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:925
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_v";

   function capy_dc_cmd_w (ctx : access CapyPDF_DrawContext; line_width : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:930
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_w";

   function capy_dc_cmd_W (ctx : access CapyPDF_DrawContext) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:932
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_W";

   function capy_dc_cmd_Wstar (ctx : access CapyPDF_DrawContext) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:933
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_Wstar";

   function capy_dc_cmd_y
     (ctx : access CapyPDF_DrawContext;
      x1 : double;
      y1 : double;
      x3 : double;
      y3 : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:935
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_cmd_y";

   function capy_dc_set_stroke (ctx : access CapyPDF_DrawContext; c : access CapyPDF_Color) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:941
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_set_stroke";

   function capy_dc_set_nonstroke (ctx : access CapyPDF_DrawContext; c : access CapyPDF_Color) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:943
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_set_nonstroke";

   function capy_dc_render_text
     (ctx : access CapyPDF_DrawContext;
      text : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t;
      fid : CapyPDF_FontId;
      point_size : double;
      x : double;
      y : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:946
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_render_text";

   function capy_dc_render_text_obj (ctx : access CapyPDF_DrawContext; text : access CapyPDF_Text) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:953
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_render_text_obj";

   function capy_dc_set_page_transition (ctx : access CapyPDF_DrawContext; transition : access CapyPDF_Transition) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:955
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_set_page_transition";

   function capy_dc_add_simple_navigation
     (ctx : access CapyPDF_DrawContext;
      ocgarray : access constant CapyPDF_OptionalContentGroupId;
      array_size : bits_stdint_intn_h.int32_t;
      tr : access constant CapyPDF_Transition) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:957
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_add_simple_navigation";

   function capy_dc_text_new (ctx : access CapyPDF_DrawContext; out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:962
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_text_new";

   function capy_dc_set_custom_page_properties (ctx : access CapyPDF_DrawContext; custom_properties : access constant CapyPDF_PageProperties) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:964
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_set_custom_page_properties";

   function capy_dc_annotate (ctx : access CapyPDF_DrawContext; aid : CapyPDF_AnnotationId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:966
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_annotate";

   function capy_dc_set_transparency_group_properties (ctx : access CapyPDF_DrawContext; trprop : access CapyPDF_TransparencyGroupProperties) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:968
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_set_transparency_group_properties";

   function capy_dc_set_group_matrix
     (ctx : access CapyPDF_DrawContext;
      a : double;
      b : double;
      c : double;
      d : double;
      e : double;
      f : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:971
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_set_group_matrix";

   function capy_dc_append_viewport (ctx : access CapyPDF_DrawContext; vport : access CapyPDF_Viewport) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:978
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_append_viewport";

   function capy_dc_destroy (arg1 : access CapyPDF_DrawContext) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:981
   with Import => True, 
        Convention => C, 
        External_Name => "capy_dc_destroy";

   function capy_form_xobject_new
     (gen : access CapyPDF_Generator;
      l : double;
      b : double;
      r : double;
      t : double;
      out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:985
   with Import => True, 
        Convention => C, 
        External_Name => "capy_form_xobject_new";

   function capy_tiling_pattern_context_new
     (gen : access CapyPDF_Generator;
      out_ptr : System.Address;
      l : double;
      b : double;
      r : double;
      t : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:991
   with Import => True, 
        Convention => C, 
        External_Name => "capy_tiling_pattern_context_new";

   function capy_text_sequence_new (out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1000
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_sequence_new";

   function capy_text_sequence_append_codepoint (tseq : access CapyPDF_TextSequence; codepoint : bits_stdint_uintn_h.uint32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1002
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_sequence_append_codepoint";

   function capy_text_sequence_append_string
     (tseq : access CapyPDF_TextSequence;
      u8str : Interfaces.C.Strings.chars_ptr;
      strlen : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1004
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_sequence_append_string";

   function capy_text_sequence_append_kerning (tseq : access CapyPDF_TextSequence; kern : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1006
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_sequence_append_kerning";

   function capy_text_sequence_append_actualtext_start
     (tseq : access CapyPDF_TextSequence;
      actual_text : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1008
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_sequence_append_actualtext_start";

   function capy_text_sequence_append_actualtext_end (tseq : access CapyPDF_TextSequence) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1012
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_sequence_append_actualtext_end";

   function capy_text_sequence_append_raw_glyph
     (tseq : access CapyPDF_TextSequence;
      glyph_id : bits_stdint_uintn_h.uint32_t;
      codepoint : bits_stdint_uintn_h.uint32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1014
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_sequence_append_raw_glyph";

   function capy_text_sequence_append_ligature_glyph
     (tseq : access CapyPDF_TextSequence;
      glyph_id : bits_stdint_uintn_h.uint32_t;
      original_text : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1018
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_sequence_append_ligature_glyph";

   function capy_text_sequence_destroy (tseq : access CapyPDF_TextSequence) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1023
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_sequence_destroy";

   function capy_text_cmd_Tj
     (text : access CapyPDF_Text;
      utf8_text : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1027
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_cmd_Tj";

   function capy_text_set_nonstroke (text : access CapyPDF_Text; color : access constant CapyPDF_Color) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1030
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_set_nonstroke";

   function capy_text_set_stroke (text : access CapyPDF_Text; color : access constant CapyPDF_Color) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1032
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_set_stroke";

   function capy_text_cmd_BDC_builtin (text : access CapyPDF_Text; stid : CapyPDF_StructureItemId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1034
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_cmd_BDC_builtin";

   function capy_text_cmd_EMC (text : access CapyPDF_Text) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1036
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_cmd_EMC";

   function capy_text_cmd_Tc (text : access CapyPDF_Text; spacing : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1037
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_cmd_Tc";

   function capy_text_cmd_Td
     (text : access CapyPDF_Text;
      x : double;
      y : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1039
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_cmd_Td";

   function capy_text_cmd_xTD
     (text : access CapyPDF_Text;
      x : double;
      y : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1042
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_cmd_TD";

   function capy_text_cmd_Tf
     (text : access CapyPDF_Text;
      font : CapyPDF_FontId;
      pointsize : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1045
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_cmd_Tf";

   function capy_text_cmd_TJ (text : access CapyPDF_Text; kseq : access CapyPDF_TextSequence) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1048
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_cmd_TJ";

   function capy_text_cmd_TL (text : access CapyPDF_Text; leading : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1050
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_cmd_TL";

   function capy_text_cmd_Tm
     (text : access CapyPDF_Text;
      a : double;
      b : double;
      c : double;
      d : double;
      e : double;
      f : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1052
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_cmd_Tm";

   function capy_text_cmd_Tr (text : access CapyPDF_Text; tmode : CapyPDF_Text_Mode) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1059
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_cmd_Tr";

   function capy_text_cmd_Tstar (text : access CapyPDF_Text) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1064
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_cmd_Tstar";

   function capy_text_cmd_w (text : access CapyPDF_Text; line_width : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1066
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_cmd_w";

   function capy_text_cmd_M (text : access CapyPDF_Text; miterlimit : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1068
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_cmd_M";

   function capy_text_cmd_j (text : access CapyPDF_Text; join_style : CapyPDF_Line_Join) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1070
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_cmd_j";

   function capy_text_cmd_J (text : access CapyPDF_Text; cap_style : CapyPDF_Line_Cap) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1072
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_cmd_J";

   function capy_text_cmd_d
     (text : access CapyPDF_Text;
      dash_array : access double;
      array_size : bits_stdint_intn_h.int32_t;
      phase : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1074
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_cmd_d";

   function capy_text_cmd_gs (text : access CapyPDF_Text; gsid : CapyPDF_GraphicsStateId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1078
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_cmd_gs";

   function capy_text_destroy (text : access CapyPDF_Text) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1080
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_destroy";

   function capy_color_new (out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1084
   with Import => True, 
        Convention => C, 
        External_Name => "capy_color_new";

   function capy_color_destroy (color : access CapyPDF_Color) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1085
   with Import => True, 
        Convention => C, 
        External_Name => "capy_color_destroy";

   function capy_color_set_rgb
     (c : access CapyPDF_Color;
      r : double;
      g : double;
      b : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1086
   with Import => True, 
        Convention => C, 
        External_Name => "capy_color_set_rgb";

   function capy_color_set_gray (c : access CapyPDF_Color; v : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1088
   with Import => True, 
        Convention => C, 
        External_Name => "capy_color_set_gray";

   function capy_color_set_cmyk
     (color : access CapyPDF_Color;
      c : double;
      m : double;
      y : double;
      k : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1090
   with Import => True, 
        Convention => C, 
        External_Name => "capy_color_set_cmyk";

   function capy_color_set_icc
     (color : access CapyPDF_Color;
      icc_id : CapyPDF_IccColorSpaceId;
      values : access double;
      num_values : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1092
   with Import => True, 
        Convention => C, 
        External_Name => "capy_color_set_icc";

   function capy_color_set_separation
     (color : access CapyPDF_Color;
      sep_id : CapyPDF_SeparationId;
      value : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1096
   with Import => True, 
        Convention => C, 
        External_Name => "capy_color_set_separation";

   function capy_color_set_pattern (color : access CapyPDF_Color; pat_id : CapyPDF_PatternId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1099
   with Import => True, 
        Convention => C, 
        External_Name => "capy_color_set_pattern";

   function capy_color_set_lab
     (color : access CapyPDF_Color;
      lab_id : CapyPDF_LabColorSpaceId;
      l : double;
      a : double;
      b : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1101
   with Import => True, 
        Convention => C, 
        External_Name => "capy_color_set_lab";

   function capy_transition_new (out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1108
   with Import => True, 
        Convention => C, 
        External_Name => "capy_transition_new";

   function capy_transition_set_S (tr : access CapyPDF_Transition; c_type : CapyPDF_Transition_Type) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1110
   with Import => True, 
        Convention => C, 
        External_Name => "capy_transition_set_S";

   function capy_transition_set_D (tr : access CapyPDF_Transition; duration : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1112
   with Import => True, 
        Convention => C, 
        External_Name => "capy_transition_set_D";

   function capy_transition_set_Dm (tr : access CapyPDF_Transition; dim : CapyPDF_Transition_Dimension) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1114
   with Import => True, 
        Convention => C, 
        External_Name => "capy_transition_set_Dm";

   function capy_transition_set_M (tr : access CapyPDF_Transition; m : CapyPDF_Transition_Motion) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1116
   with Import => True, 
        Convention => C, 
        External_Name => "capy_transition_set_M";

   function capy_transition_set_Di (tr : access CapyPDF_Transition; direction : bits_stdint_uintn_h.uint32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1118
   with Import => True, 
        Convention => C, 
        External_Name => "capy_transition_set_Di";

   function capy_transition_set_SS (tr : access CapyPDF_Transition; scale : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1120
   with Import => True, 
        Convention => C, 
        External_Name => "capy_transition_set_SS";

   function capy_transition_set_B (tr : access CapyPDF_Transition; is_opaque : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1122
   with Import => True, 
        Convention => C, 
        External_Name => "capy_transition_set_B";

   function capy_transition_destroy (transition : access CapyPDF_Transition) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1124
   with Import => True, 
        Convention => C, 
        External_Name => "capy_transition_destroy";

   function capy_optional_content_group_new (out_ptr : System.Address; name : Interfaces.C.Strings.chars_ptr) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1128
   with Import => True, 
        Convention => C, 
        External_Name => "capy_optional_content_group_new";

   function capy_optional_content_group_destroy (group : access CapyPDF_OptionalContentGroup) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1130
   with Import => True, 
        Convention => C, 
        External_Name => "capy_optional_content_group_destroy";

   function capy_graphics_state_new (out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1134
   with Import => True, 
        Convention => C, 
        External_Name => "capy_graphics_state_new";

   function capy_graphics_state_set_xCA (state : access CapyPDF_GraphicsState; value : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1136
   with Import => True, 
        Convention => C, 
        External_Name => "capy_graphics_state_set_CA";

   function capy_graphics_state_set_ca (state : access CapyPDF_GraphicsState; value : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1138
   with Import => True, 
        Convention => C, 
        External_Name => "capy_graphics_state_set_ca";

   function capy_graphics_state_set_BM (state : access CapyPDF_GraphicsState; blendmode : CapyPDF_Blend_Mode) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1140
   with Import => True, 
        Convention => C, 
        External_Name => "capy_graphics_state_set_BM";

   function capy_graphics_state_set_op (state : access CapyPDF_GraphicsState; value : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1142
   with Import => True, 
        Convention => C, 
        External_Name => "capy_graphics_state_set_op";

   function capy_graphics_state_set_xOP (state : access CapyPDF_GraphicsState; value : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1144
   with Import => True, 
        Convention => C, 
        External_Name => "capy_graphics_state_set_OP";

   function capy_graphics_state_set_OPM (state : access CapyPDF_GraphicsState; value : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1146
   with Import => True, 
        Convention => C, 
        External_Name => "capy_graphics_state_set_OPM";

   function capy_graphics_state_set_SMask (state : access CapyPDF_GraphicsState; smid : CapyPDF_SoftMaskId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1148
   with Import => True, 
        Convention => C, 
        External_Name => "capy_graphics_state_set_SMask";

   function capy_graphics_state_set_FL (state : access CapyPDF_GraphicsState; value : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1150
   with Import => True, 
        Convention => C, 
        External_Name => "capy_graphics_state_set_FL";

   function capy_graphics_state_set_HT (state : access CapyPDF_GraphicsState; ht : access CapyPDF_Halftone) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1152
   with Import => True, 
        Convention => C, 
        External_Name => "capy_graphics_state_set_HT";

   function capy_graphics_state_set_SM (state : access CapyPDF_GraphicsState; value : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1154
   with Import => True, 
        Convention => C, 
        External_Name => "capy_graphics_state_set_SM";

   function capy_graphics_state_set_AIS (state : access CapyPDF_GraphicsState; value : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1156
   with Import => True, 
        Convention => C, 
        External_Name => "capy_graphics_state_set_AIS";

   function capy_graphics_state_set_TK (state : access CapyPDF_GraphicsState; value : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1158
   with Import => True, 
        Convention => C, 
        External_Name => "capy_graphics_state_set_TK";

   function capy_graphics_state_set_blackpoint_compensation (state : access CapyPDF_GraphicsState; use_comp : CapyPDF_Black_Point_Compensation) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1160
   with Import => True, 
        Convention => C, 
        External_Name => "capy_graphics_state_set_blackpoint_compensation";

   function capy_graphics_state_destroy (state : access CapyPDF_GraphicsState) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1163
   with Import => True, 
        Convention => C, 
        External_Name => "capy_graphics_state_destroy";

   function capy_transparency_group_new
     (gen : access CapyPDF_Generator;
      left : double;
      bottom : double;
      right : double;
      top : double;
      out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1167
   with Import => True, 
        Convention => C, 
        External_Name => "capy_transparency_group_new";

   function capy_transparency_group_properties_new (out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1174
   with Import => True, 
        Convention => C, 
        External_Name => "capy_transparency_group_properties_new";

   function capy_transparency_group_properties_set_CS (props : access CapyPDF_TransparencyGroupProperties; cs : CapyPDF_Device_Colorspace) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1176
   with Import => True, 
        Convention => C, 
        External_Name => "capy_transparency_group_properties_set_CS";

   function capy_transparency_group_properties_set_I (props : access CapyPDF_TransparencyGroupProperties; I : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1179
   with Import => True, 
        Convention => C, 
        External_Name => "capy_transparency_group_properties_set_I";

   function capy_transparency_group_properties_set_K (props : access CapyPDF_TransparencyGroupProperties; K : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1181
   with Import => True, 
        Convention => C, 
        External_Name => "capy_transparency_group_properties_set_K";

   function capy_transparency_group_properties_destroy (props : access CapyPDF_TransparencyGroupProperties) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1183
   with Import => True, 
        Convention => C, 
        External_Name => "capy_transparency_group_properties_destroy";

   function capy_raster_image_builder_new (out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1187
   with Import => True, 
        Convention => C, 
        External_Name => "capy_raster_image_builder_new";

   function capy_raster_image_builder_set_size
     (builder : access CapyPDF_RasterImageBuilder;
      w : bits_stdint_uintn_h.uint32_t;
      h : bits_stdint_uintn_h.uint32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1189
   with Import => True, 
        Convention => C, 
        External_Name => "capy_raster_image_builder_set_size";

   function capy_raster_image_builder_set_pixel_depth (builder : access CapyPDF_RasterImageBuilder; depth : bits_stdint_uintn_h.uint32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1191
   with Import => True, 
        Convention => C, 
        External_Name => "capy_raster_image_builder_set_pixel_depth";

   function capy_raster_image_builder_set_pixel_data
     (builder : access CapyPDF_RasterImageBuilder;
      buf : Interfaces.C.Strings.chars_ptr;
      bufsize : bits_stdint_uintn_h.uint64_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1194
   with Import => True, 
        Convention => C, 
        External_Name => "capy_raster_image_builder_set_pixel_data";

   function capy_raster_image_builder_set_alpha_depth (builder : access CapyPDF_RasterImageBuilder; depth : bits_stdint_uintn_h.uint32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1197
   with Import => True, 
        Convention => C, 
        External_Name => "capy_raster_image_builder_set_alpha_depth";

   function capy_raster_image_builder_set_alpha_data
     (builder : access CapyPDF_RasterImageBuilder;
      buf : Interfaces.C.Strings.chars_ptr;
      bufsize : bits_stdint_uintn_h.uint64_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1200
   with Import => True, 
        Convention => C, 
        External_Name => "capy_raster_image_builder_set_alpha_data";

   function capy_raster_image_builder_set_input_data_compression_format (builder : access CapyPDF_RasterImageBuilder; compression : CapyPDF_Compression) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1203
   with Import => True, 
        Convention => C, 
        External_Name => "capy_raster_image_builder_set_input_data_compression_format";

   function capy_raster_image_builder_set_colorspace (builder : access CapyPDF_RasterImageBuilder; colorspace : CapyPDF_Image_Colorspace) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1206
   with Import => True, 
        Convention => C, 
        External_Name => "capy_raster_image_builder_set_colorspace";

   function capy_raster_image_builder_destroy (builder : access CapyPDF_RasterImageBuilder) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1209
   with Import => True, 
        Convention => C, 
        External_Name => "capy_raster_image_builder_destroy";

   function capy_raster_image_builder_build (builder : access CapyPDF_RasterImageBuilder; out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1211
   with Import => True, 
        Convention => C, 
        External_Name => "capy_raster_image_builder_build";

   function capy_raster_image_get_size
     (image : access constant CapyPDF_RasterImage;
      w : access bits_stdint_uintn_h.uint32_t;
      h : access bits_stdint_uintn_h.uint32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1215
   with Import => True, 
        Convention => C, 
        External_Name => "capy_raster_image_get_size";

   function capy_raster_image_get_colorspace (image : access constant CapyPDF_RasterImage; out_ptr : access CapyPDF_Image_Colorspace) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1218
   with Import => True, 
        Convention => C, 
        External_Name => "capy_raster_image_get_colorspace";

   function capy_raster_image_has_profile (image : access constant CapyPDF_RasterImage; out_ptr : access bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1221
   with Import => True, 
        Convention => C, 
        External_Name => "capy_raster_image_has_profile";

   function capy_raster_image_destroy (image : access CapyPDF_RasterImage) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1223
   with Import => True, 
        Convention => C, 
        External_Name => "capy_raster_image_destroy";

   function capy_type2_function_new
     (domain : access double;
      domain_size : bits_stdint_intn_h.int32_t;
      c1 : access constant CapyPDF_Color;
      c2 : access constant CapyPDF_Color;
      n : double;
      out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1227
   with Import => True, 
        Convention => C, 
        External_Name => "capy_type2_function_new";

   function capy_function_destroy (func : access CapyPDF_Function) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1234
   with Import => True, 
        Convention => C, 
        External_Name => "capy_function_destroy";

   function capy_type3_function_new
     (domain : access double;
      domain_size : bits_stdint_intn_h.int32_t;
      functions : access CapyPDF_FunctionId;
      functions_size : bits_stdint_intn_h.int32_t;
      bounds : access double;
      bounds_size : bits_stdint_intn_h.int32_t;
      encode : access double;
      encode_size : bits_stdint_intn_h.int32_t;
      out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1236
   with Import => True, 
        Convention => C, 
        External_Name => "capy_type3_function_new";

   function capy_type4_function_new
     (domain : access double;
      domain_size : bits_stdint_intn_h.int32_t;
      c_range : access double;
      range_size : bits_stdint_intn_h.int32_t;
      code : Interfaces.C.Strings.chars_ptr;
      code_size : bits_stdint_intn_h.int32_t;
      out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1246
   with Import => True, 
        Convention => C, 
        External_Name => "capy_type4_function_new";

   function capy_type2_shading_new
     (cs : CapyPDF_Device_Colorspace;
      x0 : double;
      y0 : double;
      x1 : double;
      y1 : double;
      func : CapyPDF_FunctionId;
      out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1256
   with Import => True, 
        Convention => C, 
        External_Name => "capy_type2_shading_new";

   function capy_shading_destroy (shade : access CapyPDF_Shading) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1264
   with Import => True, 
        Convention => C, 
        External_Name => "capy_shading_destroy";

   function capy_shading_set_extend
     (shade : access CapyPDF_Shading;
      starting : bits_stdint_intn_h.int32_t;
      ending : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1266
   with Import => True, 
        Convention => C, 
        External_Name => "capy_shading_set_extend";

   function capy_shading_set_domain
     (shade : access CapyPDF_Shading;
      starting : double;
      ending : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1269
   with Import => True, 
        Convention => C, 
        External_Name => "capy_shading_set_domain";

   function capy_type3_shading_new
     (cs : CapyPDF_Device_Colorspace;
      coords : access double;
      func : CapyPDF_FunctionId;
      out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1273
   with Import => True, 
        Convention => C, 
        External_Name => "capy_type3_shading_new";

   function capy_type4_shading_new
     (cs : CapyPDF_Device_Colorspace;
      minx : double;
      miny : double;
      maxx : double;
      maxy : double;
      out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1279
   with Import => True, 
        Convention => C, 
        External_Name => "capy_type4_shading_new";

   function capy_type4_shading_add_triangle
     (shade : access CapyPDF_Shading;
      coords : access double;
      colors : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1286
   with Import => True, 
        Convention => C, 
        External_Name => "capy_type4_shading_add_triangle";

   function capy_type4_shading_extend
     (shade : access CapyPDF_Shading;
      flag : bits_stdint_intn_h.int32_t;
      coords : access double;
      color : access constant CapyPDF_Color) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1290
   with Import => True, 
        Convention => C, 
        External_Name => "capy_type4_shading_extend";

   function capy_type6_shading_new
     (cs : CapyPDF_Device_Colorspace;
      minx : double;
      miny : double;
      maxx : double;
      maxy : double;
      out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1296
   with Import => True, 
        Convention => C, 
        External_Name => "capy_type6_shading_new";

   function capy_type6_shading_add_patch
     (shade : access CapyPDF_Shading;
      coords : access double;
      colors : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1303
   with Import => True, 
        Convention => C, 
        External_Name => "capy_type6_shading_add_patch";

   function capy_type6_shading_extend
     (shade : access CapyPDF_Shading;
      flag : bits_stdint_intn_h.int32_t;
      coords : access double;
      colors : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1307
   with Import => True, 
        Convention => C, 
        External_Name => "capy_type6_shading_extend";

   function capy_text_annotation_new
     (utf8_text : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t;
      out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1314
   with Import => True, 
        Convention => C, 
        External_Name => "capy_text_annotation_new";

   function capy_link_annotation_new (out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1318
   with Import => True, 
        Convention => C, 
        External_Name => "capy_link_annotation_new";

   function capy_line_annotation_new
     (utf8_text : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t;
      x1 : double;
      y1 : double;
      x2 : double;
      y2 : double;
      out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1320
   with Import => True, 
        Convention => C, 
        External_Name => "capy_line_annotation_new";

   function capy_file_attachment_annotation_new (fid : CapyPDF_EmbeddedFileId; out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1328
   with Import => True, 
        Convention => C, 
        External_Name => "capy_file_attachment_annotation_new";

   function capy_widget_annotation_new (out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1330
   with Import => True, 
        Convention => C, 
        External_Name => "capy_widget_annotation_new";

   function capy_printers_mark_annotation_new (fid : CapyPDF_FormXObjectId; out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1332
   with Import => True, 
        Convention => C, 
        External_Name => "capy_printers_mark_annotation_new";

   function capy_3d_annotation_new (out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1334
   with Import => True, 
        Convention => C, 
        External_Name => "capy_3d_annotation_new";

   function capy_annotation_set_destination (annotation : access CapyPDF_Annotation; d : access constant CapyPDF_Destination) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1336
   with Import => True, 
        Convention => C, 
        External_Name => "capy_annotation_set_destination";

   function capy_annotation_set_uri
     (annotation : access CapyPDF_Annotation;
      uri : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1338
   with Import => True, 
        Convention => C, 
        External_Name => "capy_annotation_set_uri";

   function capy_annotation_set_rectangle
     (annotation : access CapyPDF_Annotation;
      x1 : double;
      y1 : double;
      x2 : double;
      y2 : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1341
   with Import => True, 
        Convention => C, 
        External_Name => "capy_annotation_set_rectangle";

   function capy_annotation_set_flags (annotation : access CapyPDF_Annotation; flags : CapyPDF_Annotation_Flags) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1346
   with Import => True, 
        Convention => C, 
        External_Name => "capy_annotation_set_flags";

   function capy_annotation_set_3d_stream (annotation : access CapyPDF_Annotation; id : CapyPDF_3DStreamId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1348
   with Import => True, 
        Convention => C, 
        External_Name => "capy_annotation_set_3d_stream";

   function capy_annotation_set_line_leader
     (annotation : access CapyPDF_Annotation;
      LL : double;
      LLE : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1350
   with Import => True, 
        Convention => C, 
        External_Name => "capy_annotation_set_line_leader";

   function capy_annotation_set_line_endings
     (annotation : access CapyPDF_Annotation;
      start : CapyPDF_Line_Annotation_End_Style;
      c_end : CapyPDF_Line_Annotation_End_Style) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1352
   with Import => True, 
        Convention => C, 
        External_Name => "capy_annotation_set_line_endings";

   function capy_annotation_set_parent_field (annotation : access CapyPDF_Annotation; id : CapyPDF_FormFieldId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1356
   with Import => True, 
        Convention => C, 
        External_Name => "capy_annotation_set_parent_field";

   function capy_annotation_set_widget_button_appearance
     (annotation : access CapyPDF_Annotation;
      on_state : CapyPDF_FormXObjectId;
      off_state : CapyPDF_FormXObjectId;
      on_state_name : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1359
   with Import => True, 
        Convention => C, 
        External_Name => "capy_annotation_set_widget_button_appearance";

   function capy_annotation_destroy (annotation : access CapyPDF_Annotation) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1364
   with Import => True, 
        Convention => C, 
        External_Name => "capy_annotation_destroy";

   function capy_struct_item_extra_data_new (out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1368
   with Import => True, 
        Convention => C, 
        External_Name => "capy_struct_item_extra_data_new";

   function capy_struct_item_extra_data_set_t
     (extra : access CapyPDF_StructItemExtraData;
      ttext : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1370
   with Import => True, 
        Convention => C, 
        External_Name => "capy_struct_item_extra_data_set_t";

   function capy_struct_item_extra_data_set_lang
     (extra : access CapyPDF_StructItemExtraData;
      lang : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1374
   with Import => True, 
        Convention => C, 
        External_Name => "capy_struct_item_extra_data_set_lang";

   function capy_struct_item_extra_data_set_alt
     (extra : access CapyPDF_StructItemExtraData;
      alt : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1378
   with Import => True, 
        Convention => C, 
        External_Name => "capy_struct_item_extra_data_set_alt";

   function capy_struct_item_extra_data_set_actual_text
     (extra : access CapyPDF_StructItemExtraData;
      actual : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1383
   with Import => True, 
        Convention => C, 
        External_Name => "capy_struct_item_extra_data_set_actual_text";

   function capy_struct_item_extra_data_destroy (extra : access CapyPDF_StructItemExtraData) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1386
   with Import => True, 
        Convention => C, 
        External_Name => "capy_struct_item_extra_data_destroy";

   function capy_image_pdf_properties_new (out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1390
   with Import => True, 
        Convention => C, 
        External_Name => "capy_image_pdf_properties_new";

   function capy_image_pdf_properties_set_mask (par : access CapyPDF_ImagePdfProperties; as_mask : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1392
   with Import => True, 
        Convention => C, 
        External_Name => "capy_image_pdf_properties_set_mask";

   function capy_image_pdf_properties_set_interpolate (par : access CapyPDF_ImagePdfProperties; interp : CapyPDF_Image_Interpolation) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1394
   with Import => True, 
        Convention => C, 
        External_Name => "capy_image_pdf_properties_set_interpolate";

   function capy_image_pdf_properties_set_conversion_intent (par : access CapyPDF_ImagePdfProperties; ri : CapyPDF_Rendering_Intent) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1397
   with Import => True, 
        Convention => C, 
        External_Name => "capy_image_pdf_properties_set_conversion_intent";

   function capy_image_pdf_properties_destroy (par : access CapyPDF_ImagePdfProperties) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1399
   with Import => True, 
        Convention => C, 
        External_Name => "capy_image_pdf_properties_destroy";

   function capy_destination_new (out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1403
   with Import => True, 
        Convention => C, 
        External_Name => "capy_destination_new";

   function capy_destination_set_page_fit (dest : access CapyPDF_Destination; physical_page_number : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1405
   with Import => True, 
        Convention => C, 
        External_Name => "capy_destination_set_page_fit";

   function capy_destination_set_page_xyz
     (dest : access CapyPDF_Destination;
      physical_page_number : bits_stdint_intn_h.int32_t;
      x : access double;
      y : access double;
      z : access double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1407
   with Import => True, 
        Convention => C, 
        External_Name => "capy_destination_set_page_xyz";

   function capy_destination_destroy (dest : access CapyPDF_Destination) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1413
   with Import => True, 
        Convention => C, 
        External_Name => "capy_destination_destroy";

   function capy_outline_new (out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1417
   with Import => True, 
        Convention => C, 
        External_Name => "capy_outline_new";

   function capy_outline_set_title
     (outline : access CapyPDF_Outline;
      title : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1419
   with Import => True, 
        Convention => C, 
        External_Name => "capy_outline_set_title";

   function capy_outline_set_destination (outline : access CapyPDF_Outline; dest : access constant CapyPDF_Destination) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1422
   with Import => True, 
        Convention => C, 
        External_Name => "capy_outline_set_destination";

   function capy_outline_set_C
     (outline : access CapyPDF_Outline;
      r : double;
      g : double;
      b : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1424
   with Import => True, 
        Convention => C, 
        External_Name => "capy_outline_set_C";

   function capy_outline_set_F (outline : access CapyPDF_Outline; F : bits_stdint_uintn_h.uint32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1426
   with Import => True, 
        Convention => C, 
        External_Name => "capy_outline_set_F";

   function capy_outline_set_parent (outline : access CapyPDF_Outline; parent : CapyPDF_OutlineId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1428
   with Import => True, 
        Convention => C, 
        External_Name => "capy_outline_set_parent";

   function capy_outline_destroy (outline : access CapyPDF_Outline) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1430
   with Import => True, 
        Convention => C, 
        External_Name => "capy_outline_destroy";

   function capy_shading_pattern_new (shid : CapyPDF_ShadingId; out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1434
   with Import => True, 
        Convention => C, 
        External_Name => "capy_shading_pattern_new";

   function capy_shading_pattern_set_matrix
     (shp : access CapyPDF_ShadingPattern;
      a : double;
      b : double;
      c : double;
      d : double;
      e : double;
      f : double) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1436
   with Import => True, 
        Convention => C, 
        External_Name => "capy_shading_pattern_set_matrix";

   function capy_shading_pattern_destroy (shp : access CapyPDF_ShadingPattern) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1443
   with Import => True, 
        Convention => C, 
        External_Name => "capy_shading_pattern_destroy";

   function capy_soft_mask_new
     (c_subtype : CapyPDF_Soft_Mask_Subtype;
      trid : CapyPDF_TransparencyGroupId;
      out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1446
   with Import => True, 
        Convention => C, 
        External_Name => "capy_soft_mask_new";

   function capy_soft_mask_destroy (sm : access CapyPDF_SoftMask) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1450
   with Import => True, 
        Convention => C, 
        External_Name => "capy_soft_mask_destroy";

   function capy_embedded_file_new (out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1455
   with Import => True, 
        Convention => C, 
        External_Name => "capy_embedded_file_new";

   function capy_embedded_file_load_file (efile : access CapyPDF_EmbeddedFile; path : Interfaces.C.Strings.chars_ptr) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1457
   with Import => True, 
        Convention => C, 
        External_Name => "capy_embedded_file_load_file";

   function capy_embedded_file_set_contents
     (efile : access CapyPDF_EmbeddedFile;
      data : Interfaces.C.Strings.chars_ptr;
      datasize : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1459
   with Import => True, 
        Convention => C, 
        External_Name => "capy_embedded_file_set_contents";

   function capy_embedded_file_set_subtype
     (efile : access CapyPDF_EmbeddedFile;
      c_subtype : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1461
   with Import => True, 
        Convention => C, 
        External_Name => "capy_embedded_file_set_subtype";

   function capy_embedded_file_set_pdf_name
     (efile : access CapyPDF_EmbeddedFile;
      pdf_name : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1465
   with Import => True, 
        Convention => C, 
        External_Name => "capy_embedded_file_set_pdf_name";

   function capy_embedded_file_destroy (efile : access CapyPDF_EmbeddedFile) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1469
   with Import => True, 
        Convention => C, 
        External_Name => "capy_embedded_file_destroy";

   function capy_bdc_tags_new (out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1473
   with Import => True, 
        Convention => C, 
        External_Name => "capy_bdc_tags_new";

   function capy_bdc_tags_add_tag
     (tags : access CapyPDF_BDCTags;
      key : Interfaces.C.Strings.chars_ptr;
      keylen : bits_stdint_intn_h.int32_t;
      value : Interfaces.C.Strings.chars_ptr;
      valuelen : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1475
   with Import => True, 
        Convention => C, 
        External_Name => "capy_bdc_tags_add_tag";

   function capy_bdc_tags_destroy (tags : access CapyPDF_BDCTags) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1480
   with Import => True, 
        Convention => C, 
        External_Name => "capy_bdc_tags_destroy";

   function capy_font_properties_new (out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1484
   with Import => True, 
        Convention => C, 
        External_Name => "capy_font_properties_new";

   function capy_font_properties_set_subfont (fprop : access CapyPDF_FontProperties; subfont : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1486
   with Import => True, 
        Convention => C, 
        External_Name => "capy_font_properties_set_subfont";

   function capy_font_properties_set_variation
     (fprop : access CapyPDF_FontProperties;
      axis : Interfaces.C.Strings.chars_ptr;
      axis_size : bits_stdint_intn_h.int32_t;
      value : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1488
   with Import => True, 
        Convention => C, 
        External_Name => "capy_font_properties_set_variation";

   function capy_font_properties_destroy (fprop : access CapyPDF_FontProperties) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1493
   with Import => True, 
        Convention => C, 
        External_Name => "capy_font_properties_destroy";

   function capy_halftone_new (out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1497
   with Import => True, 
        Convention => C, 
        External_Name => "capy_halftone_new";

   function capy_halftone_set_default (ht : access CapyPDF_Halftone) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1499
   with Import => True, 
        Convention => C, 
        External_Name => "capy_halftone_set_default";

   function capy_halftone_set_type1
     (ht : access CapyPDF_Halftone;
      frequency : double;
      angle : double;
      htspot : CapyPDF_Halftone_Spot_Function) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1501
   with Import => True, 
        Convention => C, 
        External_Name => "capy_halftone_set_type1";

   function capy_halftone_destroy (ht : access CapyPDF_Halftone) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1506
   with Import => True, 
        Convention => C, 
        External_Name => "capy_halftone_destroy";

   function capy_3d_stream_new
     (fname : Interfaces.C.Strings.chars_ptr;
      format : CapyPDF_3D_File_Format;
      out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1511
   with Import => True, 
        Convention => C, 
        External_Name => "capy_3d_stream_new";

   function capy_3d_stream_destroy (stream : access CapyPDF_3DStream) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1515
   with Import => True, 
        Convention => C, 
        External_Name => "capy_3d_stream_destroy";

   function capy_form_field_new (c_type : CapyPDF_Form_Field_Type; out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1519
   with Import => True, 
        Convention => C, 
        External_Name => "capy_form_field_new";

   function capy_form_field_set_parent (field : access CapyPDF_FormField; parent : CapyPDF_FormFieldId) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1521
   with Import => True, 
        Convention => C, 
        External_Name => "capy_form_field_set_parent";

   function capy_form_field_set_T
     (field : access CapyPDF_FormField;
      T : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1523
   with Import => True, 
        Convention => C, 
        External_Name => "capy_form_field_set_T";

   function capy_form_field_set_Ff (field : access CapyPDF_FormField; Ff : bits_stdint_uintn_h.uint32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1526
   with Import => True, 
        Convention => C, 
        External_Name => "capy_form_field_set_Ff";

   function capy_form_field_set_V
     (field : access CapyPDF_FormField;
      V : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1528
   with Import => True, 
        Convention => C, 
        External_Name => "capy_form_field_set_V";

   function capy_form_field_add_Opt_entry
     (field : access CapyPDF_FormField;
      choice : Interfaces.C.Strings.chars_ptr;
      strsize : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1531
   with Import => True, 
        Convention => C, 
        External_Name => "capy_form_field_add_Opt_entry";

   function capy_form_field_destroy (field : access CapyPDF_FormField) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1533
   with Import => True, 
        Convention => C, 
        External_Name => "capy_form_field_destroy";

   function capy_viewport_new
     (x1 : double;
      y1 : double;
      x2 : double;
      y2 : double;
      out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1538
   with Import => True, 
        Convention => C, 
        External_Name => "capy_viewport_new";

   function capy_viewport_set_measure (vp : access CapyPDF_Viewport; measure : access CapyPDF_Measure) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1540
   with Import => True, 
        Convention => C, 
        External_Name => "capy_viewport_set_measure";

   function capy_viewport_destroy (vp : access CapyPDF_Viewport) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1542
   with Import => True, 
        Convention => C, 
        External_Name => "capy_viewport_destroy";

   function capy_measure_new (out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1545
   with Import => True, 
        Convention => C, 
        External_Name => "capy_measure_new";

   function capy_measure_append_X (m : access CapyPDF_Measure; f : access CapyPDF_NumberFormat) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1547
   with Import => True, 
        Convention => C, 
        External_Name => "capy_measure_append_X";

   function capy_measure_append_Y (m : access CapyPDF_Measure; f : access CapyPDF_NumberFormat) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1549
   with Import => True, 
        Convention => C, 
        External_Name => "capy_measure_append_Y";

   function capy_measure_append_D (m : access CapyPDF_Measure; f : access CapyPDF_NumberFormat) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1551
   with Import => True, 
        Convention => C, 
        External_Name => "capy_measure_append_D";

   function capy_measure_append_A (m : access CapyPDF_Measure; f : access CapyPDF_NumberFormat) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1553
   with Import => True, 
        Convention => C, 
        External_Name => "capy_measure_append_A";

   function capy_measure_destroy (m : access CapyPDF_Measure) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1555
   with Import => True, 
        Convention => C, 
        External_Name => "capy_measure_destroy";

   function capy_number_format_new
     (name : Interfaces.C.Strings.chars_ptr;
      namelen : bits_stdint_intn_h.int32_t;
      C : double;
      out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1558
   with Import => True, 
        Convention => C, 
        External_Name => "capy_number_format_new";

   function capy_number_format_destroy (f : access CapyPDF_NumberFormat) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1560
   with Import => True, 
        Convention => C, 
        External_Name => "capy_number_format_destroy";

   function capy_collection_new (out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1565
   with Import => True, 
        Convention => C, 
        External_Name => "capy_collection_new";

   function capy_collection_set_D
     (coll : access CapyPDF_Collection;
      buf : Interfaces.C.Strings.chars_ptr;
      bufsize : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1567
   with Import => True, 
        Convention => C, 
        External_Name => "capy_collection_set_D";

   function capy_collection_set_schema (coll : access CapyPDF_Collection; schema : access CapyPDF_CollectionSchema) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1570
   with Import => True, 
        Convention => C, 
        External_Name => "capy_collection_set_schema";

   function capy_collection_set_view (coll : access CapyPDF_Collection; view : CapyPDF_Collection_View) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1572
   with Import => True, 
        Convention => C, 
        External_Name => "capy_collection_set_view";

   function capy_collection_destroy (coll : access CapyPDF_Collection) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1574
   with Import => True, 
        Convention => C, 
        External_Name => "capy_collection_destroy";

   function capy_collection_schema_new (out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1577
   with Import => True, 
        Convention => C, 
        External_Name => "capy_collection_schema_new";

   function capy_collection_schema_add_entry
     (schema : access CapyPDF_CollectionSchema;
      name : Interfaces.C.Strings.chars_ptr;
      namelen : bits_stdint_intn_h.int32_t;
      field : access CapyPDF_CollectionField) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1579
   with Import => True, 
        Convention => C, 
        External_Name => "capy_collection_schema_add_entry";

   function capy_collection_schema_destroy (coll : access CapyPDF_CollectionSchema) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1584
   with Import => True, 
        Convention => C, 
        External_Name => "capy_collection_schema_destroy";

   function capy_collection_field_new
     (c_subtype : CapyPDF_Collection_Subtype;
      name : Interfaces.C.Strings.chars_ptr;
      namelen : bits_stdint_intn_h.int32_t;
      out_ptr : System.Address) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1587
   with Import => True, 
        Convention => C, 
        External_Name => "capy_collection_field_new";

   function capy_collection_field_set_O (coll : access CapyPDF_CollectionField; O : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1592
   with Import => True, 
        Convention => C, 
        External_Name => "capy_collection_field_set_O";

   function capy_collection_field_set_V (coll : access CapyPDF_CollectionField; V : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1594
   with Import => True, 
        Convention => C, 
        External_Name => "capy_collection_field_set_V";

   function capy_collection_field_set_E (coll : access CapyPDF_CollectionField; E : bits_stdint_intn_h.int32_t) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1596
   with Import => True, 
        Convention => C, 
        External_Name => "capy_collection_field_set_E";

   function capy_collection_field_destroy (coll : access CapyPDF_CollectionField) return CapyPDF_EC  -- /usr/local/include/capypdf-0/capypdf.h:1598
   with Import => True, 
        Convention => C, 
        External_Name => "capy_collection_field_destroy";

   function capy_error_message (error_code : CapyPDF_EC) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/capypdf-0/capypdf.h:1603
   with Import => True, 
        Convention => C, 
        External_Name => "capy_error_message";

end capypdf_0_capypdf_h;

pragma Style_Checks (On);
pragma Warnings (On, "-gnatwu");
