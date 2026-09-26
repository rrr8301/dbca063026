#!/bin/bash

set -e

# Clone the repository (simulating actions/checkout@v6)
# Assuming the repo is already mounted or provided
# If running standalone, uncomment below:
# git clone https://github.com/mruby/mruby.git /workspace/repo
# cd /workspace/repo

# If repo is already in /workspace, navigate to it
if [ ! -f "Makefile" ]; then
    echo "Error: Makefile not found. Ensure repository is mounted at /workspace"
    exit 1
fi

cd /workspace

# Display Ruby version
echo "=== Ruby version ==="
ruby -v

# Display Compiler version
echo "=== Clang version ==="
clang --version

# Set environment variables as per the job
export MRUBY_CONFIG=ci/gcc-clang
export CC=clang
export CXX=clang++
export LD=clang

# Build and test
echo "=== Building and testing mruby ==="
rake -m test:run:serial

echo "=== Build and test completed successfully ==="