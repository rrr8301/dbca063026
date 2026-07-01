#!/usr/bin/env bash

set -e

cd /app

export CMAKE_INSTALL_PREFIX="/app/install-prefix"
export CMAKE_BUILD_TYPE="Debug"
export YAML_BUILD_SHARED_LIBS="OFF"
export YAML_USE_SYSTEM_GTEST="OFF"
export CMAKE_CXX_FLAGS_DEBUG="-g -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC"

echo "=== Configure ==="
cmake \
  -S "/app" \
  -B build \
  -D CMAKE_CXX_STANDARD=11 \
  -D CMAKE_INSTALL_PREFIX="${CMAKE_INSTALL_PREFIX}" \
  -D CMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE}" \
  -D CMAKE_CXX_FLAGS_DEBUG="${CMAKE_CXX_FLAGS_DEBUG}" \
  -D YAML_BUILD_SHARED_LIBS="${YAML_BUILD_SHARED_LIBS}" \
  -D YAML_USE_SYSTEM_GTEST="${YAML_USE_SYSTEM_GTEST}" \
  -D YAML_CPP_BUILD_TESTS=ON

echo "=== Build ==="
cmake \
  --build build \
  --config "${CMAKE_BUILD_TYPE}" \
  --verbose \
  --parallel

echo "=== Run Tests ==="
ctest \
  --test-dir build \
  --build-config "${CMAKE_BUILD_TYPE}" \
  --output-on-failure \
  --verbose

echo "=== Install ==="
cmake --install build --config "${CMAKE_BUILD_TYPE}"

echo "=== Configure CMake package test ==="
cmake \
  -S "/app/test/cmake" \
  -B consumer-build \
  -D CMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE}" \
  -D CMAKE_PREFIX_PATH="${CMAKE_INSTALL_PREFIX}"

echo "=== Build CMake package test ==="
cmake \
  --build consumer-build \
  --config "${CMAKE_BUILD_TYPE}" \
  --verbose

echo "FINAL_STATUS = SUCCESS"
