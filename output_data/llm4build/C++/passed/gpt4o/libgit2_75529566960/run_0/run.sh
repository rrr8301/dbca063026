#!/bin/bash

# Prepare build directory
mkdir -p build

# Build the project
cd build
../source/ci/build.sh

# Test the project
../source/ci/test.sh