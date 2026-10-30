#!/bin/bash

# Clone the repository and initialize submodules
git clone --recurse-submodules https://github.com/your-repo/omath.git /app
cd /app

# Set up vcpkg
export VCPKG_ROOT=/app/vcpkg
git clone https://github.com/microsoft/vcpkg "$VCPKG_ROOT"
cd "$VCPKG_ROOT"
./bootstrap-vcpkg.sh
cd /app

# Configure using CMake
cmake --preset linux-release-vcpkg \
  -DVCPKG_INSTALL_OPTIONS="--allow-unsupported" \
  -DOMATH_BUILD_TESTS=ON \
  -DOMATH_BUILD_BENCHMARK=OFF \
  -DOMATH_ENABLE_COVERAGE=ON \
  -DVCPKG_MANIFEST_FEATURES="imgui;avx2;tests;lua"

# Build using CMake
cmake --build cmake-build/build/linux-release-vcpkg --target unit_tests omath

# Run unit tests
./out/Release/unit_tests