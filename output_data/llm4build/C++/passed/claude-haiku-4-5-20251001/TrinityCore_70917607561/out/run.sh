#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
TEST_FAILED=0

# Set environment variables for the build
export CMAKE_BUILD_TYPE=Debug
export CMAKE_C_COMPILER_LAUNCHER=""
export CMAKE_CXX_COMPILER_LAUNCHER=""
export CC=/usr/bin/clang-17
export CXX=/usr/bin/clang++-17

# Set ccache environment variables
export CCACHE_BASEDIR=/workspace
export CCACHE_DIR=/workspace/.ccache
export CCACHE_CPP2=1

# Define build output directory
BUILD_OUTPUT_DIR=/workspace/bin

# Record build start time
BUILD_START=$EPOCHSECONDS

echo "=========================================="
echo "TrinityCore Build & Test"
echo "=========================================="

# Step 1: CMake Configuration
echo ""
echo "Step 1: Configuring CMake..."
cmake -GNinja \
  -S /workspace \
  -B "$BUILD_OUTPUT_DIR" \
  -DWITH_WARNINGS=1 \
  -DWITH_WARNINGS_AS_ERRORS=1 \
  -DWITH_COREDEBUG=0 \
  -DUSE_COREPCH=1 \
  -DUSE_SCRIPTPCH=1 \
  -DTOOLS=1 \
  -DSCRIPTS=dynamic \
  -DSERVERS=1 \
  -DNOJEM=0 \
  -DCMAKE_C_FLAGS_DEBUG="-DNDEBUG -g0" \
  -DCMAKE_CXX_FLAGS_DEBUG="-DNDEBUG -g0" \
  -DCMAKE_INSTALL_PREFIX=check_install \
  -DBUILD_TESTING=1

# Step 2: Build
echo ""
echo "Step 2: Building project..."
ccache -z
cmake --build "$BUILD_OUTPUT_DIR"
ccache -s
BUILD_END=$EPOCHSECONDS
BUILD_DURATION=$((BUILD_END - BUILD_START))
ccache --evict-older-than ${BUILD_DURATION}s || true

# Step 3: Unit Tests
echo ""
echo "Step 3: Running unit tests..."
if ! cmake --build "$BUILD_OUTPUT_DIR" --target test; then
  echo "WARNING: Some unit tests failed"
  TEST_FAILED=1
fi

# Step 4: Check Executables
echo ""
echo "Step 4: Checking executables..."
cmake --install "$BUILD_OUTPUT_DIR"

if [ -f /workspace/check_install/bin/bnetserver ]; then
  echo "Testing bnetserver..."
  /workspace/check_install/bin/bnetserver --version || TEST_FAILED=1
else
  echo "ERROR: bnetserver not found"
  TEST_FAILED=1
fi

if [ -f /workspace/check_install/bin/worldserver ]; then
  echo "Testing worldserver..."
  /workspace/check_install/bin/worldserver --version || TEST_FAILED=1
else
  echo "ERROR: worldserver not found"
  TEST_FAILED=1
fi

echo ""
echo "=========================================="
if [ $TEST_FAILED -eq 0 ]; then
  echo "Build and tests completed successfully!"
  echo "=========================================="
  exit 0
else
  echo "Build completed with test failures!"
  echo "=========================================="
  exit 1
fi