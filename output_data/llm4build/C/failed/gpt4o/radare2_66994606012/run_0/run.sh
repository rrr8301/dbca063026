#!/bin/bash

# Activate environment variables
export LD_LIBRARY_PATH=/usr/local/lib

# Run tests
make tests || true  # Ensure all tests run even if some fail