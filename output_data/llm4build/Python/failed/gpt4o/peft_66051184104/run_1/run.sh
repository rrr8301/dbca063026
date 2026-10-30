#!/bin/bash

# Activate the virtual environment
source /app/venv/bin/activate

# Install project dependencies
pip install --upgrade pip setuptools
pip install -e .[test]

# Run tests
make test

# Ensure all test cases are executed
(rm -r "/tmp/pytest-of-$(id -u -n)" || true)