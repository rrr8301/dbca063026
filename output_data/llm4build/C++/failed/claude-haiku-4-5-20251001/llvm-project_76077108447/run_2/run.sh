#!/bin/bash

set -e

# Set environment variables for clang-23
export CC=clang-23
export CXX=clang++-23
export LD_LIBRARY_PATH=/opt/clang-23/lib:$LD_LIBRARY_PATH

# Create Python virtual environment with system packages
python3 -m venv --system-site-packages .venv

# Activate virtual environment
source .venv/bin/activate

# Install Python requirements
pip install -r libcxx/test/requirements.txt

# Run the buildbot script
libcxx/utils/ci/run-buildbot generic-cxx26

echo "Build and test completed successfully"