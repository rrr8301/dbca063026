#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone . /app

# Create build directory
cmake -E make_directory /app/build

# Configure CMake
cd /app/build
sanitizer_flags=""
if [[ "ubuntu-latest" != "windows-latest" ]]; then
  sanitizer_flags="-DENABLE_SANITIZE_ADDR=ON -DENABLE_SANITIZE_UNDEF=ON"
fi

cmake /app \
  -DLIBSRTP_TEST_APPS=ON \
  -DCMAKE_BUILD_TYPE=Debug \
  $sanitizer_flags \
  -DCRYPTO_LIBRARY=internal

# Build the project
cmake --build .

# Run tests
ctest