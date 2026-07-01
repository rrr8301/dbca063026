#!/bin/bash

# Activate Python environment
python3.11 -m venv venv
source venv/bin/activate

# Install project dependencies
pip install --upgrade pip
pip install -r requirements.txt || true  # Assuming a requirements.txt file exists

# Run tests using tox
tox  # Ensure all tests run even if some fail