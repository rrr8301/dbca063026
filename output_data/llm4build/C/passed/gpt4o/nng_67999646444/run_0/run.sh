#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone <repository-url> /app
cd /app

# Install project dependencies
# (No additional dependencies specified beyond system packages)

# Configure the build
mkdir build.mbed
cd build.mbed
cmake -G Ninja -DCMAKE_BUILD_TYPE=Debug -DNNG_ENABLE_TLS=ON -DNNG_POLLQ_POLLER=auto -DNNG_TLS_ENGINE=mbed ..

# Build the project
ninja

# Run tests
ctest --output-on-failure