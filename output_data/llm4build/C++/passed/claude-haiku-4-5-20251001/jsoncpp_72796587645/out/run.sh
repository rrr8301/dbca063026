#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Build with Meson
echo "Building with Meson..."
meson setup builddir
meson compile -C builddir

# Run tests with Meson
echo "Running tests with Meson..."
meson test -C builddir