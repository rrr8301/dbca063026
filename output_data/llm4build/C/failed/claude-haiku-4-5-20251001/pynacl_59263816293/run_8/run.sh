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
# For libsodium builds: limit make check parallelism to 4 to avoid race conditions
# while keeping build parallelism higher. This is done via environment variables
# that libsodium's setup respects.
export LIBSODIUM_MAKE_ARGS="-j4"
export CFLAGS="-O2"

echo "Running nox tests session..."
nox -s tests

echo "Test execution completed."