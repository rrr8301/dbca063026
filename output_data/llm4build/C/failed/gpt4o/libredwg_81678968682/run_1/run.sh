#!/bin/bash

# Activate Python environment
export PATH="/usr/local/bin:$PATH"

# Run cmake
cmake -DLIBREDWG_LIBONLY=On -DCMAKE_C_COMPILER_LAUNCHER=ccache .

# Run make
make -j

# Run tests
make -j test

# Handle failure
if [ $? -ne 0 ]; then
  tar cfz cmake-failure.tgz Testing/Temporary/LastTest.log src/config.h
fi