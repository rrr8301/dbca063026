#!/bin/bash

set -e

# Print environment for debugging
echo "=== Build Environment ==="
echo "CC: $CC"
echo "CFLAGS: $CFLAGS"
echo "PWD: $(pwd)"
echo ""

# Verify CMakeLists.txt or Makefile exists
echo "=== Checking for build configuration ==="
if [ ! -f "/workspace/CMakeLists.txt" ] && [ ! -f "/workspace/Makefile" ]; then
    echo "ERROR: Neither CMakeLists.txt nor Makefile found in /workspace"
    echo "Contents of /workspace:"
    ls -la /workspace/ | head -50
    exit 1
fi

if [ -f "/workspace/CMakeLists.txt" ]; then
    echo "CMakeLists.txt found - using CMake build"
    BUILD_TYPE="cmake"
else
    echo "Makefile found - using Make build"
    BUILD_TYPE="make"
fi
echo ""

# Create build directory
echo "=== Setting up build directory ==="
mkdir -p /workspace/build
cd /workspace/build

if [ "$BUILD_TYPE" = "cmake" ]; then
    # Configure using CMake
    echo "=== Configuring with CMake ==="
    cmake .. -G "Unix Makefiles"
    
    # Build using CMake
    echo ""
    echo "=== Building ==="
    cmake --build . --verbose -- -j$(nproc)
    
    # Test
    echo ""
    echo "=== Running Tests ==="
    CTEST_OUTPUT_ON_FAILURE=1 ctest --build-config Debug || true
else
    # Ensure all shell scripts have execute permissions
    echo "=== Fixing script permissions ==="
    find /workspace -type f -name "*.sh" -exec chmod +x {} \;
    
    # Configure using autoconf/configure if available
    echo "=== Configuring ==="
    if [ -f "/workspace/configure" ]; then
        /workspace/configure
    else
        echo "No configure script found, proceeding with direct make"
    fi
    
    # Build using Make
    echo ""
    echo "=== Building ==="
    make -C /workspace -j$(nproc)
    
    # Test
    echo ""
    echo "=== Running Tests ==="
    if [ -f "/workspace/Makefile" ] && grep -q "^test:" /workspace/Makefile; then
        make -C /workspace test
    else
        echo "No test target found in Makefile"
    fi
fi

echo ""
echo "=== Build and Tests Complete ==="