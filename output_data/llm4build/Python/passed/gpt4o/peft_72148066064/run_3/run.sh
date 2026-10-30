#!/bin/bash

# Use the correct Python binary directly
PYTHON_BIN=python3.11

# Install project dependencies
$PYTHON_BIN -m pip install --user --upgrade pip setuptools
$PYTHON_BIN -m pip install -e .[test]

# Run tests
set +e  # Continue execution even if some tests fail
make test
rm -r "/tmp/pytest-of-$(id -u -n)" || true
set -e  # Stop execution on errors after tests

# Clean up cache
$PYTHON_BIN scripts/ci_clean_cache.py -d || true