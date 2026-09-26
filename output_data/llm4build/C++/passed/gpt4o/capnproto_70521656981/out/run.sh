#!/bin/bash

# Set environment variables
export CC=clang-18
export CXX=clang++-18

# Ensure libtoolize is run to set up libtool
libtoolize

# Run autoreconf to regenerate configuration scripts
autoreconf -i

# Run tests
./super-test.sh quick