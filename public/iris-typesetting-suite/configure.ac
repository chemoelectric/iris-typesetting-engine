AC_PREREQ([2.72])
AC_INIT([iris-typesetting-suite],[0.0.0])

AC_CONFIG_SRCDIR([iris_main.adb])

AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_AUX_DIR([build-aux])
AC_CANONICAL_BUILD                 dnl On what platform are we compiling?
AC_CANONICAL_HOST                  dnl For what platform are we compiling?
AC_USE_SYSTEM_EXTENSIONS           dnl Define such macros as _GNU_SOURCE.

AM_INIT_AUTOMAKE([foreign subdir-objects tar-pax no-dist-gzip dist-xz])
AM_SILENT_RULES([yes])
AM_MAINTAINER_MODE

LT_PREREQ([2.5.4])
LT_INIT([pic-only,dlopen])

AC_ARG_ENABLE([color],
  [AS_HELP_STRING([--disable-color],
    [disable color in test outputs])],
  [enable_color="${enableval}"],
  [enable_color=yes])
AC_SUBST([enable_color])

AC_PROG_CC
AC_PROG_CC_C_O
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PROG_MKDIR_P
AC_PROG_AWK
AC_PROG_SED
AC_PROG_GREP
AC_PROG_FGREP
AC_PROG_EGREP
AC_CHECK_PROGS([GNATBIND],[gnatbind])
test -n "${GNATBIND}" || AC_MSG_ERROR([gnatbind is missing])
AC_CHECK_PROGS([GNATLINK],[gnatlink])
test -n "${GNATLINK}" || AC_MSG_ERROR([gnatlink is missing])ss

: "${ADA:=${CC}}"
AC_ARG_VAR([ADA],[Ada compiler [CC]])

: "${ADAFLAGS:=-g -O3 -march=native -mtune=native}"
AC_ARG_VAR([ADAFLAGS],
  [Ada compiler flags [-g -O3 -march=native -mtune=native]])

CHEM_C23_FLAGS([c23_flags])
CFLAGS="${CFLAGS}${CFLAGS+ }${c23_flags}"

PKG_CHECK_MODULES([CAPYPDF],[capypdf])
CFLAGS="${CFLAGS}${CFLAGS+ }${CAPYPDF_CFLAGS}"

# You can use ‘@GNU@’ to make GNU Make constructs unbothersome to
# Automake. (Often you can use ‘$(eval ...)’ instead, but @GNU@ is
# more straightforward.)
AC_SUBST([GNU],[])

CHEM_REQUIRE_GNU_MAKE_IN_PATH
CHEM_CONFIG_MAKEFILES
#AC_CONFIG_FILES([tests/atlocal])

AC_OUTPUT

# local variables:
# coding: utf-8
# end:
