#!/bin/bash

# Activate Python virtual environment
source /opt/venv/bin/activate

# Install project dependencies
pip install --upgrade pip setuptools wheel
pip install -e .[test]
pip install check-manifest pytest-cov pytest

# Build the project
python -m build
shasum -a 256 dist/*

# Check manifest
check-manifest

# Run tests
pytest --color=yes -raXxs --cov --cov-report=xml --maxfail=15 || true

# Note: Coverage upload to Codecov is skipped