#!/bin/bash
set -e

# Install meson and ninja via pipx
pipx install meson ninja

# Ensure pipx binaries are in PATH
export PATH="/root/.local/bin:$PATH"

# Set compiler environment variables
export CC=clang
export CXX=clang++

# Configure the build
meson setup build-debug --buildtype=debug -Dtests=enabled

# Build the project
meson compile -C build-debug

# Run tests (normal)
meson test -C build-debug --timeout-multiplier 5 --print-errorlogs

# Run benchmark tests
meson test --benchmark -C build-debug --timeout-multiplier 5 --print-errorlogs

echo "All tests completed successfully!"