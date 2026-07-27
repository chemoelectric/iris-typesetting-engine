# ==============================================================================
# Automake File for Iris Batch Typographic System
# Standard: Automake 1.15+ / Autoconf 2.69+ (Compatible with 1.18.1 / 2.72+)
# Guarantees full out-of-source (VPATH) build and 100% 'make distcheck' pass.
# Requires GNU Make for pattern rules & VPATH support.
# ==============================================================================

AUTOMAKE_OPTIONS = foreign subdir-objects

# Recursive build for subdirectories (kpsewhich built via recursive make)
SUBDIRS = kpsewhich

# ------------------------------------------------------------------------------
# Executable Binaries
# ------------------------------------------------------------------------------
bin_PROGRAMS = iris

iris_SOURCES = fortran/iris_main.f90
iris_LDADD = libiris.a

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
	fortran/iris_opentype.f90 \
	fortran/iris_font_json.f90 \
	fortran/iris_evaluate_pegs.f90 \
	fortran/iris_pdf.f90 \
	fortran/iris_markup_parser.f90 \
	fortran/iris_kpsewhich.f90 \
	fortran/iris_tex.f90 \
	fortran/iris_batch_engine.f90

# AM_FCFLAGS for include paths in build directory and source directory (VPATH support)
AM_FCFLAGS = -I. -I$(srcdir) -Ifortran -I$(srcdir)/fortran

# Explicit Fortran Module Dependencies for Parallel / VPATH Builds
fortran/iris_cli_args.$(OBJEXT): fortran/iris_json.$(OBJEXT)
fortran/iris_bezier_intersect.$(OBJEXT): fortran/iris_json.$(OBJEXT)
fortran/iris_spline.$(OBJEXT): fortran/iris_bezier_intersect.$(OBJEXT)
fortran/iris_spline_collection.$(OBJEXT): fortran/iris_json.$(OBJEXT)
fortran/iris_font_json.$(OBJEXT): fortran/iris_opentype.$(OBJEXT) fortran/iris_json.$(OBJEXT)
fortran/iris_evaluate_pegs.$(OBJEXT): fortran/iris_opentype.$(OBJEXT) fortran/iris_spline_collection.$(OBJEXT)
fortran/iris_pdf.$(OBJEXT): fortran/iris_evaluate_pegs.$(OBJEXT)
fortran/iris_markup_parser.$(OBJEXT): fortran/iris_json.$(OBJEXT)
fortran/iris_kpsewhich.$(OBJEXT): fortran/iris_json.$(OBJEXT)
fortran/iris_tex.$(OBJEXT): fortran/iris_kpsewhich.$(OBJEXT) fortran/iris_json.$(OBJEXT)
fortran/iris_batch_engine.$(OBJEXT): fortran/iris_markup_parser.$(OBJEXT) fortran/iris_pdf.$(OBJEXT)
fortran/iris_main.$(OBJEXT): fortran/iris_batch_engine.$(OBJEXT) fortran/iris_cli_args.$(OBJEXT) fortran/iris_kpsewhich.$(OBJEXT) fortran/iris_tex.$(OBJEXT)

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
	scheme/iris/kpsewhich.sld \
	scheme/iris/tex.sld \
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
	fortran/iris_kpsewhich.md \
	fortran/iris_tex.md \
	fortran/iris_batch_engine.md \
	fortran/iris_main.md \
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
	scheme/iris/kpsewhich.md \
	scheme/iris/tex.md \
	scheme/iris/batch-engine.md

# ------------------------------------------------------------------------------
# Test Harness Integration
# ------------------------------------------------------------------------------
check_PROGRAMS = \
	test_iris_json \
	test_iris_cli_args \
	test_iris_bezier \
	test_iris_spline \
	test_iris_spline_collection \
	test_iris_opentype \
	test_iris_font_json \
	test_iris_evaluate_pegs \
	test_iris_pdf \
	test_iris_markup_parser \
	test_iris_kpsewhich \
	test_iris_tex \
	test_iris_batch

test_iris_json_SOURCES = tests/test_iris_json.f90
test_iris_json_LDADD = libiris.a
tests/test_iris_json.$(OBJEXT): fortran/iris_json.$(OBJEXT)

test_iris_cli_args_SOURCES = tests/test_iris_cli_args.f90
test_iris_cli_args_LDADD = libiris.a
tests/test_iris_cli_args.$(OBJEXT): fortran/iris_cli_args.$(OBJEXT)

test_iris_bezier_SOURCES = tests/test_iris_bezier.f90
test_iris_bezier_LDADD = libiris.a
tests/test_iris_bezier.$(OBJEXT): fortran/iris_bezier_intersect.$(OBJEXT)

test_iris_spline_SOURCES = tests/test_iris_spline.f90
test_iris_spline_LDADD = libiris.a
tests/test_iris_spline.$(OBJEXT): fortran/iris_spline.$(OBJEXT)

test_iris_spline_collection_SOURCES = tests/test_iris_spline_collection.f90
test_iris_spline_collection_LDADD = libiris.a
tests/test_iris_spline_collection.$(OBJEXT): fortran/iris_spline_collection.$(OBJEXT)

test_iris_opentype_SOURCES = tests/test_iris_opentype.f90
test_iris_opentype_LDADD = libiris.a
tests/test_iris_opentype.$(OBJEXT): fortran/iris_opentype.$(OBJEXT)

test_iris_font_json_SOURCES = tests/test_iris_font_json.f90
test_iris_font_json_LDADD = libiris.a
tests/test_iris_font_json.$(OBJEXT): fortran/iris_font_json.$(OBJEXT)

test_iris_evaluate_pegs_SOURCES = tests/test_iris_evaluate_pegs.f90
test_iris_evaluate_pegs_LDADD = libiris.a
tests/test_iris_evaluate_pegs.$(OBJEXT): fortran/iris_evaluate_pegs.$(OBJEXT)

test_iris_pdf_SOURCES = tests/test_iris_pdf.f90
test_iris_pdf_LDADD = libiris.a
tests/test_iris_pdf.$(OBJEXT): fortran/iris_pdf.$(OBJEXT)

test_iris_markup_parser_SOURCES = tests/test_iris_markup_parser.f90
test_iris_markup_parser_LDADD = libiris.a
tests/test_iris_markup_parser.$(OBJEXT): fortran/iris_markup_parser.$(OBJEXT)

test_iris_kpsewhich_SOURCES = tests/test_iris_kpsewhich.f90
test_iris_kpsewhich_LDADD = libiris.a
tests/test_iris_kpsewhich.$(OBJEXT): fortran/iris_kpsewhich.$(OBJEXT)

test_iris_tex_SOURCES = tests/test_iris_tex.f90
test_iris_tex_LDADD = libiris.a
tests/test_iris_tex.$(OBJEXT): fortran/iris_tex.$(OBJEXT)

test_iris_batch_SOURCES = tests/test_iris_batch.f90
test_iris_batch_LDADD = libiris.a
tests/test_iris_batch.$(OBJEXT): fortran/iris_batch_engine.$(OBJEXT)

TESTS = $(check_PROGRAMS)

# ------------------------------------------------------------------------------
# Cleanup Rules for Fortran Module Binaries & Output PDF Files
# ------------------------------------------------------------------------------
CLEANFILES = *.mod fortran/*.mod tests/*.mod *.pdf test_output.pdf test_pdf_out.pdf

EXTRA_DIST = autogen.sh
