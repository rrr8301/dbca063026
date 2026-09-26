#!/bin/bash
set -e

# Set environment variables
export VCPKG_ROOT="${VCPKG_ROOT:-/workspace/vcpkg}"
export WORKSPACE="${WORKSPACE:-/workspace}"

# Determine if repository is already checked out
if [ -d ".git" ]; then
    echo "Repository already checked out at $(pwd)"
    REPO_DIR="$(pwd)"
elif [ -d "/workspace/repo/.git" ]; then
    echo "Found repository at /workspace/repo"
    cd /workspace/repo
    REPO_DIR="$(pwd)"
else
    echo "Error: Repository not found. Please ensure the code is checked out or mounted."
    echo "Expected either:"
    echo "  - Current directory to be a git repository (.git exists)"
    echo "  - Repository at /workspace/repo"
    exit 1
fi

# Set up vcpkg
if [ ! -d "$VCPKG_ROOT" ]; then
    echo "Setting up vcpkg..."
    git clone https://github.com/microsoft/vcpkg "$VCPKG_ROOT"
    cd "$VCPKG_ROOT"
    ./bootstrap-vcpkg.sh
    cd "$REPO_DIR"
else
    echo "vcpkg already set up at $VCPKG_ROOT"
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