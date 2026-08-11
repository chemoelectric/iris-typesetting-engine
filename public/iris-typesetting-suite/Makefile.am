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
TESTS_ADB =
TESTS_ADS =
DEP_FILES =
DEP_FILES += $(ADB_FILES:%.adb=.deps/%.adbdep)
DEP_FILES += $(ADS_FILES:%.ads=.deps/%.adsdep)
DEP_FILES += $(TESTS_ADB:%.adb=.deps/%.adbdep)
DEP_FILES += $(TESTS_ADS:%.ads=.deps/%.adsdep)
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

@GNU@define get-adainclude
@GNU@$(shell $(ADA) --print-file-name=adainclude)
@GNU@endef

@GNU@define get-adalib
@GNU@$(shell $(ADA) --print-file-name=adalib)
@GNU@endef

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

@GNU@define link-ada
@GNU@$(GNATBIND) -x $(1).ali
@GNU@$(LTADACOMPILE) -c b~$(1).adb
@GNU@$(ADALINK) $(IRIS_OBJ_FILES) b~$(1).lo \
@GNU@	-L$(call get-adalib) \
@GNU@	-R$(call get-adalib) \
@GNU@	-lgnat $(2)
@GNU@endef

@GNU@define color-flag
@GNU@$(shell \
@GNU@  if test "${enable_color}" = no; then \
@GNU@    printf '%s' "--color=never"; \
@GNU@  else \
@GNU@    printf '%s' "--color=auto"; \
@GNU@  fi)
@GNU@endef

@GNU@define jobs-flag
@GNU@$(shell \
@GNU@  printf "%s\n" "$(MAKEFLAGS) $(MFLAGS)" | \
@GNU@    $(SED) -n 's/.*?\(-j[0-9]*\|--jobs=[0-9]*\).*/\1/p' | \
@GNU@    $(SED) 's/--jobs=/ -j/')
@GNU@endef

#---------------------------------------------------------------------

AM_ADAFLAGS += -gnat2022
AM_ADAFLAGS += -gnatwa
AM_ADAFLAGS += -I$(call get-adainclude)
AM_ADAFLAGS += -I$(builddir)
AM_ADAFLAGS += -I$(srcdir)

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
	$(call link-ada,iris,$(CAPYPDF_LIBS))

ADB_FILES += $(IRIS_ADB_FILES)
ADS_FILES += $(IRIS_ADS_FILES)

IRIS_ADB_COMMON =
IRIS_ADS_COMMON =
IRIS_ADB_COMMON += capypdf.adb
IRIS_ADS_COMMON += capypdf.ads

IRIS_ADB_FILES = $(IRIS_ADB_COMMON)
IRIS_ADS_FILES = $(IRIS_ADS_COMMON)
IRIS_ADB_FILES += iris.adb

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

AUTOM4TE = $(SHELL) $(srcdir)/build-aux/missing --run autom4te

EXTRA_DIST += $(TESTSUITE_DEPS)
TESTSUITE_DEPS =
TESTSUITE_DEPS += $(srcdir)/atconfig.in
TESTSUITE_DEPS += $(srcdir)/package.m4
TESTSUITE_DEPS += $(srcdir)/testsuite.at

DISTCLEANFILES += testsuite testsuite.log
testsuite: $(TESTSUITE_DEPS)
	$(AUTOM4TE) --language=autotest \
		-I '$(srcdir)' -o $(@) $(srcdir)/$(@).at

ALL_THE_CHECK_FLAGS = $(color-flag) $(jobs-flag) $(TESTSUITEFLAGS)

check-local:: atconfig testsuite
	$(SHELL) testsuite $(ALL_THE_CHECK_FLAGS)

installcheck-local:: atconfig testsuite
	@if false; then \
		$(SHELL) testsuite AUTOTEST_PATH='$(bindir)' \
			$(ALL_THE_CHECK_FLAGS); \
	fi							# installcheck is disabled.

check_PROGRAMS =

check_PROGRAMS += test_capypdf
test_capypdf_SOURCE = $(test_capypdf_ADB) $(test_capypdf_ADS)
test_capypdf_SOURCE += test_capypdf.adb
#
test_capypdf$(EXEEXT): test_capypdf.lo $(test_capypdf_ADB:%.adb=%.lo)
	$(call link-ada,test_capypdf,$(CAPYPDF_LIBS))
#
test_capypdf_ADB = $(IRIS_ADB_COMMON)
test_capypdf_ADS = $(IRIS_ADB_COMMON)
test_capypdf_ADB += capypdf_tests.adb
test_capypdf_ADS += capypdf_tests.ads
TESTS_ADB += capypdf_tests.adb test_capypdf.adb
TESTS_ADS += capypdf_tests.ads

#---------------------------------------------------------------------
# local variables:
# coding: utf-8
# tab-width: 4
# end:
