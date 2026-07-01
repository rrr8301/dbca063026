#!/bin/bash
set -e

# Clone repository with submodules
if [ ! -d "/workspace/omath" ]; then
    git clone --recursive https://github.com/YOUR_REPO_URL /workspace/omath
fi

cd /workspace/omath

# Set VCPKG_ROOT
export VCPKG_ROOT="/workspace/vcpkg"

# Set up vcpkg
if [ ! -d "$VCPKG_ROOT" ]; then
    git clone https://github.com/microsoft/vcpkg "$VCPKG_ROOT"
    cd "$VCPKG_ROOT"
    ./bootstrap-vcpkg.sh
    cd /workspace/omath
fi

# Configure with CMake preset
cmake --preset linux-release-vcpkg \
    -DVCPKG_INSTALL_OPTIONS="--allow-unsupported" \
    -DOMATH_BUILD_TESTS=ON \
    -DOMATH_BUILD_BENCHMARK=OFF \
    -DOMATH_ENABLE_COVERAGE=ON \
    -DVCPKG_MANIFEST_FEATURES="imgui;avx2;tests;lua"

# Build targets
cmake --build cmake-build/build/linux-release-vcpkg --target unit_tests omath

# Run unit tests
./out/Release/unit_tests

# Run coverage
chmod +x scripts/coverage-llvm.sh
./scripts/coverage-llvm.sh \
    "/workspace/omath" \
    "cmake-build/build/linux-release-vcpkg" \
    "./out/Release/unit_tests" \
    "cmake-build/build/linux-release-vcpkg/coverage"

echo "All tests and coverage generation completed successfully!"