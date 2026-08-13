#---------------------------------------------------------------------
# SPDX-License-Identifier: MIT
#---------------------------------------------------------------------

AC_PREREQ([2.72])
AC_INIT([iris-typesetting-suite],[0.0.0])

AC_CONFIG_SRCDIR([iris.adb])

AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_AUX_DIR([build-aux])
AC_CANONICAL_BUILD       dnl On what platform are we compiling?
AC_CANONICAL_HOST        dnl For what platform are we compiling?
AC_USE_SYSTEM_EXTENSIONS dnl Define such macros as _GNU_SOURCE.

AM_INIT_AUTOMAKE([foreign tar-pax no-dist-gzip dist-xz])
AM_SILENT_RULES([no])
AM_MAINTAINER_MODE

LT_PREREQ([2.5.4])
LT_INIT([pic-only,dlopen])

m4_include([enforce-out-of-source.ac])

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
AC_CHECK_PROGS([GAUCHE_CONFIG],[gauche-config])
test -n "${GAUCHE_CONFIG}" || AC_MSG_ERROR([gauche-config is missing])

m4_include([find-kpsewhich.ac])

: "${ADA:=${CC}}"
AC_ARG_VAR([ADA],[Ada compiler command [default is: same command as CC]])

: "${ADAFLAGS:=-g -O3 -march=native -mtune=native}"
AC_ARG_VAR([ADAFLAGS],
  [Ada compiler flags [-g -O3 -march=native -mtune=native]])

CHEM_C23_FLAGS([c23_flags])
CFLAGS="${CFLAGS}${CFLAGS+ }${c23_flags}"

PKG_CHECK_MODULES([CAPYPDF],[capypdf])
CFLAGS="${CFLAGS}${CFLAGS+ }${CAPYPDF_CFLAGS}"
LIBS="${LIBS}${LIBS+ }${CAPYPDF_LIBS}"

AC_MSG_CHECKING([C flags to link with Gauche Scheme])
: "${GAUCHE_CFLAGS=`${GAUCHE_CONFIG} -I | tr '\r\n' '  '`}"
AC_ARG_VAR([GAUCHE_CFLAGS],
  [C flags to link with Gauche Scheme])
AC_MSG_RESULT([${GAUCHE_CFLAGS}])
CFLAGS="${CFLAGS}${CFLAGS+ }${GAUCHE_CFLAGS}"

AC_MSG_CHECKING([linker flags to link with Gauche Scheme])
: "${GAUCHE_LIBS=`(${GAUCHE_CONFIG} -L && ${GAUCHE_CONFIG} -l) | tr '\r\n' '  '`}"
AC_ARG_VAR([GAUCHE_LIBS],
  [linker flags to link with Gauche Scheme])
AC_MSG_RESULT([${GAUCHE_LIBS}])
LIBS="${LIBS}${LIBS+ }${GAUCHE_LIBS}"

AC_ARG_VAR([GAUCHE_SITELIBDIR],
  [where to install Gauche Scheme libraries])
AC_MSG_CHECKING([where to install Gauche Scheme libraries])
: "${GAUCHE_SITELIBDIR=`${GAUCHE_CONFIG} --sitelibdir`}"
AC_MSG_RESULT([${GAUCHE_SITELIBDIR}])
AC_SUBST([gauche_sitelibdir],[${GAUCHE_SITELIBDIR}])

# You can use ‘@GNU@’ to make GNU Make constructs unbothersome to
# Automake. (Often you can use ‘$(eval ...)’ instead, but @GNU@ is
# more straightforward.)
AC_SUBST([GNU],[])

CHEM_REQUIRE_GNU_MAKE_IN_PATH
CHEM_CONFIG_MAKEFILES
AC_CONFIG_FILES([atconfig])

AC_CONFIG_COMMANDS([r7rs],[
  AS_MKDIR_P(["${r7rs_dst}/iris/kpsewhich"])
  (cd "${r7rs_src}" && tar cf - .) | (cd "${r7rs_dst}" && tar xf -)
  chmod -R +w "${r7rs_dst}"
  cat > "${r7rs_dst}/iris/kpsewhich/kpsewhich-process.sld" <<EOF
(define-library (iris kpsewhich kpsewhich-process)
  (export kpsewhich-process)
  (import (scheme base)
          (srfi 13)
          (srfi 14))
  (begin
    (define (kpsewhich-process . args)
      \`(,@(map string->symbol
               (string-tokenize "${kpsewhich_command}"))
        ,@(map string->symbol args)))
    ))
EOF
],[
  r7rs_src="${srcdir}/r7rs"
  r7rs_dst="r7rs"
  kpsewhich_command="${KPSEWHICH}"
])

AC_OUTPUT

# local variables:
# mode: autoconf
# coding: utf-8
# end:
