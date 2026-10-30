#!/bin/bash

set -e

# Set environment variables for clang
export CC=clang
export CXX=clang++

# Ensure pipx-installed tools are in PATH
export PATH="/root/.local/bin:$PATH"

# Configure with meson
echo "=== Configuring with meson ==="
meson setup build-debug --buildtype=debug -Dtests=enabled

# Build with meson
echo "=== Building with meson ==="
meson compile -C build-debug

# Run tests with meson
echo "=== Running tests ==="
meson test -C build-debug --timeout-multiplier 0

echo "=== All tests completed ==="