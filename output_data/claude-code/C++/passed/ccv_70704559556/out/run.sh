#!/usr/bin/env bash
set -e

cd /app

# Set compiler environment variables
export CC=gcc
export CXX=g++

# Run the configure and build steps from the workflow
# On Linux, we can't use MPS, so disable it
cd lib && ./configure && cd ..
make -C lib lib CC=gcc CXX=g++
make -C bin CC=gcc CXX=g++
make -C site source
make -C test CC=gcc CXX=g++
make -C test test

echo "FINAL_STATUS = SUCCESS"
