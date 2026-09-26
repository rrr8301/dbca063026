#!/bin/bash

# Install project dependencies
python3.12 -m pip install -e .

# Run tests with tox
tox || true

# Check formatting
pyink --check . || true