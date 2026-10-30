#!/bin/bash

# Activate Python environment
source /usr/bin/python3.11

# Install project dependencies
python3.11 -m pip install --upgrade pip setuptools
python3.11 -m pip install -e .[test]

# Run tests
set +e  # Continue execution even if some tests fail
make test
rm -r "/tmp/pytest-of-$(id -u -n)" || true
set -e  # Stop execution on errors after tests

# Clean up cache
python scripts/ci_clean_cache.py -d || true