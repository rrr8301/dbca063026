#!/bin/bash

set -e

# Set environment variables
export COLUMNS=120

echo "=========================================="
echo "Building IPython with Python build"
echo "=========================================="
python -m build
echo "Build artifacts:"
shasum -a 256 dist/*

echo ""
echo "=========================================="
echo "Checking manifest"
echo "=========================================="
check-manifest

echo ""
echo "=========================================="
echo "Running pytest with coverage"
echo "=========================================="
pytest --color=yes -raXxs --cov --cov-report=xml --maxfail=15 || TEST_FAILED=1

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
if [ -f coverage.xml ]; then
    echo "Coverage report generated: coverage.xml"
else
    echo "Warning: coverage.xml not found"
fi

if [ "$TEST_FAILED" = "1" ]; then
    echo "Some tests failed, but test suite completed."
    exit 1
fi

echo "All tests passed!"
exit 0