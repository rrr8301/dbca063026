#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
TEST_FAILED=0

echo "=========================================="
echo "IPython Test Suite"
echo "=========================================="

# Navigate to workspace
cd /workspace

echo ""
echo "Step 1: Installing Python dependencies with uv (prerelease versions)..."
uv pip install --system --prerelease=allow setuptools wheel build
uv pip install --system --prerelease=allow \
    --extra-index-url https://pypi.anaconda.org/scientific-python-nightly-wheels/simple \
    -e .[test]
uv pip install --system --prerelease=allow \
    --extra-index-url https://pypi.anaconda.org/scientific-python-nightly-wheels/simple \
    check-manifest pytest-cov

echo ""
echo "Step 2: Building with Python build..."
python -m build
echo "Build artifacts:"
shasum -a 256 dist/* || true

echo ""
echo "Step 3: Checking manifest..."
check-manifest || {
    echo "WARNING: Manifest check failed, but continuing with tests..."
    TEST_FAILED=1
}

echo ""
echo "Step 4: Running pytest with coverage..."
export COLUMNS=120
pytest --color=yes -raXxs --cov --cov-report=xml --maxfail=15 || {
    echo "WARNING: Some tests failed"
    TEST_FAILED=1
}

echo ""
echo "=========================================="
echo "Test suite completed"
echo "=========================================="

# Print coverage report location if it exists
if [ -f coverage.xml ]; then
    echo "Coverage report generated: coverage.xml"
fi

exit $TEST_FAILED