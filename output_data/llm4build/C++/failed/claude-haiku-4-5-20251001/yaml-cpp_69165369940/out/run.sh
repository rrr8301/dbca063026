#!/bin/bash

set -e

# Set environment variables
export YAML_BUILD_SHARED_LIBS='OFF'
export YAML_USE_SYSTEM_GTEST='ON'
export CMAKE_GENERATOR=''
export CMAKE_INSTALL_PREFIX="/workspace/install-prefix"
export CMAKE_BUILD_TYPE=Debug
export CMAKE_CXX_FLAGS_DEBUG='-g'

# Configure
cmake \
  -S "/workspace" \
  -B build \
  -D CMAKE_CXX_STANDARD=11 \
  -D CMAKE_INSTALL_PREFIX="${CMAKE_INSTALL_PREFIX}" \
  -D CMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE}" \
  -D CMAKE_CXX_FLAGS_DEBUG="${CMAKE_CXX_FLAGS_DEBUG}" \
  -D YAML_BUILD_SHARED_LIBS="${YAML_BUILD_SHARED_LIBS}" \
  -D YAML_USE_SYSTEM_GTEST="${YAML_USE_SYSTEM_GTEST}" \
  -D YAML_CPP_BUILD_TESTS=ON

# Build
cmake \
  --build build \
  --config "${CMAKE_BUILD_TYPE}" \
  --verbose \
  --parallel

# Run Tests
ctest \
  --test-dir build \
  --build-config "${CMAKE_BUILD_TYPE}" \
  --output-on-failure \
  --verbose