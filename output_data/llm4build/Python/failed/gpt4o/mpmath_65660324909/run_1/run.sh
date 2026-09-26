#!/bin/bash

# Activate Python environment
source /app/venv/bin/activate

# Install project dependencies
pip install --upgrade setuptools pip
pip install --upgrade .[develop,gmpy2,gmp,ci]

# Run tests
pytest || true  # Ensure all tests run even if some fail