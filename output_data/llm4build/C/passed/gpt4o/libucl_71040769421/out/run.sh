#!/bin/bash

# Clone the repository (simulating actions/checkout)
# Assuming the repository is already copied in the Dockerfile

# Set build output directory
BUILD_OUTPUT_DIR="/app/build"

# Configure CMake
cmake -B "$BUILD_OUTPUT_DIR" \
    -DCMAKE_CXX_COMPILER=g++ \
    -DCMAKE_C_COMPILER=gcc \
    -DCMAKE_BUILD_TYPE=Release \
    -S /app

# Build
cmake --build "$BUILD_OUTPUT_DIR" --config Release

# Test
cd "$BUILD_OUTPUT_DIR"
ctest --progress --output-on-failure --build-config Release