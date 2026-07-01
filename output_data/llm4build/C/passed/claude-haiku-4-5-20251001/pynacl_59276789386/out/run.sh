#!/bin/bash

set -e

# Change to workspace directory
cd /workspace

# Display Python version for debugging
echo "Python version:"
python --version

# Display nox version
echo "Nox version:"
nox --version

# Run tests via nox
# LIBSODIUM_MAKE_ARGS enables parallel compilation for libsodium
echo "Running nox tests..."
LIBSODIUM_MAKE_ARGS="-j$(nproc)" nox -s tests

echo "All tests completed successfully!"