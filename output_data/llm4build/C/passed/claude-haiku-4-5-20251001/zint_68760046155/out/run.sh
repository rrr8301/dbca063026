#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Configure git safe directory
git config --global --add safe.directory /workspace

# Install GS1 Syntax Engine
echo "Installing GS1 Syntax Engine..."
git clone --depth=1 https://github.com/gs1/gs1-syntax-engine
cd gs1-syntax-engine/src/c-lib
make lib
make install
cd /workspace

# Create build directory
mkdir -p build
cd build

# Detect Qt5 installation path
QT_ROOT_DIR=$(qmake -query QT_INSTALL_PREFIX)
export QT_ROOT_DIR

# Configure CMake
echo "Configuring CMake..."
CMAKE_PREFIX_PATH=$QT_ROOT_DIR cmake /workspace \
  -DCMAKE_BUILD_TYPE=Release \
  -DZINT_TEST=ON \
  -DZINT_STATIC=ON

# Build
echo "Building..."
cmake --build . -j8 --config Release

# Run tests
echo "Running tests..."
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$(pwd)/backend"
export PATH=$PATH:"$(pwd)/frontend"
export QT_QPA_PLATFORM=offscreen

ctest -V -C Release

echo "All tests completed successfully!"