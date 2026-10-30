#!/bin/bash

set -e

# Clone the repository (simulating actions/checkout@v3)
# Assuming the repo is passed as an environment variable or mounted
# For local testing, we expect the repo to be in /workspace or cloned from a source
if [ ! -d "/workspace/.git" ]; then
    echo "Repository not found. Cloning from source..."
    # This assumes REPO_URL is set; otherwise, use the mounted volume
    if [ -z "$REPO_URL" ]; then
        echo "Error: Repository not mounted and REPO_URL not set"
        exit 1
    fi
    git clone "$REPO_URL" /workspace
    cd /workspace
else
    cd /workspace
fi

# Set reusable strings (simulating GitHub Actions step outputs)
BUILD_OUTPUT_DIR="/workspace/build"

# Configure CMake
echo "Configuring CMake..."
cmake -B "$BUILD_OUTPUT_DIR" \
    -DCMAKE_CXX_COMPILER=g++ \
    -DCMAKE_C_COMPILER=gcc \
    -DCMAKE_BUILD_TYPE=Release \
    -S /workspace

# Build
echo "Building project..."
cmake --build "$BUILD_OUTPUT_DIR" --config Release

# Test
echo "Running tests..."
cd "$BUILD_OUTPUT_DIR"
ctest --progress --output-on-failure --build-config Release

echo "All tests completed successfully!"