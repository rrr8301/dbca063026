#!/bin/bash
set -e

# Print Maven version for debugging
./mvnw --version

# Build code
echo "=== Building code with make install-fast ==="
make install-fast

# Run tests
echo "=== Running tests with make run-tests ==="
make run-tests

echo "=== All tests completed ==="