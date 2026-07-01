#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Configure build
mkdir -p build
cd build
cmake .. -DUSE_MP3=0 -DUSE_DOUBLE=0 -DBUILD_TESTS=1 -DBUILD_STATIC_LIBRARY=1 -DBUILD_RTPW_PLUGIN=0 -DBUILD_RTALSA_PLUGIN=1 -DBUILD_RTPULSE_PLUGIN=1

# Build Csound
make

# Run tests
make test
make csdtests