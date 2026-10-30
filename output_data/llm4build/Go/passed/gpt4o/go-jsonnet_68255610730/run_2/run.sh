#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Activate Python virtual environment
source /app/venv/bin/activate

# Install project dependencies
make install.dependencies

# Run tests
make test  # Ensure all tests run