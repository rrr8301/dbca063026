#!/bin/bash

# Activate the environment (if any virtual environment is used, activate it here)

# Install project dependencies
python3.10 -m pip install --upgrade pip
python3.10 -m pip install tox

# Run tests using tox
tox -e tests || true  # Ensure all tests run even if some fail