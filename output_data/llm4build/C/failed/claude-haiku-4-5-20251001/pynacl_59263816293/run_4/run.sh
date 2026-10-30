#!/bin/bash
set -e

# Clone the repository (assuming it's passed as an argument or already present)
# If repo is already mounted/copied, skip this step
if [ ! -d ".git" ]; then
    echo "Repository not found. Assuming it will be mounted or copied."
fi

# Use Python 3.12 explicitly to ensure correct pip is used
python3.12 -m pip install --upgrade pip setuptools wheel

# Install nox
python3.12 -m pip install nox

# Run nox tests
# LIBSODIUM_MAKE_ARGS is set to use all available CPU cores for parallel builds
export LIBSODIUM_MAKE_ARGS="-j$(nproc)"

echo "Running nox tests session..."
nox -s tests

echo "Test execution completed."