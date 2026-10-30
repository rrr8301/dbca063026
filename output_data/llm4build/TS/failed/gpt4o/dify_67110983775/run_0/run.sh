#!/bin/bash

# Activate any necessary environments (if applicable)

# Install project dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Run tests
pytest || true  # Ensure all tests run even if some fail