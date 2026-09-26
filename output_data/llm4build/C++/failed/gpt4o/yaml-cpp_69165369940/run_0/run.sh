#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone . /app

# Navigate to the app directory
cd /app

# Configure the build using CMake
cmake \
  -S . \
  -B build \
  -D CMAKE_CXX_STANDARD=11 \
  -D CMAKE_INSTALL_PREFIX=/app/install-prefix \
  -D CMAKE_BUILD_TYPE=Debug \
  -D CMAKE_CXX_FLAGS_DEBUG='-g -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC' \
  -D YAML_BUILD_SHARED_LIBS=OFF \
  -D YAML_USE_SYSTEM_GTEST=OFF \
  -D YAML_CPP_BUILD_TESTS=ON

# Build the project
cmake --build build --config Debug --verbose --parallel

# Run tests
ctest --test-dir build --build-config Debug --output-on-failure --verbose