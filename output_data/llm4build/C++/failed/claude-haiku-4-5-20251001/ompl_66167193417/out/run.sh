#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Create build directory
mkdir -p build/Release
cd build/Release

# Configure with CMake
cmake ../.. \
  -DCMAKE_BUILD_TYPE=Release \
  -DOMPL_BUILD_DEMOS=OFF \
  -DVAMP_PORTABLE_BUILD=ON \
  -DCMAKE_INSTALL_PREFIX=/workspace/install \
  -DOMPL_PYTHON_INSTALL_DIR=/workspace/install/python

# Build
make -j $(nproc)

# Run tests
ctest --output-on-failure

# Install
make install

echo "Build and test completed successfully!"