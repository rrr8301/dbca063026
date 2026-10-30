#!/bin/bash

set -e

# Clone the repository (assuming it's passed as an argument or environment variable)
# For local testing, the repo should be mounted or copied
if [ ! -d ".git" ]; then
    echo "Repository not found. Assuming code is already in /workspace"
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