#!/usr/bin/env bash
set -e

# Setup meson build directory
meson setup builddir

# Build with ninja
ninja -C builddir

# Run tests
ninja -C builddir test

echo "FINAL_STATUS = SUCCESS"
