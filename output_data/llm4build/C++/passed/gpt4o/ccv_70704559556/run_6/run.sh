#!/bin/bash

# Build the project
cd lib && ./configure --enable-mps && cd ..

# Ensure the make commands are executed with the correct flags
make -C lib CFLAGS="-O3 -Wall" lib
make -C bin CFLAGS="-O3 -Wall"
make -C site CFLAGS="-O3 -Wall" source
make -C test CFLAGS="-O3 -Wall"
make -C test CFLAGS="-O3 -Wall" test

# Ensure all tests are executed
if [ $? -ne 0 ]; then
  echo "Some tests failed, but continuing with the rest."
fi