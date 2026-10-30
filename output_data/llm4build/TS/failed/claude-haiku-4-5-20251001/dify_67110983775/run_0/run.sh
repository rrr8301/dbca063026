#!/bin/bash

set -e

# Change to API directory
cd /workspace/dify/api

# Install project dependencies using uv
echo "Installing Python dependencies with uv..."
uv sync

# Run pytest for API tests
echo "Running API tests for Python 3.12..."
uv run pytest -v

echo "API tests completed successfully!"