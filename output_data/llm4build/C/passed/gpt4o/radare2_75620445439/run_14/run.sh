#!/bin/bash

# Set environment variables
export CFLAGS="-O2 -Wno-unused-result"
export LD_LIBRARY_PATH=/usr/local/lib

# Build Radare2
./sys/install.sh

# Ensure the necessary files are generated before running tests
make clean
./configure || { echo "Configuration failed"; exit 1; }
make all || { echo "Build failed"; exit 1; }

# Check if the missing file is generated
if [ ! -f libr/config.mk ]; then
    echo "Error: libr/config.mk not found. Build process might be incomplete."
    exit 1
fi

# Run tests
make tests || { echo "Tests failed"; exit 1; }