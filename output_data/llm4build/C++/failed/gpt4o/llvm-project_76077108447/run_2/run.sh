#!/bin/bash

# Activate Python virtual environment
python3 -m venv --system-site-packages .venv
source .venv/bin/activate

# Install Python dependencies
pip install -r libcxx/test/requirements.txt

# Set environment variables for compilers
export CC=clang-12
export CXX=clang++-12

# Run the buildbot script
libcxx/utils/ci/run-buildbot generic-cxx26