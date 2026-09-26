#!/bin/bash

set -e

# Set environment variables
export YAML_BUILD_SHARED_LIBS='OFF'
export YAML_USE_SYSTEM_GTEST='OFF'
export CMAKE_GENERATOR=''
export CMAKE_INSTALL_PREFIX="/workspace/install-prefix"
export CMAKE_BUILD_TYPE=Debug
export CMAKE_CXX_FLAGS_DEBUG='-g -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC'

# Configure
echo "=== Configuring CMake ==="
cmake \
  -S "/workspace" \
  -B build \
  -D CMAKE_CXX_STANDARD=11 \
  -D CMAKE_INSTALL_PREFIX="${CMAKE_INSTALL_PREFIX}" \
  -D CMAKE_BUILD_TYPE=Debug \
  -D CMAKE_CXX_FLAGS_DEBUG="-g -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC" \
  -D YAML_BUILD_SHARED_LIBS=OFF \
  -D YAML_USE_SYSTEM_GTEST=OFF \
  -D YAML_CPP_BUILD_TESTS=ON

# Build
echo "=== Building ==="
cmake \
  --build build \
  --config Debug \
  --verbose \
  --parallel

# Run Tests
echo "=== Running Tests ==="
ctest \
  --test-dir build \
  --build-config Debug \
  --output-on-failure \
  --verbose

# Install
echo "=== Installing ==="
cmake --install build --config Debug

# Configure CMake package test
echo "=== Configuring CMake package test ==="
cmake \
  -S "/workspace/test/cmake" \
  -B consumer-build \
  -D CMAKE_BUILD_TYPE=Debug \
  -D CMAKE_PREFIX_PATH="${CMAKE_INSTALL_PREFIX}"

# Build CMake package test
echo "=== Building CMake package test ==="
cmake \
  --build consumer-build \
  --config Debug \
  --verbose

echo "=== All steps completed successfully ==="