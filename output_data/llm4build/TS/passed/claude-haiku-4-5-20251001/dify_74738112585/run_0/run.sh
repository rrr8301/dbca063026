#!/bin/bash
set -e

# Navigate to API directory (assuming the repo structure has api/ subdirectory)
cd /workspace

# Check UV lockfile
uv sync --frozen

# Install dependencies
uv pip install -e .

# Run dify config tests
python -m pytest tests/unit_tests/config -xvs

# Run Unit Tests with coverage
python -m pytest tests/unit_tests -xvs --cov=api --cov-report=xml

echo "All tests completed successfully!"