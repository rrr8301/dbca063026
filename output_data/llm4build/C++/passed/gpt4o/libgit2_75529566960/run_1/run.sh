#!/bin/bash

# Prepare build directory
mkdir -p build

# Build the project
cd build
/app/source/ci/build.sh

# Test the project
/app/source/ci/test.sh