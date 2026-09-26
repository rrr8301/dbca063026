#!/bin/bash

# Activate environment variables
export LD_LIBRARY_PATH=/usr/local/lib

# Ensure the build is complete before running tests
if [ ! -f "libr/config.mk" ]; then
    echo "Error: libr/config.mk not found. Ensure the build process is complete."
    exit 1
fi

# Run tests
make tests