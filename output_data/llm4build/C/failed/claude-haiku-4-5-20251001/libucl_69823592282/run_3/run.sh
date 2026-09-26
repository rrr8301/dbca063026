#!/bin/bash
set -e

# Verify repository is present at /workspace
if [ ! -f "/workspace/autogen.sh" ]; then
    echo "Error: Repository not found at /workspace"
    exit 1
fi

cd /workspace

# Run autogen.sh and configure with Lua support
./autogen.sh
./configure --enable-lua

# Build the project
make

# Run tests
make check

echo "All tests passed!"