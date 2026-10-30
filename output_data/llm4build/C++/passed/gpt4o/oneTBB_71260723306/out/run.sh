#!/bin/bash

# Activate environment variables
export BUILD_CONCURRENCY=2
export TEST_TIMEOUT=180

# Install project dependencies (if any)
# Assuming no additional dependencies are needed beyond system packages

# Build and test the project
set -x
mkdir -p build && cd build
cmake -DCMAKE_CXX_STANDARD=17 -DCMAKE_BUILD_TYPE=release \
      -DCMAKE_CXX_COMPILER=g++ -DCMAKE_C_COMPILER=gcc -DTBB_CPF=ON ..
make VERBOSE=1 -j${BUILD_CONCURRENCY}
ctest --timeout ${TEST_TIMEOUT} --output-on-failure || true  # Ensure all tests run