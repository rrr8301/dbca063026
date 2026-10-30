#!/bin/bash

set -e

# Clone the repository if not already present
if [ ! -d "/workspace/mruby" ]; then
    echo "=== Cloning mruby repository ==="
    git clone https://github.com/mruby/mruby.git /workspace/mruby
fi

cd /workspace/mruby

# Verify Makefile exists
if [ ! -f "Makefile" ]; then
    echo "Error: Makefile not found in /workspace/mruby"
    exit 1
fi

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