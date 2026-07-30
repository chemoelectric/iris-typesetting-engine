/* =============================================================================
 * Module: iris_pdf_io.c
 * Standard: ISO C23
 * Architecture: Low-Level Binary Stream I/O Layer for Iris PDF Generation
 * Rules: Strict single-entry/single-exit control constructs, no goto,
 *        explicit ban on ++ and -- (requiring += 1 and -= 1),
 *        McCabe cyclomatic complexity <= 10 per procedure.
 * =============================================================================
 */

#include "iris_pdf_io.h"
#include <stdlib.h>
#include <string.h>

/*--------------------------------0---------------------------------------------
 * Function: iris_pdf_open_stream
 * Purpose: Opens binary output file and initializes stream context
 * Complexity: <= 3
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
                stream->is_open = true;
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
 * Purpose: Flushes stream buffer, closes OS file handle, and frees stream context
 * Complexity: <= 4
 *----------------------------------------------------------------------------*/
int32_t iris_pdf_close_stream(iris_pdf_stream_t *stream) {
    int32_t status = -1;

    if (stream != nullptr) {
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
