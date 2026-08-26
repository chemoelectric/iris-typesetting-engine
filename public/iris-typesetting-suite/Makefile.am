#---------------------------------------------------------------------
# SPDX-License-Identifier: MIT
#---------------------------------------------------------------------

.DELETE_ON_ERROR:

ACLOCAL_AMFLAGS = -I m4 --install

.PHONY: extremelyclean
extremelyclean:: distclean

#---------------------------------------------------------------------

include inits.am
include common-source-files.am
include ada-interfaces.am
include definitions.am
include mk-includes.am
include rules.am
include libiris.am
include programs.am
include r7rs.am
include tests.am
include extra-dist.am

#---------------------------------------------------------------------

.PHONY: indent
indent:
	gnatformat -w 72 --charset utf-8 \
	$(addprefix $(srcdir)/, \
	pdf.ad[bs] \
	font_finders.ad[bs] \
	r7rs_sexpr.ad[bs] \
	test_pdf_[0-9][0-9].adb \
	test_find*fonts.adb)

#---------------------------------------------------------------------
# local variables:
# coding: utf-8
# tab-width: 4
# end:
