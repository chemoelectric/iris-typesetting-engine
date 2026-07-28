# ==============================================================================
# Automake File for Kpsewhich Standalone Binary
# Installs to pkglibexecdir ($(libexecdir)/$(PACKAGE))
# ==============================================================================

pkglibexecdir = $(libexecdir)/$(PACKAGE)
pkglibexec_PROGRAMS = kpsewhich

kpsewhich_SOURCES = kpsewhich_main.f90
kpsewhich_LDADD = $(top_builddir)/libiris.a -lz

AM_FCFLAGS = -I$(top_builddir) -I$(top_builddir)/fortran -I$(top_srcdir) -I$(top_srcdir)/fortran

kpsewhich_main.$(OBJEXT): $(top_builddir)/libiris.a
