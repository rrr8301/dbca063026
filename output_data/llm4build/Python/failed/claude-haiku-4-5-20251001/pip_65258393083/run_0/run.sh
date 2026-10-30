#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Run unit tests
echo "Running unit tests..."
nox -s test-3.14 -- \
  tests/unit \
  --verbose --numprocesses auto --showlocals

# Run integration tests
echo "Running integration tests..."
nox -s test-3.14 --no-install -- \
  tests/functional \
  --verbose --numprocesses auto --showlocals \
  --durations=15

echo "All tests completed successfully!"