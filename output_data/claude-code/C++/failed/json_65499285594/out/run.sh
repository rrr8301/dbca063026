#!/usr/bin/env bash
set -e

cd /app

# Run CMake
echo "Running CMake..."
cmake -S . -B build -DJSON_CI=On

# Build
echo "Building..."
cmake --build build --target ci_test_gcc

echo "FINAL_STATUS = SUCCESS"
