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

// Gauche Scheme Subr primitive handlers

static ScmObj
scm_iris_db_open (ScmObj *args, int argc, void *data)
{
  (void) argc;
  (void) data;
  const char *path = Scm_GetStringConst (SCM_STRING (args[0]));
  int writable = SCM_INT_VALUE (args[1]);
  const char *params = "";
  if (SCM_STRINGP (args[2]))
    {
      params = Scm_GetStringConst (SCM_STRING (args[2]));
    }
  return gauche_iris_db_open (path, writable, params);
}

static ScmObj
scm_iris_db_close (ScmObj *args, int argc, void *data)
{
  (void) argc;
  (void) data;
  int res = gauche_iris_db_close (args[0]);
  return SCM_MAKE_INT (res);
}

static ScmObj
scm_iris_db_check (ScmObj *args, int argc, void *data)
{
  (void) argc;
  (void) data;
  const ScmStringBody *body = SCM_STRING_BODY (args[1]);
  const char *key = SCM_STRING_BODY_START (body);
  int klen = (int) SCM_STRING_BODY_SIZE (body);
  int res = gauche_iris_db_check (args[0], key, klen);
  return SCM_MAKE_INT (res);
}

static ScmObj
scm_iris_db_get (ScmObj *args, int argc, void *data)
{
  (void) argc;
  (void) data;
  const ScmStringBody *body = SCM_STRING_BODY (args[1]);
  const char *key = SCM_STRING_BODY_START (body);
  int klen = (int) SCM_STRING_BODY_SIZE (body);
  return gauche_iris_db_get (args[0], key, klen);
}

static ScmObj
scm_iris_db_set (ScmObj *args, int argc, void *data)
{
  (void) argc;
  (void) data;
  const ScmStringBody *kbody = SCM_STRING_BODY (args[1]);
  const char *key = SCM_STRING_BODY_START (kbody);
  int klen = (int) SCM_STRING_BODY_SIZE (kbody);

  const ScmStringBody *vbody = SCM_STRING_BODY (args[2]);
  const char *val = SCM_STRING_BODY_START (vbody);
  int vlen = (int) SCM_STRING_BODY_SIZE (vbody);

  int overwrite = SCM_INT_VALUE (args[3]);
  int res = gauche_iris_db_set (args[0], key, klen, val, vlen,
                                overwrite);
  return SCM_MAKE_INT (res);
}

static ScmObj
scm_iris_db_remove (ScmObj *args, int argc, void *data)
{
  (void) argc;
  (void) data;
  const ScmStringBody *body = SCM_STRING_BODY (args[1]);
  const char *key = SCM_STRING_BODY_START (body);
  int klen = (int) SCM_STRING_BODY_SIZE (body);
  int res = gauche_iris_db_remove (args[0], key, klen);
  return SCM_MAKE_INT (res);
}

static ScmObj
scm_iris_db_count (ScmObj *args, int argc, void *data)
{
  (void) argc;
  (void) data;
  int64_t res = gauche_iris_db_count (args[0]);
  return Scm_MakeInteger64 (res);
}

static ScmObj
scm_iris_db_sync (ScmObj *args, int argc, void *data)
{
  (void) argc;
  (void) data;
  int hard = SCM_INT_VALUE (args[1]);
  int res = gauche_iris_db_sync (args[0], hard);
  return SCM_MAKE_INT (res);
}

static ScmObj
scm_iris_db_edit_distance (ScmObj *args, int argc, void *data)
{
  (void) argc;
  (void) data;
  const char *sa = Scm_GetStringConst (SCM_STRING (args[0]));
  const char *sb = Scm_GetStringConst (SCM_STRING (args[1]));
  int res = gauche_iris_db_edit_distance (sa, sb, 1);
  return SCM_MAKE_INT (res);
}

static void
define_subr (ScmModule *mod, const char *name, ScmSubrProc *proc,
             int in_arity, int opt_arity)
{
  ScmObj sname = SCM_INTERN (name);
  ScmObj subr = Scm_MakeSubr (proc, NULL, in_arity, opt_arity, sname);
  Scm_Define (mod, SCM_SYMBOL (sname), subr);
}

int
gauche_iris_db_build_from_ls_r (const char *path)
{
  int res = 0;
  if (path != NULL)
    {
      extern void gauche_runtime_init (void);
      gauche_runtime_init ();

      char buf[2048];
      snprintf (buf, sizeof (buf),
                "(guard (e (else 0))"
                "  (add-load-path \"r7rs\" :after)"
                "  (add-load-path \".\" :after)"
                "  (eval '(import (iris db builder))"
                "        (interaction-environment))"
                "  (eval '(import (iris texmf ls-R))"
                "        (interaction-environment))"
                "  (build-texmf-db \"%s\"))",
                path);

      ScmEvalPacket packet;
      int status = Scm_EvalCString (buf, SCM_OBJ (Scm_UserModule ()),
                                    &packet);
      if (status >= 0)
        {
          res = 1;
        }
    }
  return res;
}

void
gauche_iris_db_init (void)
{
  ScmModule *mod = Scm_UserModule ();
  define_subr (mod, "%iris-db-open", scm_iris_db_open, 3, 0);
  define_subr (mod, "%iris-db-close", scm_iris_db_close, 1, 0);
  define_subr (mod, "%iris-db-check", scm_iris_db_check, 2, 0);
  define_subr (mod, "%iris-db-get", scm_iris_db_get, 2, 0);
  define_subr (mod, "%iris-db-set", scm_iris_db_set, 4, 0);
  define_subr (mod, "%iris-db-remove", scm_iris_db_remove, 2, 0);
  define_subr (mod, "%iris-db-count", scm_iris_db_count, 1, 0);
  define_subr (mod, "%iris-db-sync", scm_iris_db_sync, 2, 0);
  define_subr (mod, "%iris-db-edit-distance",
               scm_iris_db_edit_distance, 2, 0);
}

static bool
append_chunk (char **pbuf, size_t *plen, size_t *pcap,
              const char *chunk, size_t clen)
{
  bool ok = true;
  if (*plen + clen + 1 >= *pcap)
    {
      *pcap *= 2;
      char *nbuf = (char *) realloc (*pbuf, *pcap);
      if (nbuf == NULL)
        {
          ok = false;
        }
      else
        {
          *pbuf = nbuf;
        }
    }
  if (ok)
    {
      memcpy (*pbuf + *plen, chunk, clen);
      *plen += clen;
      (*pbuf)[*plen] = '\0';
    }
  return ok;
}

char *
iris_run_command_output (const char *cmd)
{
  char *res = NULL;
  if (cmd != NULL)
    {
      FILE *fp = popen (cmd, "r");
      if (fp != NULL)
        {
          size_t cap = 8192;
          size_t len = 0;
          char *buf = (char *) malloc (cap);
          if (buf != NULL)
            {
              buf[0] = '\0';
              char chunk[1024];
              bool ok = true;
              while (ok && fgets (chunk, sizeof (chunk), fp) != NULL)
                {
                  size_t clen = strlen (chunk);
                  ok = append_chunk (&buf, &len, &cap, chunk, clen);
                }
              if (ok)
                {
                  res = buf;
                }
              else
                {
                  free (buf);
                }
            }
          pclose (fp);
        }
    }
  return res;
}

void
iris_free_command_output (char *ptr)
{
  if (ptr != NULL)
    {
      free (ptr);
    }
}

void
Scm_Init_libiris (void)
{
  gauche_iris_db_init ();
}
