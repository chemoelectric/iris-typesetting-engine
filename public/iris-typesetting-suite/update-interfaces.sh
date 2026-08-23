#!/bin/sh

GCC=${GCC:=gcc}
PKGCONF=${PKGCONF:=pkg-config}

FCDIR="${FCDIR:=`${PKGCONF} --variable=includedir fontconfig`}"
CAPYDIR="${FCDIR:=`${PKGCONF} --variable=includedir capypdf`}/capypdf-0"

${GCC} -I"${FCDIR}" -I"${CAPYDIR}" -fdump-ada-spec -c \
       "${FCDIR}/fontconfig/fontconfig.h" \
       "${CAPYDIR}/capypdf.h"
