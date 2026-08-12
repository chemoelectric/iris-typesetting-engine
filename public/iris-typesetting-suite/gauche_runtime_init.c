// SPDX-License-Identifier: MIT

#include <gauche.h>

void
gauche_runtime_init (void)
{
  Scm_Init (GAUCHE_SIGNATURE);
}

int
gauche_c_api_version (void)
{
  return GAUCHE_API_VERSION;
}

int
gauche_c_char_encoding_utf8 (void)
{
  return GAUCHE_CHAR_ENCODING_UTF8;
}

ScmObj
gauche_c_false (void)
{
  return SCM_FALSE;
}

ScmObj
gauche_c_true (void)
{
  return SCM_TRUE;
}

ScmObj
gauche_c_nil (void)
{
  return SCM_NIL;
}

ScmObj
gauche_c_eof (void)
{
  return SCM_EOF;
}

ScmObj
gauche_c_undefined (void)
{
  return SCM_UNDEFINED;
}

ScmObj
gauche_c_unbound (void)
{
  return SCM_UNBOUND;
}

ScmObj
gauche_c_uninitialized (void)
{
  return SCM_UNINITIALIZED;
}

int
gauche_c_falsep (ScmObj obj)
{
  return SCM_FALSEP (obj);
}

int
gauche_c_truep (ScmObj obj)
{
  return SCM_TRUEP (obj);
}

int
gauche_c_nullp (ScmObj obj)
{
  return SCM_NULLP (obj);
}

int
gauche_c_eofp (ScmObj obj)
{
  return SCM_EOFP (obj);
}

int
gauche_c_undefinedp (ScmObj obj)
{
  return SCM_UNDEFINEDP (obj);
}

int
gauche_c_unboundp (ScmObj obj)
{
  return SCM_UNBOUNDP (obj);
}

int
gauche_c_uninitializedp (ScmObj obj)
{
  return SCM_UNINITIALIZEDP (obj);
}

int
gauche_c_boolp (ScmObj obj)
{
  return SCM_BOOLP (obj);
}

int
gauche_c_intp (ScmObj obj)
{
  return SCM_INTP (obj);
}

int
gauche_c_flonump (ScmObj obj)
{
  return SCM_FLONUMP (obj);
}

int
gauche_c_charp (ScmObj obj)
{
  return SCM_CHARP (obj);
}

int
gauche_c_pairp (ScmObj obj)
{
  return SCM_PAIRP (obj);
}

int
gauche_c_listp (ScmObj obj)
{
  return SCM_LISTP (obj);
}

int
gauche_c_procedurep (ScmObj obj)
{
  return SCM_PROCEDUREP (obj);
}

long
gauche_c_int_value (ScmObj obj)
{
  return SCM_INT_VALUE (obj);
}

ScmObj
gauche_c_make_int (long val)
{
  return SCM_MAKE_INT (val);
}

double
gauche_c_flonum_value (ScmObj obj)
{
  return SCM_FLONUM_VALUE (obj);
}

long
gauche_c_char_value (ScmObj obj)
{
  return SCM_CHAR_VALUE (obj);
}

ScmObj
gauche_c_make_char (long ch)
{
  return SCM_MAKE_CHAR (ch);
}

ScmObj
gauche_c_car (ScmObj obj)
{
  return SCM_CAR (obj);
}

ScmObj
gauche_c_cdr (ScmObj obj)
{
  return SCM_CDR (obj);
}

ScmObj
gauche_c_caar (ScmObj obj)
{
  return SCM_CAAR (obj);
}

ScmObj
gauche_c_cadr (ScmObj obj)
{
  return SCM_CADR (obj);
}

ScmObj
gauche_c_cdar (ScmObj obj)
{
  return SCM_CDAR (obj);
}

ScmObj
gauche_c_cddr (ScmObj obj)
{
  return SCM_CDDR (obj);
}
