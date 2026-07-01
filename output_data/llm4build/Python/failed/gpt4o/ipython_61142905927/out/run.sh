#!/bin/bash

# Install project dependencies
pip install --upgrade pip
pip install --no-cache-dir setuptools wheel build
pip install --no-cache-dir --extra-index-url https://pypi.anaconda.org/scientific-python-nightly-wheels/simple -e .[test]
pip install --no-cache-dir --extra-index-url https://pypi.anaconda.org/scientific-python-nightly-wheels/simple check-manifest pytest-cov

# Try building with Python build
python -m build
shasum -a 256 dist/*

# Check manifest
check-manifest

# Run pytest
pytest --color=yes -raXxs --maxfail=15