#!/bin/bash

set -e

# Set environment variables from matrix
export CC=gcc
export CMAKE_GENERATOR=Ninja
export CMAKE_OPTIONS="-DUSE_HTTPS=OpenSSL -DREGEX_BACKEND=builtin -DDEBUG_LEAK_CHECKER=valgrind -DUSE_GSSAPI=ON -DUSE_SSH=libssh2 -DDEBUG_STRICT_ALLOC=ON -DDEBUG_STRICT_OPEN=ON"

# Prepare build directory (if not already present)
mkdir -p build

# Build
cd build
../source/ci/build.sh

# Test
../source/ci/test.sh

echo "Build and test completed successfully"