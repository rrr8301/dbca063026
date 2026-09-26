#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Configure CMake
export CXX=g++-9
cmake -S cpp-sort -B build \
      -DCMAKE_BUILD_TYPE=Debug \
      -DCPPSORT_BUILD_TESTING=ON \
      -DCPPSORT_SANITIZE=address,undefined \
      -DCPPSORT_USE_VALGRIND=OFF \
      -DCPPSORT_BUILD_EXAMPLES=ON \
      -G"Unix Makefiles"

# Build the test suite
export ASAN_OPTIONS="use_sigaltstack=false"
export UBSAN_OPTIONS="use_sigaltstack=false"
cd /workspace/build
cmake --build . --config Debug -j 2

# Run the test suite
export CTEST_OUTPUT_ON_FAILURE=1
ctest -C Debug --no-tests=error