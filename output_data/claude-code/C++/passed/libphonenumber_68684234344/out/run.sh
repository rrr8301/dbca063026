#!/usr/bin/env bash

set -e

cd /app/cpp
mkdir build
cd build
cmake ..
make

# Run tests
./tools/generate_geocoding_data_test
./libphonenumber_test

echo "FINAL_STATUS = SUCCESS"
