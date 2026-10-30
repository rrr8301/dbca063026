#!/bin/bash

# Activate the virtual environment
source venv/bin/activate

# Install the project in editable mode
pip install . --no-deps

# Run tests
set +e  # Continue on errors
python -m pytest --durations=10 --benchmark-disable --cov --cov-report= tests/
python -m pytest -vv --minimal-messages-config tests/test_functional.py --benchmark-disable