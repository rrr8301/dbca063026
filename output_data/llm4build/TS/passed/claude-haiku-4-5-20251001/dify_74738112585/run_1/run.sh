#!/bin/bash
set -e

# Navigate to workspace directory
cd /workspace

# Verify pyproject.toml exists
if [ ! -f "pyproject.toml" ]; then
    echo "Error: pyproject.toml not found in /workspace"
    ls -la /workspace
    exit 1
fi

# Check UV lockfile
uv sync --frozen

# Install dependencies
uv pip install -e .

# Run dify config tests
python -m pytest tests/unit_tests/config -xvs

# Run Unit Tests with coverage
python -m pytest tests/unit_tests -xvs --cov=api --cov-report=xml

echo "All tests completed successfully!"