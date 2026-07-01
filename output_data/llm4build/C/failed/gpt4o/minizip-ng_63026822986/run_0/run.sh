#!/bin/bash

# Activate environment variables
export CC=gcc
export CXX=g++
export CFLAGS=""
export LDFLAGS=""

# Generate project files
cmake -S . -B build -D MZ_BUILD_TESTS=ON -D MZ_BUILD_UNIT_TESTS=ON -D BUILD_SHARED_LIBS=OFF -D CMAKE_BUILD_TYPE=Release -D MZ_SANITIZER=Address

# Compile source code
cmake --build build --config Release

# Run test cases
ctest --output-on-failure -C Release --test-dir build || true

# Setup Python for coverage report
python3 -m pip install gcovr

# Generate coverage report
python3 -m gcovr --exclude-unreachable-branches --gcov-ignore-parse-errors --gcov-executable "gcov" --root . --xml --output coverage.xml --verbose || true