#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies
make install.dependencies

# Run tests
make test  # Ensure all tests run