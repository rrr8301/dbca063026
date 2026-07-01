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
sudo make install
cd /workspace

# Create build directory
echo "Creating build environment..."
cmake -E make_directory build

# Configure CMake
echo "Configuring CMake..."
cd build
CMAKE_PREFIX_PATH=$QT_ROOT_DIR cmake /workspace \
    -DCMAKE_BUILD_TYPE=Debug \
    -DZINT_TEST=ON \
    -DZINT_STATIC=ON \
    -DZINT_QT6=ON

# Build
echo "Building project..."
cmake --build . -j$(nproc) --config Debug

# Run tests
echo "Running tests..."
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$(pwd)/backend"
export PATH=$PATH:"$(pwd)/frontend"
export QT_QPA_PLATFORM=offscreen
ctest -V -C Debug

echo "Build and tests completed successfully!"