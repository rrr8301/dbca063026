#!/bin/bash
set -e

# Set compiler environment variables
export CC=clang-22
export CXX=clang++-22

# Add host usr local bin to PATH (from GitHub Actions step)
export PATH="/usr/local/bin:$PATH"

# Run CI setup script
echo "Running CI setup..."
script/ci_setup_linux.sh

# Setup libc++ (conditional for clang >= 12)
if [ "22" -ge "12" ]; then
    echo "Installing libunwind-22-dev..."
    apt-get update && apt-get install -y --no-install-recommends libunwind-22-dev
fi

# Set C++ flags for libc++
export CXXFLAGS=-stdlib=libc++

# Build and run tests
echo "Building and running tests..."
script/ci.sh run_tests

echo "All tests completed successfully!"