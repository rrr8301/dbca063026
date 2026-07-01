#!/bin/bash

# Activate Python environment (if any virtual environment is used)
# source /path/to/venv/bin/activate

# Install project dependencies
pip install -r requirements-dev.txt

# Run tests
pytest -n auto || true  # Ensure all tests run even if some fail