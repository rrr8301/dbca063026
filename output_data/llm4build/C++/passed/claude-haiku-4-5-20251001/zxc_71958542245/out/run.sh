#!/bin/bash

set -e

# Set compiler environment variables
export CC=gcc-14
export CXX=g++-14

echo "Compiler versions:"
gcc-14 --version
g++-14 --version

# Configure CMake
echo "Configuring CMake..."
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DZXC_NATIVE_ARCH=OFF

# Build
echo "Building project..."
cmake --build build --config Release --parallel

# Run native tests
echo "Running native tests..."
cd build
ctest -C Release --output-on-failure || TEST_FAILED=1
cd ..

# Run CLI tests
echo "Running CLI tests..."
BUILD_DIR="build"

# Find binary (handle both Ninja and Visual Studio generators)
if [ -f "$BUILD_DIR/Release/zxc" ]; then
    ZXC_BIN="$BUILD_DIR/Release/zxc"
elif [ -f "$BUILD_DIR/zxc" ]; then
    ZXC_BIN="$BUILD_DIR/zxc"
else
    echo "Binary not found for CLI test!"
    find "$BUILD_DIR" -name "zxc"
    exit 1
fi

echo "Testing with binary: $ZXC_BIN"
chmod +x tests/test_cli.sh
./tests/test_cli.sh "$ZXC_BIN" || TEST_FAILED=1

# Exit with failure if any test failed
if [ "$TEST_FAILED" = "1" ]; then
    exit 1
fi

echo "All tests passed!"