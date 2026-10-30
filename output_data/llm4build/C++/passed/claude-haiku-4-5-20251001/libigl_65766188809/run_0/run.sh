#!/bin/bash
set -e

# Prepare ccache
ccache --max-size=1.0G
ccache -V && ccache --show-stats && ccache --zero-stats

# Configure
mkdir -p build
cd build
cmake .. \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
  -DCMAKE_BUILD_TYPE=Release \
  -DLIBIGL_USE_STATIC_LIBRARY=ON \
  -DLIBIGL_BUILD_TUTORIALS=ON \
  -DLIBIGL_GLFW_TESTS=OFF \
  -DLIBIGL_BUILD_TESTS=ON \
  -DLIBIGL_COPYLEFT_CGAL=ON

# Build
make -j2
ccache --show-stats

# Tests
ctest --show-only
ctest --verbose