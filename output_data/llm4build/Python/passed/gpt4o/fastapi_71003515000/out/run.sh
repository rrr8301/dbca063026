#!/bin/bash

# Activate the environment (if any virtual environment is used)
# source /path/to/venv/bin/activate

# Install project dependencies
uv sync --no-dev --group tests --extra all

# Ensure the lowest supported Pydantic version
uv pip install "pydantic==2.9.0"

# Create coverage directory
mkdir -p coverage

# Run tests with coverage
set +e  # Continue executing even if some tests fail
uv run --no-sync bash scripts/test-cov.sh