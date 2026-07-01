#!/bin/bash
set -e

# Set environment variables
export VCPKG_ROOT="${WORKSPACE:-/workspace}/vcpkg"

# Checkout repository with submodules
if [ ! -d ".git" ]; then
    echo "Cloning repository..."
    git clone --recursive https://github.com/YOUR_ORG/omath.git /workspace/repo
    cd /workspace/repo
else
    cd /workspace
fi

# Set up vcpkg
if [ ! -d "$VCPKG_ROOT" ]; then
    echo "Setting up vcpkg..."
    git clone https://github.com/microsoft/vcpkg "$VCPKG_ROOT"
    cd "$VCPKG_ROOT"
    ./bootstrap-vcpkg.sh
    cd /workspace
fi

# Configure with CMake preset
echo "Configuring CMake..."
cmake --preset linux-release-vcpkg-x86 \
    -DVCPKG_INSTALL_OPTIONS="--allow-unsupported" \
    -DOMATH_BUILD_TESTS=ON \
    -DOMATH_BUILD_BENCHMARK=OFF \
    -DOMATH_ENABLE_COVERAGE=OFF \
    -DVCPKG_MANIFEST_FEATURES="imgui;avx2;tests;lua"

# Build
echo "Building..."
cmake --build cmake-build/build/linux-release-vcpkg-x86 --target unit_tests omath

# Run unit tests
echo "Running unit tests..."
./out/Release/unit_tests

echo "All tests completed successfully!"