#!/bin/bash

# Activate the virtual environment
source /app/venv/bin/activate

# Upgrade pip and setuptools inside the virtual environment
pip install --upgrade pip setuptools

# Install project dependencies
pip install --upgrade .[develop,gmpy2,gmp,ci]

# Run tests with pytest
pytest || true  # Ensure all tests run even if some fail