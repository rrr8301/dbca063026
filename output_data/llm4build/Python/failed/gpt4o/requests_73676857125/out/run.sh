#!/bin/bash

# Activate the virtual environment
source venv/bin/activate

# Install project dependencies
make

# Run tests
make ci  # Removed the `|| true` to ensure all tests run and failures are not ignored