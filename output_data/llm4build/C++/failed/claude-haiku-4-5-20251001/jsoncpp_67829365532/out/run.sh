#!/bin/bash

set -e

# Navigate to the repository root
cd /workspace

# Setup Meson build directory
echo "Setting up Meson build..."
meson setup builddir

# Build the project
echo "Building project with Meson..."
meson compile -C builddir

# Run tests
echo "Running tests with Meson..."
meson test -C builddir

echo "Build and test completed successfully!"