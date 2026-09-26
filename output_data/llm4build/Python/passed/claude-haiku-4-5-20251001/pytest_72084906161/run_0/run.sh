#!/bin/bash

set -e

# Set environment variables
export PYTEST_ADDOPTS="--color=yes"
export _PYTEST_TOX_POSARGS_JUNIT="--junitxml=junit.xml"

echo "=========================================="
echo "Building pytest package..."
echo "=========================================="

# Build the package (simulate the 'package' job)
python -m pip install --upgrade pip setuptools wheel build
python -m build --sdist

# Verify package was built
PACKAGE_FILE=$(find dist/*.tar.gz 2>/dev/null | head -1)
if [ -z "$PACKAGE_FILE" ]; then
    echo "ERROR: Package build failed. No .tar.gz found in dist/"
    exit 1
fi

echo "Package built: $PACKAGE_FILE"

echo "=========================================="
echo "Running tests with tox (py311-coverage)..."
echo "=========================================="

# Run tox with the built package
tox run -e py311-coverage --installpkg "$PACKAGE_FILE" || TEST_FAILED=1

echo "=========================================="
echo "Test Summary"
echo "=========================================="

# Check if coverage.xml exists
if [ -f coverage.xml ]; then
    echo "✓ Coverage report generated: coverage.xml"
else
    echo "⚠ Coverage report not found"
fi

# Check if junit.xml exists
if [ -f junit.xml ]; then
    echo "✓ JUnit report generated: junit.xml"
else
    echo "⚠ JUnit report not found"
fi

# Exit with failure if tests failed
if [ "$TEST_FAILED" = "1" ]; then
    echo "=========================================="
    echo "Tests FAILED"
    echo "=========================================="
    exit 1
fi

echo "=========================================="
echo "All tests PASSED"
echo "=========================================="
exit 0