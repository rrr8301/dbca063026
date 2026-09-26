#!/bin/bash

# Activate Python environment
source /app/.venv/bin/activate

# Install project dependencies
uv pip install --system --prerelease=allow setuptools wheel build
uv pip install --system --prerelease=allow --extra-index-url https://pypi.anaconda.org/scientific-python-nightly-wheels/simple -e .[test]
uv pip install --system --prerelease=allow --extra-index-url https://pypi.anaconda.org/scientific-python-nightly-wheels/simple check-manifest pytest-cov

# Try building with Python build
python -m build
shasum -a 256 dist/*

# Check manifest
check-manifest

# Run pytest
pytest --color=yes -raXxs --maxfail=15