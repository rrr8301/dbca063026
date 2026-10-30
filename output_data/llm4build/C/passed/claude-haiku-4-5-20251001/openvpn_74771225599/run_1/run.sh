#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Run autoconf
echo "Running autoreconf..."
autoreconf -fvi

# Run configure with OpenSSL and PKCS11 support
echo "Running configure..."
./configure --with-crypto-library=openssl --enable-pkcs11 --enable-werror

# Build the project
echo "Building OpenVPN..."
make -j3

# Configure test environment
echo "Configuring test environment..."
echo 'RUN_SUDO="sudo -E"' > tests/t_server_null.rc

# Run tests
echo "Running tests..."
make -j3 check VERBOSE=1

echo "Build and tests completed successfully!"