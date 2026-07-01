#!/bin/bash

set -e

# Print commands for debugging
set -x

# Navigate to workspace
cd /workspace

# Ensure git is configured (needed for some operations)
git config --global --add safe.directory /workspace

# Install project dependencies using uv with locked dependencies
echo "Installing dependencies with uv..."
uv sync --locked

# Run tests using tox for Python 3.11
echo "Running tests with tox for Python 3.11..."
uv run --locked tox run -e py3.11

echo "All tests completed successfully!"