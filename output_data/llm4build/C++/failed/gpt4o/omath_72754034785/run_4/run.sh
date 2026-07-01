#!/bin/bash

# Clone the repository and initialize submodules
if [ ! -d "/app/.git" ]; then
  git clone --recurse-submodules https://github.com/your-repo/omath.git /app || { echo "Failed to clone repository"; exit 1; }
fi
cd /app

# Check if CMakeLists.txt exists
if [ ! -f "CMakeLists.txt" ]; then
  echo "CMakeLists.txt not found in /app"
  exit 1
fi

# Set up vcpkg
export VCPKG_ROOT=/app/vcpkg
if [ ! -d "$VCPKG_ROOT" ]; then
  git clone https://github.com/microsoft/vcpkg "$VCPKG_ROOT" || { echo "Failed to clone vcpkg"; exit 1; }
  cd "$VCPKG_ROOT"
  ./bootstrap-vcpkg.sh || { echo "Failed to bootstrap vcpkg"; exit 1; }
  cd /app
fi

# Configure using CMake
if [ ! -d "cmake-build/build/linux-release-vcpkg" ]; then
  cmake -S . -B cmake-build/build/linux-release-vcpkg \
    -DVCPKG_INSTALL_OPTIONS="--allow-unsupported" \
    -DOMATH_BUILD_TESTS=ON \
    -DOMATH_BUILD_BENCHMARK=OFF \
    -DOMATH_ENABLE_COVERAGE=ON \
    -DVCPKG_MANIFEST_FEATURES="imgui;avx2;tests;lua" || { echo "CMake configuration failed"; exit 1; }
fi

# Build using CMake
cmake --build cmake-build/build/linux-release-vcpkg --target unit_tests omath || { echo "Build failed"; exit 1; }

# Run unit tests
if [ -f "./out/Release/unit_tests" ]; then
  ./out/Release/unit_tests || { echo "Unit tests failed"; exit 1; }
else
  echo "Unit tests executable not found!"
  exit 1
fi