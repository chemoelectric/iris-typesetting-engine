# ==============================================================================
# Automake File for Iris Batch Typographic System
# Standard: Automake 1.18.1+ / Autoconf 2.72+
# Guarantees full out-of-source (VPATH) build and 100% 'make distcheck' pass.
# Requires GNU Make for pattern rules & VPATH support.
# ==============================================================================

.DELETE_ON_ERROR:

AUTOMAKE_OPTIONS = foreign subdir-objects

# ------------------------------------------------------------------------------
# Executable Binaries
# ------------------------------------------------------------------------------
bin_PROGRAMS = iris iris-tex iris-kpsewhich iris-trip iris-compile

iris_SOURCES = fortran/iris_main.f90
iris_LDADD = libiris.a $(LAPACK_LIBS) $(BLAS_LIBS) $(CAPYPDF_LIBS) -lz

iris_tex_SOURCES = fortran/iris_cmd_tex.f90
iris_tex_LDADD = libiris.a $(LAPACK_LIBS) $(BLAS_LIBS) $(CAPYPDF_LIBS) -lz

iris_kpsewhich_SOURCES = fortran/iris_cmd_kpsewhich.f90
iris_kpsewhich_LDADD = libiris.a $(LAPACK_LIBS) $(BLAS_LIBS) $(CAPYPDF_LIBS) -lz

iris_trip_SOURCES = fortran/iris_cmd_trip.f90
iris_trip_LDADD = libiris.a $(LAPACK_LIBS) $(BLAS_LIBS) $(CAPYPDF_LIBS) -lz

iris_compile_SOURCES = fortran/iris_cmd_compile.f90
iris_compile_LDADD = libiris.a $(LAPACK_LIBS) $(BLAS_LIBS) $(CAPYPDF_LIBS) -lz

# ------------------------------------------------------------------------------
# Fortran Convenience Library
# ------------------------------------------------------------------------------
noinst_LIBRARIES = libiris.a

libiris_a_SOURCES = \
	c/iris_pdf_io.c \
	c/iris_pdf_io.h \
	fortran/iris_c_pdf_io.f90 \
	fortran/iris_dynamic_array.f90 \
	fortran/iris_dynamic_string.f90 \
	fortran/iris_json.f90 \
	fortran/iris_cli_args.f90 \
	fortran/iris_bezier_intersect.f90 \
	fortran/iris_spline.f90 \
	fortran/iris_svd_fallback.f90 \
	fortran/iris_svd_bridge.f90 \
	fortran/iris_hobby_svd.f90 \
	fortran/spiro_lapack_bridge_mod.f90 \
	fortran/spiro_svd_mod.f90 \
	fortran/iris_spline_collection.f90 \
	fortran/iris_opentype.f90 \
	fortran/iris_font_json.f90 \
	fortran/iris_evaluate_pegs.f90 \
	fortran/iris_pdf.f90 \
	fortran/iris_dvi.f90 \
	fortran/iris_markup_parser.f90 \
	fortran/iris_kpsewhich.f90 \
	fortran/iris_tex_lexer.f90 \
	fortran/iris_tex_parser.f90 \
	fortran/iris_tex_math.f90 \
	fortran/iris_tex_trip.f90 \
	fortran/iris_typography_levels.f90 \
	fortran/iris_tex.f90 \
	fortran/iris_batch_engine.f90

# AM_FCFLAGS and AM_CPPFLAGS for include paths in build directory and source directory (VPATH support)
AM_CPPFLAGS = -I. -I$(srcdir) -Ic -I$(srcdir)/c
AM_FCFLAGS = -I. -I$(srcdir) -Ifortran -I$(srcdir)/fortran

# Explicit Fortran Module Dependencies for Parallel / VPATH Builds
fortran/iris_c_pdf_io.$(OBJEXT): c/iris_pdf_io.$(OBJEXT)
fortran/iris_cli_args.$(OBJEXT): fortran/iris_json.$(OBJEXT)
fortran/iris_bezier_intersect.$(OBJEXT): fortran/iris_json.$(OBJEXT)
fortran/iris_spline.$(OBJEXT): fortran/iris_bezier_intersect.$(OBJEXT)
fortran/iris_svd_bridge.$(OBJEXT): fortran/iris_svd_fallback.$(OBJEXT)
fortran/iris_hobby_svd.$(OBJEXT): fortran/iris_svd_bridge.$(OBJEXT)
fortran/spiro_svd_mod.$(OBJEXT): fortran/spiro_lapack_bridge_mod.$(OBJEXT)
fortran/iris_spline_collection.$(OBJEXT): fortran/iris_json.$(OBJEXT) fortran/iris_bezier_intersect.$(OBJEXT) fortran/iris_spline.$(OBJEXT)
fortran/iris_opentype.$(OBJEXT): fortran/iris_json.$(OBJEXT)
fortran/iris_font_json.$(OBJEXT): fortran/iris_opentype.$(OBJEXT) fortran/iris_json.$(OBJEXT)
fortran/iris_evaluate_pegs.$(OBJEXT): fortran/iris_opentype.$(OBJEXT)
fortran/iris_pdf.$(OBJEXT): fortran/iris_c_pdf_io.$(OBJEXT) fortran/iris_dynamic_array.$(OBJEXT) fortran/iris_dynamic_string.$(OBJEXT)
fortran/iris_markup_parser.$(OBJEXT): fortran/iris_json.$(OBJEXT)
fortran/iris_kpsewhich.$(OBJEXT): fortran/iris_json.$(OBJEXT)
fortran/iris_tex_lexer.$(OBJEXT): fortran/iris_json.$(OBJEXT)
fortran/iris_tex_parser.$(OBJEXT): fortran/iris_tex_lexer.$(OBJEXT) fortran/iris_json.$(OBJEXT)
fortran/iris_tex_math.$(OBJEXT): fortran/iris_json.$(OBJEXT)
fortran/iris_tex_trip.$(OBJEXT): fortran/iris_json.$(OBJEXT)
fortran/iris_typography_levels.$(OBJEXT): fortran/iris_json.$(OBJEXT)
fortran/iris_tex.$(OBJEXT): fortran/iris_tex_lexer.$(OBJEXT) fortran/iris_tex_parser.$(OBJEXT) fortran/iris_tex_math.$(OBJEXT) fortran/iris_tex_trip.$(OBJEXT) fortran/iris_typography_levels.$(OBJEXT) fortran/iris_kpsewhich.$(OBJEXT) fortran/iris_json.$(OBJEXT)
fortran/iris_batch_engine.$(OBJEXT): fortran/iris_markup_parser.$(OBJEXT) fortran/iris_pdf.$(OBJEXT)
fortran/iris_cmd_tex.$(OBJEXT): fortran/iris_tex.$(OBJEXT) fortran/iris_cli_args.$(OBJEXT) fortran/iris_json.$(OBJEXT) fortran/iris_batch_engine.$(OBJEXT) fortran/iris_dynamic_string.$(OBJEXT)
fortran/iris_cmd_kpsewhich.$(OBJEXT): fortran/iris_kpsewhich.$(OBJEXT) fortran/iris_cli_args.$(OBJEXT)
fortran/iris_cmd_trip.$(OBJEXT): fortran/iris_tex.$(OBJEXT) fortran/iris_cli_args.$(OBJEXT)
fortran/iris_cmd_compile.$(OBJEXT): fortran/iris_batch_engine.$(OBJEXT) fortran/iris_cli_args.$(OBJEXT) fortran/iris_dynamic_string.$(OBJEXT)
fortran/iris_main.$(OBJEXT): fortran/iris_cli_args.$(OBJEXT)

# ------------------------------------------------------------------------------
# Documentation Distribution
# ------------------------------------------------------------------------------
nobase_dist_doc_DATA = \
	c/iris_pdf_io.md \
	fortran/iris_c_pdf_io.md \
	fortran/iris_dynamic_array.md \
	fortran/iris_dynamic_string.md \
	fortran/iris_json.md \
	fortran/iris_cli_args.md \
	fortran/iris_bezier_intersect.md \
	fortran/iris_spline.md \
	fortran/iris_svd_fallback.md \
	fortran/iris_svd_bridge.md \
	fortran/iris_hobby_svd.md \
	fortran/iris_spline_collection.md \
	fortran/iris_font_json.md \
	fortran/iris_opentype.md \
	fortran/iris_evaluate_pegs.md \
	fortran/iris_pdf.md \
	fortran/iris_dvi.md \
	fortran/iris_markup_parser.md \
	fortran/iris_kpsewhich.md \
	fortran/iris_tex_lexer.md \
	fortran/iris_tex_parser.md \
	fortran/iris_tex_math.md \
	fortran/iris_tex_trip.md \
	fortran/iris_typography_levels.md \
	fortran/iris_tex.md \
	fortran/iris_batch_engine.md \
	fortran/iris_cmd_tex.md \
	fortran/iris_cmd_kpsewhich.md \
	fortran/iris_cmd_trip.md \
	fortran/iris_cmd_compile.md \
	fortran/iris_main.md

# ------------------------------------------------------------------------------
# Test Harness Integration
# ------------------------------------------------------------------------------
check_PROGRAMS = \
	test_iris_json \
	test_iris_cli_args \
	test_iris_bezier \
	test_iris_spline \
	test_iris_svd \
	test_iris_spline_collection \
	test_iris_opentype \
	test_iris_font_json \
	test_iris_evaluate_pegs \
	test_iris_pdf \
	test_iris_dvi \
	test_iris_markup_parser \
	test_iris_kpsewhich \
	test_iris_tex \
	test_iris_trip \
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

test_iris_svd_SOURCES = tests/test_iris_svd.f90
test_iris_svd_LDADD = libiris.a $(LAPACK_LIBS) $(BLAS_LIBS)
tests/test_iris_svd.$(OBJEXT): fortran/iris_hobby_svd.$(OBJEXT) fortran/iris_svd_bridge.$(OBJEXT) fortran/iris_svd_fallback.$(OBJEXT)

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
test_iris_pdf_LDADD = libiris.a $(LAPACK_LIBS) $(BLAS_LIBS) $(CAPYPDF_LIBS) -lz
tests/test_iris_pdf.$(OBJEXT): fortran/iris_pdf.$(OBJEXT)

test_iris_dvi_SOURCES = tests/test_iris_dvi.f90
test_iris_dvi_LDADD = libiris.a
tests/test_iris_dvi.$(OBJEXT): fortran/iris_dvi.$(OBJEXT)

test_iris_markup_parser_SOURCES = tests/test_iris_markup_parser.f90
test_iris_markup_parser_LDADD = libiris.a
tests/test_iris_markup_parser.$(OBJEXT): fortran/iris_markup_parser.$(OBJEXT)

test_iris_kpsewhich_SOURCES = tests/test_iris_kpsewhich.f90
test_iris_kpsewhich_LDADD = libiris.a
tests/test_iris_kpsewhich.$(OBJEXT): fortran/iris_kpsewhich.$(OBJEXT)

test_iris_tex_SOURCES = tests/test_iris_tex.f90
test_iris_tex_LDADD = libiris.a $(LAPACK_LIBS) $(BLAS_LIBS) $(CAPYPDF_LIBS) -lz
tests/test_iris_tex.$(OBJEXT): fortran/iris_tex.$(OBJEXT)

test_iris_trip_SOURCES = tests/test_iris_trip.f90
test_iris_trip_LDADD = libiris.a $(LAPACK_LIBS) $(BLAS_LIBS) $(CAPYPDF_LIBS) -lz
tests/test_iris_trip.$(OBJEXT): fortran/iris_tex.$(OBJEXT)

test_iris_batch_SOURCES = tests/test_iris_batch.f90
test_iris_batch_LDADD = libiris.a $(LAPACK_LIBS) $(BLAS_LIBS) $(CAPYPDF_LIBS) -lz
tests/test_iris_batch.$(OBJEXT): fortran/iris_batch_engine.$(OBJEXT)

TESTS = $(check_PROGRAMS)

# ------------------------------------------------------------------------------
# Cleanup Rules for Fortran Module Binaries & Output PDF Files
# ------------------------------------------------------------------------------
CLEANFILES = *.mod fortran/*.mod tests/*.mod *.pdf *.dvi test_output.pdf test_pdf_out.pdf test_dvi_out.dvi

EXTRA_DIST = autogen.sh LICENSE COPYING
