#!/bin/bash

set -e

# Print environment for debugging
echo "=== Build Environment ==="
echo "CC: $CC"
echo "CFLAGS: $CFLAGS"
echo "PWD: $(pwd)"
echo ""

# Build
echo "=== Building ==="
mkdir -p build
cd build
cmake .. -G "Unix Makefiles"
cmake --build . --verbose

# Test
echo ""
echo "=== Running Tests ==="
cd /workspace/build
CTEST_OUTPUT_ON_FAILURE=1 ctest --build-config Debug

echo ""
echo "=== Build and Tests Complete ==="