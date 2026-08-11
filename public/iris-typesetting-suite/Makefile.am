#---------------------------------------------------------------------

.DELETE_ON_ERROR:

ACLOCAL_AMFLAGS = -I m4 --install

#---------------------------------------------------------------------

EXTRA_DIST =
bin_PROGRAMS =

ADB_FILES =
ADS_FILES =
DEP_FILES =
DEP_FILES += $(ADB_FILES:%.adb=.deps/%.adbdep)
DEP_FILES += $(ADS_FILES:%.ads=.deps/%.adsdep)

@GNU@include $(top_srcdir)/silent-rules.mk
@GNU@-include $(DEP_FILES)

EXTRA_DIST += silent-rules.mk

#---------------------------------------------------------------------

ADAFLAGS += -gnat2022
#ADAFLAGS += -gnatwa
ADAFLAGS += -I$(builddir)
ADAFLAGS += -I$(srcdir)

%.$(OBJEXT) %.ali: %.adb
	$(call v,ADA)set -e; \
		$(ADA) -c $(ADAFLAGS) $(<) -o $(@); \
		$(MKDIR_P) .deps; \
		printf "$(*).$(OBJEXT) $(*).ali: \$$(wildcard " \
			> .deps/$(*).adbdep; \
		$(GREP) '^D ' $(*).ali | $(AWK) '{print $$2}' | tr '\n' ' ' \
			>> .deps/$(*).adbdep; \
		printf ")\n" >> .deps/$(*).adbdep

%.$(OBJEXT) %.ali: %.ads
	$(call v,ADA)set -e; \s
		$(ADA) -c $(ADAFLAGS) $(<) -o $(@); \
		$(MKDIR_P) .deps; \
		printf "$(*).$(OBJEXT) $(*).ali: \$$(wildcard " \
			> .deps/$(*).adsdep; \
		$(GREP) '^D ' $(*).ali | $(AWK) '{print $$2}' | tr '\n' ' ' \
			>> .deps/$(*).adsdep; \
		printf ")\n" >> .deps/$(*).adsdep

clean-local::
	-rm -f *.o *.ali b~* b__*

#---------------------------------------------------------------------

bin_PROGRAMS += iris
iris_SOURCES =
iris_SOURCES += $(IRIS_ADB_FILES)
iris_SOURCES += $(IRIS_ADS_FILES)

iris$(EXEEXT): $(IRIS_OBJ_FILES)
	$(GNATBIND) -x iris_main.ali
	$(GNATLINK) iris_main.ali -o $(@) $(CAPYPDF_LIBS)

ADB_FILES += $(IRIS_ADB_FILES)
ADS_FILES += $(IRIS_ADS_FILES)

IRIS_ADB_FILES =
IRIS_ADS_FILES =
IRIS_ADB_FILES += iris_main.adb
IRIS_ADB_FILES += capypdf.adb
IRIS_ADS_FILES += capypdf.ads

IRIS_OBJ_FILES =
IRIS_OBJ_FILES += $(IRIS_ADB_FILES:%.adb=%.$(OBJEXT))

#---------------------------------------------------------------------
# local variables:
# coding: utf-8
# tab-width: 4
# end:
