#!/bin/bash

set -e

# Set compiler environment variables
export CC=clang
export CXX=clang++

# Ensure pipx binaries are in PATH
export PATH="/root/.local/bin:${PATH}"

# Configure with meson (debug build, tests enabled)
echo "Configuring with meson..."
meson setup build-debug --buildtype=debug -Dtests=enabled

# Build with meson
echo "Building..."
meson compile -C build-debug

# Run tests
echo "Running tests..."
meson test -C build-debug --timeout-multiplier 0

echo "All tests completed successfully!"