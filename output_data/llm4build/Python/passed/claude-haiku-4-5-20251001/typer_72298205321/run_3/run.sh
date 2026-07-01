#!/bin/bash
set -e

# Ensure uv is in PATH
export PATH="/root/.cargo/bin:$PATH"

# Verify uv is available
if ! command -v uv &> /dev/null; then
    echo "ERROR: uv command not found in PATH"
    echo "PATH: $PATH"
    exit 1
fi

# Print GitHub context (simulated)
echo "Running tests for Python 3.14 with uv"

# Install dependencies
echo "Installing dependencies..."
uv sync --no-dev --group tests

# Create coverage directory
mkdir -p coverage

# Run test-files script
echo "Running test-files script..."
uv run bash scripts/test-files.sh

# Run main tests with coverage
echo "Running tests..."
export COVERAGE_FILE=coverage/.coverage.Linux-py3.14
export CONTEXT=Linux-py3.14
uv run bash scripts/test.sh

echo "Tests completed successfully!"