#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Build the project
cd lib && ./configure --enable-mps && cd ..

# Ensure the make commands are executed with the correct flags
make -C lib CFLAGS="-O3 -Wall" LDFLAGS=""
make -C bin CFLAGS="-O3 -Wall" LDFLAGS=""
make -C site CFLAGS="-O3 -Wall" LDFLAGS=""
make -C test CFLAGS="-O3 -Wall" LDFLAGS=""
make -C test CFLAGS="-O3 -Wall" LDFLAGS="" test

# Ensure all tests are executed
echo "All tests executed successfully."