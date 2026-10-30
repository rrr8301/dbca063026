#!/bin/bash
set -e

# Set compiler to GCC 14
export CC=gcc-14
export CXX=g++-14

# Ensure Rust is available and properly sourced
source /home/testuser/.cargo/env
export PATH="/home/testuser/.cargo/bin:${PATH}"

# Print versions for debugging
echo "=== Build Environment ==="
gcc-14 --version
g++-14 --version
cmake --version
ninja --version
rustc --version
cargo --version
python3 --version
echo "========================="

# Prepare libavif (cmake)
echo "Configuring libavif with CMake..."
cmake -G Ninja -S . -B build \
  -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF \
  -DAVIF_CODEC_AOM=LOCAL -DAVIF_CODEC_DAV1D=LOCAL \
  -DAVIF_CODEC_RAV1E=LOCAL -DAVIF_CODEC_SVT=LOCAL \
  -DAVIF_OPTIMIZE_RAV1E_FOR_SIZE=ON \
  -DAVIF_CODEC_LIBGAV1=LOCAL \
  -DAVIF_LIBSHARPYUV=LOCAL -DAVIF_LIBXML2=LOCAL -DAVIF_LIBYUV=LOCAL \
  -DAVIF_BUILD_EXAMPLES=ON -DAVIF_BUILD_APPS=ON \
  -DAVIF_BUILD_TESTS=ON -DAVIF_GTEST=LOCAL \
  -DAVIF_ENABLE_EXPERIMENTAL_MINI=ON \
  -DAVIF_ENABLE_EXPERIMENTAL_EXTENDED_PIXI=ON \
  -DAVIF_ENABLE_WERROR=ON

# Build libavif with verbose output
echo "Building libavif..."
cmake --build build --config Release --parallel 4 --verbose

# Check if build succeeded
if [ ! -d "./build" ]; then
    echo "ERROR: Build directory not created"
    exit 1
fi

# Run AVIF Tests
echo "Running AVIF tests..."
cd ./build

# Run ctest with verbose output to see which tests pass/fail
ctest -j $(getconf _NPROCESSORS_ONLN) --output-on-failure --verbose

# Capture the test result
TEST_RESULT=$?

if [ $TEST_RESULT -eq 0 ]; then
    echo "=== All tests completed successfully ==="
else
    echo "=== Tests failed with exit code $TEST_RESULT ==="
    exit $TEST_RESULT
fi