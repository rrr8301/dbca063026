#!/usr/bin/env bash
set -e

echo "=== Geany Linux Meson Build ==="

# Configuration
echo "Running meson configuration..."
meson _build

# Build
echo "Building with ninja..."
ninja -C _build

# Run Tests
echo "Running tests..."
ninja -C _build test

# Success
echo "FINAL_STATUS = SUCCESS"
