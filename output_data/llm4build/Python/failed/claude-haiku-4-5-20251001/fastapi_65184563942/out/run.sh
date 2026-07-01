#!/bin/bash

set -e

# Set environment variables for testing
export UV_NO_SYNC=true
export INLINE_SNAPSHOT_DEFAULT_FLAGS=review
export UV_PYTHON=3.13
export UV_RESOLUTION=highest
export STARLETTE_SRC=starlette-pypi
export COVERAGE_FILE=coverage/.coverage.Linux-py3.13
export CONTEXT=Linux-py3.13

# Ensure uv is in PATH
export PATH="$HOME/.local/bin:$PATH"

# Create coverage directory
mkdir -p coverage

# Install dependencies
echo "Installing dependencies with uv..."
uv sync --no-dev --group tests --extra all

# Run tests
echo "Running tests..."
uv run --no-sync bash scripts/test-cov.sh

echo "Tests completed!"