// SPDX-License-Identifier: MIT
//
// Gauche Scheme bridge to the Ada Database interface (iris_db_*).
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <gauche.h>

// Declarations of Ada exported C functions from database.ads
extern void* iris_db_open (const char* path, int writable,
                           const char* params);
extern int iris_db_close (void* db);
extern int iris_db_check (void* db, const char* key_ptr, int key_size);
extern char* iris_db_get (void* db, const char* key_ptr, int key_size,
                          int* value_size);
extern int iris_db_set (void* db, const char* key_ptr, int key_size,
                        const char* val_ptr, int val_size,
                        int overwrite);
extern int iris_db_remove (void* db, const char* key_ptr, int key_size);
extern long long iris_db_count (void* db);
extern int iris_db_sync (void* db, int hard);
extern int iris_db_edit_distance (const char* str_a, const char* str_b,
                                  int utf);
extern void iris_db_free (void* ptr);

// C bridge wrappers for Gauche Scheme

ScmObj
gauche_iris_db_open (const char* path, int writable, const char* params)
{
  if (path == NULL)
    {
      return SCM_FALSE;
    }
  void* handle = iris_db_open (path, writable,
                               params != NULL ? params : "");
  if (handle == NULL)
    {
      return SCM_FALSE;
    }
  return Scm_MakeForeignPointer (NULL, handle);
}

int
gauche_iris_db_close (ScmObj db_obj)
{
  if (!SCM_FOREIGN_POINTER_P (db_obj))
    {
      return 1;
    }
  void* handle = SCM_FOREIGN_POINTER_REF (void*, db_obj);
  if (handle == NULL)
    {
      return 1;
    }
  int res = iris_db_close (handle);
  SCM_FOREIGN_POINTER_REF (void*, db_obj) = NULL;
  return res;
}

int
gauche_iris_db_check (ScmObj db_obj, const char* key_ptr, int key_size)
{
  if (!SCM_FOREIGN_POINTER_P (db_obj) || key_ptr == NULL)
    {
      return 0;
    }
  void* handle = SCM_FOREIGN_POINTER_REF (void*, db_obj);
  if (handle == NULL)
    {
      return 0;
    }
  return iris_db_check (handle, key_ptr, key_size);
}

ScmObj
gauche_iris_db_get (ScmObj db_obj, const char* key_ptr, int key_size)
{
  if (!SCM_FOREIGN_POINTER_P (db_obj) || key_ptr == NULL)
    {
      return SCM_FALSE;
    }
  void* handle = SCM_FOREIGN_POINTER_REF (void*, db_obj);
  if (handle == NULL)
    {
      return SCM_FALSE;
    }
  int val_size = 0;
  char* val = iris_db_get (handle, key_ptr, key_size, &val_size);
  if (val == NULL)
    {
      return SCM_FALSE;
    }
  ScmObj res = Scm_MakeString (val, val_size, val_size,
                               SCM_STRING_COPYING);
  iris_db_free (val);
  return res;
}

int
gauche_iris_db_set (ScmObj db_obj, const char* key_ptr, int key_size,
                    const char* val_ptr, int val_size, int overwrite)
{
  if (!SCM_FOREIGN_POINTER_P (db_obj) || key_ptr == NULL ||
      val_ptr == NULL)
    {
      return 0;
    }
  void* handle = SCM_FOREIGN_POINTER_REF (void*, db_obj);
  if (handle == NULL)
    {
      return 0;
    }
  return iris_db_set (handle, key_ptr, key_size,
                      val_ptr, val_size, overwrite);
}

int
gauche_iris_db_remove (ScmObj db_obj, const char* key_ptr,
                       int key_size)
{
  if (!SCM_FOREIGN_POINTER_P (db_obj) || key_ptr == NULL)
    {
      return 0;
    }
  void* handle = SCM_FOREIGN_POINTER_REF (void*, db_obj);
  if (handle == NULL)
    {
      return 0;
    }
  return iris_db_remove (handle, key_ptr, key_size);
}

int64_t
gauche_iris_db_count (ScmObj db_obj)
{
  if (!SCM_FOREIGN_POINTER_P (db_obj))
    {
      return 0;
    }
  void* handle = SCM_FOREIGN_POINTER_REF (void*, db_obj);
  if (handle == NULL)
    {
      return 0;
    }
  return (int64_t) iris_db_count (handle);
}

int
gauche_iris_db_sync (ScmObj db_obj, int hard)
{
  if (!SCM_FOREIGN_POINTER_P (db_obj))
    {
      return 1;
    }
  void* handle = SCM_FOREIGN_POINTER_REF (void*, db_obj);
  if (handle == NULL)
    {
      return 1;
    }
  return iris_db_sync (handle, hard);
}

int
gauche_iris_db_edit_distance (const char* str_a, const char* str_b,
                              int utf)
{
  if (str_a == NULL || str_b == NULL)
    {
      return -1;
    }
  return iris_db_edit_distance (str_a, str_b, utf);
}
