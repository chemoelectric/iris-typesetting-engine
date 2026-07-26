#!/bin/sh
# ==============================================================================
# Autogen script for bootstrap generating GNU Autotools build environment
# ==============================================================================
set -e

echo "Bootstrapping Iris build system using GNU Autotools..."
mkdir -p build-aux m4
autoreconf --install --force --verbose

echo "Bootstrap complete. Run './configure' to generate Makefiles."
