#!/bin/bash
set -e

# Navigate to repository root
cd /workspace

# Configure
mkdir build.mbed && cd build.mbed && cmake -G Ninja -DCMAKE_BUILD_TYPE=Debug -D NNG_ENABLE_TLS=ON -DNNG_POLLQ_POLLER=auto -DNNG_TLS_ENGINE=mbed ..

# Build
cd /workspace/build.mbed && ninja

# Test
cd /workspace/build.mbed && ctest --output-on-failure