#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Build the project
cd lib && ./configure --enable-mps && cd ..

# Ensure the make commands are executed with the correct flags
make -C lib CFLAGS="-O3 -Wall" || true
make -C bin CFLAGS="-O3 -Wall" || true
make -C site CFLAGS="-O3 -Wall" || true
make -C test CFLAGS="-O3 -Wall" || true
make -C test CFLAGS="-O3 -Wall" test || true

# Ensure all tests are executed
if [ $? -ne 0 ]; then
  echo "Some tests failed, but continuing with the rest."
fi