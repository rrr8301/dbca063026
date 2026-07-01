#!/bin/bash
set -e

# Set compiler environment variables
export CC=clang-18
export CXX=clang++-18

# Run the test suite
./super-test.sh quick