/* =============================================================================
 * Header: iris_pdf_io.h
 * Standard: ISO C23
 * Architecture: Low-Level Binary Stream I/O Layer for Iris PDF Generation
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
    FILE *file_handle;
    int64_t current_offset;
    bool is_open;
} iris_pdf_stream_t;

iris_pdf_stream_t *iris_pdf_open_stream(const char *filename);
int32_t iris_pdf_write_bytes(iris_pdf_stream_t *stream, const uint8_t *data, size_t length);
int32_t iris_pdf_write_string(iris_pdf_stream_t *stream, const char *str);
int32_t iris_pdf_write_formatted_int(iris_pdf_stream_t *stream, int64_t val);
int64_t iris_pdf_get_offset(const iris_pdf_stream_t *stream);
int32_t iris_pdf_close_stream(iris_pdf_stream_t *stream);

#ifdef __cplusplus
}
#endif

#endif /* IRIS_PDF_IO_H */
