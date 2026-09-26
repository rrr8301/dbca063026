#!/bin/bash

set -e

# Build C++
cd cpp
mkdir -p build
cd build
cmake ..
make

# Run tests
# Test C++ Build Tools
./cpp/build/tools/generate_geocoding_data_test || TEST_FAILED=1

# Test C++ API
./cpp/build/libphonenumber_test || TEST_FAILED=1

# Exit with failure if any test failed
if [ "$TEST_FAILED" = "1" ]; then
    exit 1
fi

exit 0