#!/usr/bin/env bash

set -e

export BUILD_OUTPUT_DIR="/app/bin"
export BUILD_START=$EPOCHSECONDS

# Set up environment
export CMAKE_BUILD_TYPE="Debug"
export CMAKE_C_COMPILER_LAUNCHER=""
export CMAKE_CXX_COMPILER_LAUNCHER=""
export CC="/usr/bin/clang-17"
export CXX="/usr/bin/clang++-17"
export CCACHE_BASEDIR="/app"
export CCACHE_DIR="/app/.ccache"
export CCACHE_CPP2="1"

echo "===== Setup ====="
cmake -GNinja -S /app -B "$BUILD_OUTPUT_DIR" \
    -DWITH_WARNINGS=1 -DWITH_WARNINGS_AS_ERRORS=1 -DWITH_COREDEBUG=0 \
    -DUSE_COREPCH=1 -DUSE_SCRIPTPCH=1 -DTOOLS=1 -DSCRIPTS=dynamic -DSERVERS=1 -DNOJEM=0 \
    -DCMAKE_C_FLAGS_DEBUG="-DNDEBUG -g0" -DCMAKE_CXX_FLAGS_DEBUG="-DNDEBUG -g0" \
    -DCMAKE_INSTALL_PREFIX=check_install -DBUILD_TESTING=1

echo "===== Build ====="
ccache -z
cmake --build "$BUILD_OUTPUT_DIR"
ccache -s
ccache --evict-older-than $(($EPOCHSECONDS - $BUILD_START))s

echo "===== Unit tests ====="
cmake --build "$BUILD_OUTPUT_DIR" --target test

echo "===== Check executables ====="
cmake --install "$BUILD_OUTPUT_DIR"
cd /app/check_install/bin
./bnetserver --version
./worldserver --version

echo "FINAL_STATUS = SUCCESS"
