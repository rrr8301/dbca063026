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

# Sync dependencies (installs all dependencies including dev/test dependencies)
uv sync

# Run dify config tests
python3.12 -m pytest tests/unit_tests/config -xvs

# Run Unit Tests with coverage
python3.12 -m pytest tests/unit_tests -xvs --cov=api --cov-report=xml

echo "All tests completed successfully!"