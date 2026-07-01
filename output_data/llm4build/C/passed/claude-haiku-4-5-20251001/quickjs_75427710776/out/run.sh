#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Ensure pipx binaries are available
export PATH="/root/.local/bin:$PATH"

# Verify meson and ninja are installed
meson --version
ninja --version

# Setup build directory with meson
# Matrix values: flavor=debug, mode.args=-Dtests=enabled, features.args=""
echo "Setting up Meson build..."
meson setup build-debug --buildtype=debug -Dtests=enabled

# Build the project
echo "Building project..."
meson compile -C build-debug

# Run tests
echo "Running tests..."
meson test -C build-debug --timeout-multiplier 5 --print-errorlogs

# Run benchmark tests
echo "Running benchmark tests..."
meson test --benchmark -C build-debug --timeout-multiplier 5 --print-errorlogs

echo "All tests completed successfully!"