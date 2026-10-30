#!/bin/bash

# Run build scripts with specified actions
./build/ci/build.sh -a autogen
./build/ci/build.sh -a configure
./build/ci/build.sh -a build
./build/ci/build.sh -a test
./build/ci/build.sh -a install
./build/ci/build.sh -a artifact