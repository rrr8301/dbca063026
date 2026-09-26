#!/bin/bash
set -e

# Clone the repository (simulating actions/checkout@v3)
# Assuming the repo is mounted or provided; if not, clone from a source
if [ ! -d "/workspace/.git" ]; then
    echo "Repository not found. Assuming it will be mounted at /workspace"
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