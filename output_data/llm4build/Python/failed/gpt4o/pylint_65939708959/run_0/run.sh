#!/bin/bash

# Activate virtual environment
source venv/bin/activate

# Install the package
pip install . --no-deps

# List installed packages
pip list | grep 'astroid\|pylint'

# Run tests
python -m pytest --durations=10 --benchmark-disable --cov --cov-report= tests/