#!/bin/bash

# Activate environment variables
export BUILD_CONCURRENCY=2
export TEST_TIMEOUT=180

# Install project dependencies (if any)
# Assuming no additional dependencies are needed beyond system packages

# Build and test
set -x
mkdir build && cd build
cmake -DCMAKE_CXX_STANDARD=14 -DCMAKE_BUILD_TYPE=relwithdebinfo \
      -DCMAKE_CXX_COMPILER=g++ -DCMAKE_C_COMPILER=gcc -DTBB_CPF=OFF ..
make VERBOSE=1 -j${BUILD_CONCURRENCY}
ctest --timeout ${TEST_TIMEOUT} --output-on-failure || true  # Ensure all tests run