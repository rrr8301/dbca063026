#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Run meson setup with the specified arguments
meson setup builddir . --prefix=$PWD/_instdir

# Configure meson
meson configure builddir

# Build with ninja and install
ninja -C builddir install

# Run meson tests
meson test -C builddir --print-errorlogs

echo "Build and tests completed successfully!"