# ==============================================================================
# Automake File for Iris Batch Typographic System
# Standard: Automake 1.15+ / Autoconf 2.69+ (Compatible with 1.18.1 / 2.72+)
# Guarantees full out-of-source (VPATH) build and 100% 'make distcheck' pass.
# Requires GNU Make for pattern rules & VPATH support.
# ==============================================================================

AUTOMAKE_OPTIONS = foreign subdir-objects

# ------------------------------------------------------------------------------
# Fortran Convenience Library
# ------------------------------------------------------------------------------
noinst_LIBRARIES = libiris.a

libiris_a_SOURCES = \
	fortran/iris_json.f90 \
	fortran/iris_cli_args.f90 \
	fortran/iris_bezier_intersect.f90 \
	fortran/iris_spline.f90 \
	fortran/iris_spline_collection.f90 \
	fortran/iris_font_json.f90 \
	fortran/iris_opentype.f90 \
	fortran/iris_evaluate_pegs.f90 \
	fortran/iris_pdf.f90 \
	fortran/iris_markup_parser.f90 \
	fortran/iris_batch_engine.f90

# AM_FCFLAGS for include paths in build directory
AM_FCFLAGS = -I. -I$(srcdir)

# Explicit Fortran Module Dependencies for Parallel / VPATH Builds
fortran/iris_cli_args.$(OBJEXT): fortran/iris_json.$(OBJEXT)
fortran/iris_bezier_intersect.$(OBJEXT): fortran/iris_json.$(OBJEXT)
fortran/iris_spline.$(OBJEXT): fortran/iris_bezier_intersect.$(OBJEXT)
fortran/iris_spline_collection.$(OBJEXT): fortran/iris_spline.$(OBJEXT)
fortran/iris_font_json.$(OBJEXT): fortran/iris_json.$(OBJEXT)
fortran/iris_opentype.$(OBJEXT): fortran/iris_font_json.$(OBJEXT)
fortran/iris_evaluate_pegs.$(OBJEXT): fortran/iris_opentype.$(OBJEXT) fortran/iris_spline_collection.$(OBJEXT)
fortran/iris_pdf.$(OBJEXT): fortran/iris_evaluate_pegs.$(OBJEXT)
fortran/iris_markup_parser.$(OBJEXT): fortran/iris_json.$(OBJEXT)
fortran/iris_batch_engine.$(OBJEXT): fortran/iris_markup_parser.$(OBJEXT) fortran/iris_pdf.$(OBJEXT)

# ------------------------------------------------------------------------------
# R7RS Scheme Library Distribution
# ------------------------------------------------------------------------------
schemedir = $(pkgdatadir)/scheme/iris
nobase_dist_scheme_DATA = \
	scheme/iris/json.sld \
	scheme/iris/cli-args.sld \
	scheme/iris/bezier-intersect.sld \
	scheme/iris/spline.sld \
	scheme/iris/spline-collection.sld \
	scheme/iris/font-json.sld \
	scheme/iris/opentype.sld \
	scheme/iris/evaluate-pegs.sld \
	scheme/iris/pdf.sld \
	scheme/iris/markup-parser.sld \
	scheme/iris/batch-engine.sld

# ------------------------------------------------------------------------------
# Documentation Distribution
# ------------------------------------------------------------------------------
nobase_dist_doc_DATA = \
	fortran/iris_json.md \
	fortran/iris_cli_args.md \
	fortran/iris_bezier_intersect.md \
	fortran/iris_spline.md \
	fortran/iris_spline_collection.md \
	fortran/iris_font_json.md \
	fortran/iris_opentype.md \
	fortran/iris_evaluate_pegs.md \
	fortran/iris_pdf.md \
	fortran/iris_markup_parser.md \
	fortran/iris_batch_engine.md \
	scheme/iris/json.md \
	scheme/iris/cli-args.md \
	scheme/iris/bezier-intersect.md \
	scheme/iris/spline.md \
	scheme/iris/spline-collection.md \
	scheme/iris/font-json.md \
	scheme/iris/opentype.md \
	scheme/iris/evaluate-pegs.md \
	scheme/iris/pdf.md \
	scheme/iris/markup-parser.md \
	scheme/iris/batch-engine.md

# ------------------------------------------------------------------------------
# Test Harness Integration
# ------------------------------------------------------------------------------
check_PROGRAMS = test_iris_batch

test_iris_batch_SOURCES = tests/test_iris_batch.f90
test_iris_batch_LDADD = libiris.a
tests/test_iris_batch.$(OBJEXT): fortran/iris_batch_engine.$(OBJEXT)

TESTS = $(check_PROGRAMS)

# ------------------------------------------------------------------------------
# Cleanup Rules for Fortran Module Binaries & Output PDF Files
# ------------------------------------------------------------------------------
CLEANFILES = *.mod fortran/*.mod tests/*.mod *.pdf test_output.pdf

EXTRA_DIST = autogen.sh
