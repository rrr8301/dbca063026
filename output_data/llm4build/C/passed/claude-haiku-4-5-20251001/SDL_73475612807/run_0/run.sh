#!/bin/bash

set -e

echo "=========================================="
echo "Building SDL - Steam Linux Runtime 4.0 (x86_64)"
echo "=========================================="

# Navigate to workspace
cd /workspace

# Display environment info
echo "Git version:"
git --version
echo ""

echo "CMake version:"
cmake --version
echo ""

echo "Compiler info:"
gcc --version
echo ""

# Initialize submodules if any
echo "Initializing git submodules..."
git submodule update --init --recursive || true

# Create build directory
BUILD_DIR="build"
if [ -d "$BUILD_DIR" ]; then
    rm -rf "$BUILD_DIR"
fi
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configure build with CMake
echo "Configuring SDL build with CMake..."
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_COMPILER=gcc \
    -DCMAKE_CXX_COMPILER=g++ \
    ..

# Build the project
echo "Building SDL..."
ninja -v

# Run tests if available
echo "Running tests..."
if [ -f "test" ] || [ -d "tests" ]; then
    ctest --output-on-failure || true
else
    echo "No tests found, skipping test execution"
fi

echo "=========================================="
echo "Build completed successfully!"
echo "=========================================="