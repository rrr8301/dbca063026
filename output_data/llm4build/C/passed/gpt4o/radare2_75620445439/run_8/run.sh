#!/bin/bash

# Set environment variables
export CFLAGS="-O2 -Wno-unused-result"
export LD_LIBRARY_PATH=/usr/local/lib

# Build Radare2
./sys/install.sh

# Ensure the necessary files are generated before running tests
make all

# Run tests
make tests || { echo "Tests failed"; exit 1; }