#!/bin/bash

set -e

TEST_FAILED=0

# Build C++
cd cpp
mkdir -p build
cd build
cmake ..
make

# Run tests
# Test C++ Build Tools
if [ -f ./tools/generate_geocoding_data_test ]; then
    ./tools/generate_geocoding_data_test || TEST_FAILED=1
else
    echo "Warning: generate_geocoding_data_test not found"
fi

# Test C++ API
if [ -f ./libphonenumber_test ]; then
    ./libphonenumber_test || TEST_FAILED=1
else
    echo "Warning: libphonenumber_test not found"
fi

# Exit with failure if any test failed
if [ "$TEST_FAILED" = "1" ]; then
    exit 1
fi

exit 0