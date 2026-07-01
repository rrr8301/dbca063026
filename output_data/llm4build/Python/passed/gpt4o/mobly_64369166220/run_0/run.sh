#!/bin/bash

# Activate Python environment
source /usr/local/bin/virtualenvwrapper.sh

# Install project dependencies
python3.12 -m pip install -e .

# Run tests with tox
tox || true

# Check formatting
pyink --check . || true