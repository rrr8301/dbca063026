#!/bin/bash
set -e

# Export environment variables
export CTEST_OUTPUT_ON_FAILURE=1
export GITHUB_WORKSPACE=/workspace

# Create build directory
cmake -E make_directory $GITHUB_WORKSPACE/build

# Configure CMake
cd $GITHUB_WORKSPACE/build

sanitizer_flags=""
if [[ "ubuntu-latest" != "windows-latest" ]]; then
  sanitizer_flags="-DENABLE_SANITIZE_ADDR=ON -DENABLE_SANITIZE_UNDEF=ON"
fi

cmake $GITHUB_WORKSPACE \
  -DLIBSRTP_TEST_APPS=ON \
  -DCMAKE_BUILD_TYPE=Debug \
  $sanitizer_flags \
  -DCRYPTO_LIBRARY=internal

# Build
cmake --build .

# Test
ctest