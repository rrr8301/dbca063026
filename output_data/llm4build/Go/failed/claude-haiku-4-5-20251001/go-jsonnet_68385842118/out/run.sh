#!/bin/bash

set -e

# Print environment info
echo "=== Environment Info ==="
go version
python3 --version
echo "GOARCH: $GOARCH"
echo "CGO_ENABLED: $CGO_ENABLED"
echo "SKIP_PYTHON_BINDINGS_TESTS: $SKIP_PYTHON_BINDINGS_TESTS"
echo ""

# Install project dependencies
echo "=== Installing Project Dependencies ==="
make install.dependencies

# Ensure all test scripts are executable (both .sh and .py files)
find /workspace -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} \;

# Run tests
echo "=== Running Tests ==="
make test

echo ""
echo "=== All Tests Completed ==="