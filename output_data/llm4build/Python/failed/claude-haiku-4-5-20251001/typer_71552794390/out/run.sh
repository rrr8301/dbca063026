#!/bin/bash
set -e

# Set environment variables
export UV_NO_SYNC=true
export UV_PYTHON=3.10
export UV_RESOLUTION=lowest-direct
export PATH="/root/.local/bin:$PATH"

# Create coverage directory
mkdir -p coverage

# Install dependencies using uv
uv sync --no-dev --group tests

# Run test-files script
uv run bash scripts/test-files.sh

# Run tests with coverage
COVERAGE_FILE=coverage/.coverage.Linux-py3.10 \
CONTEXT=Linux-py3.10 \
uv run bash scripts/test.sh

echo "Tests completed successfully!"