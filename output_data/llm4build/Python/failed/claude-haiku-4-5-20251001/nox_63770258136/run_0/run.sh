#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
test_exit_code=0

# Clone or use existing repo (if already copied via COPY in Dockerfile)
if [ ! -d "/workspace/.git" ]; then
    echo "Repository not found, assuming it's already in /workspace"
fi

cd /workspace

# Install the project using uv
echo "Installing Nox under test using uv..."
uv pip install --system .

# Run tests for Python 3.12
echo "Running tests for Python 3.12..."
if ! nox --session "tests-3.12" -- --full-trace; then
    test_exit_code=1
fi

# Run min-version tests for Python 3.12
echo "Running min-version tests for Python 3.12..."
if ! nox --session minimums --force-python="3.12" -- --full-trace; then
    test_exit_code=1
fi

# Exit with appropriate code
if [ $test_exit_code -ne 0 ]; then
    echo "Some tests failed!"
    exit $test_exit_code
fi

echo "All tests completed successfully!"
exit 0