#!/bin/bash

set -e

# Build concurrency and test timeout from environment or defaults
BUILD_CONCURRENCY=${BUILD_CONCURRENCY:-2}
TEST_TIMEOUT=${TEST_TIMEOUT:-180}

echo "=== Building oneTBB ==="
mkdir -p build
cd build

echo "=== Running CMake ==="
cmake -DCMAKE_CXX_STANDARD=17 \
      -DCMAKE_BUILD_TYPE=release \
      -DCMAKE_CXX_COMPILER=g++ \
      -DCMAKE_C_COMPILER=gcc \
      -DTBB_CPF=ON \
      ..

echo "=== Building with Make ==="
make VERBOSE=1 -j${BUILD_CONCURRENCY}

echo "=== Running Tests ==="
ctest --timeout ${TEST_TIMEOUT} --output-on-failure

echo "=== Build and Tests Complete ==="