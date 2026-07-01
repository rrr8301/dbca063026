#!/bin/bash

# Create and activate Python virtual environment
python -m venv /app/venv
source /app/venv/bin/activate

# Upgrade pip in the virtual environment
pip install --upgrade pip

# Run tests
pytest -n auto