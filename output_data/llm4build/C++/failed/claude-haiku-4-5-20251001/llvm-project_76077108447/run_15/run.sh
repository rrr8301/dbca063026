#!/bin/bash

set -e

# Set environment variables for clang-23
export CC=clang-23
export CXX=clang++-23

# Verify clang-23 is available
echo "Verifying clang-23 installation..."
which clang-23 || (echo "clang-23 not found in PATH" && exit 1)
clang-23 --version || (echo "clang-23 failed to execute" && exit 1)

# Verify llvm-23 is available
echo "Verifying llvm-23 installation..."
which llvm-config-23 || (echo "llvm-config-23 not found in PATH" && exit 1)
llvm-config-23 --version || (echo "llvm-config-23 failed to execute" && exit 1)

# Create Python virtual environment with system packages
echo "Creating Python virtual environment..."
python3 -m venv --system-site-packages .venv

# Activate virtual environment
source .venv/bin/activate

# Upgrade pip to ensure compatibility
echo "Upgrading pip, setuptools, and wheel..."
pip install --upgrade pip setuptools wheel

# Install Python requirements
if [ -f libcxx/test/requirements.txt ]; then
    echo "Installing Python requirements from libcxx/test/requirements.txt..."
    pip install -r libcxx/test/requirements.txt
else
    echo "Warning: libcxx/test/requirements.txt not found"
fi

# Run the buildbot script with generic-cxx26 configuration
# The run-buildbot script handles all CMake configuration internally
echo "Starting build and test with generic-cxx26 configuration..."
bash libcxx/utils/ci/run-buildbot generic-cxx26

echo "Build and test completed successfully"