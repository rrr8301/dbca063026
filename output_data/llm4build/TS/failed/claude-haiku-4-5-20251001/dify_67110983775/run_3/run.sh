#!/bin/bash

set -e

# Source uv environment to ensure it is in PATH
export PATH="/root/.local/bin:$PATH"

# Find the API directory - check multiple possible locations
API_DIR=""

if [ -d "/workspace/dify/api" ]; then
    API_DIR="/workspace/dify/api"
elif [ -d "/workspace/api" ]; then
    API_DIR="/workspace/api"
elif [ -d "/workspace" ] && [ -f "/workspace/pyproject.toml" ]; then
    API_DIR="/workspace"
else
    # Search for pyproject.toml in the workspace
    FOUND_DIR=$(find /workspace -name "pyproject.toml" -type f | head -1 | xargs dirname)
    if [ -n "$FOUND_DIR" ]; then
        API_DIR="$FOUND_DIR"
    fi
fi

# Verify API directory was found
if [ -z "$API_DIR" ] || [ ! -d "$API_DIR" ]; then
    echo "Error: Could not find API directory with pyproject.toml"
    echo "Searched locations:"
    echo "  - /workspace/dify/api"
    echo "  - /workspace/api"
    echo "  - /workspace"
    exit 1
fi

# Change to API directory
cd "$API_DIR"

echo "Working directory: $(pwd)"
echo "Directory contents:"
ls -la

# Verify uv is available
if ! command -v uv &> /dev/null; then
    echo "Error: uv command not found in PATH"
    echo "PATH: $PATH"
    exit 1
fi

echo "uv version:"
uv --version

# Install project dependencies using uv
echo "Installing Python dependencies with uv..."
uv sync

# Run pytest for API tests
echo "Running API tests for Python 3.12..."
uv run pytest -v

echo "API tests completed successfully!"