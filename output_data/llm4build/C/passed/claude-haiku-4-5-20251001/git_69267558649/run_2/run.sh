#!/bin/bash

set -e

# Print environment for debugging
echo "=== Build Environment ==="
echo "CC: $CC"
echo "CFLAGS: $CFLAGS"
echo "PWD: $(pwd)"
echo ""

# Verify CMakeLists.txt exists
echo "=== Checking for CMakeLists.txt ==="
if [ ! -f "/workspace/CMakeLists.txt" ]; then
    echo "ERROR: CMakeLists.txt not found in /workspace"
    echo "Contents of /workspace:"
    ls -la /workspace/ | head -50
    echo ""
    echo "Searching for CMakeLists.txt in subdirectories..."
    find /workspace -name "CMakeLists.txt" -type f 2>/dev/null | head -20
    exit 1
fi
echo "CMakeLists.txt found"
echo ""

# Build
echo "=== Building ==="
mkdir -p /workspace/build
cd /workspace/build
cmake .. -G "Unix Makefiles"
cmake --build . --verbose

# Test
echo ""
echo "=== Running Tests ==="
cd /workspace/build
CTEST_OUTPUT_ON_FAILURE=1 ctest --build-config Debug

echo ""
echo "=== Build and Tests Complete ==="