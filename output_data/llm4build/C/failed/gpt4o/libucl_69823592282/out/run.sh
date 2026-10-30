#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Configure the project
./autogen.sh && ./configure --enable-lua

# Build the project
make

# Run tests
make check