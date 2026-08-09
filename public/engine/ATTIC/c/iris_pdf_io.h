/* =============================================================================
 * Header: iris_pdf_io.h
 * Standard: ISO C23
 * Architecture: Low-Level CapyPDF 0.21.0 C23 Binding Layer for Iris PDF Generation
 * Rules: Strict single-entry/single-exit control constructs, no goto,
 *        explicit ban on ++ and -- (requiring += 1 and -= 1),
 *        McCabe cyclomatic complexity <= 10 per procedure.
 * =============================================================================
 */

#ifndef IRIS_PDF_IO_H
#define IRIS_PDF_IO_H

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct iris_pdf_stream {
    void *generator;      /* CapyPDF_Generator pointer */
    void *draw_context;   /* CapyPDF_DrawContext pointer */
    void *options;        /* CapyPDF_Options pointer */
    FILE *file_handle;
    int64_t current_offset;
    int32_t page_count;
    int32_t default_font_id;
    bool is_open;
} iris_pdf_stream_t;

iris_pdf_stream_t *iris_pdf_open_stream(const char *filename);
int32_t iris_pdf_write_bytes(iris_pdf_stream_t *stream, const uint8_t *data, size_t length);
int32_t iris_pdf_write_string(iris_pdf_stream_t *stream, const char *str);
int32_t iris_pdf_write_formatted_int(iris_pdf_stream_t *stream, int64_t val);
int32_t iris_pdf_capy_add_page(iris_pdf_stream_t *stream, double width, double height);
int32_t iris_pdf_capy_write_text(iris_pdf_stream_t *stream, double x, double y, double font_size, const char *text);
int32_t iris_pdf_capy_draw_rect(iris_pdf_stream_t *stream, double x, double y, double w, double h, int fill_flag);
int32_t iris_pdf_capy_embed_font(iris_pdf_stream_t *stream, const char *font_name, const uint8_t *data, size_t len);
int64_t iris_pdf_get_offset(const iris_pdf_stream_t *stream);
int32_t iris_pdf_close_stream(iris_pdf_stream_t *stream);

#ifdef __cplusplus
}
#endif

#endif /* IRIS_PDF_IO_H */
