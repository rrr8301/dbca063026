#!/bin/bash

# Build C++
cd cpp
mkdir -p build  # Use -p to avoid error if build directory already exists
cd build
cmake ..
make

# Test C++ Build Tools
if [ -f "./tools/generate_geocoding_data_test" ]; then
    ./tools/generate_geocoding_data_test
else
    echo "generate_geocoding_data_test not found!"
    exit 1
fi

# Test C++ API
if [ -f "./libphonenumber_test" ]; then
    ./libphonenumber_test
else
    echo "libphonenumber_test not found!"
    exit 1
fi