#!/bin/bash

set -e

# Print environment for debugging
echo "=== Build Environment ==="
echo "CC: $CC"
echo "CFLAGS: $CFLAGS"
echo "PWD: $(pwd)"
echo ""

# Verify Makefile exists
echo "=== Checking for Makefile ==="
if [ ! -f "/workspace/Makefile" ]; then
    echo "ERROR: Makefile not found in /workspace"
    echo "Contents of /workspace:"
    ls -la /workspace/ | head -50
    exit 1
fi
echo "Makefile found"
echo ""

# Create build directory
echo "=== Setting up build directory ==="
mkdir -p /workspace/build
cd /workspace/build

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

echo ""
echo "=== Build and Tests Complete ==="