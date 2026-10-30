#!/usr/bin/env bash
set -e

echo "Starting ZXC build and test..."

# Configure CMake
echo "Configuring CMake..."
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DZXC_NATIVE_ARCH=OFF

# Build
echo "Building..."
cmake --build build --config Release --parallel

# Test (native)
echo "Running tests..."
cd build
ctest -C Release --output-on-failure
TEST_STATUS=$?
cd ..

if [ $TEST_STATUS -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
  exit 0
else
  echo "FINAL_STATUS = FAIL"
  exit 1
fi
