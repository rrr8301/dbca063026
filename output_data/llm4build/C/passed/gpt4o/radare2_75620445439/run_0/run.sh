#!/bin/bash

# Set environment variables
export CFLAGS="-O2 -Wno-unused-result"
export LD_LIBRARY_PATH=/usr/local/lib

# Build Radare2
sys/install.sh

# Run tests
make tests