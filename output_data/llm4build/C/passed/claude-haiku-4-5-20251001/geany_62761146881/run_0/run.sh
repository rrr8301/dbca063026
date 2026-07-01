#!/bin/bash

set -e

# Print environment info
echo "=== Build Environment ==="
echo "CC: $CC"
echo "CXX: $CXX"
echo "CFLAGS: $CFLAGS"
echo "CCACHE_DIR: $CCACHE_DIR"
echo "JOBS: $JOBS"
echo ""

# Create ccache directory if it doesn't exist
mkdir -p "$CCACHE_DIR"

# Configure with meson
echo "=== Configuring with Meson ==="
meson _build

# Build with ninja
echo "=== Building with Ninja ==="
ninja -C _build

# Run tests
echo "=== Running Tests ==="
ninja -C _build test

echo ""
echo "=== Build and Tests Complete ==="