#!/bin/sh
# Run this script to generate or regenerate the `configure' script and
# related Automake files, in cases where `autoreconf', etc., alone
# might not suffice,

# Sorts Mill Autogen (modified for iris-typesetting-suite)
#
# Copyright (C) 2013, 2015, 2021, 2026 Khaled Hosny and Barry Schwartz
# 
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

progname=`basename "${0}"`

test -n "${srcdir}" || srcdir=`dirname "$0"`
test -n "${srcdir}" || srcdir='.'

newline='
'

not_word='[^_0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz]'

echo_n() {
    # Like `echo -n' but hopefully less system-dependent.
    # (Unfortunately, it will remove _all_ newlines.)
    echo ${1+"$@"} | tr -d "${newline}"
}

grep_word_quietly() {
    pattern="${1}"
    shift
    if LC_ALL=C grep "^${pattern}\$" ${1+"$@"} \
        2> /dev/null > /dev/null; then
        true
    elif LC_ALL=C grep "${not_word}${pattern}\$" ${1+"$@"} \
        2> /dev/null > /dev/null; then
        true
    elif LC_ALL=C grep "^${pattern}${not_word}" ${1+"$@"} \
        2> /dev/null > /dev/null; then
        true
    else
        false
    fi
}

have_autoconf_m4() {
    test -d m4 -a -f "m4/${1}" || test -f "${1}"
}

find_autoconf_m4() {
    if test -d m4 -a -f "m4/${1}"; then
        echo "m4/${1}"
    elif test -f "${1}"; then
        echo "${1}"
    else
        echo "${progname}: possible internal error: find_autoconf_m4 may have been called incorrectly."
        echo "It also is possible the source files were modified while ${progname} was running."
        exit 86
    fi
}

need_sortsmill_tig() {
    # If sortsmill-tig.m4 is included in the package, then we do not
    # need TIG to do the autoreconf.
    test -f configure.ac && \
        grep_word_quietly 'StM_PROG_SORTSMILL_TIG' configure.ac  && \
        ! have_autoconf_m4 sortsmill-tig.m4
}

need_pkg_config() {
    # If pkg.m4 is included in the package, then we do not need
    # pkg-config to do the autoreconf.
    test -f configure.ac && \
        grep_word_quietly \
        'PKG_\(CHECK_MODULES\|PROG_PKG_CONFIG\|CHECK_EXISTS\|INSTALLDIR\|NOARCH_INSTALLDIR\|CHECK_VAR\)' \
        configure.ac && \
        ! have_autoconf_m4 pkg.m4
}

need_gnulib_tool() {
    test -f m4/gnulib-cache.m4 -a ! -f lib/Makefile.am
}

need_gperf_for_gnulib() {
    if have_autoconf_m4 gnulib-comp.m4; then
        grep 'gperf' `find_autoconf_m4 gnulib-comp.m4` \
            2> /dev/null > /dev/null
    else
        false
    fi
}

need_intltoolize() {
    test -f configure.ac && \
        grep_word_quietly 'IT_PROG_INTLTOOL' configure.ac
}

need_aclocal() {
    test -f configure.ac
}

need_autoreconf() {
    test -f configure.ac
}

require_command() {
    echo_n "Checking for ${1}... "
    if which "${1}" 2> /dev/null > /dev/null; then
        which "${1}"
    else
        echo "not found"
        echo ""
        echo "***  ${1} was not found in \$PATH. Please install ${1}."
        if test -n "${2}"; then
            echo "***  See <${2}>"
        fi
        if test -n "${3}"; then
            echo "***  ${3}"
        fi
        exit 1
    fi
}

require_sortsmill_tig() {
    require_command sortsmill-tig \
        'https://bitbucket.org/sortsmill/sortsmill-tig'
}

require_pkg_config() {
    require_command pkg-config \
        'http://www.freedesktop.org/wiki/Software/pkg-config/' \
        "Your operating system may have a \`pkg-config' or \`pkgconfig' package."
}

require_gcc() {
    require_command gcc \
        'http://gcc.gnu.org'
}

require_gnulib_tool() {
    require_command gnulib-tool \
        'http://www.gnu.org/software/gnulib/' \
        "Your operating system may have a \`gnulib' package."
}

require_gperf() {
    require_command gperf \
        'http://www.gnu.org/software/gperf/' \
        "Your operating system may have a \`gperf' package."
}

require_intltoolize() {
    require_command intltoolize \
        'http://freedesktop.org/wiki/Software/intltool/' \
        "Your operating system may have an \`intltool' package."
}

require_aclocal() {
    require_command aclocal \
        'http://www.gnu.org/software/autoconf/' \
        "Your operating system may have packages for GNU autoconf,
***  automake, libtool, and gettext, some or all of which might
***  be needed."
}

require_autoreconf() {
    require_command autoreconf \
        'http://www.gnu.org/software/autoconf/' \
        "Your operating system may have packages for GNU autoconf,
***  automake, libtool, and gettext, some or all of which might
***  be needed."
}

run_gnulib_tool() {
    echo "Running gnulib-tool --update"
    gnulib-tool --update || exit $?
}

run_intltoolize() {
    echo "Running intltoolize --copy --force --automake"
    intltoolize --copy --force --automake || exit $?
}

run_aclocal() {
    echo "Running aclocal --force --install"
    aclocal --force --install || exit $?
}

run_autoreconf() {
    echo "Running autoreconf --force --install --verbose"
    autoreconf --force --install --verbose || exit $?
}

write_ada_program() {
    cat >> programs.am <<EOF
$2\$(EXEEXT): $2.lo $2.ali libiris.la
	\$(call link-ada,\$(basename \$(@)),\
          \$(filter-out %.ali,\$(^)),\$(LIBS))

$1_PROGRAMS += $2
$2_SOURCES = $2.adb
$2_LDADD = .libs/$2.\$(OBJEXT)
$2_LDADD += libiris.la
$2_DEPENDENCIES = $2.lo $2.ali

DEP_FILES += .deps/$2.adbdep
CLEANFILES += $2\$(EXEEXT)

EOF
}

mk_temp_dir() {
    done=false
    while ! ${done}; do
        rand_suffix=$(od -An -N8 -tx /dev/urandom | tr -d ' ')
        tmp_dir="${TMPDIR:-/tmp}/tmp.${rand_suffix}"
        (umask 077 && mkdir "${tmp_dir}") && done=true
    done
    printf '%s' "${tmp_dir}"
}

write_ada_interfaces_am() {
    echo "Generating FFIs and writing ada-interfaces.am"
    set -e
    source_dir="${PWD}"
    ada_interfaces_am="${source_dir}/ada-interfaces.am"
    ada_interfaces="$(mk_temp_dir)"
    rm -f "${ada_interfaces_am}" 
    (
        cd "${ada_interfaces}"
        includes="\
          $(pkg-config --cflags fontconfig) \
          $(pkg-config --cflags capypdf) \
          $(pkg-config --cflags tkrzw) \
          "
        c_headers="\
          $(pkg-config --variable=includedir fontconfig)/fontconfig/fontconfig.h \
          $(pkg-config --variable=includedir capypdf)/capypdf-0/capypdf.h \
          $(pkg-config --variable=includedir tkrzw)/tkrzw_langc.h \
          "
        gcc ${includes} -fdump-ada-spec -c ${c_headers}
        for f in *.ads; do
          sed -e 's/^\([[:space:]]*\)function capy_dc_cmd_B\([^[:alpha:]]\)/\1function capy_dc_cmd_xB\2/' \
              -e 's/^\([[:space:]]*\)function capy_dc_cmd_Bstar\([^[:alpha:]]\)/\1function capy_dc_cmd_xBstar\2/' \
              -e 's/^\([[:space:]]*\)function capy_dc_cmd_Bstar\([^[:alpha:]]\)/\1function capy_dc_cmd_xBstar\2/' \
              -e 's/^\([[:space:]]*\)function capy_dc_cmd_G\([^[:alpha:]]\)/\1function capy_dc_cmd_xG\2/' \
              -e 's/^\([[:space:]]*\)function capy_dc_cmd_K\([^[:alpha:]]\)/\1function capy_dc_cmd_xK\2/' \
              -e 's/^\([[:space:]]*\)function capy_dc_cmd_Q\([^[:alpha:]]\)/\1function capy_dc_cmd_xQ\2/' \
              -e 's/^\([[:space:]]*\)function capy_dc_cmd_RG\([^[:alpha:]]\)/\1function capy_dc_cmd_xRG\2/' \
              -e 's/^\([[:space:]]*\)function capy_dc_cmd_S\([^[:alpha:]]\)/\1function capy_dc_cmd_xS\2/' \
              -e 's/^\([[:space:]]*\)function capy_text_cmd_TD\([^[:alpha:]]\)/\1function capy_text_cmd_xTD\2/' \
              -e 's/^\([[:space:]]*\)function capy_graphics_state_set_CA\([^[:alpha:]]\)/\1function capy_graphics_state_set_xCA\2/' \
              -e 's/^\([[:space:]]*\)function capy_graphics_state_set_OP\([^[:alpha:]]\)/\1function capy_graphics_state_set_xOP\2/' \
              -e 's/^\([[:space:]]*\)function capy_dc_cmd_B$/\1function capy_dc_cmd_xB/' \
              -e 's/^\([[:space:]]*\)function capy_dc_cmd_Bstar$/\1function capy_dc_cmd_xBstar/' \
              -e 's/^\([[:space:]]*\)function capy_dc_cmd_Bstar$/\1function capy_dc_cmd_xBstar/' \
              -e 's/^\([[:space:]]*\)function capy_dc_cmd_G$/\1function capy_dc_cmd_xG/' \
              -e 's/^\([[:space:]]*\)function capy_dc_cmd_K$/\1function capy_dc_cmd_xK/' \
              -e 's/^\([[:space:]]*\)function capy_dc_cmd_Q$/\1function capy_dc_cmd_xQ/' \
              -e 's/^\([[:space:]]*\)function capy_dc_cmd_RG$/\1function capy_dc_cmd_xRG/' \
              -e 's/^\([[:space:]]*\)function capy_dc_cmd_S$/\1function capy_dc_cmd_xS/' \
              -e 's/^\([[:space:]]*\)function capy_text_cmd_TD$/\1function capy_text_cmd_xTD/' \
              -e 's/^\([[:space:]]*\)function capy_graphics_state_set_CA$/\1function capy_graphics_state_set_xCA/' \
              -e 's/^\([[:space:]]*\)function capy_graphics_state_set_OP$/\1function capy_graphics_state_set_xOP/' \
              "${f}" > "${source_dir}"/"${f}"
          printf "LIBIRIS_ADS_FILES += %s\n" "${f}" >> "${ada_interfaces_am}"
          printf 'extremelyclean:: ; -rm -f $(srcdir)/%s\n' "${f}" >> "${ada_interfaces_am}"
          printf '\n' >> "${ada_interfaces_am}"
        done
    )
    rm -R -f "${ada_interfaces}"
}

write_programs_am() {
    echo "Writing programs.am"
    rm -f programs.am
    touch programs.am
    while IFS= read -r args; do
        if printf "%s" "${args}" |
                grep -q -E '^[[:space:]]*(bin|check)[[:space:]]'; then
          echo "  write_ada_program ${args}"
          write_ada_program ${args}
        fi
    done < ada-programs.list
}

expand_m4() {
    set -e
    printf 'm4 %s.prelude.m4 %s.m4 > %s' "$1" "$1" "$1"
    m4 "$1".prelude.m4 "$1".m4 > "$1"
    if command -v gnatformat > /dev/null; then
        printf ' \\\n        %s %s\n' \
               '&& gnatformat -w 72 --charset utf-8' "$1"
        gnatformat -w 72 --charset utf-8 "$1"
    else
        printf '\n'
    fi
}

# Run everything in a subshell, so the user does not get stuck in a
# new directory if the process is interrupted.
(
    cd "${srcdir}"

    require_pkg_config
    require_gcc

    write_ada_interfaces_am
    write_programs_am

    expand_m4 pdf.adb

    need_sortsmill_tig && require_sortsmill_tig
    need_pkg_config && require_pkg_config
    need_gnulib_tool && require_gnulib_tool
    need_intltoolize && require_intltoolize
    need_aclocal && require_aclocal
    need_autoreconf && require_autoreconf

    if need_gnulib_tool; then
        run_gnulib_tool
        need_gperf_for_gnulib && require_gperf
    fi
    need_intltoolize && run_intltoolize
    need_aclocal && run_aclocal
    need_autoreconf && run_autoreconf
)
