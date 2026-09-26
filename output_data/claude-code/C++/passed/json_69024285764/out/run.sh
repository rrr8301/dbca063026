#!/usr/bin/env bash
set -e

cd /app

echo "Running CMake configuration..."
cmake -S . -B build -DJSON_CI=On

echo "Building ci_test_gcc target..."
cmake --build build --target ci_test_gcc

echo "FINAL_STATUS = SUCCESS"
