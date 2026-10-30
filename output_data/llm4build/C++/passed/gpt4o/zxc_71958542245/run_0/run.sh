#!/bin/bash

# Set environment variables for compiler
export CC=gcc-14
export CXX=g++-14

# Verify compiler version
gcc-14 --version

# Configure CMake
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DZXC_NATIVE_ARCH=OFF

# Build the project
cmake --build build --config Release --parallel

# Run native tests
cd build
ctest -C Release --output-on-failure

# Test CLI
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
chmod +x ../tests/test_cli.sh
../tests/test_cli.sh "$ZXC_BIN"