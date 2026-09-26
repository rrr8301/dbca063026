#!/bin/bash

set -e

# Clone the repository (full history, matching fetch-depth: 0)
git clone https://github.com/libgit2/libgit2.git source

# Set environment variables from matrix
export CC=gcc
export CMAKE_GENERATOR=Ninja
export CMAKE_OPTIONS="-DUSE_HTTPS=OpenSSL -DREGEX_BACKEND=builtin -DDEBUG_LEAK_CHECKER=valgrind -DUSE_GSSAPI=ON -DUSE_SSH=libssh2 -DDEBUG_STRICT_ALLOC=ON -DDEBUG_STRICT_OPEN=ON"

# Prepare build directory
mkdir -p build

# Build
cd build
../source/ci/build.sh

# Test
../source/ci/test.sh

echo "Build and test completed successfully"