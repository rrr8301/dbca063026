#!/bin/bash
set -e

# Assume repository is already checked out in current directory
# If running in Docker, the repo should be mounted or copied in
if [ ! -f "CMakeLists.txt" ]; then
    echo "Error: Repository not found in current directory"
    echo "Expected to find CMakeLists.txt in $(pwd)"
    exit 1
fi

REPO_ROOT="$(pwd)"

# Set VCPKG_ROOT
export VCPKG_ROOT="${VCPKG_ROOT:-/workspace/vcpkg}"

# Set up vcpkg if not already present
if [ ! -d "$VCPKG_ROOT" ]; then
    echo "Setting up vcpkg at $VCPKG_ROOT..."
    git clone https://github.com/microsoft/vcpkg "$VCPKG_ROOT"
    cd "$VCPKG_ROOT"
    ./bootstrap-vcpkg.sh
    cd "$REPO_ROOT"
fi

echo "Repository root: $REPO_ROOT"
echo "VCPKG_ROOT: $VCPKG_ROOT"

# Configure with CMake preset
echo "Configuring CMake..."
cmake --preset linux-release-vcpkg \
    -DVCPKG_INSTALL_OPTIONS="--allow-unsupported" \
    -DOMATH_BUILD_TESTS=ON \
    -DOMATH_BUILD_BENCHMARK=OFF \
    -DOMATH_ENABLE_COVERAGE=ON \
    -DVCPKG_MANIFEST_FEATURES="imgui;avx2;tests;lua"

# Build targets
echo "Building targets..."
cmake --build cmake-build/build/linux-release-vcpkg --target unit_tests omath

# Run unit tests
echo "Running unit tests..."
./out/Release/unit_tests

# Run coverage
echo "Generating coverage report..."
chmod +x scripts/coverage-llvm.sh
./scripts/coverage-llvm.sh \
    "$REPO_ROOT" \
    "cmake-build/build/linux-release-vcpkg" \
    "./out/Release/unit_tests" \
    "cmake-build/build/linux-release-vcpkg/coverage"

echo "All tests and coverage generation completed successfully!"