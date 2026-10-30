#!/bin/bash

# Build C++
cd cpp
mkdir build
cd build
cmake ..
make

# Test C++ Build Tools
./tools/generate_geocoding_data_test

# Test C++ API
./libphonenumber_test