#!/bin/bash

# Clone and setup MbedTLS
git clone https://github.com/Mbed-TLS/mbedtls.git
cd mbedtls
git checkout mbedtls-4.0.0
git submodule update --init --recursive
cmake -S . -B build
cmake --build build
cmake --install build --prefix /usr/local
cd ..

# Create build environment
cmake -E make_directory ./build

# Configure CMake
cd build
sanitizer_flags="-DENABLE_SANITIZE_ADDR=ON -DENABLE_SANITIZE_UNDEF=ON"
cmake .. \
  -DLIBSRTP_TEST_APPS=ON \
  -DCMAKE_BUILD_TYPE=Debug \
  $sanitizer_flags \
  -DCRYPTO_LIBRARY=mbedtls \
  -DMBEDTLS_INCLUDE_DIRS=/usr/local/include \
  -DMBEDTLS_LIBRARY=/usr/local/lib/libmbedtls.a \
  -DMBEDX509_LIBRARY=/usr/local/lib/libmbedx509.a \
  -DMBEDCRYPTO_LIBRARY=/usr/local/lib/libmbedcrypto.a

# Build
cmake --build .

# Test
ctest