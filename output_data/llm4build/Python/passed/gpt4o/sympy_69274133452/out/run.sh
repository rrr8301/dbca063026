#!/bin/bash

# Activate Python virtual environment
source /opt/venv/bin/activate

# Install project dependencies (if not already installed)
pip install -r requirements-dev.txt

# Run tests
pytest -n auto  # Ensure all tests run