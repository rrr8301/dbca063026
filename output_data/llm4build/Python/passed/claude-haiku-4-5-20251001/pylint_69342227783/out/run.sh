#!/bin/bash

set -e

# Configuration
REPOSITORY="${REPOSITORY:-}"
ASTROID_SHA="${ASTROID_SHA:-}"
PYTHON_VERSION="3.10"

echo "=========================================="
echo "Pylint Test Suite"
echo "=========================================="
echo "Python Version: $PYTHON_VERSION"
echo "Repository: ${REPOSITORY:-github.repository}"
echo "Astroid SHA: ${ASTROID_SHA:-default}"
echo "=========================================="

# Create Python virtual environment
echo "Creating Python virtual environment..."
python3.10 -m venv venv
source venv/bin/activate

# Upgrade pip
echo "Upgrading pip..."
python -m pip install --upgrade pip

# Install test requirements
echo "Installing test requirements..."
if [ -f "requirements_test.txt" ]; then
    pip install --upgrade --requirement requirements_test.txt
else
    echo "WARNING: requirements_test.txt not found, installing minimal test dependencies..."
    pip install pytest pytest-cov pytest-benchmark
fi

# Install requested astroid SHA if provided
if [ -n "$ASTROID_SHA" ]; then
    echo "Installing astroid from SHA: $ASTROID_SHA"
    pip install --force-reinstall --no-deps "git+https://github.com/pylint-dev/astroid@${ASTROID_SHA}"
fi

# Install the project itself
echo "Installing pylint package..."
pip install . --no-deps

# Display installed versions
echo "=========================================="
echo "Installed versions:"
pip list | grep -E 'astroid|pylint' || true
echo "=========================================="

# Run pytest with coverage
echo "Running pytest with coverage..."
python -m pytest --durations=10 --benchmark-disable --cov --cov-report= tests/ || TEST_FAILED=1

# Run functional tests with minimal messages config (only if astroid_sha is empty)
if [ -z "$ASTROID_SHA" ]; then
    echo "=========================================="
    echo "Running functional tests with minimal messages config..."
    python -m pytest -vv --minimal-messages-config tests/test_functional.py --benchmark-disable || TEST_FAILED=1
else
    echo "Skipping functional tests (astroid_sha provided)"
fi

echo "=========================================="
if [ "${TEST_FAILED:-0}" -eq 1 ]; then
    echo "Some tests failed, but continuing..."
    exit 1
else
    echo "All tests completed successfully!"
    exit 0
fi