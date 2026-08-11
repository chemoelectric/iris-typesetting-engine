#---------------------------------------------------------------------
# SPDX-License-Identifier: MIT
#---------------------------------------------------------------------

.DELETE_ON_ERROR:

ACLOCAL_AMFLAGS = -I m4 --install

#---------------------------------------------------------------------

MOSTLYCLEANFILES =
CLEANFILES =
DISTCLEANFILES =
EXTRA_DIST =
bin_PROGRAMS =
AM_ADAFLAGS =

ADB_FILES =
ADS_FILES =
DEP_FILES =
DEP_FILES += $(ADB_FILES:%.adb=.deps/%.adbdep)
DEP_FILES += $(ADS_FILES:%.ads=.deps/%.adsdep)
DISTCLEANFILES += $(DEP_FILES)

@GNU@include $(top_srcdir)/silent-rules.mk
@GNU@-include $(DEP_FILES)

EXTRA_DIST += silent-rules.mk

DISTCLEANFILES += Makefile GNUmakefile

ADALD = $(ADA)
LTADACOMPILE = $(LIBTOOL) $(AM_V_lt) $(AM_LIBTOOLFLAGS) \
	$(LIBTOOLFLAGS) --mode=compile $(ADA) $(AM_ADAFLAGS) $(ADAFLAGS)
ADALINK = $(LIBTOOL) $(AM_V_lt) $(AM_LIBTOOLFLAGS) \
        $(LIBTOOLFLAGS) --mode=link $(ADALD) \
		$(AM_CFLAGS) $(CFLAGS) \
		$(AM_ADAFLAGS) $(ADAFLAGS) \
		$(AM_LDFLAGS) $(LDFLAGS) -o $(@)

@GNU@define get-adalib
@GNU@$(shell $(ADA) --print-file-name=adalib)
@GNU@endef

#---------------------------------------------------------------------

AM_ADAFLAGS += -gnat2022
#AM_ADAFLAGS += -gnatwa
AM_ADAFLAGS += -I$(builddir)
AM_ADAFLAGS += -I$(srcdir)

@GNU@define compile-ada
@GNU@$(LTADACOMPILE) -c $(1) -o $(2)
@GNU@endef

@GNU@define make-ada-dep
@GNU@$(MKDIR_P) .deps; \
@GNU@printf "$(1).lo $(1).ali: \$$(wildcard " \
@GNU@  > .deps/$(1)$(2); \
@GNU@$(GREP) '^D ' $(1).ali | $(AWK) '{print $$2}' | tr '\n' ' ' \
@GNU@  >> .deps/$(1)$(2); \
@GNU@printf ")\n" >> .deps/$(1)$(2)
@GNU@endef

%.lo %.ali: %.adb
	$(call v,ADA)set -e; $(call compile-ada,$(<),$(@)); \
		$(call make-ada-dep,$(*),.adbdep)

%.lo %.ali: %.ads
	$(call v,ADA)set -e; $(call compile-ada,$(<),$(@)); \
		$(call make-ada-dep,$(*),.adsdep)

clean-local::
	-rm -f *.ali b~* b__*

#---------------------------------------------------------------------

bin_PROGRAMS += iris
iris_SOURCES =
iris_SOURCES += $(IRIS_ADB_FILES)
iris_SOURCES += $(IRIS_ADS_FILES)

iris$(EXEEXT): $(IRIS_OBJ_FILES)
	$(GNATBIND) -x iris.ali
	$(LTADACOMPILE) -c b~iris.adb
	$(ADALINK) $(IRIS_OBJ_FILES) b~iris.lo \
		-L$(call get-adalib) \
		-R$(call get-adalib) \
		-lgnat $(CAPYPDF_LIBS)

ADB_FILES += $(IRIS_ADB_FILES)
ADS_FILES += $(IRIS_ADS_FILES)

IRIS_ADB_FILES =
IRIS_ADS_FILES =
IRIS_ADB_FILES += iris.adb
IRIS_ADB_FILES += capypdf.adb
IRIS_ADS_FILES += capypdf.ads

IRIS_OBJ_FILES =
IRIS_OBJ_FILES += $(IRIS_ADB_FILES:%.adb=%.lo)

#---------------------------------------------------------------------

EXTRA_DIST += $(srcdir)/package.m4
$(srcdir)/package.m4: $(top_srcdir)/configure.ac $(srcdir)/Makefile.am
	$(AWK) \
	  'BEGIN{printf "# Signature of the current package.\n"; \
		 printf "m4_define([AT_PACKAGE_NAME],"; \
		 printf "[$(PACKAGE_NAME)])\n"; \
		 printf "m4_define([AT_PACKAGE_TARNAME],"; \
		 printf "[$(PACKAGE_TARNAME)])\n"; \
		 printf "m4_define([AT_PACKAGE_VERSION],"; \
		 printf "[$(PACKAGE_VERSION)])\n"; \
		 printf "m4_define([AT_PACKAGE_STRING],"; \
		 printf "[$(PACKAGE_STRING)])\n"; \
		 printf "m4_define([AT_PACKAGE_BUGREPORT],"; \
		 printf "[$(PACKAGE_BUGREPORT)])\n"; \
		 printf "m4_define([AT_PACKAGE_URL],"; \
		 printf "[$(PACKAGE_URL)])\n"}' > $(@)

#---------------------------------------------------------------------
# local variables:
# coding: utf-8
# tab-width: 4
# end:
