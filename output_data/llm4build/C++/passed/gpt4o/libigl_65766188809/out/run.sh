#!/bin/bash

# Simple script to verify the container is running
echo "Container is running successfully!"

# Navigate to the build directory
mkdir -p build
cd build

# Configure the project
cmake .. \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
  -DCMAKE_BUILD_TYPE=Release \
  -DLIBIGL_USE_STATIC_LIBRARY=ON \
  -DLIBIGL_BUILD_TUTORIALS=ON \
  -DLIBIGL_GLFW_TESTS=OFF \
  -DLIBIGL_BUILD_TESTS=ON \
  -DLIBIGL_COPYLEFT_CGAL=ON

# Build the project
make -j2

# Run tests
ctest --verbose