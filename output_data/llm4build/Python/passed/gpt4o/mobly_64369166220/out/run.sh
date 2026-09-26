#!/bin/bash

# Activate the virtual environment
source /app/venv/bin/activate

# Install project dependencies
pip install -e .

# Run tests with tox
tox || true

# Check formatting
pyink --check . || true