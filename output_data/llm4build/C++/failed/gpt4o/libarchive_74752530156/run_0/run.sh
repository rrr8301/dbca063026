#!/bin/bash

# Run the build steps
./build/ci/build.sh -a autogen
./build/ci/build.sh -a configure
./build/ci/build.sh -a build

# Run tests
./build/ci/build.sh -a test