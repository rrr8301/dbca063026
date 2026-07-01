#!/bin/bash

# Build C++ project
cd cpp
mkdir build
cd build
cmake ..
make

# Run tests
./tools/generate_geocoding_data_test
./libphonenumber_test