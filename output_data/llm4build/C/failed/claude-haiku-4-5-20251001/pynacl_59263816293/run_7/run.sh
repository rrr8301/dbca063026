#!/bin/bash
set -e

# Check if repository exists (should be mounted or copied)
if [ ! -f "noxfile.py" ]; then
    echo "Error: noxfile.py not found in /workspace"
    echo "The repository must be mounted or copied to /workspace before running this script."
    exit 1
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