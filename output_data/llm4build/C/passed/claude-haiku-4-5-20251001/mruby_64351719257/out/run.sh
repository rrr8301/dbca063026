#!/bin/bash

set -e

# Set environment variables as per the GitHub Actions job
export MRUBY_CONFIG=ci/gcc-clang
export CC=clang
export CXX=clang++
export LD=clang

# Display versions for debugging
echo "=== Ruby version ==="
ruby -v

echo "=== Clang version ==="
clang --version

# Build and test
echo "=== Building and testing mruby ==="
rake -m test:run:serial

echo "=== All tests completed ==="