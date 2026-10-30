#!/bin/bash

set -e

# Verify that CMakeLists.txt exists in the workspace
if [ ! -f "CMakeLists.txt" ]; then
    echo "Error: CMakeLists.txt not found in /workspace"
    echo "The source code must be copied or mounted into /workspace"
    exit 1
fi

# Build configuration
BUILD_CONCURRENCY=${BUILD_CONCURRENCY:-2}
TEST_TIMEOUT=${TEST_TIMEOUT:-180}

# Create build directory
mkdir -p build
cd build

# Configure with CMake
cmake -DCMAKE_CXX_STANDARD=14 \
       -DCMAKE_BUILD_TYPE=relwithdebinfo \
       -DCMAKE_CXX_COMPILER=g++ \
       -DCMAKE_C_COMPILER=gcc \
       -DTBB_CPF=OFF \
       ..

# Build
make VERBOSE=1 -j${BUILD_CONCURRENCY}

# Run tests
ctest --timeout ${TEST_TIMEOUT} --output-on-failure

echo "All tests completed successfully!"