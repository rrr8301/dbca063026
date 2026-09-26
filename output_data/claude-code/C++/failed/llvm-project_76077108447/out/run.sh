#!/usr/bin/env bash
set -e

# Activate the virtual environment
source .venv/bin/activate

# Set environment variables
export CC=clang-23
export CXX=clang++-23

# Run the buildbot script for generic-cxx26 configuration
libcxx/utils/ci/run-buildbot generic-cxx26

echo "FINAL_STATUS = SUCCESS"
