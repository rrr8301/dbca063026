#!/bin/bash

# Configure the build
mkdir build.wolf
cd build.wolf
cmake -G Ninja -DCMAKE_BUILD_TYPE=Debug -DNNG_ENABLE_TLS=ON -DNNG_POLLQ_POLLER=poll -DNNG_TLS_ENGINE=wolf ..

# Build the project
ninja

# Run tests
ctest --output-on-failure