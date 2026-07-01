#!/bin/bash
set -e

# Enable error handling: continue on test failures but report them
TEST_FAILED=0

# Activate Python 3.12 environment
export PATH="/usr/bin:$PATH"
export PYTHONUNBUFFERED=1

# Set uv to not auto-download Python versions
export UV_PYTHON_DOWNLOADS=never

# Install project dependencies using uv with locked dependencies
echo "Installing project dependencies..."
uv sync --locked --no-default-groups --group dev || TEST_FAILED=$?

# Run tox tests for Python 3.12
echo "Running tox tests for Python 3.12..."
uv run --locked --no-default-groups --group dev tox run -e py312 || TEST_FAILED=$?

# Report test results
if [ $TEST_FAILED -ne 0 ]; then
    echo "Tests failed with exit code: $TEST_FAILED"
    exit $TEST_FAILED
else
    echo "All tests passed!"
    exit 0
fi