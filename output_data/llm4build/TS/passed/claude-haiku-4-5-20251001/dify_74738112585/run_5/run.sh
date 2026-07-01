#!/bin/bash
set -e

# Navigate to api directory where pyproject.toml is located
cd /workspace/api

# Verify pyproject.toml exists
if [ ! -f "pyproject.toml" ]; then
    echo "Error: pyproject.toml not found in /workspace/api"
    ls -la /workspace/api
    exit 1
fi

# Sync dependencies and create virtual environment
uv sync

# Activate the virtual environment created by uv sync
source .venv/bin/activate

# Run dify config tests
python -m pytest tests/unit_tests/config -xvs

# Run Unit Tests with coverage
python -m pytest tests/unit_tests -xvs --cov=api --cov-report=xml

echo "All tests completed successfully!"