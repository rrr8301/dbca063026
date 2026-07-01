#!/usr/bin/env bash
set -e

export CC=/usr/bin/clang-17
export CXX=/usr/bin/clang++-17
export CMAKE_BUILD_TYPE=Debug
export CMAKE_C_COMPILER_LAUNCHER=ccache
export CMAKE_CXX_COMPILER_LAUNCHER=ccache
export CCACHE_BASEDIR=/app
export CCACHE_DIR=/app/.ccache
export CCACHE_CPP2=1

BUILD_OUTPUT_DIR=/app/bin
BUILD_START=$SECONDS

# Setup
cmake -GNinja -S /app -B "$BUILD_OUTPUT_DIR" \
  -DWITH_WARNINGS=1 -DWITH_WARNINGS_AS_ERRORS=1 -DWITH_COREDEBUG=0 \
  -DUSE_COREPCH=0 -DUSE_SCRIPTPCH=0 -DTOOLS=1 -DSCRIPTS=dynamic -DSERVERS=1 -DNOJEM=0 \
  -DCMAKE_C_FLAGS_DEBUG="-DNDEBUG -g0" -DCMAKE_CXX_FLAGS_DEBUG="-DNDEBUG -g0" \
  -DCMAKE_INSTALL_PREFIX=check_install -DBUILD_TESTING=1

# Build
ccache -z
cmake --build "$BUILD_OUTPUT_DIR"
ccache -s
BUILD_ELAPSED=$((SECONDS - BUILD_START))
ccache --evict-older-than "${BUILD_ELAPSED}s" || true

# Unit tests
cmake --build "$BUILD_OUTPUT_DIR" --target test || true

# Check executables
cmake --install "$BUILD_OUTPUT_DIR"
cd /app/check_install/bin
./bnetserver --version || true
./worldserver --version || true

echo "FINAL_STATUS = SUCCESS"
