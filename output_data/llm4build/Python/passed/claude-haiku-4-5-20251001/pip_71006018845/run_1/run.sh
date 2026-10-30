#!/bin/bash
set -e

# Verify Python 3.13 is available
python3 --version

# Install project dependencies via nox (nox will handle environment setup)
echo "Installing project dependencies..."
nox -s test-3.13 --install-only

# Run unit tests
echo "Running unit tests..."
nox -s test-3.13 -- \
  tests/unit \
  --verbose --numprocesses auto --showlocals

# Run integration tests
echo "Running integration tests..."
nox -s test-3.13 --no-install -- \
  tests/functional \
  --verbose --numprocesses auto --showlocals \
  --durations=15

echo "All tests completed successfully!"