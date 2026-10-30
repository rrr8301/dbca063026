#!/bin/bash

# Build the project
cd lib && ./configure --enable-mps && cd ..
make -C lib lib
make -C bin
make -C site source
make -C test
make -C test test

# Ensure all tests are executed
if [ $? -ne 0 ]; then
  echo "Some tests failed, but continuing with the rest."
fi