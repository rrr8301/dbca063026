#!/usr/bin/env bash

set -e

cd /app

CMAKE_INSTALL_PREFIX="/app/install-prefix"
CMAKE_BUILD_TYPE="Debug"
CMAKE_CXX_FLAGS_DEBUG="-g"

# Configure
echo "=== Configure ==="
cmake \
  -S "/app" \
  -B build \
  -D CMAKE_CXX_STANDARD=11 \
  -D CMAKE_INSTALL_PREFIX="${CMAKE_INSTALL_PREFIX}" \
  -D CMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE}" \
  -D CMAKE_CXX_FLAGS_DEBUG="${CMAKE_CXX_FLAGS_DEBUG}" \
  -D YAML_BUILD_SHARED_LIBS=OFF \
  -D YAML_USE_SYSTEM_GTEST=OFF \
  -D YAML_CPP_BUILD_TESTS=ON

# Build
echo "=== Build ==="
cmake \
  --build build \
  --config "${CMAKE_BUILD_TYPE}" \
  --verbose \
  --parallel

# Run Tests
echo "=== Run Tests ==="
ctest \
  --test-dir build \
  --build-config "${CMAKE_BUILD_TYPE}" \
  --output-on-failure \
  --verbose

# Install
echo "=== Install ==="
cmake --install build --config "${CMAKE_BUILD_TYPE}"

# Configure CMake package test
echo "=== Configure CMake package test ==="
cmake \
  -S "/app/test/cmake" \
  -B consumer-build \
  -D CMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE}" \
  -D CMAKE_PREFIX_PATH="${CMAKE_INSTALL_PREFIX}"

# Build CMake package test
echo "=== Build CMake package test ==="
cmake \
  --build consumer-build \
  --config "${CMAKE_BUILD_TYPE}" \
  --verbose

echo "FINAL_STATUS = SUCCESS"
