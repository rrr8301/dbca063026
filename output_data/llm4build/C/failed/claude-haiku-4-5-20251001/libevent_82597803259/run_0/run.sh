#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Install dependencies
sudo apt-get update
sudo apt-get install -y libmbedtls-dev

# Build
EVENT_CMAKE_OPTIONS="-DEVENT__DISABLE_OPENSSL=ON"

mkdir -p build
cd build
echo [cmake]: cmake .. -DEVENT__ENABLE_GCC_WARNINGS=ON $EVENT_CMAKE_OPTIONS
cmake .. -DEVENT__ENABLE_GCC_WARNINGS=ON $EVENT_CMAKE_OPTIONS || (rm -rf * && cmake .. -DEVENT__ENABLE_GCC_WARNINGS=ON $EVENT_CMAKE_OPTIONS)
cmake --build .

# Test
JOBS=20
export CTEST_PARALLEL_LEVEL=$JOBS
export CTEST_OUTPUT_ON_FAILURE=1

export TSAN_OPTIONS=suppressions=$PWD/../extra/tsan.supp:allocator_may_return_null=1
export LSAN_OPTIONS=suppressions=$PWD/../extra/lsan.supp
export ASAN_OPTIONS=allocator_may_return_null=1

cmake --build . --target verify