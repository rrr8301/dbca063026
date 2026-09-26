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

# Build using Makefile
echo "=== Building ==="
cd /workspace
make -j$(nproc) CC="$CC" CFLAGS="$CFLAGS"

# Test
echo ""
echo "=== Running Tests ==="
cd /workspace
make test CC="$CC" CFLAGS="$CFLAGS"

echo ""
echo "=== Build and Tests Complete ==="