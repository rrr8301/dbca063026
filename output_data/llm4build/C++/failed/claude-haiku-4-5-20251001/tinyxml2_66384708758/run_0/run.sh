#!/bin/bash
set -e

# Configure: Static Debug build
cmake -G Ninja -S . -B build-static-dbg -DCMAKE_BUILD_TYPE=Debug "-DCMAKE_DEBUG_POSTFIX=d_static"

# Build: Static Debug
cmake --build build-static-dbg

# Test: Static Debug
cd build-static-dbg
ctest --output-on-failure
cd ..

echo "All tests passed!"