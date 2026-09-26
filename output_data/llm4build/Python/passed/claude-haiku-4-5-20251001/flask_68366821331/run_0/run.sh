#!/bin/bash
set -e

# Activate Python 3.13
export PYTHON_VERSION=3.13
export PATH="/usr/bin:$PATH"

# Ensure uv is available
which uv || pip3 install uv

# Install project dependencies using uv with locked dependencies
echo "Installing project dependencies..."
uv sync --locked || uv pip install -e .

# Set tox environment variable
export TOX_ENV=py313

# Run tests using tox via uv
echo "Running tests with tox..."
uv run --locked tox run || TEST_FAILED=1

# Exit with appropriate code
if [ "$TEST_FAILED" = "1" ]; then
    echo "Tests failed, but continuing to ensure all test suites run..."
    exit 1
fi

exit 0