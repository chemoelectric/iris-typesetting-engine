# ==============================================================================
# Configure Script Generator for Iris Typographic Engine
# Standard: GNU Autoconf 2.72+ / Automake 1.18.1+
# Domain: Fortran 2008 & R7RS Scheme Dual Engine
# ==============================================================================

AC_PREREQ([2.72])
AC_INIT([iris],[1.0.0])
AC_CONFIG_SRCDIR([fortran/iris_batch_engine.f90])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([m4])
AC_CANONICAL_BUILD                 dnl On what platform are we compiling?
AC_CANONICAL_HOST                  dnl For what platform are we compiling?
AC_USE_SYSTEM_EXTENSIONS           dnl Define such macros as _GNU_SOURCE.

AM_INIT_AUTOMAKE([1.18.1 foreign subdir-objects tar-pax no-dist-gzip dist-xz])
AM_SILENT_RULES([no])
AM_MAINTAINER_MODE

AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PROG_MKDIR_P
AC_PROG_AWK
AC_PROG_SED
AC_PROG_GREP
AC_PROG_FGREP
AC_PROG_EGREP

# Archive & Ranlib tools for static libraries (libiris.a)
AM_PROG_AR
AC_PROG_RANLIB

# Require GNU Make.
CHEM_REQUIRE_GNU_MAKE_IN_PATH

# Check for a C compiler.
AC_PROG_CC
AC_PROG_CC_C_O

# Try to force C23, and prefer GNU enhancements.
CHEM_C23_FLAGS([c23_flags])
CFLAGS="${CFLAGS}${CFLAGS+ }${c23_flags}"

# Check for Fortran 2008 compiler
AC_PROG_FC
AC_FC_SRCEXT([f90])
AC_FC_FREEFORM

# Enforce Fortran 2008 standard flag when available
CHEM_GNU_FC_FLAGS([fc_flags],[-std=f2008 -ffree-line-length-none -cpp])
FCFLAGS="${FCFLAGS}${FCFLAGS+ }${fc_flags}"

# ==============================================================================
# Configure Options: BLAS & LAPACK Linear Algebra Libraries
# ==============================================================================

BLAS_LIBS=""
LAPACK_LIBS=""
have_blas=no
have_lapack=no

AC_ARG_WITH([blas],
  [AS_HELP_STRING([--with-blas[[=LIB]]], [use BLAS library [default=check]])],
  [with_blas=$withval],
  [with_blas=check])

AC_ARG_WITH([lapack],
  [AS_HELP_STRING([--with-lapack[[=LIB]]], [use LAPACK library [default=check]])],
  [with_lapack=$withval],
  [with_lapack=check])

AC_LANG_PUSH([Fortran])

# Check for BLAS
AS_IF([test "x$with_blas" != "xno"], [
  AS_IF([test "x$with_blas" != "xyes" && test "x$with_blas" != "xcheck"], [
    BLAS_LIBS="$with_blas"
    have_blas=yes
  ], [
    save_LIBS="$LIBS"
    AC_SEARCH_LIBS([dgemm], [blis-mt mkl_rt openblas flexiblas blas], [
      have_blas=yes
      AS_IF([test "x$ac_cv_search_dgemm" != "xnone required"], [
        BLAS_LIBS="$ac_cv_search_dgemm"
      ])
    ], [
      have_blas=no
    ])
    LIBS="$save_LIBS"
  ])
  AS_IF([test "x$have_blas" = "xno" && test "x$with_blas" != "xcheck"], [
    AC_MSG_ERROR([BLAS library requested but not found])
  ])
])

# Check for LAPACK
AS_IF([test "x$with_lapack" != "xno"], [
  AS_IF([test "x$with_lapack" != "xyes" && test "x$with_lapack" != "xcheck"], [
    LAPACK_LIBS="$with_lapack"
    have_lapack=yes
  ], [
    save_LIBS="$LIBS"
    LIBS="$BLAS_LIBS $LIBS"
    AC_SEARCH_LIBS([dgesvd], [flame mkl_rt openblas flexiblas lapack], [
      have_lapack=yes
      AS_IF([test "x$ac_cv_search_dgesvd" != "xnone required"], [
        LAPACK_LIBS="$ac_cv_search_dgesvd"
      ])
    ], [
      have_lapack=no
    ])
    LIBS="$save_LIBS"
  ])
  AS_IF([test "x$have_lapack" = "xno" && test "x$with_lapack" != "xcheck"], [
    AC_MSG_ERROR([LAPACK library requested but not found])
  ])
])

AC_LANG_POP([Fortran])

AC_SUBST([BLAS_LIBS])
AC_SUBST([LAPACK_LIBS])

AS_IF([test "x$have_blas" = "xyes"], [
  AC_DEFINE([HAVE_BLAS], [1], [Define if BLAS library is available])
  FCFLAGS="$FCFLAGS -DHAVE_BLAS"
])

AS_IF([test "x$have_lapack" = "xyes"], [
  AC_DEFINE([HAVE_LAPACK], [1], [Define if LAPACK library is available])
  FCFLAGS="$FCFLAGS -DHAVE_LAPACK"
])

# Check for zlib library
AC_CHECK_LIB([z], [compress], [], [AC_MSG_ERROR([zlib library is required])])

# Check for Gauche Scheme interpreter (R7RS) for Scheme test harness
AC_CHECK_PROGS([GOSH], [gosh], [none])
AM_CONDITIONAL([HAVE_GOSH], [test "x$GOSH" != "xnone"])

# Output configuration files
CHEM_CONFIG_MAKEFILES
AC_OUTPUT
