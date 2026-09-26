#!/bin/bash
set -e

# Verify repository is mounted at /workspace
if [ ! -f "/workspace/autogen.sh" ]; then
    echo "Error: Repository not found at /workspace"
    echo "Please mount the repository: docker run -v /path/to/repo:/workspace <image>"
    exit 1
fi

cd /workspace

# Run autogen.sh and configure with Lua support
./autogen.sh
./configure --enable-lua

# Install dependencies (build the project)
make

# Run tests
make check

echo "All tests passed!"