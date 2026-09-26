#!/bin/bash

set -e

# Environment variables from matrix
export UV_PYTHON="3.10"
export UV_RESOLUTION="lowest-direct"
export STARLETTE_SRC="starlette-pypi"
export UV_NO_SYNC=true
export INLINE_SNAPSHOT_DEFAULT_FLAGS=review

# Create coverage directory
mkdir -p coverage

# Install dependencies using uv
echo "Installing dependencies with uv..."
uv sync --no-dev --group tests --extra all

# Install specific Pydantic version for lowest-direct resolution
echo "Installing Pydantic 2.9.0 for lowest-direct resolution..."
uv pip install "pydantic==2.9.0"

# Set coverage file path
export COVERAGE_FILE="coverage/.coverage.Linux-py3.10"
export CONTEXT="Linux-py3.10"

# Run tests
echo "Running tests..."
uv run --no-sync bash scripts/test-cov.sh

echo "Tests completed successfully!"