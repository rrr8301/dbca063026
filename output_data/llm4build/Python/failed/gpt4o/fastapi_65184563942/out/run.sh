#!/bin/bash

# Activate the virtual environment
source /app/venv/bin/activate

# Activate environment variables
export UV_NO_SYNC=true
export INLINE_SNAPSHOT_DEFAULT_FLAGS=review
export UV_PYTHON=3.13
export UV_RESOLUTION=highest

# Install project dependencies
uv sync --no-dev --group tests --extra all

# Create coverage directory
mkdir -p coverage

# Run tests
set +e  # Continue on errors
uv run --no-sync bash scripts/test-cov.sh
set -e  # Stop on errors

# Note: Coverage files are stored in the coverage directory