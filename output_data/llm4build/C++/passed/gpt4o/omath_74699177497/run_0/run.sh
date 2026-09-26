#!/bin/bash

# Set up vcpkg
VCPKG_ROOT=/app/vcpkg
git clone https://github.com/microsoft/vcpkg "$VCPKG_ROOT"
cd "$VCPKG_ROOT"
./bootstrap-vcpkg.sh

# Configure using CMake
cd /app
cmake --preset linux-release-vcpkg-x86 \
  -DVCPKG_INSTALL_OPTIONS="--allow-unsupported" \
  -DOMATH_BUILD_TESTS=ON \
  -DOMATH_BUILD_BENCHMARK=OFF \
  -DOMATH_ENABLE_COVERAGE=OFF \
  -DVCPKG_MANIFEST_FEATURES="imgui;avx2;tests;lua"

# Build using CMake
cmake --build cmake-build/build/linux-release-vcpkg-x86 --target unit_tests omath

# Run unit tests
./out/Release/unit_tests