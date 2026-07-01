#!/bin/bash

set -e

# Print commands for debugging
set -x

# Navigate to workspace
cd /workspace

# Create virtual environment using uv
echo "Creating virtual environment..."
uv venv .venv

# Activate virtual environment
source .venv/bin/activate

# Install dependencies with uv (including test extras)
echo "Installing dependencies..."
uv sync --extra test

# Run unit tests with pytest
echo "Running unit tests..."
pytest tests/unittests \
  --ignore=tests/unittests/artifacts/test_artifact_service.py \
  --ignore=tests/unittests/tools/google_api_tool/test_googleapi_to_openapi_converter.py \
  -v

echo "Unit tests completed successfully!"