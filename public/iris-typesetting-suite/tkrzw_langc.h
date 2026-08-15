/*************************************************************************************************
 * C language binding of Tkrzw
 *
 * Copyright 2020 Google LLC
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
 * except in compliance with the License.  You may obtain a copy of the License at
 *     https://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied.  See the License for the specific language governing permissions
 * and limitations under the License.
 *************************************************************************************************/

#ifndef _TKRZW_LANGC_H
#define _TKRZW_LANGC_H

#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

#if defined(__cplusplus)
extern "C" {
#endif

/** The string expression of the package version. */
extern const char* const TKRZW_PACKAGE_VERSION;

/** The string expression of the library version. */
extern const char* const TKRZW_LIBRARY_VERSION;

/** The recognized OS name. */
extern const char* const TKRZW_OS_NAME;

/** The size of a memory page on the OS. */
extern const int32_t TKRZW_PAGE_SIZE;

/** The minimum value of int64_t. */
extern const int64_t TKRZW_INT64MIN;

/** The maximum value of int64_t. */
extern const int64_t TKRZW_INT64MAX;

/** Enumeration for status codes. */
enum {
  /** Success. */
  TKRZW_STATUS_SUCCESS = 0,
  /** Generic error whose cause is unknown. */
  TKRZW_STATUS_UNKNOWN_ERROR = 1,
  /** Generic error from underlying systems. */
  TKRZW_STATUS_SYSTEM_ERROR = 2,
  /** Error that the feature is not implemented. */
  TKRZW_STATUS_NOT_IMPLEMENTED_ERROR = 3,
  /** Error that a precondition is not met. */
  TKRZW_STATUS_PRECONDITION_ERROR = 4,
  /** Error that a given argument is invalid. */
  TKRZW_STATUS_INVALID_ARGUMENT_ERROR = 5,
  /** Error that the operation is canceled. */
  TKRZW_STATUS_CANCELED_ERROR = 6,
  /** Error that a specific resource is not found. */
  TKRZW_STATUS_NOT_FOUND_ERROR = 7,
  /** Error that the operation is not permitted. */
  TKRZW_STATUS_PERMISSION_ERROR = 8,
  /** Error that the operation is infeasible. */
  TKRZW_STATUS_INFEASIBLE_ERROR = 9,
  /** Error that a specific resource is duplicated. */
  TKRZW_STATUS_DUPLICATION_ERROR = 10,
  /** Error that internal data are broken. */
  TKRZW_STATUS_BROKEN_DATA_ERROR = 11,
  /** Error caused by networking failure. */
  TKRZW_STATUS_NETWORK_ERROR = 12,
  /** Generic error caused by the application logic. */
  TKRZW_STATUS_APPLICATION_ERROR = 13,
};

/**
 * Pair of a status code and a message.
 */
typedef struct {
  /** The status code. */
  int32_t code;
  /** The message string. */
  const char* message;
} TkrzwStatus;

/**
 * Future interface, just for type check.
 */
typedef struct {
  /** A dummy member which is never used. */
  void* _dummy_;
} TkrzwFuture;

/**
 * DBM interface, just for type check.
 */
typedef struct {
  /** A dummy member which is never used. */
  void* _dummy_;
} TkrzwDBM;

/**
 * Iterator interface, just for type check.
 */
typedef struct {
  /** A dummy member which is never used. */
  void* _dummy_;
} TkrzwDBMIter;

/**
 * Asynchronous DBM interface, just for type check.
 */
typedef struct {
  /** A dummy member which is never used. */
  void* _dummy_;
} TkrzwAsyncDBM;

/**
 * File interface, just for type check.
 */
typedef struct {
  /** A dummy member which is never used. */
  void* _dummy_;
} TkrzwFile;

/**
 * Index interface, just for type check.
 */
typedef struct {
  /** A dummy member which is never used. */
  void* _dummy_;
} TkrzwIndex;

/**
 * Index iterator interface, just for type check.
 */
typedef struct {
  /** A dummy member which is never used. */
  void* _dummy_;
} TkrzwIndexIter;

/** The special string_view value to represent any data. */
extern const char* const TKRZW_ANY_DATA;

/**
 * Type of the record processor function.
 */
typedef const char* (*tkrzw_record_processor)(
    void*, const char*, int32_t, const char*, int32_t, int32_t*);

/** The special string indicating no operation. */
extern const char* const TKRZW_REC_PROC_NOOP;

/** The special string indicating removing operation. */
extern const char* const TKRZW_REC_PROC_REMOVE;

/**
 * String pointer and its size.
 */
typedef struct {
  /** The pointer to the region. */
  const char* ptr;
  /** The size of the region. */
  int32_t size;
} TkrzwStr;

/**
 * Pair of a key and its value.
 */
typedef struct {
  /** The key pointer. */
  const char* key_ptr;
  /** The key size. */
  int32_t key_size;
  /** The value pointer. */
  const char* value_ptr;
  /** The value size. */
  int32_t value_size;
} TkrzwKeyValuePair;

/**
 * Pair of a key and its processor.
 */
typedef struct {
  /** The key pointer. */
  const char* key_ptr;
  /** The key size. */
  int32_t key_size;
  /** The function pointer to process the key. */
  tkrzw_record_processor proc;
  /** An arbitrary data which is given to the callback function. */
  void* proc_arg;
} TkrzwKeyProcPair;

/**
 * Type of the file processor function.
 */
typedef void (*tkrzw_file_processor)(void* arg, const char*);

void tkrzw_set_last_status(int32_t code, const char* message);
TkrzwStatus tkrzw_get_last_status(void);
int32_t tkrzw_get_last_status_code(void);
const char* tkrzw_get_last_status_message(void);
const char* tkrzw_status_code_name(int32_t code);
double tkrzw_get_wall_time(void);
int64_t tkrzw_get_memory_capacity(void);
int64_t tkrzw_get_memory_usage(void);
uint64_t tkrzw_primary_hash(const char* data_ptr, int32_t data_size, uint64_t num_buckets);
uint64_t tkrzw_secondary_hash(const char* data_ptr, int32_t data_size, uint64_t num_shards);
void tkrzw_free_str_array(TkrzwStr* array, int32_t size);
void tkrzw_free_str_map(TkrzwKeyValuePair* array, int32_t size);
TkrzwKeyValuePair* tkrzw_search_str_map(TkrzwKeyValuePair* array, int32_t size,
                                        const char* key_ptr, int32_t key_size);
int32_t tkrzw_str_search_regex(const char* text, const char* pattern);
char* tkrzw_str_replace_regex(const char* text, const char* pattern, const char* replace);
int32_t tkrzw_str_edit_distance_lev(const char* a, const char* b, bool utf);
uint64_t tkrzw_str_to_int_be(const void* ptr, size_t size);
long double tkrzw_str_to_float_be(const void* ptr, size_t size);
char* tkrzw_int_to_str_be(uint64_t data, size_t size);
char* tkrzw_float_to_str_be(long double data, size_t size);
char* tkrzw_str_escape_c(const char* ptr, int32_t size, bool esc_nonasc, int32_t* res_size);
char* tkrzw_str_unescape_c(const char* ptr, int32_t size, int32_t* res_size);
char* tkrzw_str_append(char* modified, const char* appended);

void tkrzw_future_free(TkrzwFuture* future);
bool tkrzw_future_wait(TkrzwFuture* future, double timeout);
void tkrzw_future_get(TkrzwFuture* future);
char* tkrzw_future_get_str(TkrzwFuture* future, int32_t* size);
TkrzwKeyValuePair* tkrzw_future_get_str_pair(TkrzwFuture* future);
TkrzwStr* tkrzw_future_get_str_array(TkrzwFuture* future, int32_t* num_elems);
TkrzwKeyValuePair* tkrzw_future_get_str_map(TkrzwFuture* future, int32_t* num_elems);
int64_t tkrzw_future_get_int(TkrzwFuture* future);

TkrzwDBM* tkrzw_dbm_open(const char* path, bool writable, const char* params);
bool tkrzw_dbm_close(TkrzwDBM* dbm);
bool tkrzw_dbm_process(
    TkrzwDBM* dbm, const char* key_ptr, int32_t key_size, tkrzw_record_processor proc,
    void* proc_arg, bool writable);
bool tkrzw_dbm_check(TkrzwDBM* dbm, const char* key_ptr, int32_t key_size);
char* tkrzw_dbm_get(TkrzwDBM* dbm, const char* key_ptr, int32_t key_size, int32_t* value_size);
TkrzwKeyValuePair* tkrzw_dbm_get_multi(
    TkrzwDBM* dbm, const TkrzwStr* keys, int32_t num_keys, int32_t* num_matched);
bool tkrzw_dbm_set(
    TkrzwDBM* dbm, const char* key_ptr, int32_t key_size,
    const char* value_ptr, int32_t value_size, bool overwrite);
char* tkrzw_dbm_set_and_get(
    TkrzwDBM* dbm, const char* key_ptr, int32_t key_size,
    const char* value_ptr, int32_t value_size, bool overwrite, int32_t* old_value_size);
bool tkrzw_dbm_set_multi(
    TkrzwDBM* dbm, const TkrzwKeyValuePair* records, int32_t num_records, bool overwrite);
bool tkrzw_dbm_remove(TkrzwDBM* dbm, const char* key_ptr, int32_t key_size);
char* tkrzw_dbm_remove_and_get(TkrzwDBM* dbm, const char* key_ptr, int32_t key_size,
                               int32_t* value_size);
bool tkrzw_dbm_remove_multi(TkrzwDBM* dbm, const TkrzwStr* keys, int32_t num_keys);
bool tkrzw_dbm_append(
    TkrzwDBM* dbm, const char* key_ptr, int32_t key_size,
    const char* value_ptr, int32_t value_size,
    const char* delim_ptr, int32_t delim_size);
bool tkrzw_dbm_append_multi(
    TkrzwDBM* dbm, const TkrzwKeyValuePair* records, int32_t num_records,
    const char* delim_ptr, int32_t delim_size);
bool tkrzw_dbm_compare_exchange(
    TkrzwDBM* dbm, const char* key_ptr, int32_t key_size,
    const char* expected_ptr, int32_t expected_size,
    const char* desired_ptr, int32_t desired_size);
char* tkrzw_dbm_compare_exchange_and_get(
    TkrzwDBM* dbm, const char* key_ptr, int32_t key_size,
    const char* expected_ptr, int32_t expected_size,
    const char* desired_ptr, int32_t desired_size, int32_t* actual_size);
int64_t tkrzw_dbm_increment(
    TkrzwDBM* dbm, const char* key_ptr, int32_t key_size,
    int64_t increment, int64_t initial);
bool tkrzw_dbm_process_multi(
    TkrzwDBM* dbm, TkrzwKeyProcPair* key_proc_pairs, int32_t num_pairs, bool writable);
bool tkrzw_dbm_compare_exchange_multi(
    TkrzwDBM* dbm, const TkrzwKeyValuePair* expected, int32_t num_expected,
    const TkrzwKeyValuePair* desired, int32_t num_desired);
bool tkrzw_dbm_rekey(
    TkrzwDBM* dbm, const char* old_key_ptr, int32_t old_key_size,
    const char* new_key_ptr, int32_t new_key_size, bool overwrite, bool copying);
bool tkrzw_dbm_process_first(
    TkrzwDBM* dbm, tkrzw_record_processor proc, void* proc_arg, bool writable);
bool tkrzw_dbm_pop_first(TkrzwDBM* dbm, char** key_ptr, int32_t* key_size,
                         char** value_ptr, int32_t* value_size);
bool tkrzw_dbm_push_last(TkrzwDBM* dbm, const char* value_ptr, int32_t value_size, double wtime);
bool tkrzw_dbm_process_each(
    TkrzwDBM* dbm, tkrzw_record_processor proc, void* proc_arg, bool writable);
int64_t tkrzw_dbm_count(TkrzwDBM* dbm);
int64_t tkrzw_dbm_get_file_size(TkrzwDBM* dbm);
char* tkrzw_dbm_get_file_path(TkrzwDBM* dbm);
double tkrzw_dbm_get_timestamp(TkrzwDBM* dbm);
bool tkrzw_dbm_clear(TkrzwDBM* dbm);
bool tkrzw_dbm_rebuild(TkrzwDBM* dbm, const char* params);
bool tkrzw_dbm_should_be_rebuilt(TkrzwDBM* dbm);
bool tkrzw_dbm_synchronize(
    TkrzwDBM* dbm, bool hard, tkrzw_file_processor proc, void* proc_arg, const char* params);
bool tkrzw_dbm_copy_file_data(TkrzwDBM* dbm, const char* dest_path, bool sync_hard);
bool tkrzw_dbm_export(TkrzwDBM* dbm, TkrzwDBM* dest_dbm);
bool tkrzw_dbm_export_to_flat_records(TkrzwDBM* dbm, TkrzwFile* dest_file);
bool tkrzw_dbm_import_from_flat_records(TkrzwDBM* dbm, TkrzwFile* src_file);
bool tkrzw_dbm_export_keys_as_lines(TkrzwDBM* dbm, TkrzwFile* dest_file);
TkrzwKeyValuePair* tkrzw_dbm_inspect(TkrzwDBM* dbm, int32_t* num_records);
bool tkrzw_dbm_is_writable(TkrzwDBM* dbm);
bool tkrzw_dbm_is_healthy(TkrzwDBM* dbm);
bool tkrzw_dbm_is_ordered(TkrzwDBM* dbm);
TkrzwStr* tkrzw_dbm_search(
    TkrzwDBM* dbm, const char* mode, const char* pattern_ptr, int32_t pattern_size,
    int32_t capacity, int32_t* num_matched);

TkrzwDBMIter* tkrzw_dbm_make_iterator(TkrzwDBM* dbm);
void tkrzw_dbm_iter_free(TkrzwDBMIter* iter);
bool tkrzw_dbm_iter_first(TkrzwDBMIter* iter);
bool tkrzw_dbm_iter_last(TkrzwDBMIter* iter);
bool tkrzw_dbm_iter_jump(TkrzwDBMIter* iter, const char* key_ptr, int32_t key_size);
bool tkrzw_dbm_iter_jump_lower(TkrzwDBMIter* iter, const char* key_ptr, int32_t key_size,
                               bool inclusive);
bool tkrzw_dbm_iter_jump_upper(TkrzwDBMIter* iter, const char* key_ptr, int32_t key_size,
                               bool inclusive);
bool tkrzw_dbm_iter_next(TkrzwDBMIter* iter);
bool tkrzw_dbm_iter_previous(TkrzwDBMIter* iter);
bool tkrzw_dbm_iter_process(
    TkrzwDBMIter* iter, tkrzw_record_processor proc, void* proc_arg, bool writable);
bool tkrzw_dbm_iter_get(
    TkrzwDBMIter* iter, char** key_ptr, int32_t* key_size,
    char** value_ptr, int32_t* value_size);
char* tkrzw_dbm_iter_get_key(TkrzwDBMIter* iter, int32_t* key_size);
char* tkrzw_dbm_iter_get_value(TkrzwDBMIter* iter, int32_t* value_size);
bool tkrzw_dbm_iter_set(TkrzwDBMIter* iter, const char* value_ptr, int32_t value_size);
bool tkrzw_dbm_iter_remove(TkrzwDBMIter* iter);
bool tkrzw_dbm_iter_step(
    TkrzwDBMIter* iter, char** key_ptr, int32_t* key_size,
    char** value_ptr, int32_t* value_size);

bool tkrzw_dbm_restore_database(
    const char* old_file_path, const char* new_file_path,
    const char* class_name, int64_t end_offset, const char* cipher_key);

#if defined(__cplusplus)
}
#endif

#endif  /* _TKRZW_LANGC_H */
