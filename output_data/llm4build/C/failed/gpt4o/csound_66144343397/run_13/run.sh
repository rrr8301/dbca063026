#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Configure build
mkdir -p build
cd build
cmake .. -DUSE_MP3=0 -DUSE_DOUBLE=0 -DBUILD_TESTS=1 -DBUILD_STATIC_LIBRARY=1

# Modify rtpw.c to avoid errors related to 'requested' member
sed -i '/pwbuf->requested/d' ../InOut/rtpw.c

# Build Csound
make

# Run tests
make test
make csdtests