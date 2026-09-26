#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Update git submodules (in case they weren't fully initialized during COPY)
git submodule update --init --recursive

# Create build directory
mkdir -p /workspace/build
mkdir -p /workspace/install

# Configure CMake
cd /workspace/build
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DOMPL_BUILD_DEMOS=OFF \
  -DVAMP_PORTABLE_BUILD=ON \
  -DCMAKE_INSTALL_PREFIX=/workspace/install \
  -DOMPL_PYTHON_INSTALL_PREFIX=/workspace/install/python

# Build
cmake --build . --config Release

# Run CTest
ctest --output-on-failure

# Install
cmake --install .

# Test CMake target linkage to ompl::ompl
cd /workspace/tests/cmake_export
cmake -B build -DCMAKE_INSTALL_PREFIX=/workspace/install
cmake --build build

# Run Python tests (python install dir)
export PYTHONPATH=/workspace/install/python
pytest /workspace/tests/pytests --ignore=/workspace/tests/pytests/deprecated

# Install python wheel (scikit-build)
cd /workspace
pip install ./py-bindings --break-system-packages

# Run Python tests (scikit-build)
pytest /workspace/tests/pytests --ignore=/workspace/tests/pytests/deprecated

echo "All tests completed successfully!"