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
  ScmObj res = SCM_FALSE;
  if (path != NULL)
    {
      const char* p = (params != NULL) ? params : "";
      void* handle = iris_db_open (path, writable, p);
      if (handle != NULL)
        {
          res = Scm_MakeForeignPointer (NULL, handle);
        }
    }
  return res;
}

int
gauche_iris_db_close (ScmObj db_obj)
{
  int res = 1;
  if (SCM_FOREIGN_POINTER_P (db_obj))
    {
      void* handle = SCM_FOREIGN_POINTER_REF (void*, db_obj);
      if (handle != NULL)
        {
          res = iris_db_close (handle);
        }
    }
  return res;
}

int
gauche_iris_db_check (ScmObj db_obj, const char* key_ptr, int key_size)
{
  int res = 0;
  if (SCM_FOREIGN_POINTER_P (db_obj) && key_ptr != NULL)
    {
      void* handle = SCM_FOREIGN_POINTER_REF (void*, db_obj);
      if (handle != NULL)
        {
          res = iris_db_check (handle, key_ptr, key_size);
        }
    }
  return res;
}

ScmObj
gauche_iris_db_get (ScmObj db_obj, const char* key_ptr, int key_size)
{
  ScmObj res = SCM_FALSE;
  if (SCM_FOREIGN_POINTER_P (db_obj) && key_ptr != NULL)
    {
      void* handle = SCM_FOREIGN_POINTER_REF (void*, db_obj);
      if (handle != NULL)
        {
          int val_size = 0;
          char* val = iris_db_get (handle, key_ptr, key_size,
                                   &val_size);
          if (val != NULL)
            {
              res = Scm_MakeString (val, val_size, val_size,
                                    SCM_STRING_COPYING);
              iris_db_free (val);
            }
        }
    }
  return res;
}

int
gauche_iris_db_set (ScmObj db_obj, const char* key_ptr, int key_size,
                    const char* val_ptr, int val_size, int overwrite)
{
  int res = 0;
  if (SCM_FOREIGN_POINTER_P (db_obj) && key_ptr != NULL &&
      val_ptr != NULL)
    {
      void* handle = SCM_FOREIGN_POINTER_REF (void*, db_obj);
      if (handle != NULL)
        {
          res = iris_db_set (handle, key_ptr, key_size,
                             val_ptr, val_size, overwrite);
        }
    }
  return res;
}

int
gauche_iris_db_remove (ScmObj db_obj, const char* key_ptr,
                       int key_size)
{
  int res = 0;
  if (SCM_FOREIGN_POINTER_P (db_obj) && key_ptr != NULL)
    {
      void* handle = SCM_FOREIGN_POINTER_REF (void*, db_obj);
      if (handle != NULL)
        {
          res = iris_db_remove (handle, key_ptr, key_size);
        }
    }
  return res;
}

int64_t
gauche_iris_db_count (ScmObj db_obj)
{
  int64_t res = 0;
  if (SCM_FOREIGN_POINTER_P (db_obj))
    {
      void* handle = SCM_FOREIGN_POINTER_REF (void*, db_obj);
      if (handle != NULL)
        {
          res = (int64_t) iris_db_count (handle);
        }
    }
  return res;
}

int
gauche_iris_db_sync (ScmObj db_obj, int hard)
{
  int res = 1;
  if (SCM_FOREIGN_POINTER_P (db_obj))
    {
      void* handle = SCM_FOREIGN_POINTER_REF (void*, db_obj);
      if (handle != NULL)
        {
          res = iris_db_sync (handle, hard);
        }
    }
  return res;
}

int
gauche_iris_db_edit_distance (const char* str_a, const char* str_b,
                              int utf)
{
  int res = -1;
  if (str_a != NULL && str_b != NULL)
    {
      res = iris_db_edit_distance (str_a, str_b, utf);
    }
  return res;
}
