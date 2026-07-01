#!/bin/bash
set -e

# Enable error output
export CTEST_OUTPUT_ON_FAILURE=1

echo "=== Building MbedTLS 4.0.0 ==="
git clone https://github.com/Mbed-TLS/mbedtls.git
cd mbedtls
git checkout mbedtls-4.0.0
git submodule update --init --recursive
cmake -S . -B build
cmake --build build
sudo cmake --install build
cd ..

echo "=== Repository already checked out ==="
# Repository is copied into the container, no need to clone

echo "=== Creating Build Environment ==="
mkdir -p /workspace/build

echo "=== Configuring CMake ==="
cd /workspace/build
sanitizer_flags="-DENABLE_SANITIZE_ADDR=ON -DENABLE_SANITIZE_UNDEF=ON"

cmake /workspace \
  -DLIBSRTP_TEST_APPS=ON \
  -DCMAKE_BUILD_TYPE=Debug \
  $sanitizer_flags \
  -DCRYPTO_LIBRARY=mbedtls

echo "=== Building ==="
cmake --build .

echo "=== Running Tests ==="
ctest

echo "=== All tests completed successfully ==="