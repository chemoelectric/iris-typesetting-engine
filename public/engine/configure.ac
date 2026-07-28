# ==============================================================================
# Configure Script Generator for Iris Typographic Engine
# Standard: GNU Autoconf 2.69+ / Automake 1.15+ (Compatible with 2.72 / 1.18.1+)
# Domain: Fortran 2008 & R7RS Scheme Dual Engine
# ==============================================================================

AC_PREREQ([2.69])
AC_INIT([iris], [1.0.0], [support@iris.org])
AC_CONFIG_SRCDIR([fortran/iris_batch_engine.f90])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([m4])

AM_INIT_AUTOMAKE([foreign subdir-objects -Wall -Werror dist-xz])
AM_SILENT_RULES([yes])

# Archive & Ranlib tools for static libraries (libiris.a)
AM_PROG_AR
AC_PROG_RANLIB

# Check for Fortran 2008 compiler
AC_PROG_FC
AC_FC_SRCEXT([f90])
AC_FC_FREEFORM

# Enforce Fortran 2008 standard flag when available
AS_IF([test "x$FC" != "x"], [
  FCFLAGS="$FCFLAGS -std=f2008 -ffree-line-length-none"
])

# Check for zlib library
AC_CHECK_LIB([z], [compress], [], [AC_MSG_ERROR([zlib library is required])])

# Check for libkpathsea library (with fallback notice referencing vendor tarball)
AC_CHECK_LIB([kpathsea], [kpse_find_file],
  [AC_DEFINE([HAVE_LIBKPATHSEA], [1], [Define if libkpathsea is available])],
  [AC_MSG_NOTICE([
----------------------------------------------------------------------
NOTE: libkpathsea was not found on your system.
If you require native kpathsea file searching capabilities, please install
libkpathsea-dev or compile the included source tarball located at:
  vendor/libkpathsea.tar.xz
Iris will fall back to its internal Fortran search engine for kpsewhich.
----------------------------------------------------------------------])])

# Check for Gauche Scheme interpreter (R7RS) for Scheme test harness
AC_CHECK_PROGS([GOSH], [gosh], [none])
AM_CONDITIONAL([HAVE_GOSH], [test "x$GOSH" != "xnone"])

# Output configuration files
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
