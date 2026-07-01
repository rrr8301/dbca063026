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
    exit 1
fi
echo "CMakeLists.txt found"
echo ""

# Create build directory
echo "=== Setting up build directory ==="
mkdir -p /workspace/build
cd /workspace/build

# Configure using CMake
echo "=== Configuring with CMake ==="
cmake .. -G "Unix Makefiles"

# Build using CMake
echo ""
echo "=== Building ==="
cmake --build . --verbose

# Test
echo ""
echo "=== Running Tests ==="
CTEST_OUTPUT_ON_FAILURE=1 ctest --build-config Debug

echo ""
echo "=== Build and Tests Complete ==="