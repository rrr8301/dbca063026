#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Build the project
cd lib && ./configure --disable-openmp && cd ..
make -C lib lib
make -C bin
make -C site source
make -C test
make -C test test