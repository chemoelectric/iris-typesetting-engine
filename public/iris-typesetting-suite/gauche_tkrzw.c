// SPDX-License-Identifier: MIT
//
// Gauche and C interface to the Tkrzw key-value database.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "tkrzw_langc.h"

// Open database with path, writable flag, and tuning parameters
TkrzwDBM*
gauche_tkrzw_open (const char* path, bool writable, const char* params)
{
  if (path == NULL)
    {
      return NULL;
    }
  return tkrzw_dbm_open (path, writable, params != NULL ? params : "");
}

// Close database
bool
gauche_tkrzw_close (TkrzwDBM* dbm)
{
  if (dbm == NULL)
    {
      return true;
    }
  return tkrzw_dbm_close (dbm);
}

// Check key existence
bool
gauche_tkrzw_check (TkrzwDBM* dbm, const char* key_ptr, int32_t key_size)
{
  if (dbm == NULL || key_ptr == NULL)
    {
      return false;
    }
  return tkrzw_dbm_check (dbm, key_ptr, key_size);
}

// Get value for key
char*
gauche_tkrzw_get (TkrzwDBM* dbm, const char* key_ptr, int32_t key_size, int32_t* value_size)
{
  if (dbm == NULL || key_ptr == NULL)
    {
      return NULL;
    }
  return tkrzw_dbm_get (dbm, key_ptr, key_size, value_size);
}

// Set value for key
bool
gauche_tkrzw_set (TkrzwDBM* dbm, const char* key_ptr, int32_t key_size,
                  const char* value_ptr, int32_t value_size, bool overwrite)
{
  if (dbm == NULL || key_ptr == NULL || value_ptr == NULL)
    {
      return false;
    }
  return tkrzw_dbm_set (dbm, key_ptr, key_size, value_ptr, value_size, overwrite);
}

// Remove key
bool
gauche_tkrzw_remove (TkrzwDBM* dbm, const char* key_ptr, int32_t key_size)
{
  if (dbm == NULL || key_ptr == NULL)
    {
      return false;
    }
  return tkrzw_dbm_remove (dbm, key_ptr, key_size);
}

// Count records
int64_t
gauche_tkrzw_count (TkrzwDBM* dbm)
{
  if (dbm == NULL)
    {
      return 0;
    }
  return tkrzw_dbm_count (dbm);
}

// Synchronize database to disk
bool
gauche_tkrzw_sync (TkrzwDBM* dbm, bool hard)
{
  if (dbm == NULL)
    {
      return true;
    }
  return tkrzw_dbm_synchronize (dbm, hard, NULL, NULL, "");
}

// Free string allocated by Tkrzw
void
gauche_tkrzw_free (void* ptr)
{
  if (ptr != NULL)
    {
      free (ptr);
    }
}
