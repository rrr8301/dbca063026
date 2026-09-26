#!/bin/bash

set -e

# Enable error handling to continue even if some tests fail
trap 'TEST_FAILED=1' ERR

TEST_FAILED=0

echo "=========================================="
echo "Starting minizip-ng build and test"
echo "=========================================="

# Set compiler environment variables
export CC=gcc
export CXX=g++

# Generate project files with CMake
echo "Generating project files with CMake..."
cmake -S . -B . \
  -D MZ_SANITIZER=Address \
  -D MZ_BUILD_TESTS=ON \
  -D MZ_BUILD_UNIT_TESTS=ON \
  -D BUILD_SHARED_LIBS=OFF \
  -D CMAKE_BUILD_TYPE=Release

# Compile source code
echo "Compiling source code..."
cmake --build . --config Release

# Run test cases
echo "Running test cases..."
ctest --output-on-failure -C Release || TEST_FAILED=1

# Setup Python and generate coverage report
echo "Generating coverage report..."
python3 -m pip install --upgrade pip
python3 -m gcovr \
  --exclude-unreachable-branches \
  --gcov-ignore-parse-errors \
  --gcov-executable "gcov" \
  --root . \
  --xml \
  --output coverage.xml \
  --verbose || TEST_FAILED=1

echo "=========================================="
echo "Build and test completed"
echo "=========================================="

# Exit with appropriate code
if [ $TEST_FAILED -eq 1 ]; then
  echo "Some tests or operations failed!"
  exit 1
fi

exit 0