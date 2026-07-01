#!/bin/bash

# Set environment variables
export CXX=g++-9
export ASAN_OPTIONS="use_sigaltstack=false"
export UBSAN_OPTIONS="use_sigaltstack=false"
export CTEST_OUTPUT_ON_FAILURE=1

# Configure CMake
cmake -S . -B build \
      -DCMAKE_BUILD_TYPE=Debug \
      -DCPPSORT_BUILD_TESTING=ON \
      -DCPPSORT_SANITIZE=address,undefined \
      -DCPPSORT_USE_VALGRIND=OFF \
      -DCPPSORT_BUILD_EXAMPLES=ON \
      -G"Unix Makefiles"

# Build the test suite
cmake --build build --config Debug -j 2

# Run the test suite
cd build
ctest -C Debug --no-tests=error