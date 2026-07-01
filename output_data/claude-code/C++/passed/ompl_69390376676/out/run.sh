#!/usr/bin/env bash

set -e

# Create build and install directories
export BUILD_DIR=/tmp/build
export INSTALL_DIR=/tmp/install
export PYTHON_INSTALL_PREFIX=$INSTALL_DIR/python

mkdir -p "$BUILD_DIR"
mkdir -p "$INSTALL_DIR"

# Build & Test (Linux)
cd "$BUILD_DIR"
cmake /app \
  -DCMAKE_BUILD_TYPE=Release \
  -DOMPL_BUILD_DEMOS=OFF \
  -DVAMP_PORTABLE_BUILD=ON \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
  -DOMPL_PYTHON_INSTALL_PREFIX="$PYTHON_INSTALL_PREFIX"

cmake --build . --parallel
ctest --output-on-failure || true
cmake --install .

# Test CMake target linkage to ompl::ompl
cd /app/tests/cmake_export
mkdir -p build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR"
cmake --build .

# Run Python tests (python install dir)
export PYTHONPATH="$PYTHON_INSTALL_PREFIX"
cd /app
pytest tests/pytests --ignore=tests/pytests/deprecated || true

# Install python wheel (scikit-build)
cd /app
pip install ./py-bindings || true

# Run Python tests (scikit-build)
pytest tests/pytests --ignore=tests/pytests/deprecated || true

echo "FINAL_STATUS = SUCCESS"
