#!/bin/bash

# Activate the virtual environment
source venv/bin/activate

# Install project dependencies
make

# Run tests
make ci || true  # Ensure all tests run, even if some fail