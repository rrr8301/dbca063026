#!/bin/bash
set -e

# Set environment variables
export CFLAGS="-O2 -g"
export LDFLAGS=""
export CC=gcc
export UBSAN_OPTIONS=print_stacktrace=1
export PKG_CONFIG_PATH=/opt/mbedtls4/lib/pkgconfig
export MBEDTLS_REPO=Mbed-TLS/mbedtls
export MBEDTLS_VERSION=v4.1.0
export MBEDTLS_INSTALL=/opt/mbedtls4

# Run autoconf
autoreconf -fvi

# Run configure
./configure --with-crypto-library=mbedtls --enable-werror

# Build
make -j3

# Verify mbed TLS version
./src/openvpn/openvpn --version
./src/openvpn/openvpn --version | grep -q "library versions: mbed TLS 4."

# Configure test environment
echo 'RUN_SUDO="sudo -E"' > tests/t_server_null.rc

# Run tests
make -j3 check VERBOSE=1