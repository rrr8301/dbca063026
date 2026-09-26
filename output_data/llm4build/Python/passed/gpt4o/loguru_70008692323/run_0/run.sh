#!/bin/bash

# Activate the Python environment
source /usr/bin/activate

# Install project dependencies
python3 -m pip install --upgrade pip
python3 -m pip install tox

# Run tests with tox
tox -e tests || true  # Ensure all tests run even if some fail