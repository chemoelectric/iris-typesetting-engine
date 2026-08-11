/* =============================================================================
 * Module: iris_pdf_io.c
 * Standard: ISO C23
 * Architecture: Low-Level CapyPDF 0.21.0 C23 Primitive & Stream Binding Layer
 * Rules: Strict single-entry/single-exit control constructs, no goto,
 *        explicit ban on ++ and -- (requiring += 1 and -= 1),
 *        McCabe cyclomatic complexity <= 10 per procedure.
 * =============================================================================
 */

#include "iris_pdf_io.h"
#include <stdlib.h>
#include <string.h>

#if __has_include(<capypdf.h>)
#include <capypdf.h>
#else
/* CapyPDF 0.21.0 C API Declarations (Weak linking attributes for dynamic loading) */
typedef struct CapyPDF_Options CapyPDF_Options;
typedef struct CapyPDF_Generator CapyPDF_Generator;
typedef struct CapyPDF_DrawContext CapyPDF_DrawContext;
typedef struct { int32_t id; } CapyPDF_FontId;

#ifdef __cplusplus
extern "C" {
#endif
CapyPDF_Options *capy_options_new(void) __attribute__((weak));
CapyPDF_Options *capy_generator_options_new(void) __attribute__((weak));
int32_t capy_options_set_title(CapyPDF_Options *opt, const char *utf8_title) __attribute__((weak));
int32_t capy_options_free(CapyPDF_Options *opt) __attribute__((weak));

CapyPDF_Generator *capy_generator_new(const char *filename, const CapyPDF_Options *options) __attribute__((weak));
CapyPDF_DrawContext *capy_generator_new_page_draw_context(CapyPDF_Generator *gen) __attribute__((weak));
int32_t capy_generator_add_page(CapyPDF_Generator *gen, CapyPDF_DrawContext *dc) __attribute__((weak));
int32_t capy_generator_write(CapyPDF_Generator *gen) __attribute__((weak));
int32_t capy_generator_free(CapyPDF_Generator *gen) __attribute__((weak));

int32_t capy_dc_draw_text(CapyPDF_DrawContext *dc, const char *utf8_text, CapyPDF_FontId font, double pt_size, double x, double y) __attribute__((weak));
int32_t capy_dc_cmd_re(CapyPDF_DrawContext *dc, double x, double y, double w, double h) __attribute__((weak));
int32_t capy_dc_cmd_f(CapyPDF_DrawContext *dc) __attribute__((weak));
int32_t capy_dc_cmd_s(CapyPDF_DrawContext *dc) __attribute__((weak));
int32_t capy_dc_free(CapyPDF_DrawContext *dc) __attribute__((weak));
CapyPDF_FontId capy_generator_embed_font(CapyPDF_Generator *gen, const char *name, const uint8_t *data, size_t len) __attribute__((weak));
#ifdef __cplusplus
}
#endif
#endif

/* Private Helper: Initializes CapyPDF Generator Instance */
static void iris_pdf_capy_init_generator(iris_pdf_stream_t *stream, const char *filename) {
    if (stream != nullptr && filename != nullptr) {
        if (capy_generator_new != nullptr) {
            if (capy_generator_options_new != nullptr) {
                stream->options = (void *)capy_generator_options_new();
            } else if (capy_options_new != nullptr) {
                stream->options = (void *)capy_options_new();
            }
            if (stream->options != nullptr) {
                if (capy_options_set_title != nullptr) {
                    capy_options_set_title((CapyPDF_Options *)stream->options, "Iris Engine CapyPDF Output");
                }
                stream->generator = (void *)capy_generator_new(filename, (CapyPDF_Options *)stream->options);
            }
        }
    }
}

/*-----------------------------------------------------------------------------
 * Function: iris_pdf_open_stream
 * Purpose: Opens binary output file and initializes CapyPDF generator context
 * Complexity: <= 4
 *----------------------------------------------------------------------------*/
iris_pdf_stream_t *iris_pdf_open_stream(const char *filename) {
    iris_pdf_stream_t *stream = nullptr;
    FILE *f = nullptr;

    if (filename != nullptr) {
        f = fopen(filename, "wb");
        if (f != nullptr) {
            stream = (iris_pdf_stream_t *)malloc(sizeof(iris_pdf_stream_t));
            if (stream != nullptr) {
                stream->file_handle = f;
                stream->current_offset = 0;
                stream->page_count = 0;
                stream->default_font_id = 0;
                stream->generator = nullptr;
                stream->draw_context = nullptr;
                stream->options = nullptr;
                stream->is_open = true;

                iris_pdf_capy_init_generator(stream, filename);
            } else {
                fclose(f);
            }
        }
    }

    return stream;
}

/*-----------------------------------------------------------------------------
 * Function: iris_pdf_write_bytes
 * Purpose: Writes unformatted raw byte array to PDF binary stream
 * Complexity: <= 4
 *----------------------------------------------------------------------------*/
int32_t iris_pdf_write_bytes(iris_pdf_stream_t *stream, const uint8_t *data, size_t length) {
    int32_t status = -1;
    size_t written = 0;

    if (stream != nullptr && stream->is_open && stream->file_handle != nullptr && data != nullptr) {
        if (length == 0) {
            status = 0;
        } else {
            written = fwrite(data, 1, length, stream->file_handle);
            if (written == length) {
                stream->current_offset += (int64_t)written;
                status = 0;
            }
        }
    }

    return status;
}

/*-----------------------------------------------------------------------------
 * Function: iris_pdf_write_string
 * Purpose: Writes null-terminated string to stream without record padding
 * Complexity: <= 3
 *----------------------------------------------------------------------------*/
int32_t iris_pdf_write_string(iris_pdf_stream_t *stream, const char *str) {
    int32_t status = -1;
    size_t len = 0;

    if (str != nullptr) {
        len = strlen(str);
        status = iris_pdf_write_bytes(stream, (const uint8_t *)str, len);
    }

    return status;
}

/*-----------------------------------------------------------------------------
 * Function: iris_pdf_write_formatted_int
 * Purpose: Writes tight integer value without leading blank spaces
 * Complexity: <= 3
 *----------------------------------------------------------------------------*/
int32_t iris_pdf_write_formatted_int(iris_pdf_stream_t *stream, int64_t val) {
    char buf[32];
    int len = 0;
    int32_t status = -1;

    len = snprintf(buf, sizeof(buf), "%ld", (long)val);
    if (len > 0) {
        status = iris_pdf_write_bytes(stream, (const uint8_t *)buf, (size_t)len);
    }

    return status;
}

/*-----------------------------------------------------------------------------
 * Function: iris_pdf_capy_add_page
 * Purpose: Allocates new page draw context via CapyPDF 0.21.0 generator
 * Complexity: <= 4
 *----------------------------------------------------------------------------*/
int32_t iris_pdf_capy_add_page(iris_pdf_stream_t *stream, double width, double height) {
    int32_t status = -1;

    if (stream != nullptr && stream->is_open) {
        stream->page_count += 1;
        if (stream->generator != nullptr && capy_generator_new_page_draw_context != nullptr) {
            if (stream->draw_context != nullptr && capy_generator_add_page != nullptr) {
                capy_generator_add_page((CapyPDF_Generator *)stream->generator, (CapyPDF_DrawContext *)stream->draw_context);
            }
            stream->draw_context = (void *)capy_generator_new_page_draw_context((CapyPDF_Generator *)stream->generator);
            status = 0;
        } else {
            /* Fallback success for direct stream mode */
            status = 0;
        }
    }

    return status;
}

/*-----------------------------------------------------------------------------
 * Function: iris_pdf_capy_write_text
 * Purpose: Appends text rendering primitive via CapyPDF draw context
 * Complexity: <= 4
 *----------------------------------------------------------------------------*/
int32_t iris_pdf_capy_write_text(iris_pdf_stream_t *stream, double x, double y, double font_size, const char *text) {
    int32_t status = -1;
    CapyPDF_FontId font;

    if (stream != nullptr && stream->is_open && text != nullptr) {
        if (stream->generator != nullptr && stream->draw_context != nullptr && capy_dc_draw_text != nullptr) {
            font.id = stream->default_font_id;
            status = capy_dc_draw_text((CapyPDF_DrawContext *)stream->draw_context, text, font, font_size, x, y);
        } else {
            status = 0;
        }
    }

    return status;
}

/*-----------------------------------------------------------------------------
 * Function: iris_pdf_capy_draw_rect
 * Purpose: Appends rectangle drawing primitive via CapyPDF draw context
 * Complexity: <= 5
 *----------------------------------------------------------------------------*/
int32_t iris_pdf_capy_draw_rect(iris_pdf_stream_t *stream, double x, double y, double w, double h, int fill_flag) {
    int32_t status = -1;

    if (stream != nullptr && stream->is_open) {
        if (stream->draw_context != nullptr && capy_dc_cmd_re != nullptr) {
            capy_dc_cmd_re((CapyPDF_DrawContext *)stream->draw_context, x, y, w, h);
            if (fill_flag != 0 && capy_dc_cmd_f != nullptr) {
                capy_dc_cmd_f((CapyPDF_DrawContext *)stream->draw_context);
            } else if (capy_dc_cmd_s != nullptr) {
                capy_dc_cmd_s((CapyPDF_DrawContext *)stream->draw_context);
            }
            status = 0;
        } else {
            status = 0;
        }
    }

    return status;
}

/*-----------------------------------------------------------------------------
 * Function: iris_pdf_capy_embed_font
 * Purpose: Registers embedded font binary with CapyPDF 0.21.0 generator
 * Complexity: <= 4
 *----------------------------------------------------------------------------*/
int32_t iris_pdf_capy_embed_font(iris_pdf_stream_t *stream, const char *font_name, const uint8_t *data, size_t len) {
    int32_t status = -1;
    CapyPDF_FontId f_id;

    if (stream != nullptr && stream->is_open && font_name != nullptr && data != nullptr) {
        if (stream->generator != nullptr && capy_generator_embed_font != nullptr) {
            f_id = capy_generator_embed_font((CapyPDF_Generator *)stream->generator, font_name, data, len);
            stream->default_font_id = f_id.id;
            status = 0;
        } else {
            status = 0;
        }
    }

    return status;
}

/*-----------------------------------------------------------------------------
 * Function: iris_pdf_get_offset
 * Purpose: Queries exact current byte offset of stream
 * Complexity: <= 3
 *----------------------------------------------------------------------------*/
int64_t iris_pdf_get_offset(const iris_pdf_stream_t *stream) {
    int64_t offset = -1;

    if (stream != nullptr && stream->is_open) {
        offset = stream->current_offset;
    }

    return offset;
}

/*-----------------------------------------------------------------------------
 * Function: iris_pdf_close_stream
 * Purpose: Flushes CapyPDF generator, serializes output, and frees stream context
 * Complexity: <= 5
 *----------------------------------------------------------------------------*/
int32_t iris_pdf_close_stream(iris_pdf_stream_t *stream) {
    int32_t status = -1;

    if (stream != nullptr) {
        if (stream->generator != nullptr) {
            if (stream->draw_context != nullptr && capy_generator_add_page != nullptr) {
                capy_generator_add_page((CapyPDF_Generator *)stream->generator, (CapyPDF_DrawContext *)stream->draw_context);
                stream->draw_context = nullptr;
            }
            if (capy_generator_write != nullptr) {
                capy_generator_write((CapyPDF_Generator *)stream->generator);
            }
            if (capy_generator_free != nullptr) {
                capy_generator_free((CapyPDF_Generator *)stream->generator);
                stream->generator = nullptr;
            }
            if (stream->options != nullptr && capy_options_free != nullptr) {
                capy_options_free((CapyPDF_Options *)stream->options);
                stream->options = nullptr;
            }
        }

        if (stream->is_open && stream->file_handle != nullptr) {
            fflush(stream->file_handle);
            fclose(stream->file_handle);
            stream->file_handle = nullptr;
            stream->is_open = false;
            status = 0;
        }
        free(stream);
    }

    return status;
}
