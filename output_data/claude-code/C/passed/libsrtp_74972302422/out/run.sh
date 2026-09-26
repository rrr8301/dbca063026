#!/usr/bin/env bash
set -e

cd /app/build

# Configure CMake
cmake /app \
  -DLIBSRTP_TEST_APPS=ON \
  -DCMAKE_BUILD_TYPE=Debug \
  -DENABLE_SANITIZE_ADDR=ON \
  -DENABLE_SANITIZE_UNDEF=ON \
  -DCRYPTO_LIBRARY=internal

# Build
cmake --build .

# Test
ctest

echo "FINAL_STATUS = SUCCESS"
