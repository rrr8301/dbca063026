#!/bin/bash

set -e

# Set environment variables for build
export CMAKE_BUILD_TYPE=Debug
export CMAKE_C_COMPILER_LAUNCHER=ccache
export CMAKE_CXX_COMPILER_LAUNCHER=ccache
export CC=/usr/bin/clang-17
export CXX=/usr/bin/clang++-17
export CCACHE_BASEDIR=/workspace
export CCACHE_DIR=/workspace/.ccache
export CCACHE_CPP2=1

# Create build output directory
BUILD_OUTPUT_DIR=/workspace/bin
mkdir -p "$BUILD_OUTPUT_DIR"

# Record build start time
BUILD_START=$EPOCHSECONDS

# Setup CMake
echo "=== Setting up CMake ==="
cmake -GNinja -S /workspace -B "$BUILD_OUTPUT_DIR" \
    -DWITH_WARNINGS=1 \
    -DWITH_WARNINGS_AS_ERRORS=1 \
    -DWITH_COREDEBUG=0 \
    -DUSE_COREPCH=0 \
    -DUSE_SCRIPTPCH=0 \
    -DTOOLS=1 \
    -DSCRIPTS=dynamic \
    -DSERVERS=1 \
    -DNOJEM=0 \
    -DCMAKE_C_FLAGS_DEBUG="-DNDEBUG -g0" \
    -DCMAKE_CXX_FLAGS_DEBUG="-DNDEBUG -g0" \
    -DCMAKE_INSTALL_PREFIX=check_install \
    -DBUILD_TESTING=1

# Build
echo "=== Building ==="
ccache -z
cmake --build "$BUILD_OUTPUT_DIR"
ccache -s
ccache --evict-older-than $(($EPOCHSECONDS - $BUILD_START))s

# Unit tests
echo "=== Running unit tests ==="
cmake --build "$BUILD_OUTPUT_DIR" --target test

# Check executables
echo "=== Checking executables ==="
cmake --install "$BUILD_OUTPUT_DIR"
cd /workspace/check_install/bin
./bnetserver --version
./worldserver --version

echo "=== Build and tests completed successfully ==="